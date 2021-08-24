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
#property indicator_color1  clrYellow,clrRed, clrGreen
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
double         BHRSICloseBuffer[];  // Indicator buffer for holding BHRSI close value
double         BHRSIHighBuffer[];   // Indicator buffer for holding BHRSI high value
double         BHRSILowBuffer[];    // Indicator buffer for holding BHRSI low value
double         BHRSIOpenBuffer[];   // Indicator buffer for holding BHRSI open value
double         BHRSITOTALBuffer[];  // Indicator buffer for holding BHRSI Total value
// Custom variables
MqlBookInfo  previousDOM[];         // This variable holds previous values of Depth Of Market
MqlBookInfo  currentDOM[];          /*
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

double       SumList[];             // This variable holds the algebraic sum of the volumes for the first row
double       SumListTotal[];        // This variable holds the algebraic sum of the values of the volumes  for the all rows
int          candlestickCounter=0;  // Counter for counting number of candlesticks pushed in every time frame
float        averagePositive;       // Variable to keep the average of the available positive values in SumList
float        averageNegative;       // Variable to keep the average of the available negative values in SumList
float        averagePositiveForBhrsiTotal;   // Variable to keep the average of the available positive values in SumListTotal
float        averageNegativeForBhrsiTotal;   // Variable to keep the average of the available negative values in SumListTotal
int          handle;                // This is an indicator handle that we used for the BarsCalculated function
int          previous_calculated;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("BHRSI OnInit");

   /* indicator buffers mapping*/
   SetIndexBuffer(0,BHRSICloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,BHRSIHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,BHRSILowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,BHRSIOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,BHRSITOTALBuffer,INDICATOR_DATA);

   /* Set the size of SumList and SumListTotal to the size of the period*/
   ArrayResize(SumList, BhrsiPeriod);
   ArrayResize(SumListTotal, BhrsiTotalPeriod);

   
   /* The following function is used to activate the OnTimer function and its argument is based on seconds*/
   // EventSetTimer(1);

   /*
    ChartSetSymbolPeriod(0, _Symbol,PERIOD_M1);
    ChartIndicatorDelete(0, 0, "PersianCalendar");
   */

   /* Returns a structure array MqlBookInfo containing records of the Depth of Market of a specified symbol.*/
   bool previousDOMBool = MarketBookGet(NULL,previousDOM);

   string short_name=StringFormat("BHRSI(%d) - BHRSI Total(%d)",BhrsiPeriod,BhrsiTotalPeriod);
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
//Print("OnCalculate");
   previous_calculated = prev_calculated;

   /*
   When the OnCalculate function is called for the first time, the values of all candlesticks
   change to 50 (the power of buyers and sellers is equal), and after then, whenever
   the difference of rates_total and prev_calculated grater than 1 then candlesticks  values changes to 50
   */
   if((rates_total-prev_calculated)>1)
     {
      for(int i=prev_calculated; i<rates_total; i++)
        {
         BHRSICloseBuffer[i]=50;
         BHRSIHighBuffer[i]=50;
         BHRSILowBuffer[i]=50;
         BHRSIOpenBuffer[i]=50;

         BHRSITOTALBuffer[i]=50;
        }
     }

   bhrsiCalculation();  // Calcualte BHRSI for draw candlestick in chart
   bhrsiTotalCalculation();   // Calcualte BHRSI total draw line in chart

   /* Whenever the new candle is pushed in the buffer then BHRSI close value is moved to BHRSI open value  */
   if(prev_calculated != 0 && rates_total != prev_calculated)
     {
      BHRSIOpenBuffer[prev_calculated]=BHRSICloseBuffer[prev_calculated];
      //BHRSICloseBuffer[prev_calculated] = 50;
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

   /* Check if the last index of BHRSI open value is equal to zero then moved BHRSI close value to BHRSI open value*/
   if(BHRSIOpenBuffer[ArraySize(BHRSIOpenBuffer)-1]==0)
      BHRSIOpenBuffer[ArraySize(BHRSIOpenBuffer)-1]=BHRSICloseBuffer[ArraySize(BHRSICloseBuffer)-2];

   /* Below code used for shifting the last index of the SumList array */
   int count = ArraySize(SumList);
   if(ArrayCopy(SumList, SumList, 1, 0, count - 1) == count - 1)
      SumList[0] = 0;

   /* Below code used for shifting the last index of the SumList array */
   count = ArraySize(SumListTotal);
   if(ArrayCopy(SumListTotal, SumListTotal, 1, 0, count - 1) == count - 1)
      SumListTotal[0] = 0;

   bhrsiCalculation();        // Calcualte BHRSI for draw candlestick in chart
   bhrsiTotalCalculation();   // Calcualte BHRSI total draw line in chart

   /* At the end of the OnTimer function, we update the previous variable of the DOM */
   if(ArraySize(currentDOM)!=0)
     {
      Print("update previousDOM");
      ArrayCopy(previousDOM,currentDOM,0,0,WHOLE_ARRAY);
     }

   candlestickCounter++;

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
//| OnDeinit function                                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();

//--- close the DOM
   if(!MarketBookRelease(_Symbol))
      Print("Failed to close the DOM!");
  }
//+------------------------------------------------------------------+
//| OnBookEvent function                                             |
//+------------------------------------------------------------------+
void OnBookEvent(const string& symbol)
  {

   if(symbol==_Symbol)
     {
      bhrsiCalculation();        // Calcualte BHRSI for draw candlestick in chart
      bhrsiTotalCalculation();  // Calcualte BHRSI total draw line in chart

      //--- array of the DOM structures
      // MqlBookInfo last_bookArray[];

      // --- get the book
      // if(MarketBookGet(_Symbol,last_bookArray))
      //  {
      //--- process book data
      //   for(int idx=0; idx<ArraySize(last_bookArray); idx++)
      //     {
      //      MqlBookInfo curr_info=last_bookArray[idx];
      //--- print
      //      PrintFormat("Type: %s",EnumToString(curr_info.type));
      //      PrintFormat("Price: %0."+IntegerToString(_Digits)+"f",curr_info.price);
      //      PrintFormat("Volume: %d",curr_info.volume);
      //     }
      //  }
     }

  }
//+------------------------------------------------------------------+
//|  This function used for calculating BHRSI                        |
//+------------------------------------------------------------------+
void bhrsiCalculation()
  {
   float diffBuy;    // Keep the difference between current bid volume and previous bid volume
   float diffSell;   // Keep the difference between current ask volume and previous ask volume
   int result[2];    // result[0]-> min   , result[1]-> max
   int min, max;     // The minimum and maximum are obtained using the findInclusiveRange function and are used to calculate diffBuy and diffSell.
   int prev_calculated = BarsCalculated(handle);   // Returns the number of calculated data in an indicator buffer or -1 in the case of error (data hasn't been calculated yet)
   int rates_total = Bars(_Symbol,PERIOD_M1);      // Returns the number of bars for a specified symbol and period

   prev_calculated = previous_calculated;

   bool getDOM=MarketBookGet(NULL,currentDOM);
   if(getDOM && ArraySize(currentDOM)!=0 && ArraySize(previousDOM) != 0)
     {
      double bid = currentDOM[5].price;
      double ask = currentDOM[4].price;

      /* Find min and max for calculating diffBuy and diffSell */
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

      /* If the number of calculated data is greater than zero then calculate BHRSI*/
      if(prev_calculated>0)
        {
         /* We put the algebraic sum of the volume of buyers and sellers in SumList */
         SumList[0] = diffBuy - diffSell;
         Print("SumList[0]: ", SumList[0]);

         /*
         If we have only one candle, we use the following equations
            - First Average Gain = Sum of Gains over the past BhrsiPeriod / BhrsiPeriod.
            - First Average Loss = Sum of Losses over the past BhrsiPeriod / BhrsiPeriod
         If we have more than one candle, we use the following equations
            - Average Gain = [(previous Average Gain) x (BhrsiPeriod - 1) + current Gain] / BhrsiPeriod.
            - Average Loss = [(previous Average Loss) x (BhrsiPeriod - 1) + current Loss] / BhrsiPeriod.
         */
         if(candlestickCounter==0)
           {
            float  sum_pos=0.0;
            float  sum_neg=0.0;

            for(int j=0; j<BhrsiPeriod; j++)
              {
               sum_pos+=(SumList[j]>0?SumList[j]:0);
               sum_neg+=(SumList[j]<0?-SumList[j]:0);
              }

            averagePositive=sum_pos/BhrsiPeriod;
            averageNegative=sum_neg/BhrsiPeriod;

            /*
            We used the below equations for calculating BHRSI:
                           100
             BHRSI = 100 - --------
                          1 + RS

             RS = Average Positive / Average Negative
            */

            if(averageNegative!=0.0)
               BHRSICloseBuffer[start]=100.0-(100.0/(1.0+averagePositive/averageNegative));
            else
              {
               /* If all SumList values are positive, BHRSICloseBuffer is equal to 100 and if all of them are negative, BHRSICloseBuffer is equal to 0 */
               if(averagePositive!=0.0)
                  BHRSICloseBuffer[start]=100.0;
               else
                  BHRSICloseBuffer[start]=50.0;
              }

            /* Update BHRSIHighBuffer when the last value of BHRSICloseBuffer is greater than the last value of BHRSIHighBuffer */
            if(BHRSICloseBuffer[start]>BHRSIHighBuffer[start])
               BHRSIHighBuffer[start]=BHRSICloseBuffer[start];

            /* Update BHRSILowBuffer when the last value of BHRSICloseBuffer is lower than the last value of BHRSILowBuffer */
            if(BHRSICloseBuffer[start]<BHRSILowBuffer[start])
               BHRSILowBuffer[start]=BHRSICloseBuffer[start];

           }
         else
           {
            for(int i=start; i<rates_total && !IsStopped(); i++)
              {
               double diff=SumList[0];

               /*
               - Average Gain = [(previous Average Gain) x (BhrsiPeriod - 1) + current Gain] / BhrsiPeriod.
               - Average Loss = [(previous Average Loss) x (BhrsiPeriod - 1) + current Loss] / BhrsiPeriod.
               */
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

            Print("BHRSICloseBuffer: ", BHRSICloseBuffer[rates_total-1]);

            if(BHRSICloseBuffer[start]>BHRSIHighBuffer[start])
               BHRSIHighBuffer[start]=BHRSICloseBuffer[start];

            if(BHRSICloseBuffer[start]<BHRSILowBuffer[start])
               BHRSILowBuffer[start]=BHRSICloseBuffer[start];
           }

        }
     }

  }

//+------------------------------------------------------------------+
//| This function used for calculating BHRSI Total                   |
//+------------------------------------------------------------------+
void bhrsiTotalCalculation()
  {
   float diffTotalBuy;  // Keep the difference between current buyers volumes and previous buyers volumes
   float diffTotalSell; // Keep the difference between current sellers volumes and previous sellers volumes
   int result[2];       // result[0]-> min   , result[1]-> max
   int min, max;        // The minimum and maximum are obtained using the findCommonRange function and are used to calculate diffTotalBuy and diffTotalSell.
   int prev_calculated = BarsCalculated(handle);   // Returns the number of calculated data in an indicator buffer or -1 in the case of error (data hasn't been calculated yet)
   int rates_total = Bars(_Symbol,PERIOD_M1);      // Returns the number of bars for a specified symbol and period

   prev_calculated = previous_calculated;

   bool getDOM=MarketBookGet(NULL,currentDOM);
   if(getDOM && ArraySize(currentDOM)!=0 && ArraySize(previousDOM) != 0)
     {
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
      diffTotalBuy = totalNewBuy - totalOldBuy;

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
      diffTotalSell = totalNewSell - totalOldSell;


      int start=prev_calculated-1;

      /* If the number of calculated data is greater than zero then calculate BHRSI*/
      if(prev_calculated>0)
        {
         /* We put the algebraic sum of the volume of buyers and sellers in SumListTotal */
         SumListTotal[0] = diffTotalBuy - diffTotalSell;

         /*
         If we have only one candle, we use the following equations
            - First Average Gain = Sum of Gains over the past BhrsiPeriod / BhrsiPeriod.
            - First Average Loss = Sum of Losses over the past BhrsiPeriod / BhrsiPeriod
         If we have more than one candle, we use the following equations
            - Average Gain = [(previous Average Gain) x (BhrsiPeriod - 1) + current Gain] / BhrsiPeriod.
            - Average Loss = [(previous Average Loss) x (BhrsiPeriod - 1) + current Loss] / BhrsiPeriod.
         */
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

           }
         else
           {
            for(int i=start; i<rates_total && !IsStopped(); i++)
              {
               double diff=SumListTotal[0];

               /*
               - Average Gain = [(previous Average Gain) x (BhrsiPeriod - 1) + current Gain] / BhrsiPeriod.
               - Average Loss = [(previous Average Loss) x (BhrsiPeriod - 1) + current Loss] / BhrsiPeriod.
               */
               averagePositiveForBhrsiTotal=(averagePositiveForBhrsiTotal*(BhrsiPeriod-1)+(diff>0.0?diff:0.0))/BhrsiPeriod;
               averageNegativeForBhrsiTotal=(averageNegativeForBhrsiTotal*(BhrsiPeriod-1)+(diff<0.0?-diff:0.0))/BhrsiPeriod;
               if(averageNegativeForBhrsiTotal!=0.0)
                  BHRSITOTALBuffer[i]=100.0-100.0/(1+averagePositiveForBhrsiTotal/averageNegativeForBhrsiTotal);
               else
                 {
                  if(averageNegativeForBhrsiTotal!=0.0)
                     BHRSITOTALBuffer[i]=100.0;
                  else
                     BHRSITOTALBuffer[i]=50.0;
                 }
              }

            Print("BHRSITOTALBuffer: ", BHRSITOTALBuffer[rates_total-1], "   BHRSICloseBuffer: ", BHRSICloseBuffer[rates_total-1], "  Avg: ", MathCeil((BHRSICloseBuffer[rates_total-1]+BHRSITOTALBuffer[rates_total-1])/2));
           }

         candlestickCounter++;

        }
     }
  }
//+------------------------------------------------------------------+
//|   bhrsiChangesForBuy function                                    |
//+------------------------------------------------------------------+
float bhrsiChangesForBuy(string priceDirection, int min, int max)
  {
   float volume = 0;

   /**
      1) Price goes up
          1) Iterate on new items
          2) Calculate summation of added items
          3) Difference between new and old headline
          4) Sum step2 and step3 values
     2) Price goes down
          1) Iterate on old items
          2) Calculate summation of added items and then negative it
          3) Difference between new and old headline
          4) Sum step2 and step3 values
   */

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

   /*  1) Price goes up
         1) Iterate on new items
         2) Calculate summation of added items and then negative it
         3) Difference between new and old headline
         4) Sum step2 and step3 values
       2) Price goes down
         1) Iterate on old items
         2) Calculate summation of added items
         3) Difference between new and old headline
         4) Sum step2 and step3 values
   */
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
//| Function that check if a value is between selected range or not  |
//| and if not then return 0                                         |
//+------------------------------------------------------------------+
float setRangeValueVolume(float queuePriceValue,float queueVolumeValue, int min, int max)
  {
   return (queuePriceValue >= min && queuePriceValue <= max)? queueVolumeValue : 0;
  }


//+------------------------------------------------------------------+
//|  Function that find inclusive range between new and old queue    |
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
//| Function that find common range between new and old queue        |
//+------------------------------------------------------------------+
void findCommonRange(int &result[])
  {
   float firstMin = currentDOM[9].price;
   float lastMin = previousDOM[9].price? previousDOM[9].price: currentDOM[9].price;

   float firstMax = currentDOM[0].price;
   float lastMax = previousDOM[0].price? previousDOM[0].price: currentDOM[0].price;


   int min = (int) MathMax(firstMin, lastMin);
   int max = (int) MathMin(firstMax, lastMax);

   result[0] = min;
   result[1] = max;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
