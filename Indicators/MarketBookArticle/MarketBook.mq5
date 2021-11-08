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

         cMainTable.TrySetValue(MarketBook.MarketBook[j].price, value);
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
         /* Update buyer/seller volume */
         UpdateVolumesCells(j, value);
         cMainTable.TrySetValue(MarketBook.LastTicks[j].last, value);
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
void UpdateVolumesCells(int tickIndex, CMainTable &value)
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
      CBookGraphTable::FindMinMaxInMainTable();

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

//+------------------------------------------------------------------+
