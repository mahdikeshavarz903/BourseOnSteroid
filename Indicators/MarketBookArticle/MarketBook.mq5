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
#include "MBookGraphTable.mqh"
#include <Charts\Chart.mqh>

CMBookBtn MButton;
CEventNewTick EventNewTick;
double fake_buffer[];
double previousBid=0, previousAsk=0;
CChart            m_chart;
   
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   /* Set timer for OnTimer() function */
   EventSetTimer(1);
   
   //--- Get the ID of the current chart
   m_chart.Attach();
//--- Enable tracking of mouse events
   m_chart.EventMouseMove(true);
   
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
   /* Check update is relative to our target symbol or not */
   if(symbol!=MarketBook.GetMarketBookSymbol())
      return;

   MarketBook.Refresh(0);

   /* Total number of rows in the main DOM */
   int total = (int)MarketBook.InfoGetInteger(MBOOK_DEPTH_TOTAL);
   double bestBidPrice = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);   /* Get best bid price */
   double bestAskPrice = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);   /* Get best ask price */

   CEventRefresh *refresh = new CEventRefresh();   /* Create refresh event */
   CMainTable *value;                              /* Create an object from CMainTable for retrieving DOM row information */

   /* This condition checks whether ‌Bid has changed */
   if(bestBidPrice != previousBid)
     {
      if(cMainTable.TryGetValue(bestBidPrice, value) && value != NULL)
        {
         /* If bid price value changed, we set seller volume to zero */
         value.SetSellerVolume(0);
         cMainTable.TrySetValue(bestBidPrice, value);
        }

      /* Update previous value after its price changes */
      previousBid = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);
     }

   /* This condition checks whether Ask has changed */
   if(bestAskPrice != previousAsk)
     {
      if(cMainTable.TryGetValue(bestAskPrice, value) && value != NULL)
        {
         /* If bid price value changed, we set buyer volume to zero */
         value.SetBuyerVolume(0);
         cMainTable.TrySetValue(bestAskPrice, value);
        }

      /* Update previous value after its price changes */
      previousAsk = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);
     }

   /* Update depth of market after a book event occurs */
   for(int j=0; j<total; j++)
     {
      /* Find target price in CMainTable list */
      if(cMainTable.TryGetValue(MarketBook.MarketBook[j].price, value) &&  value !=NULL)
        {
         if(MarketBook.MarketBook[j].type == BOOK_TYPE_SELL)
            value.SetAskVolume(MarketBook.MarketBook[j].volume);
         else
            value.SetBidVolume(MarketBook.MarketBook[j].volume);
            
         //CMainTable *previousValue;
         //double tempPrice;
         //mapDomRowIdToPrice.TryGetValue(j+13, tempPrice);

         /* Hide cells that are not in the DOM */
         /*
         if(tempPrice != MarketBook.MarketBook[j].price && cMainTable.TryGetValue(tempPrice, previousValue))
           {
            for(int z=0; z<TOTAL_COLUMN; z++)
              {
               HideCellBook(previousValue, z, refresh, tempPrice);
              }

            /* Set DOM row id to -1 after hiding cells //
            previousValue.SetDomRowId(-1);

            cMainTable.TrySetValue(tempPrice, previousValue);
           }
           */

         /* Find the type of current dom row */
         //int type = (MarketBook.MarketBook[j].type==BOOK_TYPE_SELL)?0:1;

         //value.SetDomRowId(j+13);
         //mapDomRowIdToPrice.TrySetValue(j+13, MarketBook.MarketBook[j].price);
         cMainTable.TrySetValue(MarketBook.MarketBook[j].price, value);

         /* Find min and max for hundred and below hundred, thousands, Millions, Billions */
         //FindMinMaxInMainTable();

         /* Show new cells(VOLUME_COLUMN, BUYER_COLUMN, SELLER_COLUMN, PRICE_PERCENTAGE_COLUMN)  */
         /*
         ShowCellBook(value, value.GetDomRowId(), VOLUME_COLUMN, refresh, type, value.GetVolume(), MarketBook.MarketBook[j].price, 1);
         ShowCellBook(value, value.GetDomRowId(), BUYER_COLUMN, refresh, type, value.GetBuyerVolume(), MarketBook.MarketBook[j].price, 1);
         ShowCellBook(value, value.GetDomRowId(), SELLER_COLUMN, refresh, type, value.GetSellerVolume(), MarketBook.MarketBook[j].price, 1);
         ShowCellBook(value, value.GetDomRowId(), PRICE_PERCENTAGE_COLUMN, refresh, type, MarketBook.MarketBook[j].volume, MarketBook.MarketBook[j].price, 2);
         */
        }
     }
     
   CBookGraphTable::ShiftCells(startIndex, endIndex);
   
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
   /* Refresh depth of market */
   MarketBook.Refresh();

   /* Total number of rows in the main DOM */
   int total = (int)MarketBook.InfoGetInteger(MBOOK_DEPTH_TOTAL);

   CEventRefresh *refresh = new CEventRefresh();
   CMainTable *value;

   /* Process the incoming ticks */
   for(int j=0; j<ArraySize(MarketBook.LastTicks); j++)
     {
      if(cMainTable.TryGetValue(MarketBook.LastTicks[j].last, value) && value != NULL)
        {
         /*
         /* Hide cells that are not in the DOM //
         CMainTable *previousValue;
         if(cMainTable.TryGetValue(MarketBook.LastTicks[j].last, previousValue))
           {
            for(int z=0; z<TOTAL_COLUMN; z++)
              {
               HideCellBook(previousValue, z, refresh, MarketBook.LastTicks[j].last);
              }
            previousValue.SetDomRowId(-1);

            cMainTable.TrySetValue(MarketBook.LastTicks[j].last, previousValue);
           }

         /* Change the DomRowId when the last price is equal to the asking price in the DOM //
         if(MarketBook.MarketBook[4].price==MarketBook.LastTicks[j].last)
           {
            value.SetDomRowId(17);
           }
         else
            if(MarketBook.MarketBook[5].price==MarketBook.LastTicks[j].last) /* Change the DomRowId when the last price is equal to the biding price in the DOM //
              {
               value.SetDomRowId(18);
              }
         
         */
         
         //double askPrice = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE); 
         //int type = (MarketBook.LastTicks[j].price>=askPrice)?0:1;

         /* Update buyer/seller volume */
         UpdateVolumesCells(j, value);
         cMainTable.TrySetValue(MarketBook.LastTicks[j].last, value);

         /* Find min and max for hundred and below hundred, thousands, Millions, Billions */
         //FindMinMaxInMainTable();

         /* Show new cells(VOLUME_COLUMN, BUYER_COLUMN, SELLER_COLUMN, PRICE_PERCENTAGE_COLUMN)  */
         /*
         ShowCellBook(value, value.GetDomRowId(), VOLUME_COLUMN, refresh, type, value.GetVolume(), MarketBook.LastTicks[j].last, 1);
         ShowCellBook(value, value.GetDomRowId(), BUYER_COLUMN, refresh, type, value.GetBuyerVolume(), MarketBook.LastTicks[j].last, 1);
         ShowCellBook(value, value.GetDomRowId(), SELLER_COLUMN, refresh, type, value.GetSellerVolume(), MarketBook.LastTicks[j].last, 1);
         ShowCellBook(value, value.GetDomRowId(), PRICE_PERCENTAGE_COLUMN, refresh, type, MarketBook.LastTicks[j].volume, MarketBook.LastTicks[j].last, 2);
         */
        }
     }

   /* Remove EventRefresh object */
   delete refresh;

   CBookGraphTable::ShiftCells(startIndex, endIndex);
   
   MButton.Refresh();
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Function that updates buyer/seller volumes based on new tick     |
//+------------------------------------------------------------------+
void UpdateVolumesCells(int tickIndex, CMainTable *value)
  {
   /*
      If the bits for BUY_FLAG and SELL_FLAG are the same and equal 1, it means that an N / A tick occurs.
      This tick just add volume to VOLUME_COLUMN
   */
   if((MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL && (MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
     {
      //Print("TICK_FLAG_N/A - volume: ", MarketBook.LastTicks[tickIndex].volume, "   - price: ", MarketBook.LastTicks[tickIndex].last);
      value.SetVolume(value.GetVolume() +  MarketBook.LastTicks[tickIndex].volume);
     }
   else
     {
      /* If the bit for BUY_FLAG equal 1, it means that a BUY tick occurs */
      if((MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
        {
         //Print("TICK_FLAG_BUY - volume: ", MarketBook.LastTicks[tickIndex].volume, "   - price: ", MarketBook.LastTicks[tickIndex].last);
         value.SetBuyerVolume(value.GetBuyerVolume() +  MarketBook.LastTicks[tickIndex].volume);
        }
      else
         if((MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL) /* If the bit for SELL_FLAG equal 1, it means that a SELL tick occurs */
           {
            //Print("TICK_FLAG_SELL - volume: ", MarketBook.LastTicks[tickIndex].volume, "   - price: ", MarketBook.LastTicks[tickIndex].last);
            value.SetSellerVolume(value.GetSellerVolume() +  MarketBook.LastTicks[tickIndex].volume);
           }

      /* If buy or sell flag occurs we should add it to VOLUME_COLUMN */
      if((MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL ||
         (MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
        {
         value.SetVolume(value.GetVolume() +  MarketBook.LastTicks[tickIndex].volume);
        }
     }
  }
//+------------------------------------------------------------------+
//| Function that shows one of the custom DOM cells                  |
//+------------------------------------------------------------------+
void ShowCellBook(CMainTable &value, int domRowIndex, int cellNumber, CEventRefresh *refresh, int buyOrSell, int volume, double price, int type)
  {
   if(domRowIndex!=-1)
     {
      CMainTable *tempValue=GetPointer(value);

      /* Find min and max for hundred and below hundred, thousands, Millions, Billions */
      FindMinMaxInMainTable();

      CBookCell *bookCell = new CBookCell();
      value.GetBookCell(bookCell, cellNumber, value.GetPricePercentage());

      /* type==1 => It related to volume_column(VOLUME, BUYER, SELLER) */
      if(type==1)
         bookCell.SetVariables(type, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], volume, buyOrSell);
      else
         if(type==2) /* type==2 => It related to type */
            bookCell.SetVariables(type, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], value.GetPricePercentage(), buyOrSell);
         else /* It related to price */
            bookCell.SetVariables(type, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], price, buyOrSell);

      value.SetBookCell(bookCell, cellNumber);

      /* Save changes */
      cMainTable.TrySetValue(price, tempValue);

      bookCell.Hide();  /* Hide cell */
      bookCell.Show();  /* Show cell */
      bookCell.OnRefresh2(refresh);
     }
  }
//+------------------------------------------------------------------+
//| Function that hide one of the custom DOM cells                   |
//+------------------------------------------------------------------+
void HideCellBook(CMainTable &value, int cellNumber, CEventRefresh *refresh, double price)
  {
   CMainTable *tempValue=GetPointer(value);

   CBookCell *bookCell = new CBookCell();

   /* Find and save the cell changes */
   value.GetBookCell(bookCell, cellNumber, value.GetPricePercentage());
   value.SetBookCell(bookCell, cellNumber);
   cMainTable.TrySetValue(price, tempValue);

   bookCell.Hide();
   bookCell.OnRefresh2(refresh);
  }
//+-------------------------------------------------------------------------------+
//| Find min and max for hundred and below hundred, thousands, Millions, Billions |
//+-------------------------------------------------------------------------------+
void FindMinMaxInMainTable()
  {
   /* Convert cMainTable from HashTable to ArrayList */
   double keys[];
   CMainTable *values[];
   cMainTable.CopyTo(keys, values, 0);

   long max_ask = MarketBook.InfoGetInteger(MBOOK_MAX_ASK_VOLUME);   // Find maximum volume from asks
   long max_bid = MarketBook.InfoGetInteger(MBOOK_MAX_BID_VOLUME);   // Find maximum volume from bids
   long max_volume = max_ask>max_bid ? max_ask : max_bid;            // Find maximum volume between bids and asks
   long min_volume = (ArraySize(MarketBook.MarketBook)!=0)?MarketBook.MarketBook[0].volume:0;

   /* Find min_volume in DOM */
   for(int i=1; i<ArraySize(MarketBook.MarketBook); i++)
     {
      if(min_volume > MarketBook.MarketBook[i].volume)
        {
         min_volume = MarketBook.MarketBook[i].volume;
        }
     }

   if(values[0]!=NULL)
     {
      /* ‌Before finding new min and max we should reset previous min and maxes */
      ResetMinMaxStruct();

      /*
         This loop try to find min and max volumes in the CMainTable between bids and asks, buyers and sellers, total volumes
         To achieve this goal, we select the volume of each column and compare it with the corresponding minimum or maximum in minMaxStruct
      */
      for(int i=0, j=1; i<ArraySize(keys); i++, j++)
        {
         if(values[i]!=NULL)
           {
            /* Get length of bid volume */
            int legnth = StringLen(values[i].GetBidVolume());
            string result = TempFunction(legnth);

            /* Condition is true when there is a K letter in string volume */
            if(StringCompare(result, "K")==0)
              {
               /* If the bid volume is less than minK, we have to update minK in minMaxStruct, otherwise,
               we have to compare the bid volume with maxK, and if it is more than maxK we have to update maxK. */
               if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minK)
                  minMaxStruct.pendingVolume.minK = values[i].GetBidVolume();
               else
                  if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxK)
                     minMaxStruct.pendingVolume.maxK = values[i].GetBidVolume();
              }
            else
               if(StringCompare(result, "M")==0)   /* Condition is true when there is a M letter in string volume */
                 {
                  /* If the bid volume is less than minM, we have to update minM in minMaxStruct, otherwise,
                     we have to compare the bid volume with maxM, and if it is more than maxM we have to update maxM. */
                  if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minM)
                     minMaxStruct.pendingVolume.minM = values[i].GetBidVolume();
                  else
                     if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxM)
                        minMaxStruct.pendingVolume.maxM = values[i].GetBidVolume();
                 }
               else
                  if(StringCompare(result, "B")==0) /* Condition is true when there is a B letter in string volume */
                    {
                     /* If the bid volume is less than minB, we have to update minB in minMaxStruct, otherwise,
                      we have to compare the bid volume with maxB, and if it is more than maxB we have to update maxB. */
                     if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minB)
                        minMaxStruct.pendingVolume.minB = values[i].GetBidVolume();
                     else
                        if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxB)
                           minMaxStruct.pendingVolume.maxB = values[i].GetBidVolume();
                    }
                  else
                    {
                     /* If the bid volume is less than minH, we have to update minH in minMaxStruct, otherwise,
                      we have to compare the bid volume with maxH, and if it is more than maxH we have to update maxH. */
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
//+-------------------------------------------------------------------------------+
//| Reset all min and max                                                         |
//+-------------------------------------------------------------------------------+
void ResetMinMaxStruct()
  {
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
  }
//+-------------------------------------------------------------------------------+
//| A function that determines the size of the volume                             |
//+-------------------------------------------------------------------------------+
string TempFunction(int volumeLegnth)
  {
   string result;

   if(volumeLegnth<=6 && volumeLegnth>3)
     {
      result = "K";  // Thousand
     }
   else
      if(volumeLegnth<=9 && volumeLegnth>6)
        {
         result = "M";  // Million
        }
      else
         if(volumeLegnth>9 && volumeLegnth<=12)
           {
            result = "B";  // Billion
           }
         else
            if(volumeLegnth <=3)
              {
               result = "H";  // Hundred and below hundred
              }

   return result;
  }
