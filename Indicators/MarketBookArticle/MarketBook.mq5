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
//Print("OnBookEvent");

   if(symbol!=MarketBook.GetMarketBookSymbol())
      return;
   MarketBook.Refresh();
   MButton.Refresh();
   ChartRedraw();

   int total = (int)MarketBook.InfoGetInteger(MBOOK_DEPTH_TOTAL);
   CEventRefresh *refresh = new CEventRefresh();

   double pricesToBeHide[];

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
         ArrayResize(pricesToBeHide, ArraySize(pricesToBeHide)+1);
         pricesToBeHide[ArraySize(pricesToBeHide)-1]= mainDomPrices[j];
        }
     }

   for(int i=0; i<ArraySize(cMainTable); i++)
     {
      for(int z=0; z<ArraySize(pricesToBeHide); z++)
        {
         if(cMainTable[i].GetPrice() == pricesToBeHide[z])
           {
            hideCellBook(i, 4, refresh);
            hideCellBook(i, 3, refresh);
            hideCellBook(i, 0, refresh);
           }
        }

      for(int j=0; j<total; j++)
        {
         if(cMainTable[i].GetPrice() == MarketBook.MarketBook[j].price)
           {
            mainDomPrices[j] = MarketBook.MarketBook[j].price;
            
            int type = MarketBook.MarketBook[j].type;

            hideCellBook(i, 4, refresh);
            hideCellBook(i, 3, refresh);
            hideCellBook(i, 0, refresh);

            cMainTable[i].SetDomRowId(j+13);

            showCellBook(i, cMainTable[i].GetDomRowId(), 4, refresh, type, cMainTable[i].GetBuyerVolume());
            showCellBook(i, cMainTable[i].GetDomRowId(), 3, refresh, type, cMainTable[i].GetSellerVolume());
            showCellBook(i, cMainTable[i].GetDomRowId(), 0, refresh, type, cMainTable[i].GetVolume());
           }
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
      CEventRefresh *refresh = new CEventRefresh();

      for(int i=0; i<ArraySize(cMainTable); i++)
        {
         for(int j=0; j<ArraySize(MarketBook.LastTicks); j++)
           {
            if(cMainTable[i].GetPrice()==MarketBook.LastTicks[j].last)
              {
               int type = (cMainTable[i].GetDomRowId()<18)?0:1;

               UpdateVolumesCells(j, i, refresh, type);

               break;
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
void UpdateVolumesCells(int tickIndex, int mainTableIndex, CEventRefresh *refresh, int type)
  {
   if((MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
     {
      Print("TICK_FLAG_BUY - volume: ", MarketBook.LastTicks[tickIndex].volume, "   - price: ", MarketBook.LastTicks[tickIndex].bid);

      cMainTable[mainTableIndex].SetBuyerVolume(cMainTable[mainTableIndex].GetBuyerVolume() +  MarketBook.LastTicks[tickIndex].volume);
     }

   else
      if((MarketBook.LastTicks[tickIndex]. flags & TICK_FLAG_SELL) == TICK_FLAG_SELL)
        {
         Print("TICK_FLAG_SELL - volume: ", MarketBook.LastTicks[tickIndex].volume, "   - price: ", MarketBook.LastTicks[tickIndex].ask);

         cMainTable[mainTableIndex].SetSellerVolume(cMainTable[mainTableIndex].GetSellerVolume() +  MarketBook.LastTicks[tickIndex].volume);
        }
      else
         if((MarketBook.LastTicks[tickIndex]. flags & TICK_FLAG_SELL) != TICK_FLAG_SELL &&
            (MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_BUY) != TICK_FLAG_BUY)
           {
            //Print("OnCalculate() - N/A - volume: ", MarketBook.LastTicks[j].volume, "   - price: ", MarketBook.LastTicks[j].ask);
            //cMainTable[mainTableIndex].SetVolume(cMainTable[mainTableIndex].GetVolume() +  MarketBook.LastTicks[tickIndex].volume);
            //showBookCell(tickIndex, mainTableIndex, marketBookIndex, type, 0, refresh);
           }

   if((MarketBook.LastTicks[tickIndex]. flags & TICK_FLAG_SELL) == TICK_FLAG_SELL ||
      (MarketBook.LastTicks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
     {
      Print("OnCalculate() - N/A - volume: ", MarketBook.LastTicks[tickIndex].volume, "   - price: ", MarketBook.LastTicks[tickIndex].ask);
      cMainTable[mainTableIndex].SetVolume(cMainTable[mainTableIndex].GetVolume() +  MarketBook.LastTicks[tickIndex].volume);
     }

  }
//+------------------------------------------------------------------+
void showCellBook(int mainTableIndex, int domRowIndex, int cellNumber, CEventRefresh *refresh, int type, int volume)
  {
   CBookCell *bookCell = new CBookCell();
   cMainTable[mainTableIndex].GetBookCell(bookCell, cellNumber);
   bookCell.SetVariables(domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], volume, type, 1);
   cMainTable[mainTableIndex].SetBookCell(bookCell, cellNumber);
   bookCell.Show();
   bookCell.OnRefresh2(refresh);
  }
//+------------------------------------------------------------------+
void hideCellBook(int mainTableIndex, int cellNumber, CEventRefresh *refresh)
  {
   CBookCell *bookCell = new CBookCell();
   cMainTable[mainTableIndex].GetBookCell(bookCell, cellNumber);
   cMainTable[mainTableIndex].SetBookCell(bookCell, cellNumber);
   bookCell.Hide();
   bookCell.OnRefresh2(refresh);
  }
//+------------------------------------------------------------------+
