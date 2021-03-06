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
#include <Trade\SymbolInfo.mqh>
#include "Program.mqh"

CProgram      program;
CMBookBtn     MButton;               // An object from CBookBtn class  
CEventNewTick EventNewTick;          // This object causes some events would be active
double        fake_buffer[];         
double        previousBid=0;         // The variable that holds the previous value of bid price
double        previousAsk=0;         // The variable that holds the previous value of ask price
bool          bidPriceChanged=false; // A boolean variable that keeps watching bid price changes and if it is changed then it becomes true
bool          askPriceChanged=false; // A boolean variable that keeps watching ask price changes and if it is changed then it becomes true
CChart        m_chart;               // Used for activating some events in chart
MqlBookInfo   dom[];                 // This variable holds previous values of depth of market

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   program.OnInitEvent();
   
   /* Set timer for OnTimer() function */
   EventSetTimer(1);

//--- Get the ID of the current chart
   m_chart.Attach();
   
//--- Enable tracking of mouse events
   m_chart.EventMouseMove(true);
   m_chart.AutoScroll(true);
   m_chart.MouseScroll(true);

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

   // Refresh dom variables(price and volume)
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
         
         /* The boolean value become true because the bid price changed */
         bidPriceChanged=true;
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
         
         /* The boolean value become true because the ask price changed */
         askPriceChanged=true;
        }

      /* Update previous value after its price changes */
      previousAsk = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);
     }
   
   /* Define the size of dom variable by MarketBook struct */
   if(ArraySize(dom)!=ArraySize(MarketBook.MarketBook))
      ArrayResize(dom, ArraySize(MarketBook.MarketBook));

   /* 
   These two variables keep sum snapshot volume for bid and ask
   They used in CBookArea class
   */
   globalSnapshotAskPower=0;
   globalSnapshotBidPower=0;
   
   /* Update depth of market after a book event occurs */
   for(int j=0; j<total; j++)
     {
      /* Find target price in CMainTable list */
      if(cMainTable.TryGetValue(MarketBook.MarketBook[j].price, value) &&  value !=NULL && ArraySize(dom)!=0)
        {
         /* Compare each row of the current dom with the previous dom and calculate the difference between them */
         int diff=MarketBook.MarketBook[j].volume-dom[j].volume;

         if(MarketBook.MarketBook[j].type == BOOK_TYPE_SELL)
           {
            value.SetAskVolume(MarketBook.MarketBook[j].volume);
            
            /* 
            If the price of the current row doesn't change from the previous and the volume of the previous row has changed 
            from the current, we should add diff values to the previous values of the snapshot.
            
            We should consider the below notes:
            1) If the bid price changes, we should set zero value for all snapshotBid of DOM
            2) If the ask price changes, we should set zero value for all snapshotAsk of DOM
            3) If other prices except for bid and ask changed, we should set zero value for that snapshot of DOM
            */
            if(MarketBook.MarketBook[j].price==dom[j].price)
              {
               if(MarketBook.MarketBook[j].volume!=dom[j].volume)
                 {
                  value.SetSnapshotAsk(askPriceChanged?0:(value.GetSnapshotAsk() + diff));
                 }
              }
            else
              {
               /* If the price has changed we set zero value for snapshot*/
               value.SetSnapshotAsk(0);
              }

            if(value.GetSnapshotAsk()>0)
               globalSnapshotAskPower+=value.GetSnapshotAsk();
            else 
               globalSnapshotBidPower+=MathAbs(value.GetSnapshotAsk());
           }
         else
           {
            value.SetBidVolume(MarketBook.MarketBook[j].volume);

            if(MarketBook.MarketBook[j].price==dom[j].price)
              {
               if(MarketBook.MarketBook[j].volume!=dom[j].volume)
                 {
                  value.SetSnapshotBid(bidPriceChanged?0:(value.GetSnapshotBid() + diff));
                 }
              }
            else
              {
               /* If the price has changed we set zero value for snapshot*/
               value.SetSnapshotBid(0);
              }

              if(value.GetSnapshotBid()>0)
               globalSnapshotBidPower+=value.GetSnapshotBid();
            else 
               globalSnapshotAskPower+=MathAbs(value.GetSnapshotBid());
               
           }

         cMainTable.TrySetValue(MarketBook.MarketBook[j].price, value);
        }
      
      /* Update the previous DOM by the current dom values */
      dom[j] = MarketBook.MarketBook[j];
     }

   /* After updating the values, we need to call the ShiftCells function to make changes to the columns */
   CBookGraphTable::ShiftCells(startIndex, endIndex);

   MButton.Refresh();
   ChartRedraw();

   askPriceChanged=false;
   bidPriceChanged=false;
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
   //program.ChartEvent(id,lparam,dparam,sparam);
   
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
   program.OnTimerEvent();
   
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
         globalBuyerPower+=MarketBook.LastTicks[tickIndex].volume;
        }
      else
         if((MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL) /* If the bit for SELL_FLAG equal 1, it means that a SELL tick occurs */
           {
            //Print("TICK_FLAG_SELL - volume: ", MarketBook.LastTicks[tickIndex].volume, "   - price: ", MarketBook.LastTicks[tickIndex].last);
            value.SetSellerVolume(value.GetSellerVolume() +  MarketBook.LastTicks[tickIndex].volume);
            globalSellerPower+=MarketBook.LastTicks[tickIndex].volume;
           }

      /* If buy or sell flag occurs we should add it to VOLUME_COLUMN */
      if((MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL ||
         (MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
        {
         value.SetVolume(value.GetVolume() +  MarketBook.LastTicks[tickIndex].volume);
        }
     }
  }
