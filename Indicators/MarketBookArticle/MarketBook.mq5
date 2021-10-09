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
   EventSetMillisecondTimer(200);

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
            hideCellBook(value, VOLUME_COLUMN, refresh);
            hideCellBook(value, PRICE_PERCENTAGE_COLUMN, refresh);
            hideCellBook(value, BUYER_COLUMN, refresh);
            hideCellBook(value, SELLER_COLUMN, refresh);
            
            value.SetDomRowId(-1);
           }

         cMainTable.TrySetValue(mainDomPrices[j], value);
        }

      if(cMainTable.TryGetValue(MarketBook.MarketBook[j].price, value) &&  value !=NULL)
        {
         mainDomPrices[j] = MarketBook.MarketBook[j].price;

         int type = MarketBook.MarketBook[j].type;

         hideCellBook(value, VOLUME_COLUMN, refresh);
         hideCellBook(value, BUYER_COLUMN, refresh);
         hideCellBook(value, SELLER_COLUMN, refresh);
         hideCellBook(value, PRICE_PERCENTAGE_COLUMN, refresh);

         value.SetDomRowId(j+13);

         showCellBook(value, value.GetDomRowId(), VOLUME_COLUMN, refresh, type, value.GetVolume());
         showCellBook(value, value.GetDomRowId(), BUYER_COLUMN, refresh, type, value.GetBuyerVolume());
         showCellBook(value, value.GetDomRowId(), SELLER_COLUMN, refresh, type, value.GetSellerVolume());
         showCellBook(value, value.GetDomRowId(), PRICE_PERCENTAGE_COLUMN, refresh, type, value.GetPricePercentage());

         cMainTable.TrySetValue(MarketBook.MarketBook[j].price, value);
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
//Print("TICK");
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

         ArrayResize(ticks, ArraySize(ticks)-1);
         j--;
        }
     }

   delete refresh;

  }

//+------------------------------------------------------------------+
void UpdateVolumesCells(int tickIndex, CMainTable *value)
  {
   if((ticks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
     {
      //Print("TICK_FLAG_BUY - volume: ", ticks[tickIndex].volume, "   - price: ", ticks[tickIndex].bid);

      value.SetBuyerVolume(value.GetBuyerVolume() +  ticks[tickIndex].volume);
     }

   else
      if((ticks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL)
        {
         //Print("TICK_FLAG_SELL - volume: ", ticks[tickIndex].volume, "   - price: ", ticks[tickIndex].ask);

         value.SetSellerVolume(value.GetSellerVolume() +  ticks[tickIndex].volume);
        }
      else
         if((ticks[tickIndex].flags & TICK_FLAG_SELL) != TICK_FLAG_SELL &&
            (ticks[tickIndex].flags & TICK_FLAG_BUY) != TICK_FLAG_BUY)
           {
            //Print("OnCalculate() - N/A - volume: ", MarketBook.LastTicks[j].volume, "   - price: ", MarketBook.LastTicks[j].ask);
            //cMainTable[mainTableIndex].SetVolume(cMainTable[mainTableIndex].GetVolume() +  MarketBook.LastTicks[tickIndex].volume);
            //showBookCell(tickIndex, mainTableIndex, marketBookIndex, type, 0, refresh);
           }

   if((ticks[tickIndex].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL ||
      (ticks[tickIndex].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
     {
      //Print("OnCalculate() - N/A - volume: ", ticks[tickIndex].volume, "   - price: ", ticks[tickIndex].ask);
      value.SetVolume(value.GetVolume() +  ticks[tickIndex].volume);
     }

  }
//+------------------------------------------------------------------+
void showCellBook(CMainTable &value, int domRowIndex, int cellNumber, CEventRefresh *refresh, int type, int volume)
  {
   int result[2];
   FindMinMax(result);

   CBookCell *bookCell = new CBookCell();
   value.GetBookCell(bookCell, cellNumber, value.GetPricePercentage());
   bookCell.SetVariables(1, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], volume, type, result[0], result[1]);
   value.SetBookCell(bookCell, cellNumber);
   bookCell.Show();
   bookCell.OnRefresh2(refresh);
  }
//+------------------------------------------------------------------+
void hideCellBook(CMainTable &value, int cellNumber, CEventRefresh *refresh)
  {
   int result[2];
   FindMinMax(result);

   CBookCell *bookCell = new CBookCell();
   value.GetBookCell(bookCell, cellNumber, value.GetPricePercentage());
   value.SetBookCell(bookCell, cellNumber);
   bookCell.Hide();
   bookCell.OnRefresh2(refresh);
  }
//+------------------------------------------------------------------+
void FindMinMax(int &result[])
  {
   double keys[];
   CMainTable *values[];
   cMainTable.CopyTo(keys, values, 0);
   int min, max;
   int tempList[];
   ArrayResize(tempList, ArraySize(keys)*2+1);
   ArrayInitialize(tempList, 0);

   min = values[0].GetBidVolume();
   max = values[0].GetAskVolume();
   for(int i=0, j=0; i<ArraySize(keys); i++, j+=2)
     {
      if(values[i] != NULL)
        {
         tempList[j] = values[i].GetBidVolume();
         tempList[j+1] = values[i].GetAskVolume();

         if(min > tempList[j])
            min = tempList[j];

         if(max < tempList[j])
            max = tempList[j];

         if(min > tempList[j+1])
            min = tempList[j+1];

         if(max < tempList[j+1])
            max = tempList[j+1];
        }
     }

   result[0] = min;
   result[1] = max;
  }
//+------------------------------------------------------------------+
