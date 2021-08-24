//+------------------------------------------------------------------+
//|                                             linearregression.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot volume
#property indicator_label1  "volume"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double         TimeToVanishingBuffer[];   // Buffer for holding time of vanishing queue
//--- input parameters
input int      frontLineVolumeLength=10;         // Indicator calculation period
//+------------------------------------------------+
//|  Custom variables                              |
//+------------------------------------------------+
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

int vanishingTime;           // Variable for holding time of vanishing queue
double frontLineVolume[];    // This variable holds bid or ask volume
int    frontLineIndex=0;       // This variable holds the last FrontLineVolume index for which we set the value
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,TimeToVanishingBuffer,INDICATOR_DATA);

   EventSetTimer(1);

   /* Set the size of SumList and SumListTotal to the size of the period*/
   ArrayResize(frontLineVolume, frontLineVolumeLength);

   vanishingTime=frontLineVolumeLength;
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

   if(prev_calculated==0)
     {
      ArrayInitialize(TimeToVanishingBuffer, EMPTY_VALUE);
      ArrayInitialize(frontLineVolume, -1);
      /*
      frontLineVolume[0]=300000;
      frontLineVolume[1]=250000;
      frontLineVolume[2]=200000;
      frontLineVolume[3]=150000;
      frontLineVolume[4]=120000;
      frontLineVolume[5]=123000;
      frontLineVolume[6]=140000;
      frontLineVolume[7]=20000;
      frontLineVolume[8]=15000;
      */
     }
   else //if(prev_calculated>=0)
     {
      //---- declarations of local variables
      double value,a,b,c,sumy,sumx,sumxy,sumx2;

      bool getDOM=MarketBookGet(NULL,currentDOM);
      if(getDOM && ArraySize(currentDOM)!=0)
        {

         // frontLineIndex=9;
         if(frontLineIndex==0)
           {
            frontLineVolume[frontLineIndex] = currentDOM[4].volume;
            frontLineIndex++;
           }
            
         frontLineVolume[frontLineIndex] = currentDOM[4].volume;


         //---- indexing elements in arrays as time series
         ArraySetAsSeries(TimeToVanishingBuffer,true);

         sumy=0.0;
         sumx=0.0;
         sumxy=0.0;
         sumx2=0.0;
         vanishingTime = 0;

         for(int iii=0; iii<ArraySize(frontLineVolume) && frontLineVolume[iii]!=-1; iii++)
           {
            value=frontLineVolume[iii];
            sumy+=value;
            sumxy+=value*iii;
            sumx+=iii;
            sumx2+=iii*iii;
            vanishingTime = iii + 1;
           }

         c=sumx2*vanishingTime-sumx*sumx;
         if(!c)
            return(rates_total);

         b=(sumxy*vanishingTime-sumx*sumy)/c;
         a = (sumy * sumx2 - sumx * sumxy)/c;

         double LR_price_1=a+b*vanishingTime;

         if(!b)
            return(rates_total);

         TimeToVanishingBuffer[0] = (-a / b);

         (frontLineIndex<frontLineVolumeLength-1)?frontLineIndex++:frontLineIndex;


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
   int count = ArraySize(frontLineVolume);
   if(frontLineIndex==ArraySize(frontLineVolume)-1 && ArrayCopy(frontLineVolume, frontLineVolume, 0, 1, count - 1) == count - 1)
     {
      //frontLineIndex++;
     }

  }
//+------------------------------------------------------------------+
