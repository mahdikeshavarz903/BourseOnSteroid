//+------------------------------------------------------------------+
//|                                                          buy.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property tester_indicator "BHRSI.ex5"
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
input int      BhrsiThreshold=50;         // BHRSI Threshold
input int      BhrsiTotalThreshold=50;    // BHRSI Total Threshold
input int      BhrsiPeriod=10;            // BHRSI Period
input int      BhrsiTotalPeriod=10;       // BHRSI Total Period
// Custom variables
MqlBookInfo  previousDOM[];             // This variable holds previous values of Depth Of Market
MqlBookInfo  currentDOM[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BHRSIBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,BHRSITOTALBuffer,INDICATOR_DATA);
   
   string short_name=StringFormat("BHRSI(%d) - BHRSI Total(%d)",BhrsiPeriod,BhrsiTotalPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   
   MarketBookGet(NULL,previousDOM);
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
    bool getDOM=MarketBookGet(NULL,currentDOM);
    if(getDOM)
     {
         for(int i=0;i<ArraySize(currentDOM);i++)
         {
            Print("OnCalculate => ", i+":",currentDOM[i].price ,"    Volume = ", currentDOM[i].volume, " type = ",currentDOM[i].type);
            
            double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
            double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
            
            float diffBuy;
            float diffSell;
            int result[2]; // result[0]-> min   , result[1]-> max
            int min, max;
            
            findInclusiveRange(currentDOM[5].price, previousDOM[5].price, currentDOM[4].price, previousDOM[4].price, result);
            min = result[0];
            max = result[1]; 
            
            if(bid > previousDOM[5].price)
            {
               diffBuy = bhrsiChangesForBuy("UP", min, max);
            }
            else if(bid < previousDOM[5].price)
            {
               diffBuy = bhrsiChangesForBuy("DOWN", min, max);            
            }
            else
            {
               diffBuy = (currentDOM[5].volume - previousDOM[5].volume);
            }
            
            if(ask > previousDOM[5].price)
            {
                 diffSell = bhrsiChangesForSell("UP", min, max);
            }
            else if(ask < previousDOM[5].price)
            {
                  diffSell = bhrsiChangesForSell("DOWN", min, max);
            }
            else
            {
               diffSell = (currentDOM[4].volume - previousDOM[4].volume);
            }
         }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
   ArrayCopy(previousDOM,currentDOM,0,0,WHOLE_ARRAY);
  
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

float bhrsiChangesForBuy(string priceDirection, int min, int max) 
{
    float volume = 0;

    // BUY
    for(int i=5;i<10;i++)
    {
       if (priceDirection == "UP")
       {
         if (currentDOM[i].price > previousDOM[5].price) 
         {
           //volume += setRangeValueVolume(curentDOM[i], min, max);
         } 
         else if (currentDOM[i].price == previousDOM[5].price) 
         {
           //volume += setRangeValueVolume(currentDOM[i], min, max) - setRangeValueVolume(previousDOM[5], min, max);
           break;
         } 
         else 
         {
           //volume -= setRangeValueVolume(previousDOM[5], min, max); // volume += (0 - previousDOM[5].volume);
           break;
         }
       } 
       else
       {
         if (currentDOM[5].price < previousDOM[i].price) 
         {
            //volume -= setRangeValueVolume(previousDOM[i], min, max);
         }
         else if (currentDOM[5].price == previousDOM[i].price) 
         {
           //volume += setRangeValueVolume(currentDOM[5], min, max) - setRangeValueVolume(previousDOM[i], min, max);
           break;
         } 
         else 
         {
           //volume += setRangeValueVolume(currentDOM[5], min, max); // volume += (0 - oldItems[i][1]);
           break;
         }
       }
    }

  return volume;
}


float bhrsiChangesForSell(string priceDirection, int min, int max) {
  float volume = 0;

  // TODO: This loop should be 5 for MofidOnline
  for (int i = 4; i >= 0; i--) 
  {
    if (priceDirection == "UP") 
    {
      if (currentDOM[4].price > previousDOM[i].price) 
      {
        //volume -= setRangeValueVolume(previousDOM[i], min, max);
      } 
      else if (currentDOM[4].price == previousDOM[i].price) 
      {
        //volume += setRangeValueVolume(currentDOM[4], min, max) - setRangeValueVolume(previousDOM[i], min, max);
        break;
      } 
      else 
      {
        //volume += setRangeValueVolume(currentDOM[4], min, max);
        break;
      }
    } 
    else 
    {
      if (currentDOM[i].price < previousDOM[4].price) 
      {   
         //volume += setRangeValueVolume(currentDOM[i], min, max);
      }
      else if (currentDOM[i].price == previousDOM[4].price) 
      {
        //volume += setRangeValueVolume(currentDOM[i], min, max) - setRangeValueVolume(previousDOM[4], min, max);
        break;
      } 
      else 
      {
        //volume -= setRangeValueVolume(previousDOM[4], min, max); //volume += (0 - oldItems[4][1]);
        break;
      }
    }
  }

  return volume;
}


float setRangeValueVolume(float queueValue,int min, int max) {
  return 1;
}


void findInclusiveRange(float newBid, float oldBid, float newAsk, float oldAsk, int &result[]) {

  float firstMin = newBid;
  float lastMin = oldBid ? oldBid : newBid;

  float firstMax = newAsk;
  float lastMax = oldAsk ? oldAsk : newAsk;

  int min = (int) MathMin(firstMin, lastMin);
  int max = (int) MathMax(firstMax, lastMax);
  
  result[0] = min;
  result[1] = max;
}