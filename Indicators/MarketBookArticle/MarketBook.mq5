//+------------------------------------------------------------------+
//|                                                   MarketBook.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
#include "GlobalMarketBook.mqh"
#include "GlobalMainTable.mqh"
#include "MBookCell.mqh"
#include "MBookBtn.mqh"
#include "EventNewTick.mqh"

CMBookBtn MButton;
CEventNewTick EventNewTick;
double fake_buffer[];
double mainDomPrices[10];
MqlTick  ticks[];
double previousBid=0, previousAsk=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //EventSetMillisecondTimer(500);
   EventSetTimer(1);

   MarketBook.SetMarketBookSymbol(Symbol());
//--- indicator buffers mapping
   SetIndexBuffer(0,fake_buffer,INDICATOR_CALCULATIONS);
// If the user has changed the chart on which the panel is running,
// the panel should be hidden and then re-opened.
   MButton.Hide();
   MButton.Show();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| MarketBook change event                                          |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//Print("OnBookEvent");

   if(symbol!=MarketBook.GetMarketBookSymbol())
      return;
   MarketBook.Refresh(0);

   int total = (int)MarketBook.InfoGetInteger(MBOOK_DEPTH_TOTAL);
   double bestBidPrice = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);
   double bestAskPrice = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);

   CEventRefresh *refresh = new CEventRefresh();

   CMainTable *value;

   if(bestBidPrice != previousBid)
     {
      CMainTable *value;
      if(cMainTable.TryGetValue(bestBidPrice, value) && value != NULL)
        {
         value.SetSellerVolume(0);
         cMainTable.TrySetValue(bestBidPrice, value);
        }

      previousBid = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);
     }

   if(bestAskPrice != previousAsk)
     {
      CMainTable *value;
      if(cMainTable.TryGetValue(bestAskPrice, value) && value != NULL)
        {
         value.SetBuyerVolume(0);
         cMainTable.TrySetValue(bestAskPrice, value);
        }

      previousAsk = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);
     }

   for(int j=0; j<total; j++)
     {
      bool checkExistenceOfPriceInDOM=false;
      for(int i=0; i<total; i++)
        {
         if(MarketBook.MarketBook[i].price == mainDomPrices[j])
           {
            checkExistenceOfPriceInDOM = true;
            break;
           }
        }

      if(checkExistenceOfPriceInDOM==false)
        {
         if(cMainTable.TryGetValue(mainDomPrices[j], value) && value!=NULL)
           {
            hideCellBook(value, VOLUME_COLUMN, refresh, mainDomPrices[j]);
            hideCellBook(value, PRICE_PERCENTAGE_COLUMN, refresh, mainDomPrices[j]);
            hideCellBook(value, BUYER_COLUMN, refresh, mainDomPrices[j]);
            hideCellBook(value, SELLER_COLUMN, refresh, mainDomPrices[j]);

            value.SetDomRowId(-1);
           }

         cMainTable.TrySetValue(mainDomPrices[j], value);
        }

      if(cMainTable.TryGetValue(MarketBook.MarketBook[j].price, value) &&  value !=NULL)
        {
         mainDomPrices[j] = MarketBook.MarketBook[j].price;

         int type = MarketBook.MarketBook[j].type;

         value.SetDomRowId(j+13);
         cMainTable.TrySetValue(MarketBook.MarketBook[j].price, value);

         int result[6];
         FindMinMaxInMainTable(result);

         showCellBook(value, value.GetDomRowId(), VOLUME_COLUMN, refresh, type, value.GetVolume(), MarketBook.MarketBook[j].price, 1);
         showCellBook(value, value.GetDomRowId(), BUYER_COLUMN, refresh, type, value.GetBuyerVolume(), MarketBook.MarketBook[j].price, 1);
         showCellBook(value, value.GetDomRowId(), SELLER_COLUMN, refresh, type, value.GetSellerVolume(), MarketBook.MarketBook[j].price, 1);
         showCellBook(value, value.GetDomRowId(), PRICE_PERCENTAGE_COLUMN, refresh, type, value.GetPricePercentage(), MarketBook.MarketBook[j].price, 2);
        }
     }

   MButton.Refresh();
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Chart events                                                     |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event identificator
                  const long& lparam,   // long type event parameter
                  const double& dparam, // event parameter double type
                  const string& sparam  // event parameter string type
                 )
  {
//Print("OnChartEvent");

   MButton.Event(id,lparam,dparam,sparam);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,       // size of input time series
                const int prev_calculated,  // bars handled in previous call
                const datetime& time[],     // Time
                const double& open[],       // Open
                const double& high[],       // High
                const double& low[],        // Low
                const double& close[],      // Close
                const long& tick_volume[],  // Tick Volume
                const long& volume[],       // Real Volume
                const int& spread[]         // Spread
               )
  {
//---
   /*
   Print("TICK");
   int total = (int)MarketBook.InfoGetInteger(MBOOK_DEPTH_TOTAL);

   
   MarketBook.Refresh();

   CEventRefresh *refresh = new CEventRefresh();
   CMainTable *value;

   if(prev_calculated > 0)
     {
      for(int j=0; j<ArraySize(MarketBook.LastTicks); j++)
        {
         if(cMainTable.TryGetValue(MarketBook.LastTicks[j].last, value) && value != NULL)
           {
            if((MarketBook.LastTicks[j].flags & TICK_FLAG_BID) == TICK_FLAG_BID)
              {
               value.SetSellerVolume(0);
               cMainTable.TrySetValue(MarketBook.LastTicks[j].bid, value);
              }
            if((MarketBook.LastTicks[j].flags & TICK_FLAG_ASK) == TICK_FLAG_ASK)
              {
               value.SetBuyerVolume(0);
               cMainTable.TrySetValue(MarketBook.LastTicks[j].ask, value);
              }

            int type = (value.GetDomRowId()<18)?0:1;

            UpdateVolumesCells(j, value);

            int result[6];
            FindMinMaxInMainTable(result);

            if(value.GetDomRowId()!=-1)
              {
               showCellBook(value, value.GetDomRowId(), VOLUME_COLUMN, refresh, type, value.GetVolume(), MarketBook.LastTicks[j].last, 1);
               showCellBook(value, value.GetDomRowId(), BUYER_COLUMN, refresh, type, value.GetBuyerVolume(), MarketBook.LastTicks[j].last, 1);
               showCellBook(value, value.GetDomRowId(), SELLER_COLUMN, refresh, type, value.GetSellerVolume(), MarketBook.LastTicks[j].last, 1);
               showCellBook(value, value.GetDomRowId(), PRICE_PERCENTAGE_COLUMN, refresh, type, MarketBook.LastTicks[j].volume, value.GetPricePercentage(), 2);
              }
           }
        }

      /*
      for(int j=0; j<ArraySize(MarketBook.LastTicks); j++)
        {
         ArrayResize(ticks, ArraySize(ticks)+1);
         ticks[ArraySize(ticks)-1] = MarketBook.LastTicks[j];
        }
       //
     }
   */

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Deinit                                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   MButton.Hide();
  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   MarketBook.Refresh();

   int total = (int)MarketBook.InfoGetInteger(MBOOK_DEPTH_TOTAL);

   CEventRefresh *refresh = new CEventRefresh();
   CMainTable *value;

   for(int j=0; j<ArraySize(MarketBook.LastTicks); j++)
     {
      if(cMainTable.TryGetValue(MarketBook.LastTicks[j].last, value) && value != NULL)
        {
         int type = (value.GetDomRowId()<18)?0:1;

         UpdateVolumesCells(j, value);

         int result[6];
         FindMinMaxInMainTable(result);

         showCellBook(value, value.GetDomRowId(), VOLUME_COLUMN, refresh, type, value.GetVolume(), MarketBook.LastTicks[j].last, 1);
         showCellBook(value, value.GetDomRowId(), BUYER_COLUMN, refresh, type, value.GetBuyerVolume(), MarketBook.LastTicks[j].last, 1);
         showCellBook(value, value.GetDomRowId(), SELLER_COLUMN, refresh, type, value.GetSellerVolume(), MarketBook.LastTicks[j].last, 1);
         showCellBook(value, value.GetDomRowId(), PRICE_PERCENTAGE_COLUMN, refresh, type, MarketBook.LastTicks[j].volume, value.GetPricePercentage(), 2);
        }
     }

//ArrayResize(ticks, 0);

   delete refresh;

   MButton.Refresh();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
void UpdateVolumesCells(int tickIndex, CMainTable *value)
  {
   /*
   string str = "";
   if((ticks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
      str+="TICK_FLAG_BUY  -  ";
   if((ticks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL)
      str+="TICK_FLAG_SELL  -  ";
   if((ticks[tickIndex].flags & TICK_FLAG_BID) == TICK_FLAG_BID)
      str+="TICK_FLAG_BID  -  ";
   if((ticks[tickIndex].flags & TICK_FLAG_ASK) == TICK_FLAG_ASK)
      str+="TICK_FLAG_ASK  -  ";
   if((ticks[tickIndex].flags & TICK_FLAG_LAST) == TICK_FLAG_LAST)
      str+="TICK_FLAG_LAST  -  ";
   if((ticks[tickIndex].flags & TICK_FLAG_VOLUME) == TICK_FLAG_VOLUME)
      str+="TICK_FLAG_VOLUME  -  ";
   str+=("volume: " + ticks[tickIndex].volume + "   - price: " + ticks[tickIndex].last);
   Print(str);
   */

   if((MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL && (MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
     {
      Print("OnCalculate() - N/A - volume: ", MarketBook.LastTicks[tickIndex].volume, "   - price: ", MarketBook.LastTicks[tickIndex].last);
      value.SetVolume(value.GetVolume() +  MarketBook.LastTicks[tickIndex].volume);
     }
   else
     {
      if((MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
        {
         Print("TICK_FLAG_BUY - volume: ", MarketBook.LastTicks[tickIndex].volume, "   - price: ", MarketBook.LastTicks[tickIndex].last);
         //Print("TICK_FLAG_BUY");

         value.SetBuyerVolume(value.GetBuyerVolume() +  MarketBook.LastTicks[tickIndex].volume);
        }
      else
         if((MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL)
           {
            Print("TICK_FLAG_SELL - volume: ", MarketBook.LastTicks[tickIndex].volume, "   - price: ", MarketBook.LastTicks[tickIndex].last);
            //Print("TICK_FLAG_SELL");

            value.SetSellerVolume(value.GetSellerVolume() +  MarketBook.LastTicks[tickIndex].volume);
           }

      if((MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL ||
         (MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
        {
         value.SetVolume(value.GetVolume() +  MarketBook.LastTicks[tickIndex].volume);
        }
     }
  }
//+------------------------------------------------------------------+
void showCellBook(CMainTable &value, int domRowIndex, int cellNumber, CEventRefresh *refresh, int buyOrSell, int volume, double price, int type)
  {
   if(domRowIndex!=-1)
     {
      CMainTable *tempValue=GetPointer(value);

      int result[6];
      FindMinMaxInMainTable(result);

      int k;
      if(cellNumber==VOLUME_COLUMN)
         k=0;
      else
         if(cellNumber==BID_COLUMN || cellNumber==ASK_COLUMN)
            k=2;
         else
            if(cellNumber==BUYER_COLUMN || cellNumber==SELLER_COLUMN)
               k=4;

      CBookCell *bookCell = new CBookCell();
      value.GetBookCell(bookCell, cellNumber, value.GetPricePercentage());

      //Print("DOM ROW index: ", domRowIndex);
      if(type==1)
         bookCell.SetVariables(type, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], volume, buyOrSell, result[k], result[k+1]);
      else
         if(type==2)
            bookCell.SetVariables(type, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], value.GetPricePercentage(), buyOrSell);
         else
            bookCell.SetVariables(type, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], price, buyOrSell);

      value.SetBookCell(bookCell, cellNumber);
      cMainTable.TrySetValue(price, tempValue);

      bookCell.Hide();
      bookCell.Show();
      bookCell.OnRefresh2(refresh);
     }
  }
//+------------------------------------------------------------------+
void hideCellBook(CMainTable &value, int cellNumber, CEventRefresh *refresh, double price)
  {
   CMainTable *tempValue=GetPointer(value);

   CBookCell *bookCell = new CBookCell();
   value.GetBookCell(bookCell, cellNumber, value.GetPricePercentage());
   value.SetBookCell(bookCell, cellNumber);
   cMainTable.TrySetValue(price, tempValue);

   bookCell.Hide();
   bookCell.OnRefresh2(refresh);
  }
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindMinMaxInMainTable(int &result[])
  {
   double keys[];
   CMainTable *values[];
   cMainTable.CopyTo(keys, values, 0);
   int minPendingVolume=0, maxPendingVolume=0, minVolume=0, maxVolume=0, minBuyerSellerVolume=0, maxBuyerSellerVolume=0;

   long max_ask = MarketBook.InfoGetInteger(MBOOK_MAX_ASK_VOLUME);
   long max_bid = MarketBook.InfoGetInteger(MBOOK_MAX_BID_VOLUME);
   long max_volume=max_ask>max_bid ? max_ask : max_bid;
   long min_volume = (ArraySize(MarketBook.MarketBook)!=0)?MarketBook.MarketBook[0].volume:0;

   for(int i=1; i<ArraySize(MarketBook.MarketBook); i++)
     {
      if(min_volume > MarketBook.MarketBook[i].volume)
        {
         min_volume = MarketBook.MarketBook[i].volume;
        }
     }

   if(values[0]!=NULL)
     {
      minPendingVolume = values[0].GetBidVolume();
      maxPendingVolume = values[0].GetAskVolume();

      minVolume = values[0].GetVolume();
      maxVolume = values[0].GetVolume();

      minBuyerSellerVolume = values[0].GetBuyerVolume();
      maxBuyerSellerVolume = values[0].GetSellerVolume();

      for(int i=0, j=1; i<ArraySize(keys); i++, j++)
        {
         if(values[i]!=NULL)
           {
            if(minPendingVolume > values[i].GetAskVolume())
               minPendingVolume = values[i].GetAskVolume();
            else
               if(maxPendingVolume < values[i].GetAskVolume())
                  maxPendingVolume = values[i].GetAskVolume();

            if(minPendingVolume > values[i].GetBidVolume())
               minPendingVolume = values[i].GetBidVolume();
            else
               if(maxPendingVolume < values[i].GetBidVolume())
                  maxPendingVolume = values[i].GetBidVolume();
            //************************************************************
            if(minBuyerSellerVolume > values[i].GetSellerVolume())
               minBuyerSellerVolume = values[i].GetSellerVolume();
            else
               if(maxBuyerSellerVolume < values[i].GetSellerVolume())
                  maxBuyerSellerVolume = values[i].GetSellerVolume();

            if(minBuyerSellerVolume > values[i].GetBuyerVolume())
               minBuyerSellerVolume = values[i].GetBuyerVolume();
            else
               if(maxBuyerSellerVolume < values[i].GetBuyerVolume())
                  maxBuyerSellerVolume = values[i].GetBuyerVolume();
           }
         if(j<ArraySize(keys) && values[j] != NULL)
           {
            if(minVolume > values[j].GetVolume())
               minVolume = values[j].GetVolume();
            else
               if(maxVolume < values[j].GetVolume())
                  maxVolume = values[j].GetVolume();

           }
        }
     }

   if(maxPendingVolume < max_volume)
      maxPendingVolume = max_volume;
   if(minPendingVolume > min_volume)
      minPendingVolume = min_volume;

   result[0] = minVolume;
   result[1] = maxVolume;
   result[2] = minPendingVolume;
   result[3] = maxPendingVolume;
   result[4] = minBuyerSellerVolume;
   result[5] = maxBuyerSellerVolume;

  }
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindMinMaxInMainTable(int &result[])
  {
   double keys[];
   CMainTable *values[];
   cMainTable.CopyTo(keys, values, 0);
   int minPendingVolume=0, maxPendingVolume=0, minVolume=0, maxVolume=0, minBuyerSellerVolume=0, maxBuyerSellerVolume=0;

   long max_ask = MarketBook.InfoGetInteger(MBOOK_MAX_ASK_VOLUME);
   long max_bid = MarketBook.InfoGetInteger(MBOOK_MAX_BID_VOLUME);
   long max_volume=max_ask>max_bid ? max_ask : max_bid;
   long min_volume = (ArraySize(MarketBook.MarketBook)!=0)?MarketBook.MarketBook[0].volume:0;

   for(int i=1; i<ArraySize(MarketBook.MarketBook); i++)
     {
      if(min_volume > MarketBook.MarketBook[i].volume)
        {
         min_volume = MarketBook.MarketBook[i].volume;
        }
     }

   if(values[0]!=NULL)
     {
      /*
      values[152].SetAskVolume(MarketBook.MarketBook[0].volume);
      values[153].SetAskVolume(MarketBook.MarketBook[1].volume);
      values[154].SetAskVolume(MarketBook.MarketBook[2].volume);
      values[156].SetAskVolume(MarketBook.MarketBook[3].volume);
      values[157].SetAskVolume(MarketBook.MarketBook[4].volume);
      */

      minMaxStruct.pendingVolume.minB=0;
      minMaxStruct.pendingVolume.minH=0;
      minMaxStruct.pendingVolume.minK=0;
      minMaxStruct.pendingVolume.minM=0;
      minMaxStruct.pendingVolume.maxB=0;
      minMaxStruct.pendingVolume.maxK=0;
      minMaxStruct.pendingVolume.maxM=0;
      minMaxStruct.pendingVolume.maxH=0;

      minMaxStruct.buyerSellerVolume.minB=0;
      minMaxStruct.buyerSellerVolume.minH=0;
      minMaxStruct.buyerSellerVolume.minK=0;
      minMaxStruct.buyerSellerVolume.minM=0;
      minMaxStruct.buyerSellerVolume.maxB=0;
      minMaxStruct.buyerSellerVolume.maxK=0;
      minMaxStruct.buyerSellerVolume.maxM=0;
      minMaxStruct.buyerSellerVolume.maxH=0;

      minMaxStruct.totalVolume.minB=0;
      minMaxStruct.totalVolume.minH=0;
      minMaxStruct.totalVolume.minK=0;
      minMaxStruct.totalVolume.minM=0;
      minMaxStruct.totalVolume.maxB=0;
      minMaxStruct.totalVolume.maxK=0;
      minMaxStruct.totalVolume.maxM=0;
      minMaxStruct.totalVolume.maxH=0;

      for(int i=0, j=1; i<ArraySize(keys); i++, j++)
        {
         if(values[i]!=NULL)
           {
            int legnth = StringLen(values[i].GetBidVolume());
            string result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minK)
                  minMaxStruct.pendingVolume.minK = values[i].GetBidVolume();
               else
                  if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxK)
                     minMaxStruct.pendingVolume.maxK = values[i].GetBidVolume();
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minM)
                     minMaxStruct.pendingVolume.minM = values[i].GetBidVolume();
                  else
                     if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxM)
                        minMaxStruct.pendingVolume.maxM = values[i].GetBidVolume();
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minB)
                        minMaxStruct.pendingVolume.minB = values[i].GetBidVolume();
                     else
                        if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxB)
                           minMaxStruct.pendingVolume.maxB = values[i].GetBidVolume();
                    }
                  else
                    {
                     if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minH)
                        minMaxStruct.pendingVolume.minH = values[i].GetBidVolume();
                     else
                        if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxH)
                           minMaxStruct.pendingVolume.maxH = values[i].GetBidVolume();
                    }

            legnth = StringLen(values[i].GetAskVolume());
            result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(values[i].GetAskVolume() < minMaxStruct.pendingVolume.minK)
                  minMaxStruct.pendingVolume.minK = values[i].GetAskVolume();
               else
                  if(values[i].GetAskVolume() > minMaxStruct.pendingVolume.maxK)
                     minMaxStruct.pendingVolume.maxK = values[i].GetAskVolume();
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(values[i].GetAskVolume() < minMaxStruct.pendingVolume.minM)
                     minMaxStruct.pendingVolume.minM = values[i].GetAskVolume();
                  else
                     if(values[i].GetAskVolume() > minMaxStruct.pendingVolume.maxM)
                        minMaxStruct.pendingVolume.maxM = values[i].GetAskVolume();
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(values[i].GetAskVolume() < minMaxStruct.pendingVolume.minB)
                        minMaxStruct.pendingVolume.minB = values[i].GetAskVolume();
                     else
                        if(values[i].GetAskVolume() > minMaxStruct.pendingVolume.maxB)
                           minMaxStruct.pendingVolume.maxB = values[i].GetAskVolume();
                    }
                  else
                    {
                     if(values[i].GetAskVolume() < minMaxStruct.pendingVolume.minH)
                        minMaxStruct.pendingVolume.minH = values[i].GetAskVolume();
                     else
                        if(values[i].GetAskVolume() > minMaxStruct.pendingVolume.maxH)
                           minMaxStruct.pendingVolume.maxH = values[i].GetAskVolume();
                    }

            legnth = StringLen(values[i].GetBuyerVolume());
            result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(values[i].GetBuyerVolume() < minMaxStruct.buyerSellerVolume.minK)
                  minMaxStruct.buyerSellerVolume.minK = values[i].GetBuyerVolume();
               else
                  if(values[i].GetBuyerVolume() > minMaxStruct.buyerSellerVolume.maxK)
                     minMaxStruct.buyerSellerVolume.maxK = values[i].GetBuyerVolume();
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(values[i].GetBuyerVolume() < minMaxStruct.buyerSellerVolume.minM)
                     minMaxStruct.buyerSellerVolume.minM = values[i].GetBuyerVolume();
                  else
                     if(values[i].GetBuyerVolume() > minMaxStruct.buyerSellerVolume.maxM)
                        minMaxStruct.buyerSellerVolume.maxM = values[i].GetBuyerVolume();
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(values[i].GetBuyerVolume() < minMaxStruct.buyerSellerVolume.minB)
                        minMaxStruct.buyerSellerVolume.minB = values[i].GetBuyerVolume();
                     else
                        if(values[i].GetBuyerVolume() > minMaxStruct.buyerSellerVolume.maxB)
                           minMaxStruct.buyerSellerVolume.maxB = values[i].GetBuyerVolume();
                    }
                  else
                    {
                     if(values[i].GetBuyerVolume() < minMaxStruct.buyerSellerVolume.minH)
                        minMaxStruct.buyerSellerVolume.minH = values[i].GetBuyerVolume();
                     else
                        if(values[i].GetBuyerVolume() > minMaxStruct.buyerSellerVolume.maxH)
                           minMaxStruct.buyerSellerVolume.maxH = values[i].GetBuyerVolume();
                    }

            legnth = StringLen(values[i].GetSellerVolume());
            result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(values[i].GetSellerVolume() < minMaxStruct.buyerSellerVolume.minK)
                  minMaxStruct.buyerSellerVolume.minK = values[i].GetSellerVolume();
               else
                  if(values[i].GetSellerVolume() > minMaxStruct.buyerSellerVolume.maxK)
                     minMaxStruct.buyerSellerVolume.maxK = values[i].GetSellerVolume();
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(values[i].GetSellerVolume() < minMaxStruct.buyerSellerVolume.minM)
                     minMaxStruct.buyerSellerVolume.minM = values[i].GetSellerVolume();
                  else
                     if(values[i].GetSellerVolume() > minMaxStruct.buyerSellerVolume.maxM)
                        minMaxStruct.buyerSellerVolume.maxM = values[i].GetSellerVolume();
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(values[i].GetSellerVolume() < minMaxStruct.buyerSellerVolume.minB)
                        minMaxStruct.buyerSellerVolume.minB = values[i].GetSellerVolume();
                     else
                        if(values[i].GetSellerVolume() > minMaxStruct.buyerSellerVolume.maxB)
                           minMaxStruct.buyerSellerVolume.maxB = values[i].GetSellerVolume();
                    }
                  else
                    {
                     if(values[i].GetSellerVolume() < minMaxStruct.buyerSellerVolume.minH)
                        minMaxStruct.buyerSellerVolume.minH = values[i].GetSellerVolume();
                     else
                        if(values[i].GetSellerVolume() > minMaxStruct.buyerSellerVolume.maxH)
                           minMaxStruct.buyerSellerVolume.maxH = values[i].GetSellerVolume();
                    }


            legnth = StringLen(max_volume);
            result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(max_volume > minMaxStruct.pendingVolume.maxK)
                  minMaxStruct.pendingVolume.maxK = max_volume;
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(max_volume > minMaxStruct.pendingVolume.maxM)
                     minMaxStruct.pendingVolume.maxM = max_volume;
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(max_volume > minMaxStruct.pendingVolume.maxB)
                        minMaxStruct.pendingVolume.maxB = max_volume;
                    }
                  else
                    {
                     if(max_volume > minMaxStruct.pendingVolume.maxH)
                        minMaxStruct.pendingVolume.maxH = max_volume;
                    }
            
            legnth = StringLen(min_volume);
            result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(min_volume < minMaxStruct.pendingVolume.minK)
                     minMaxStruct.pendingVolume.minK = min_volume;
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(min_volume < minMaxStruct.pendingVolume.minM)
                        minMaxStruct.pendingVolume.minM = min_volume;
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(min_volume < minMaxStruct.pendingVolume.minB)
                           minMaxStruct.pendingVolume.minB = min_volume;
                    }
                  else
                    {
                     if(min_volume < minMaxStruct.pendingVolume.minH)
                           minMaxStruct.pendingVolume.minH = min_volume;
                    }
                    
            if(j<ArraySize(keys) && values[j] != NULL)
              {
               legnth = StringLen(values[j].GetVolume());
               result = TempFunction(legnth);

               if(StringCompare(result, "K")==0)
                 {
                  if(values[j].GetVolume() < minMaxStruct.totalVolume.minK)
                     minMaxStruct.totalVolume.minK = values[j].GetVolume();
                  else
                     if(values[j].GetVolume() > minMaxStruct.totalVolume.maxK)
                        minMaxStruct.totalVolume.maxK = values[j].GetVolume();
                 }
               else
                  if(StringCompare(result, "M")==0)
                    {
                     if(values[j].GetVolume() < minMaxStruct.totalVolume.minM)
                        minMaxStruct.totalVolume.minM = values[j].GetVolume();
                     else
                        if(values[j].GetVolume() > minMaxStruct.totalVolume.maxM)
                           minMaxStruct.totalVolume.maxM = values[j].GetVolume();
                    }
                  else
                     if(StringCompare(result, "B")==0)
                       {
                        if(values[j].GetVolume() < minMaxStruct.totalVolume.minB)
                           minMaxStruct.totalVolume.minB = values[j].GetVolume();
                        else
                           if(values[j].GetVolume() > minMaxStruct.totalVolume.maxB)
                              minMaxStruct.totalVolume.maxB = values[j].GetVolume();
                       }
                     else
                       {
                        if(values[j].GetVolume() < minMaxStruct.totalVolume.minH)
                           minMaxStruct.totalVolume.minH = values[j].GetVolume();
                        else
                           if(values[j].GetVolume() > minMaxStruct.totalVolume.maxH)
                              minMaxStruct.totalVolume.maxH = values[j].GetVolume();
                       }
              }

           }
        }
     }

  }
//+------------------------------------------------------------------+
string TempFunction(int volumeLegnth)
  {
   string result;

   if(volumeLegnth<=6 && volumeLegnth>3)
     {
      result = "K";
     }
   else
      if(volumeLegnth<=9 && volumeLegnth>6)
        {
         result = "M";
        }
      else
         if(volumeLegnth>9 && volumeLegnth<=12)
           {
            result = "B";
           }
         else
            if(volumeLegnth <=3)
              {
               result = "H";
              }

   return result;
  }
//+------------------------------------------------------------------+
