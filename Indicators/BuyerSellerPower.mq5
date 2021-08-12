//+------------------------------------------------------------------+
//|                                             BuyerSellerPower.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot FrontlineBuyerPower
#property indicator_label1  "FrontlineBuyerPower"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot FrontlineSellerPower
#property indicator_label2  "FrontlineSellerPower"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot TotalBuyerPower
#property indicator_label3  "TotalBuyerPower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLawnGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot TotalSellterPower
#property indicator_label4  "TotalSellterPower"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrYellow
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- indicator buffers
double         FrontlineBuyerPowerBuffer[];
double         FrontlineSellerPowerBuffer[];
double         TotalBuyerPowerBuffer[];
double         TotalSellterPowerBuffer[];
// Custom variables
int          handle;
MqlBookInfo  currentDOM[];    /*
                                This variable holds current values of Depth Of Market

                                CurrentDOM: [0] -> The fifth line of sellers
                                                   [1] -> The fourth line of sellers
                                                   [2] -> The third line of sellers
                                                   [3] -> The second line of sellers
                                                   [4] -> The first line of sellers(ASK)
                                                   [5] -> The first line of buyers(BID)
                                                   [6] -> The second line of buyers
                                                   [7] -> The third line of buyers
                                                   [8] -> The fourth line of buyers
                                                   [9] -> The fifth line of buyers
                               */
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,FrontlineBuyerPowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,FrontlineSellerPowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,TotalBuyerPowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,TotalSellterPowerBuffer,INDICATOR_DATA);

   string short_name="BuyerSellerPower";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);

   /* Provides opening of Depth of Market for a selected symbol, and subscribes for receiving notifications of the DOM changes*/
   MarketBookAdd(_Symbol);

   /*Returns the handle of the indicator with the specified short name in the specified chart window*/
   handle = ChartIndicatorGet(0, ChartWindowFind(), short_name);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   if((rates_total-prev_calculated)>1)
     {
      for(int i=prev_calculated; i<rates_total; i++)
        {
         FrontlineBuyerPowerBuffer[i]=50;
         FrontlineSellerPowerBuffer[i]=50;
         TotalBuyerPowerBuffer[i]=50;
         TotalSellterPowerBuffer[i]=50;
        }
     }

   calculateBuyerSellerPower();


//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
//| OnBookEvent function                                              |
//+------------------------------------------------------------------+
void OnBookEvent(const string& symbol)
  {

   if(symbol==_Symbol)
     {
      calculateBuyerSellerPower();
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateBuyerSellerPower()
  {
   int prev_calculated = BarsCalculated(handle);   // Returns the number of calculated data in an indicator buffer or -1 in the case of error (data hasn't been calculated yet)
   int rates_total = Bars(_Symbol,PERIOD_M1);      // Returns the number of bars for a specified symbol and period

   bool getDOM=MarketBookGet(NULL,currentDOM);
   if(getDOM && ArraySize(currentDOM)!=0)
     {
      for(int i=prev_calculated-1; i<rates_total; i++)
        {
         FrontlineBuyerPowerBuffer[i] = (currentDOM[5].volume/(currentDOM[5].volume+currentDOM[4].volume))*100;
         FrontlineSellerPowerBuffer[i] = 100 - FrontlineBuyerPowerBuffer[i];

         float tBuyer = currentDOM[5].volume+currentDOM[6].volume+currentDOM[7].volume+currentDOM[8].volume+currentDOM[9].volume;
         float tSeller = currentDOM[4].volume+currentDOM[3].volume+currentDOM[2].volume+currentDOM[1].volume+currentDOM[0].volume;
         TotalBuyerPowerBuffer[i] = ((tBuyer) / (tBuyer+tSeller))*100;
         TotalSellterPowerBuffer[i] = 100 - TotalBuyerPowerBuffer[i];
        }
     }
  }
//+------------------------------------------------------------------+
