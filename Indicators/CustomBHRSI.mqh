//+------------------------------------------------------------------+
//|                                                  CustomBHRSI.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <indicators/custom.mqh>
#include <MqlParams.mqh>
#include <Arrays\ArrayFloat.mqh>
#include <../Shared Projects/BourseOnSteroid/Include/Trade/MarketBook.mqh>
//#include "BHRSI.mq5";
//#include "BufferStruct.mqh";

#define INDICATOR_NAME "\Indicators\Shared Projects\BourseOnSteroid\Indicators\BHRSI"
//#define INDICATOR_NAME "..\Shared Projects\BourseOnSteroid\Indicators\CustomBHRSI"
#define INITIAL_BUFFER_SIZE 2048

class BufferSet
{
   private:
      double            BHRSICloseBuffer[];  // Indicator buffer for holding BHRSI close value
      double            BHRSIHighBuffer[];   // Indicator buffer for holding BHRSI high value
      double            BHRSILowBuffer[];    // Indicator buffer for holding BHRSI low value
      double            BHRSIOpenBuffer[];   // Indicator buffer for holding BHRSI open value
      double            BHRSITOTALBuffer[];  // Indicator buffer for holding BHRSI Total value
   public:
      void              Set(double &b);
       
};

void BufferSet::Set(double &b)
{
   //this.BHRSICloseBuffer = b;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CustomBHRSI : public CiCustom
  {
private:
   //--- input parameters
   int               BhrsiThreshold;         // BHRSI Threshold
   int               BhrsiTotalThreshold;    // BHRSI Total Threshold
   int               BhrsiPeriod;            // BHRSI Period
   int               BhrsiTotalPeriod;       // BHRSI Total Period
   //--- indicator buffers
   double            BHRSICloseBuffer[];  // Indicator buffer for holding BHRSI close value
   double            BHRSIHighBuffer[];   // Indicator buffer for holding BHRSI high value
   double            BHRSILowBuffer[];    // Indicator buffer for holding BHRSI low value
   double            BHRSIOpenBuffer[];   // Indicator buffer for holding BHRSI open value
   double            BHRSITOTALBuffer[];  // Indicator buffer for holding BHRSI Total value
   
   //Buffers buffers;
   // Custom variables
   MqlBookInfo       previousDOM[];         // This variable holds previous values of Depth Of Market
   MqlBookInfo       currentDOM[];          /*
                                       This variable holds current values of Depth Of Market

                                       CurrentDOM: [0] -> The fifth line of sellers
                                                   [1] -> The fourth line of sellers
                                                   [2] -> The third line of sellers
                                                   [3] -> The second line of sellers
                                                   [best_ask] -> The first line of sellers(ASK)
                                                   [best_bid] -> The first line of buyers(BID)
                                                   [6] -> The second line of buyers
                                                   [7] -> The third line of buyers
                                                   [8] -> The fourth line of buyers
                                                   [9] -> The fifth line of buyers
                                    */

   double            SumList[];             // This variable holds the algebraic sum of the volumes for the first row
   double            SumListTotal[];        // This variable holds the algebraic sum of the values of the volumes  for the all rows
   int               candlestickCounter;  // Counter for counting number of candlesticks pushed in every time frame
   float             averagePositive;       // Variable to keep the average of the available positive values in SumList
   float             averageNegative;       // Variable to keep the average of the available negative values in SumList
   float             averagePositiveForBhrsiTotal;   // Variable to keep the average of the available positive values in SumListTotal
   float             averageNegativeForBhrsiTotal;   // Variable to keep the average of the available negative values in SumListTotal
   int               handle;                // This is an indicator handle that we used for the BarsCalculated function
   int               previous_calculated;
   int               previous_best_bid_index, previous_last_bid_index, previous_best_ask_index, previous_last_ask_index;
   CMarketBook       Book;         // Initialize class with current instrument


protected:
   virtual bool      Initialize(const string symbol,
                                const ENUM_TIMEFRAMES period,
                                const int num_params,
                                const MqlParam &params[]
                               ) override;

public:
   void              InitializeVariables(const int BhrsiThreshold,
                                         const int BhrsiTotalThreshold,
                                         const int BhrsiPeriod,
                                         const int BhrsiTotalPeriod);

   virtual bool      Create(string symbol,
                            ENUM_TIMEFRAMES period,
                            int numberOfParams,
                            MqlParam &params[]
                           );
                           
   virtual double    GetBHRSICloseBuffer(int index) { return this.GetData(0, index);}
   virtual double    dnBuffer(int index) { return this.GetData(1, index); }

   //void              SetBuffers(Buffers &buffersTemp);
   int               DoOnInit(double &buffer1[], 
                             double &buffer2[],
                             double &buffer3[],
                             double &buffer4[],
                             double &buffer5[]);
   int               DoOnInit(int BhrsiPeriod, int BhrsiTotalPeriod, int BhrsiThreshold, int BhrsiTotalThreshold);
                                                    
   void              DoOnTimer();
   void              bhrsiCalculation();
   void              bhrsiTotalCalculation();
   float             bhrsiChangesForBuy(string priceDirection, int min, int max);
   float             bhrsiChangesForSell(string priceDirection, int min, int max);
   float             setRangeValueVolume(float queuePriceValue,float queueVolumeValue, int min, int max);
   void              findInclusiveRange(float newBid, float oldBid, float newAsk, float oldAsk, int &result[]);
   void              findCommonRange(int &result[]);
   int               DoOnCalculate(const int rates_total,
                               const int prev_calculated,
                               const datetime &time[],
                               const double &open[],
                               const double &high[],
                               const double &low[],
                               const double &close[],
                               const long &tick_volume[],
                               const long &volume[],
                               const int &spread[]);
  };

 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CustomBHRSI::Create(string symbol,
                         ENUM_TIMEFRAMES tf,
                         int numberOfParams,
                         MqlParam &params[]
                        )
  {
   this.BhrsiThreshold = params[1].integer_value;
   this.BhrsiTotalThreshold = params[2].integer_value;
   this.BhrsiPeriod = params[3].integer_value;
   this.BhrsiTotalPeriod = params[4].integer_value;
   
// #2 Call the parent Create method with the params
   if(!CiCustom::Create(symbol, tf, IND_CUSTOM, numberOfParams, params))
      return false;
// #3 Resize the buffer to the desired initial size
   if(!this.BufferResize(INITIAL_BUFFER_SIZE))
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CustomBHRSI::Initialize(const string symbol,
                             const ENUM_TIMEFRAMES period,
                             const int num_params,
                             const MqlParam &params[]
                            )
  {
// #1 Specify if this indicator redraws
   this.Redrawer(true);
// #2 Specify the number of indicator buffers to be used.
   if(!this.NumBuffers(5))
      return false;
// #3 Call super.Initialize
   if(!CiCustom::Initialize(symbol, period, num_params, params))
      return false;
   return true;
  }
  
//+------------------------------------------------------------------+
//void CustomBHRSI::SetBuffers(Buffers &buffersTemp)
//{
   //Buffers buffers = GetPointer(buffersTemp);
   //Print("");
//}
//+------------------------------------------------------------------+
int CustomBHRSI::DoOnInit(double &buffer1[], 
                          double &buffer2[],
                          double &buffer3[],
                          double &buffer4[],
                          double &buffer5[])
  {
   Print("CustomBHRSI OnInit");
   
   //this.BHRSICloseBuffer = buffer1;
   
   
   /* Set the size of SumList and SumListTotal to the size of the period*/
   ArrayResize(this.SumList, this.BhrsiPeriod);
   ArrayResize(this.SumListTotal, this.BhrsiTotalPeriod);


   /* The following function is used to activate the OnTimer function and its argument is based on seconds*/
// EventSetTimer(1);

   /*
    ChartSetSymbolPeriod(0, _Symbol,PERIOD_M1);
    ChartIndicatorDelete(0, 0, "PersianCalendar");
   */

   /* Returns a structure array MqlBookInfo containing records of the Depth of Market of a specified symbol.*/
   bool previousDOMBool = MarketBookGet(NULL,this.previousDOM);


//---
   return(INIT_SUCCEEDED);
  }
 //+------------------------------------------------------------------+
 
  int CustomBHRSI::DoOnInit(int BhrsiPeriod, int BhrsiTotalPeriod, int BhrsiThreshold, int BhrsiTotalThreshold)
  {
   Print("CustomBHRSI OnInit");

   this.BhrsiPeriod = BhrsiPeriod;
   this.BhrsiTotalPeriod = BhrsiTotalPeriod;
   this.BhrsiThreshold = BhrsiThreshold;
   this.BhrsiTotalThreshold = BhrsiTotalThreshold;
   
   /* Set the size of SumList and SumListTotal to the size of the period*/
   ArrayResize(this.SumList, this.BhrsiPeriod);
   ArrayResize(this.SumListTotal, this.BhrsiTotalPeriod);


   /* The following function is used to activate the OnTimer function and its argument is based on seconds*/
// EventSetTimer(1);

   /*
    ChartSetSymbolPeriod(0, _Symbol,PERIOD_M1);
    ChartIndicatorDelete(0, 0, "PersianCalendar");
   */

   /* Returns a structure array MqlBookInfo containing records of the Depth of Market of a specified symbol.*/
   bool previousDOMBool = MarketBookGet(NULL,this.previousDOM);


//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int CustomBHRSI::DoOnCalculate(const int rates_total,
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
void CustomBHRSI::DoOnTimer()
  {
//---
   Print("OnTimer");
   bool previousDOMBool = MarketBookGet(NULL,this.previousDOM);

   /* Check if the last index of BHRSI open value is equal to zero then moved BHRSI close value to BHRSI open value*/
   if(GetBHRSICloseBuffer(0)==0 )
      BHRSIOpenBuffer[ArraySize(BHRSIOpenBuffer)-1]=BHRSICloseBuffer[ArraySize(BHRSICloseBuffer)-2];

   /* Below code used for shifting the last index of the SumList array */
   int count = ArraySize(SumList);
   if(ArrayCopy(SumList, SumList, 1, 0, count - 1) == count - 1)
      SumList[0] = 0;
   
   
   /* Below code used for shifting the last index of the SumList array */
   count = ArraySize(this.SumListTotal);
   if(ArrayCopy(this.SumListTotal, this.SumListTotal, 1, 0, count - 1) == count - 1)
      SumListTotal[0] = 0;

   bhrsiCalculation();        // Calcualte BHRSI for draw candlestick in chart
   bhrsiTotalCalculation();   // Calcualte BHRSI total draw line in chart

   /* At the end of the OnTimer function, we update the previous variable of the DOM */
   if(ArraySize(currentDOM)!=0)
     {
      int best_ask = (int)Book.InfoGetInteger(MBOOK_BEST_ASK_INDEX);    // Get index of best Ask price
      int best_bid = (int)Book.InfoGetInteger(MBOOK_BEST_BID_INDEX);    // Get index of best Bid price
      int last_ask = (int)Book.InfoGetInteger(MBOOK_LAST_ASK_INDEX);    // Get index of best Ask price
      int last_bid = (int)Book.InfoGetInteger(MBOOK_LAST_BID_INDEX);    // Get index of best Bid price

      Print("update previousDOM");
      ArrayCopy(previousDOM,currentDOM,0,0,WHOLE_ARRAY);
      previous_best_ask_index = best_ask;
      previous_best_bid_index = best_bid;
      previous_last_ask_index = last_ask;
      previous_last_bid_index = last_bid;
     }

   candlestickCounter++;

  }
  
  //+------------------------------------------------------------------+
//|  This function used for calculating BHRSI                        |
//+------------------------------------------------------------------+
void CustomBHRSI::bhrsiCalculation()
  {
   float diffBuy;    // Keep the difference between current bid volume and previous bid volume
   float diffSell;   // Keep the difference between current ask volume and previous ask volume
   int result[2];    // result[0]-> min   , result[1]-> max
   int min, max;     // The minimum and maximum are obtained using the findInclusiveRange function and are used to calculate diffBuy and diffSell.
   int prev_calculated = BarsCalculated(handle);   // Returns the number of calculated data in an indicator buffer or -1 in the case of error (data hasn't been calculated yet)
   int rates_total = Bars(_Symbol,PERIOD_M1);      // Returns the number of bars for a specified symbol and period

   prev_calculated = previous_calculated;

   int best_ask = (int)Book.InfoGetInteger(MBOOK_BEST_ASK_INDEX);    // Get index of best Ask price
   int best_bid = (int)Book.InfoGetInteger(MBOOK_BEST_BID_INDEX);    // Get index of best Bid price

   bool getDOM=MarketBookGet(NULL,currentDOM);
   if(getDOM && ArraySize(currentDOM)!=0 && ArraySize(previousDOM) != 0)
     {
      double bid = currentDOM[best_bid].price;
      double ask = currentDOM[best_ask].price;

      /* Find min and max for calculating diffBuy and diffSell */
      findInclusiveRange(currentDOM[best_bid].price, previousDOM[previous_best_bid_index].price, currentDOM[best_ask].price, previousDOM[previous_best_ask_index].price, result);
      min = result[0];
      max = result[1];

      if(bid > previousDOM[previous_best_bid_index].price)
        {
         diffBuy = bhrsiChangesForBuy("UP", min, max);
        }
      else
         if(bid < previousDOM[previous_best_bid_index].price)
           {
            diffBuy = bhrsiChangesForBuy("DOWN", min, max);
           }
         else
           {
            diffBuy = (currentDOM[best_bid].volume - previousDOM[previous_best_bid_index].volume);
           }

      if(ask > previousDOM[previous_best_ask_index].price)
        {
         diffSell = bhrsiChangesForSell("UP", min, max);
        }
      else
         if(ask < previousDOM[previous_best_ask_index].price)
           {
            diffSell = bhrsiChangesForSell("DOWN", min, max);
           }
         else
           {
            diffSell = (currentDOM[best_ask].volume - previousDOM[previous_best_ask_index].volume);
           }


      int start=prev_calculated-1;

      /* If the number of calculated data is greater than zero then calculate BHRSI*/
      if(prev_calculated>0)
        {
         /* We put the algebraic sum of the volume of buyers and sellers in SumList */
         SumList[0] = diffBuy - diffSell;

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
void CustomBHRSI::bhrsiTotalCalculation()
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
      int best_ask = (int)Book.InfoGetInteger(MBOOK_BEST_ASK_INDEX);    // Get index of best Ask price
      int best_bid = (int)Book.InfoGetInteger(MBOOK_BEST_BID_INDEX);    // Get index of best Bid price
      int last_ask = (int)Book.InfoGetInteger(MBOOK_LAST_ASK_INDEX);    // Get index of best Ask price
      int last_bid = (int)Book.InfoGetInteger(MBOOK_LAST_BID_INDEX);    // Get index of best Bid price

      Print("best_ask: ", best_ask, "  best_bid: ", best_bid);
      Print("best_ask: ", best_ask, "  best_bid: ", best_bid);
      Print("best_ask: ", best_ask, "  best_bid: ", best_bid);
      Print("best_ask: ", best_ask, "  best_bid: ", best_bid);


      double bid = currentDOM[best_bid].price;
      double ask = currentDOM[best_ask].price;

      findCommonRange(result);
      min = result[0];
      max = result[1];

      float totalNewBuy = 0;
      for(int i=best_bid; i<=last_bid; i++)
        {
         totalNewBuy += setRangeValueVolume(currentDOM[i].price, currentDOM[i].volume, min, max);
        }

      float totalOldBuy = 0;
      for(int i=best_bid; i<=last_bid; i++)
        {
         totalOldBuy += setRangeValueVolume(previousDOM[i].price, previousDOM[i].volume, min, max);
        }

      diffTotalBuy = totalNewBuy - totalOldBuy;

      float totalNewSell = 0;
      for(int i=last_ask; i<=best_ask; i++)
        {
         totalNewSell += setRangeValueVolume(currentDOM[i].price, currentDOM[i].volume, min, max);
        }

      float totalOldSell = 0;
      for(int i=last_ask; i<=best_ask; i++)
        {
         totalOldSell += setRangeValueVolume(previousDOM[i].price, previousDOM[i].volume, min, max);
        }

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
float CustomBHRSI::bhrsiChangesForBuy(string priceDirection, int min, int max)
  {
   float volume = 0;

   int best_ask = (int)Book.InfoGetInteger(MBOOK_BEST_ASK_INDEX);    // Get index of best Ask price
   int best_bid = (int)Book.InfoGetInteger(MBOOK_BEST_BID_INDEX);    // Get index of best Bid price
   int last_bid = (int)Book.InfoGetInteger(MBOOK_LAST_BID_INDEX);    // Index of worst or last bid price

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
   for(int i=best_bid; i<last_bid; i++)
     {
      if(priceDirection == "UP")
        {
         if(currentDOM[i].price > previousDOM[previous_best_bid_index].price)
           {
            volume += setRangeValueVolume(currentDOM[i].price, currentDOM[i].volume, min, max);
           }
         else
            if(currentDOM[i].price == previousDOM[previous_best_bid_index].price)
              {
               float vol1 = setRangeValueVolume(currentDOM[i].price, currentDOM[i].volume, min, max);
               float vol2 = setRangeValueVolume(previousDOM[previous_best_bid_index].price, previousDOM[previous_best_bid_index].volume, min, max);
               volume += (vol1 - vol2);
               break;
              }
            else
              {
               volume -= setRangeValueVolume(previousDOM[previous_best_bid_index].price, previousDOM[previous_best_bid_index].volume, min, max); // volume += (0 - previousDOM[previous_best_bid_index].volume);
               break;
              }
        }
      else
        {
         if(currentDOM[best_bid].price < previousDOM[i].price)
           {
            volume -= setRangeValueVolume(previousDOM[i].price, previousDOM[i].volume, min, max);
           }
         else
            if(currentDOM[best_bid].price == previousDOM[i].price)
              {
               float vol1 = setRangeValueVolume(currentDOM[best_bid].price, currentDOM[best_bid].volume, min, max);
               float vol2 = setRangeValueVolume(previousDOM[i].price, previousDOM[i].volume, min, max);
               volume += (vol1 - vol2);
               break;
              }
            else
              {
               volume += setRangeValueVolume(currentDOM[best_bid].price, currentDOM[best_bid].volume, min, max); // volume += (0 - oldItems[i][1]);
               break;
              }
        }
     }

   return volume;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float CustomBHRSI::bhrsiChangesForSell(string priceDirection, int min, int max)
  {
   int last_ask = (int)Book.InfoGetInteger(MBOOK_LAST_ASK_INDEX);    // Index of worst or last Ask price
   int best_ask = (int)Book.InfoGetInteger(MBOOK_BEST_ASK_INDEX);    // Get index of best Ask price
   int best_bid = (int)Book.InfoGetInteger(MBOOK_BEST_BID_INDEX);    // Get index of best Bid price

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
   for(int i = best_ask; i >= last_ask; i--)
     {
      if(priceDirection == "UP")
        {
         if(currentDOM[best_ask].price > previousDOM[i].price)
           {
            volume -= setRangeValueVolume(previousDOM[i].price, previousDOM[i].volume, min, max);
           }
         else
            if(currentDOM[best_ask].price == previousDOM[i].price)
              {
               float vol1 = setRangeValueVolume(currentDOM[best_ask].price, currentDOM[best_ask].volume, min, max);
               float vol2 = setRangeValueVolume(previousDOM[i].price, previousDOM[i].volume, min, max);
               volume += (vol1 - vol2);
               break;
              }
            else
              {
               volume += setRangeValueVolume(currentDOM[best_ask].price, currentDOM[best_ask].volume, min, max);
               break;
              }
        }
      else
        {
         if(currentDOM[i].price < previousDOM[previous_best_ask_index].price)
           {
            volume += setRangeValueVolume(currentDOM[i].price, currentDOM[i].volume, min, max);
           }
         else
            if(currentDOM[i].price == previousDOM[previous_best_ask_index].price)
              {
               float vol1 = setRangeValueVolume(currentDOM[i].price, currentDOM[i].volume, min, max);
               float vol2 = setRangeValueVolume(previousDOM[previous_best_ask_index].price, previousDOM[previous_best_ask_index].volume, min, max);
               volume += (vol1 - vol2);
               break;
              }
            else
              {
               volume -= setRangeValueVolume(previousDOM[previous_best_ask_index].price, previousDOM[previous_best_ask_index].volume, min, max); //volume += (0 - oldItems[best_ask][1]);
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
float CustomBHRSI::setRangeValueVolume(float queuePriceValue,float queueVolumeValue, int min, int max)
  {
   return (queuePriceValue >= min && queuePriceValue <= max)? queueVolumeValue : 0;
  }


//+------------------------------------------------------------------+
//|  Function that find inclusive range between new and old queue    |
//+------------------------------------------------------------------+
void CustomBHRSI::findInclusiveRange(float newBid, float oldBid, float newAsk, float oldAsk, int &result[])
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
void CustomBHRSI::findCommonRange(int &result[])
  {
   int last_ask = (int)Book.InfoGetInteger(MBOOK_LAST_ASK_INDEX);    // Index of worst or last Ask price
   int last_bid = (int)Book.InfoGetInteger(MBOOK_LAST_BID_INDEX);    // Index of worst or last Ask price

   float firstMin = currentDOM[last_bid].price;
   float lastMin = previousDOM[previous_last_bid_index].price? previousDOM[previous_last_bid_index].price: currentDOM[last_bid].price;

   float firstMax = currentDOM[last_ask].price;
   float lastMax = previousDOM[previous_last_ask_index].price? previousDOM[previous_last_ask_index].price: currentDOM[last_ask].price;


   int min = (int) MathMax(firstMin, lastMin);
   int max = (int) MathMin(firstMax, lastMax);

   result[0] = min;
   result[1] = max;
  }