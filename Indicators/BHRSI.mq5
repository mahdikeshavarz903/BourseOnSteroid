//+------------------------------------------------------------------+
//|                                                          BHRSI.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
#property tester_indicator "BHRSI.ex5"
//--- plot BHRSI
#property indicator_label1  "BHRSI"
#property indicator_type1   DRAW_CANDLES
#property indicator_color1  clrGreen,clrWhite,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot BHRSITOTAL
#property indicator_label2  "BHRSITOTAL"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1


#include <Arrays\ArrayFloat.mqh>

//--- input parameters
input int      BhrsiThreshold=50;         // BHRSI Threshold
input int      BhrsiTotalThreshold=50;    // BHRSI Total Threshold
input int      BhrsiPeriod=10;            // BHRSI Period
input int      BhrsiTotalPeriod=10;       // BHRSI Total Period
//--- indicator buffers
double         BHRSICloseBuffer[];
double         BHRSIHighBuffer[];
double         BHRSILowBuffer[];
double         BHRSIOpenBuffer[];
double         BHRSITOTALBuffer[];
// Custom variables
MqlBookInfo  previousDOM[];             // This variable holds previous values of Depth Of Market
MqlBookInfo  currentDOM[];
double       SumList[];
double       SumListTotal[];
int          candlestickCounter=0;
float        averagePositive;
float        averageNegative;
float        averagePositiveForBhrsiTotal;
float        averageNegativeForBhrsiTotal;
int          handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("OnInit");

//--- indicator buffers mapping
   SetIndexBuffer(0,BHRSICloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,BHRSIHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,BHRSILowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,BHRSIOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,BHRSITOTALBuffer,INDICATOR_DATA);

//PlotIndexSetDouble(index_of_plot_DRAW_COLOR_CANDLES,PLOT_EMPTY_VALUE,0);

   ArrayResize(SumList, BhrsiPeriod);
   ArrayResize(SumListTotal, BhrsiTotalPeriod);

   EventSetTimer(1);
// ChartSetSymbolPeriod(0, _Symbol,PERIOD_M1);
// ChartIndicatorDelete(0, 0, "PersianCalendar");

   bool previousDOMBool = MarketBookGet(NULL,previousDOM);

   string short_name=StringFormat("BHRSI(%d) - BHRSI Total(%d)",BhrsiPeriod,BhrsiTotalPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);

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
   Print("OnCalculate");

   if((rates_total-prev_calculated)>1)
     {
      for(int i=0; i<rates_total; i++)
        {
         BHRSICloseBuffer[i]=50;
         BHRSIHighBuffer[i]=50;
         BHRSILowBuffer[i]=50;
         BHRSIOpenBuffer[i]=50;

         BHRSITOTALBuffer[i]=50;
        }
     }

   if(prev_calculated != 0 && prev_calculated != rates_total)
     {
      BHRSIOpenBuffer[prev_calculated]=BHRSICloseBuffer[prev_calculated-1];
      BHRSICloseBuffer[prev_calculated] = 50;
     }

   bool getDOM=MarketBookGet(NULL,currentDOM);
   if(getDOM && ArraySize(currentDOM)!=0 && ArraySize(previousDOM) != 0)
     {
      //bhrsiTotalCalculation();
      bhrsiCalculation();
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
   Print("OnTimer");

   bool getDOM=MarketBookGet(NULL,currentDOM);
   if(getDOM && ArraySize(currentDOM) != 0 && ArraySize(previousDOM) != 0)
     {
      if(BHRSIOpenBuffer[ArraySize(BHRSIOpenBuffer)-1]==0)
         BHRSIOpenBuffer[ArraySize(BHRSIOpenBuffer)-1]=BHRSICloseBuffer[ArraySize(BHRSICloseBuffer)-2];

      // Below code used for shifting SumList array
      int count = ArraySize(SumList);
      if(ArrayCopy(SumList, SumList, 1, 0, count - 1) == count - 1)
         SumList[0] = 0;

      count = ArraySize(SumListTotal);
      if(ArrayCopy(SumListTotal, SumListTotal, 1, 0, count - 1) == count - 1)
         SumListTotal[0] = 0;

      //bhrsiTotalCalculation();
      bhrsiCalculation();


      if(ArraySize(currentDOM)!=0)
         ArrayCopy(previousDOM,currentDOM,0,0,WHOLE_ARRAY);

      candlestickCounter++;
     }

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
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- close the DOM
//if(!MarketBookRelease(_Symbol))
//  Print("Failed to close the DOM!");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnBookEvent(const string& symbol)
  {

//bhrsiCalculation();

   /*
      if(symbol==_Symbol)
        {
         //--- array of the DOM structures
         MqlBookInfo last_bookArray[];

         --- get the book
         if(MarketBookGet(_Symbol,last_bookArray))
           {
            //--- process book data
            for(int idx=0;idx<ArraySize(last_bookArray);idx++)
              {
               MqlBookInfo curr_info=last_bookArray[idx];
               //--- print
               PrintFormat("Type: %s",EnumToString(curr_info.type));
               PrintFormat("Price: %0."+IntegerToString(_Digits)+"f",curr_info.price);
               PrintFormat("Volume: %d",curr_info.volume);
              }
           }
        }
   */
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void bhrsiCalculation()
  {
   Print("bhrsiCalculation");


   float diffBuy;
   float diffSell;
   int result[2]; // result[0]-> min   , result[1]-> max
   int min, max;
   int prev_calculated = BarsCalculated(handle);

   int rates_total = Bars(_Symbol,PERIOD_M1);


   Print("Current DOM");
   double bid = currentDOM[5].price;
   double ask = currentDOM[4].price;

   findInclusiveRange(currentDOM[5].price, previousDOM[5].price, currentDOM[4].price, previousDOM[4].price, result);
   min = result[0];
   max = result[1];

   if(bid > previousDOM[5].price)
     {
      diffBuy = bhrsiChangesForBuy("UP", min, max);
     }
   else
      if(bid < previousDOM[5].price)
        {
         diffBuy = bhrsiChangesForBuy("DOWN", min, max);
        }
      else
        {
         diffBuy = (currentDOM[5].volume - previousDOM[5].volume);
        }

   if(ask > previousDOM[4].price)
     {
      diffSell = bhrsiChangesForSell("UP", min, max);
     }
   else
      if(ask < previousDOM[4].price)
        {
         diffSell = bhrsiChangesForSell("DOWN", min, max);
        }
      else
        {
         diffSell = (currentDOM[4].volume - previousDOM[4].volume);
        }


   int start=prev_calculated-1;

   if(prev_calculated>0)
     {
      SumList[0] = diffBuy - diffSell;

      if(candlestickCounter==0)
        {
         float    sum_pos=0.0;
         float    sum_neg=0.0;

         for(int j=0; j<BhrsiPeriod; j++)
           {
            sum_pos+=(SumList[j]>0?SumList[j]:0);
            sum_neg+=(SumList[j]<0?-SumList[j]:0);
           }

         averagePositive=sum_pos/BhrsiPeriod;
         averageNegative=sum_neg/BhrsiPeriod;

         if(averageNegative!=0.0)
            BHRSICloseBuffer[start]=100.0-(100.0/(1.0+averagePositive/averageNegative));
         else
           {
            if(averagePositive!=0.0)
               BHRSICloseBuffer[start]=100.0;
            else
               BHRSICloseBuffer[start]=50.0;
           }

         if(BHRSICloseBuffer[start]>BHRSIHighBuffer[start])
            BHRSIHighBuffer[start]=BHRSICloseBuffer[start];

         if(BHRSICloseBuffer[start]<BHRSILowBuffer[start])
            BHRSILowBuffer[start]=BHRSICloseBuffer[start];


        }
      else
        {
         for(int i=start; i<rates_total && !IsStopped(); i++)
           {
            double diff=SumList[0];
            averagePositive=(averagePositive*(BhrsiPeriod-1)+(diff>0.0?diff:0.0))/BhrsiPeriod;
            averageNegative=(averageNegative*(BhrsiPeriod-1)+(diff<0.0?-diff:0.0))/BhrsiPeriod;
            if(averageNegative!=0.0)
               BHRSICloseBuffer[i]=100.0-100.0/(1+averagePositive/averageNegative);
            else
              {
               if(averagePositive!=0.0)
                  BHRSICloseBuffer[i]=100.0;
               else
                  BHRSICloseBuffer[i]=50.0;
              }
           }

         if(BHRSICloseBuffer[start]>BHRSIHighBuffer[start])
            BHRSIHighBuffer[start]=BHRSICloseBuffer[start];

         if(BHRSICloseBuffer[start]<BHRSILowBuffer[start])
            BHRSILowBuffer[start]=BHRSICloseBuffer[start];
        }

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void bhrsiTotalCalculation()
  {
   float diffBuy;
   float diffSell;
   int result[2]; // result[0]-> min   , result[1]-> max
   int min, max;
   int prev_calculated = BarsCalculated(handle);

   int rates_total = Bars(_Symbol,PERIOD_M1);

   double bid = currentDOM[5].price;
   double ask = currentDOM[4].price;

   findCommonRange(result);
   min = result[0];
   max = result[1];

   float totalNewBuy =
      setRangeValueVolume(currentDOM[5].price, currentDOM[5].volume, min, max) +
      setRangeValueVolume(currentDOM[6].price, currentDOM[6].volume, min, max) +
      setRangeValueVolume(currentDOM[7].price, currentDOM[7].volume, min, max) +
      setRangeValueVolume(currentDOM[8].price, currentDOM[8].volume, min, max) +
      setRangeValueVolume(currentDOM[9].price, currentDOM[9].volume, min, max);
   float totalOldBuy =
      setRangeValueVolume(previousDOM[5].price, previousDOM[5].volume, min, max) +
      setRangeValueVolume(previousDOM[6].price, previousDOM[6].volume, min, max) +
      setRangeValueVolume(previousDOM[7].price, previousDOM[7].volume, min, max) +
      setRangeValueVolume(previousDOM[8].price, previousDOM[8].volume, min, max) +
      setRangeValueVolume(previousDOM[9].price, previousDOM[9].volume, min, max);
   float diffTotalBuy = totalNewBuy - totalOldBuy;

   float totalNewSell =
      setRangeValueVolume(currentDOM[4].price, currentDOM[4].volume, min, max) +
      setRangeValueVolume(currentDOM[3].price, currentDOM[3].volume, min, max) +
      setRangeValueVolume(currentDOM[2].price, currentDOM[2].volume, min, max) +
      setRangeValueVolume(currentDOM[1].price, currentDOM[1].volume, min, max) +
      setRangeValueVolume(currentDOM[0].price, currentDOM[0].volume, min, max);
   float totalOldSell =
      setRangeValueVolume(previousDOM[4].price, previousDOM[4].volume, min, max) +
      setRangeValueVolume(previousDOM[3].price, previousDOM[3].volume, min, max) +
      setRangeValueVolume(previousDOM[2].price, previousDOM[2].volume, min, max) +
      setRangeValueVolume(previousDOM[1].price, previousDOM[1].volume, min, max) +
      setRangeValueVolume(previousDOM[0].price, previousDOM[0].volume, min, max);
   float diffTotalSell = totalNewSell - totalOldSell;


   int start=prev_calculated-1;

   if(prev_calculated>0)
     {
      SumListTotal[0] = diffTotalBuy - diffTotalSell;

      if(candlestickCounter==0)
        {
         float    sum_pos=0.0;
         float    sum_neg=0.0;

         for(int j=0; j<BhrsiPeriod; j++)
           {
            sum_pos+=(SumListTotal[j]>0?SumListTotal[j]:0);
            sum_neg+=(SumListTotal[j]<0?-SumListTotal[j]:0);
           }

         averagePositiveForBhrsiTotal=sum_pos/BhrsiPeriod;
         averageNegativeForBhrsiTotal=sum_neg/BhrsiPeriod;

         if(averageNegativeForBhrsiTotal!=0.0)
            BHRSITOTALBuffer[start]=100.0-(100.0/(1.0+averagePositiveForBhrsiTotal/averageNegativeForBhrsiTotal));
         else
           {
            if(averagePositiveForBhrsiTotal!=0.0)
               BHRSITOTALBuffer[start]=100.0;
            else
               BHRSITOTALBuffer[start]=50.0;
           }

         //if(BHRSITOTALBuffer[start]>BHRSIHighBuffer[start])
         //   BHRSIHighBuffer[start]=BHRSICloseBuffer[start];

         //if(BHRSICloseBuffer[start]<BHRSILowBuffer[start])
         //   BHRSILowBuffer[start]=BHRSICloseBuffer[start];


        }
      else
        {
         for(int i=start; i<rates_total && !IsStopped(); i++)
           {
            double diff=SumListTotal[0];
            averagePositiveForBhrsiTotal=(averagePositiveForBhrsiTotal*(BhrsiPeriod-1)+(diff>0.0?diff:0.0))/BhrsiPeriod;
            averageNegativeForBhrsiTotal=(averageNegativeForBhrsiTotal*(BhrsiPeriod-1)+(diff<0.0?-diff:0.0))/BhrsiPeriod;
            if(averageNegative!=0.0)
               BHRSITOTALBuffer[i]=100.0-100.0/(1+averagePositiveForBhrsiTotal/averageNegativeForBhrsiTotal);
            else
              {
               if(averagePositive!=0.0)
                  BHRSITOTALBuffer[i]=100.0;
               else
                  BHRSITOTALBuffer[i]=50.0;
              }
           }

         //if(BHRSICloseBuffer[start]>BHRSIHighBuffer[start])
         //   BHRSIHighBuffer[start]=BHRSICloseBuffer[start];

         //if(BHRSICloseBuffer[start]<BHRSILowBuffer[start])
         //   BHRSILowBuffer[start]=BHRSICloseBuffer[start];
        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float bhrsiChangesForBuy(string priceDirection, int min, int max)
  {
   float volume = 0;

// BUY
   for(int i=5; i<10; i++)
     {
      if(priceDirection == "UP")
        {
         if(currentDOM[i].price > previousDOM[5].price)
           {
            volume += setRangeValueVolume(currentDOM[i].price, currentDOM[i].volume, min, max);
           }
         else
            if(currentDOM[i].price == previousDOM[5].price)
              {
               float vol1 = setRangeValueVolume(currentDOM[i].price, currentDOM[i].volume, min, max);
               float vol2 = setRangeValueVolume(previousDOM[5].price, previousDOM[5].volume, min, max);
               volume += (vol1 - vol2);
               break;
              }
            else
              {
               volume -= setRangeValueVolume(previousDOM[5].price, previousDOM[5].volume, min, max); // volume += (0 - previousDOM[5].volume);
               break;
              }
        }
      else
        {
         if(currentDOM[5].price < previousDOM[i].price)
           {
            volume -= setRangeValueVolume(previousDOM[i].price, previousDOM[i].volume, min, max);
           }
         else
            if(currentDOM[5].price == previousDOM[i].price)
              {
               float vol1 = setRangeValueVolume(currentDOM[5].price, currentDOM[5].volume, min, max);
               float vol2 = setRangeValueVolume(previousDOM[i].price, previousDOM[i].volume, min, max);
               volume += (vol1 - vol2);
               break;
              }
            else
              {
               volume += setRangeValueVolume(currentDOM[5].price, currentDOM[5].volume, min, max); // volume += (0 - oldItems[i][1]);
               break;
              }
        }
     }

   return volume;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float bhrsiChangesForSell(string priceDirection, int min, int max)
  {
   float volume = 0;

// TODO: This loop should be 5 for MofidOnline
   for(int i = 4; i >= 0; i--)
     {
      if(priceDirection == "UP")
        {
         if(currentDOM[4].price > previousDOM[i].price)
           {
            volume -= setRangeValueVolume(previousDOM[i].price, previousDOM[i].volume, min, max);
           }
         else
            if(currentDOM[4].price == previousDOM[i].price)
              {
               float vol1 = setRangeValueVolume(currentDOM[4].price, currentDOM[4].volume, min, max);
               float vol2 = setRangeValueVolume(previousDOM[i].price, previousDOM[i].volume, min, max);
               volume += (vol1 - vol2);
               break;
              }
            else
              {
               volume += setRangeValueVolume(currentDOM[4].price, currentDOM[4].volume, min, max);
               break;
              }
        }
      else
        {
         if(currentDOM[i].price < previousDOM[4].price)
           {
            volume += setRangeValueVolume(currentDOM[i].price, currentDOM[i].volume, min, max);
           }
         else
            if(currentDOM[i].price == previousDOM[4].price)
              {
               float vol1 = setRangeValueVolume(currentDOM[i].price, currentDOM[i].volume, min, max);
               float vol2 = setRangeValueVolume(previousDOM[4].price, previousDOM[4].volume, min, max);
               volume += (vol1 - vol2);
               break;
              }
            else
              {
               volume -= setRangeValueVolume(previousDOM[4].price, previousDOM[4].volume, min, max); //volume += (0 - oldItems[4][1]);
               break;
              }
        }
     }

   return volume;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float setRangeValueVolume(float queuePriceValue,float queueVolumeValue, int min, int max)
  {
   return (queuePriceValue >= min && queuePriceValue <= max)? queueVolumeValue : 0;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void findInclusiveRange(float newBid, float oldBid, float newAsk, float oldAsk, int &result[])
  {

   float firstMin = newBid;
   float lastMin = oldBid ? oldBid : newBid;

   float firstMax = newAsk;
   float lastMax = oldAsk ? oldAsk : newAsk;

   int min = (int) MathMin(firstMin, lastMin);
   int max = (int) MathMax(firstMax, lastMax);

   result[0] = min;
   result[1] = max;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void findCommonRange(int &result[])
  {
   float firstMin = currentDOM[9].price;
   float lastMin = previousDOM[9].price? previousDOM[9].price: currentDOM[9].price;

   float firstMax = currentDOM[0].price;
   float lastMax = previousDOM[0].price? previousDOM[0].price: currentDOM[0].price;


   int min = (int) MathMin(firstMax, lastMax);
   int max = (int) MathMax(firstMin, lastMin);

   result[0] = min;
   result[1] = max;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
