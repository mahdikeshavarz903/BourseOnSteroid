//+------------------------------------------------------------------+
//|                                                        BHRSI.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot BHRSI
#property indicator_label1  "BHRSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot BHRSITOTAL
#property indicator_label2  "BHRSITOTAL"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double         BHRSIBuffer[];
double         BHRSITOTALBuffer[];
//--- input parameters
input ulong ExtCollectTime   =30;  // test time in seconds
input ulong ExtSkipFirstTicks=10;  // number of ticks skipped at start
input int threshold;

int thresholdValue;
struct indicatorObj {
       float BHRSI[];
       float sumList[]; // sumList: store algebraic addition result here every time
       
       struct flags{
         bool buy;
         bool sell;
       }; 
    };
    
indicatorObj indicator;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BHRSIBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,BHRSITOTALBuffer,INDICATOR_DATA);
   
   
     thresholdValue = threshold;
  
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
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
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
