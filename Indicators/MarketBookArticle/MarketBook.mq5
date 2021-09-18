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
#include "GlobalMainTable2.mqh"
#include "MBookCell.mqh"
#include "MBookBtn.mqh"
#include "EventNewTick.mqh"

CMBookBtn MButton;
CEventNewTick EventNewTick;
double fake_buffer[];

int counter=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(2);

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
   Print("OnBookEvent");

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
   Print("OnChartEvent");

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
   Print("OnCalculate");
//---
   ArraySetAsSeries(close, true);

//if(ArraySize(MarketBook.LastTicks)!=0)
//   Print("TICK_FLAG: ", MarketBook.LastTicks[0].flags);
   Print("TICK");

   MarketBook.Refresh();

   if(prev_calculated > 0)
     {
      for(int j=0; j<ArraySize(MarketBook.LastTicks); j++)
        {
         for(int i=0; i<ArraySize(cMainTable); i++)
           {
            if(cMainTable[i].GetPrice()==MarketBook.LastTicks[j].last)
              {
               for(int j=0; j<ArraySize(MarketBook.MarketBook); i++)
                 {
                  if(cMainTable[i].GetPrice()==MarketBook.MarketBook[j].price)
                    {
                     int askPrice = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);
                     CBookCell *bookCell=new CBookCell();
                     CEventRefresh *refresh = new CEventRefresh();
                     int type = MarketBook.MarketBook[j].type;

                     if((MarketBook.LastTicks[j].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
                       {
                        Print("TICK_FLAG_BUY - volume: ", MarketBook.LastTicks[j].volume, "   - price: ", MarketBook.LastTicks[j].bid);

                        cMainTable[i].SetBuyerVolume(cMainTable[i].GetBuyerVolume() +  MarketBook.LastTicks[j].volume);
                        cMainTable[i].SetVolume(cMainTable[i].GetVolume() + cMainTable[i].GetBuyerVolume());

                        if(type==0)
                          {
                           cMainTable[i].GetBookCell(bookCell, 4);
                           bookCell.SetVariables(domMapCoordinates[j][4][0], domMapCoordinates[j][4][1], cMainTable[i].GetBuyerVolume(), type, 1);
                           cMainTable[i].SetBookCell(bookCell, 4);
                           bookCell.Show();
                           bookCell.OnRefresh2(refresh);
                          }

                       }

                     else
                        if((MarketBook.LastTicks[j]. flags & TICK_FLAG_SELL) == TICK_FLAG_SELL)
                          {
                           Print("TICK_FLAG_SELL - volume: ", MarketBook.LastTicks[j].volume, "   - price: ", MarketBook.LastTicks[j].ask);

                           cMainTable[i].SetSellerVolume(cMainTable[i].GetSellerVolume() +  MarketBook.LastTicks[j].volume);
                           cMainTable[i].SetVolume(cMainTable[i].GetVolume() +  cMainTable[i].GetSellerVolume());

                           if(type==1)
                             {
                              cMainTable[i].GetBookCell(bookCell, 3);
                              bookCell.SetVariables(domMapCoordinates[j][3][0], domMapCoordinates[j][3][1], cMainTable[i].GetBuyerVolume(), MarketBook.MarketBook[j].type, 1);
                              cMainTable[i].SetBookCell(bookCell, 3);
                              bookCell.Show();
                              bookCell.OnRefresh2(refresh);
                             }
                          }
                        else
                           if((MarketBook.LastTicks[j]. flags & TICK_FLAG_SELL) != TICK_FLAG_SELL &&
                              (MarketBook.LastTicks[j].flags & TICK_FLAG_BUY) != TICK_FLAG_BUY)
                             {
                              //Print("OnCalculate() - N/A - volume: ", MarketBook.LastTicks[j].volume, "   - price: ", MarketBook.LastTicks[j].ask);
                              cMainTable[i].SetVolume(cMainTable[i].GetVolume() +  MarketBook.LastTicks[j].volume);

                              cMainTable[i].GetBookCell(bookCell, 0);
                              bookCell.SetVariables(domMapCoordinates[j][0][0], domMapCoordinates[j][0][1], cMainTable[i].GetVolume(), type, 1);
                              cMainTable[i].SetBookCell(bookCell, 0);
                              bookCell.Show();
                              bookCell.OnRefresh2(refresh);
                             }
                    }
                 }


              }

            break;
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
