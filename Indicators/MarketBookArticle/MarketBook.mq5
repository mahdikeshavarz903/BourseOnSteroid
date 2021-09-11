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
#include "MBookBtn.mqh"
#include "EventNewTick.mqh"

CMBookBtn MButton;
CEventNewTick EventNewTick;
double fake_buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //EventSetTimer(2);

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
   if(symbol!=MarketBook.GetMarketBookSymbol())
      return;
   MarketBook.Refresh();
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
   ArraySetAsSeries(close, true);

   MarketBook.Refresh();

   if(prev_calculated > 0)
     {
      for(int i=0; i<ArraySize(mainTable); i++)
        {
         if(mainTable[i].price == close[0])
           {
            int lastIndex = ArraySize(MarketBook.LastTicks)-1;

            if(lastIndex>=0)
              {
               if(MarketBook.LastTicks[lastIndex].flags == TICK_FLAG_BUY)
                  Print("TICK_FLAG_BUY: ", MarketBook.LastTicks[lastIndex].flags);
               else
                  if(MarketBook.LastTicks[lastIndex].flags == TICK_FLAG_SELL)
                     Print("TICK_FLAG_SELL: ", MarketBook.LastTicks[lastIndex].flags);
                  else
                     if(MarketBook.LastTicks[lastIndex].flags == TICK_FLAG_BID)
                        Print("TICK_FLAG_BID: ", MarketBook.LastTicks[lastIndex].flags);
                     else
                        if(MarketBook.LastTicks[lastIndex].flags == TICK_FLAG_ASK)
                           Print("TICK_FLAG_ASK: ", MarketBook.LastTicks[lastIndex].flags);
                        else
                           if(MarketBook.LastTicks[lastIndex].flags == TICK_FLAG_LAST)
                              Print("TICK_FLAG_LAST: ", MarketBook.LastTicks[lastIndex].flags);
                           else
                              if(MarketBook.LastTicks[lastIndex].flags == TICK_FLAG_VOLUME)
                                 Print("TICK_FLAG_VOLUME: ", MarketBook.LastTicks[lastIndex].flags);

               Print("TICK_FLAG: ", MarketBook.LastTicks[lastIndex].flags);

               if(MarketBook.LastTicks[lastIndex].flags == TICK_FLAG_BID)
                 {
                  mainTable[i].buyerVol = MarketBook.LastTicks[lastIndex].volume;
                  mainTable[i].volume += mainTable[i].buyerVol;
                 }

               else
                  if(MarketBook.LastTicks[lastIndex]. flags == TICK_FLAG_ASK)
                    {
                     mainTable[i].sellerVol = MarketBook.LastTicks[lastIndex].volume;
                     mainTable[i].volume += mainTable[i].sellerVol;
                    }

              }

           }
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
  }
//+------------------------------------------------------------------+
