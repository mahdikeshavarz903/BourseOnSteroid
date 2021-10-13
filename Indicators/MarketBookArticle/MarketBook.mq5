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
   EventSetMillisecondTimer(1000);

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
   MarketBook.Refresh();
   MButton.Refresh();
   ChartRedraw();

   int total = (int)MarketBook.InfoGetInteger(MBOOK_DEPTH_TOTAL);
   double bestBidPrice = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);
   double bestAskPrice = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);

   CEventRefresh *refresh = new CEventRefresh();

   CMainTable *value;

   if(bestBidPrice != previousBid)
     {
      CMainTable *value;
      if(cMainTable.TryGetValue(bestBidPrice, value) && value != NULL && value.GetDomRowId()!=-1)
        {
         value.SetSellerVolume(0);
         cMainTable.TrySetValue(bestBidPrice, value);
        }

      previousBid = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);
     }

   if(bestAskPrice != previousAsk)
     {
      CMainTable *value;
      if(cMainTable.TryGetValue(bestAskPrice, value) && value != NULL && value.GetDomRowId()!=-1)
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

         showCellBook(value, value.GetDomRowId(), VOLUME_COLUMN, refresh, type, value.GetVolume(), MarketBook.MarketBook[j].price, 1);
         showCellBook(value, value.GetDomRowId(), BUYER_COLUMN, refresh, type, value.GetBuyerVolume(), MarketBook.MarketBook[j].price, 1);
         showCellBook(value, value.GetDomRowId(), SELLER_COLUMN, refresh, type, value.GetSellerVolume(), MarketBook.MarketBook[j].price, 1);
         showCellBook(value, value.GetDomRowId(), PRICE_PERCENTAGE_COLUMN, refresh, type, value.GetPricePercentage(), MarketBook.MarketBook[j].price, 2);
        }
     }
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
   Print("TICK");
   int total = (int)MarketBook.InfoGetInteger(MBOOK_DEPTH_TOTAL);

   MarketBook.Refresh();

   if(prev_calculated > 0)
     {
      for(int j=0; j<ArraySize(MarketBook.LastTicks); j++)
        {
         ArrayResize(ticks, ArraySize(ticks)+1);
         ticks[ArraySize(ticks)-1] = MarketBook.LastTicks[j];
        }
     }

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
   MButton.Refresh();
   ChartRedraw();

   int total = (int)MarketBook.InfoGetInteger(MBOOK_DEPTH_TOTAL);

   MarketBook.Refresh();
   CEventRefresh *refresh = new CEventRefresh();

   CMainTable *value;
   for(int j=0; j<ArraySize(ticks); j++)
     {
      if(cMainTable.TryGetValue(ticks[j].last, value) && value != NULL)
        {
         int type = (value.GetDomRowId()<18)?0:1;

         UpdateVolumesCells(j, value);
        }
     }

   ArrayResize(ticks, 0);

   delete refresh;

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
   
   if((ticks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL && (ticks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
     {
      value.SetVolume(value.GetVolume() +  ticks[tickIndex].volume);
     }
   else
     {
      if((ticks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
        {
         //Print("TICK_FLAG_BUY - volume: ", ticks[tickIndex].volume, "   - price: ", ticks[tickIndex].last);
         //Print("TICK_FLAG_BUY");

         value.SetBuyerVolume(value.GetBuyerVolume() +  ticks[tickIndex].volume);
        }
      else
         if((ticks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL)
           {
            //Print("TICK_FLAG_SELL - volume: ", ticks[tickIndex].volume, "   - price: ", ticks[tickIndex].last);
            //Print("TICK_FLAG_SELL");

            value.SetSellerVolume(value.GetSellerVolume() +  ticks[tickIndex].volume);
           }

      if((ticks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL ||
         (ticks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
        {
         //Print("OnCalculate() - N/A - volume: ", ticks[tickIndex].volume, "   - price: ", ticks[tickIndex].ask);
         value.SetVolume(value.GetVolume() +  ticks[tickIndex].volume);
        }
     }
  }
//+------------------------------------------------------------------+
void showCellBook(CMainTable &value, int domRowIndex, int cellNumber, CEventRefresh *refresh, int buyOrSell, int volume, double price, int type)
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
//+------------------------------------------------------------------+
