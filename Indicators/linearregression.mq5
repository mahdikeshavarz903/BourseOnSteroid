//+------------------------------------------------------------------+
//|                                             linearregression.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot seller volume
#property indicator_label1  "seller_volume"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "buyer_volume"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#include "../Include/Trade/MarketBook.mqh"
//--- indicator buffers
double         TimeToVanishingSellerBuffer[];  // Buffer for holding time of vanishing sell queue
double         TimeToVanishingBuyerBuffer[];   // Buffer for holding time of vanishing buyer queue
//--- input parameters
input int      frontLineVolumeLength=10;         // Indicator calculation period
input int      maxTimeForVanishing=10;           // This means that we do not care if the time is more than 10 and we always set the maximum time to 10.
input int      minTimeForVanishing=-10;          // This means that we do not care if the time is less than -10 and we always set the minimumm time to -10.
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

int     vanishingTimeOfSellerQueue;       // Variable for holding time of vanishing sell queue
int     vanishingTimeOfBuyerQueue;        // Variable for holding time of vanishing buy queue
double  askVolume[];                      // This variable holds ask volume
double  bidVolume[];                      // This variable holds bid volume
int     askVolumeIndex=0;                 // This variable holds the last askVolume index for which we set the value
int     bidVolumeIndex=0;                 // This variable holds the last bidVolume index for which we set the value
double  previousBidPrice=0;               // Hold previous value of bid price
double  previousAskPrice=0;               // Hold previous value of ask price
CMarketBook Book(Symbol());               // Initialize class with current instrument

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,TimeToVanishingSellerBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,TimeToVanishingBuyerBuffer,INDICATOR_DATA);

   EventSetTimer(1);

//---- indexing elements in arrays as time series
   ArraySetAsSeries(TimeToVanishingSellerBuffer,true);
   ArraySetAsSeries(TimeToVanishingBuyerBuffer,true);

   /* Set the size of askVolume and bidVolume to the size of the period*/
   ArrayResize(askVolume, frontLineVolumeLength);
   ArrayResize(bidVolume, frontLineVolumeLength);

   vanishingTimeOfSellerQueue=frontLineVolumeLength;
   vanishingTimeOfBuyerQueue =frontLineVolumeLength;

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
      // The function initializes a numeric array by a preset value.
      ArrayInitialize(TimeToVanishingSellerBuffer, EMPTY_VALUE); // EMPTY_VALUE = 1.7976931348623157E+308
      ArrayInitialize(TimeToVanishingBuyerBuffer, EMPTY_VALUE);
      ArrayInitialize(askVolume, -1);  // Initialize bidVolume and askVolume lists with -1
      ArrayInitialize(bidVolume, -1);

      bool getDOM=MarketBookGet(NULL,currentDOM);
      if(getDOM && ArraySize(currentDOM)!=0)
        {
         int best_ask = (int)Book.InfoGetInteger(MBOOK_BEST_ASK_INDEX);    // Get index of best Ask price
         int best_bid = (int)Book.InfoGetInteger(MBOOK_BEST_BID_INDEX);    // Get index of best Bid price

         previousAskPrice=NormalizeDouble(currentDOM[best_ask].price, 5);   // Rounding floating point number to a specified accuracy.
         previousBidPrice=NormalizeDouble(currentDOM[best_bid].price, 5);   // Rounding floating point number to a specified accuracy.
        }

      /*
      askVolume[0]=300000;
      askVolume[1]=250000;
      askVolume[2]=200000;
      askVolume[3]=150000;
      askVolume[4]=120000;
      askVolume[5]=123000;
      askVolume[6]=140000;
      askVolume[7]=20000;
      askVolume[8]=15000;
      */
     }
   else //if(prev_calculated>=0)
     {

      bool getDOM=MarketBookGet(NULL,currentDOM);
      if(getDOM && ArraySize(currentDOM)!=0)
        {
         checkBidAndAskChanges();
         updateBuffers();
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
   int count = ArraySize(askVolume);
   if(askVolumeIndex==ArraySize(askVolume)-1)
     {
      ArrayCopy(askVolume, askVolume, 0, 1, count - 1);
      askVolumeIndex++;
     }

   if(bidVolumeIndex==ArraySize(bidVolume)-1)
     {
      ArrayCopy(bidVolume, bidVolume, 0, 1, count - 1);
      bidVolumeIndex++;
     }

  }
//+------------------------------------------------------------------+
//| Function that receives any changes in DOM                        |
//+------------------------------------------------------------------+
void OnBookEvent(const string& symbol)
  {
   
   if(symbol==_Symbol)
     {
      // Get depth of market
      bool getDOM=MarketBookGet(NULL,currentDOM);
      if(getDOM && ArraySize(currentDOM)!=0)
        {
         checkBidAndAskChanges();
         updateBuffers();
        }
     }

  }
//+------------------------------------------------------------------+
//| Function that checks bid and ask changes                         |
//+------------------------------------------------------------------+
void checkBidAndAskChanges()
  {
   double newAskPrice, newBidPrice;
   
   int best_ask = (int)Book.InfoGetInteger(MBOOK_BEST_ASK_INDEX);    // Get index of best Ask price
   int best_bid = (int)Book.InfoGetInteger(MBOOK_BEST_BID_INDEX);    // Get index of best Bid price

   newAskPrice = NormalizeDouble(currentDOM[best_ask].price, 5);   // Get a new bid and ask
   newBidPrice = NormalizeDouble(currentDOM[best_bid].price, 5);

   /* 
      If the bid and ask values have changed, we must change all the values in the bidVolume and askVolume lists to -1. Also 
      we need to reset askVolumeIndex and bidVolumeIndex
   */
   if(previousAskPrice!=newAskPrice)
     {
      ArrayInitialize(askVolume, -1);
      askVolumeIndex=0;
     }

   if(previousBidPrice!=newBidPrice)
     {
      ArrayInitialize(bidVolume, -1);
      bidVolumeIndex=0;
     }

   previousAskPrice=newAskPrice;
   previousBidPrice=newBidPrice;

  }
//+------------------------------------------------------------------+
//| Function that calculates linear regression                       |
//+------------------------------------------------------------------+
bool calculateLinearRegression(string bidOrAsk, double &volume[]) //  bidOrAsk == "BID" => volume = bidVolume[] -  bidOrAsk == "ASK" => volume = askVolume[]
  {
//---- declarations of local variables
   double value,a,b,c,sumy,sumx,sumxy,sumx2;

   /* 
      https://www.statisticshowto.com/wp-content/uploads/2009/11/linearregressionequations.bmp 
      Above URL shows how to calculate the values of a and b in calculating the linear regression equation.
            
      Linear Regression: Y = bX + a    ===> Y: Volume , X: VanishingTime
      In this equation, we assume Y is zero and we calculate X
      
      The variables you see below are considered in terms of the above relation variables.
   */
   sumy=0.0;
   sumx=0.0;
   sumxy=0.0;
   sumx2=0.0;
   int vanishingTime = 0;  // Predict when a buy or sell queue will disappear

   for(int iii=0; iii<ArraySize(volume) && volume[iii]!=-1; iii++)
     {
      value=volume[iii];
      sumy+=value; 
      sumxy+=value*iii;
      sumx+=iii;
      sumx2+=iii*iii;
      vanishingTime = iii + 1;
     }

   c=sumx2*vanishingTime-sumx*sumx;
   if(!c)
      return 0;   // It means Exception

   b=(sumxy*vanishingTime-sumx*sumy)/c;
   a = (sumy * sumx2 - sumx * sumxy)/c;

   /* Reminder: Y = bX + a */
   double linearRegressionValue=a+b*vanishingTime;

   if(!b)
      return 0; // It means Exception

   double time = (-a / b);
   
   if(time>maxTimeForVanishing)
      time = maxTimeForVanishing;
   
   if(time<minTimeForVanishing)
      time = minTimeForVanishing;
   
   // We update the input of the values inside the buffer according to the calculated variables (a and b) and input values (bidOrAsk).
   if(bidOrAsk == "ASK")
      TimeToVanishingSellerBuffer[0] = time;
   else
      TimeToVanishingBuyerBuffer[0] = time;
      
    Print(bidOrAsk, " - TimeToVanishing: ", time);

   return 1;
  }
//+------------------------------------------------------------------+
void updateBuffers()
  {
   int best_ask = (int)Book.InfoGetInteger(MBOOK_BEST_ASK_INDEX);    // Get index of best Ask price
   int best_bid = (int)Book.InfoGetInteger(MBOOK_BEST_BID_INDEX);    // Get index of best Bid price
   
// askVolumeIndex=9;
   if(askVolumeIndex==0)
     {
      askVolume[askVolumeIndex] = currentDOM[best_ask].volume;
      askVolumeIndex++;
     }

   if(bidVolumeIndex==0)
     {
      bidVolume[bidVolumeIndex] = currentDOM[best_bid].volume;
      bidVolumeIndex++;
     }

   if(askVolumeIndex==ArraySize(askVolume))
     {
      askVolumeIndex--;
     }

   if(bidVolumeIndex==ArraySize(bidVolume))
     {
      bidVolumeIndex--;
     }

   askVolume[askVolumeIndex] = currentDOM[best_ask].volume;  // Moves the ask value to the last point where askVolumeIndex points
   bidVolume[bidVolumeIndex] = currentDOM[best_bid].volume;  // Moves the bid value to the last point where bidVolumeIndex points

   bool result;
   // Calculate LinearRegression for sell queue
   result = calculateLinearRegression("ASK", askVolume);

   if(result)
      (askVolumeIndex<frontLineVolumeLength-1)?askVolumeIndex++:askVolumeIndex;
   
   // Calculate LinearRegression for buy queue
   result = calculateLinearRegression("BID", bidVolume);

   if(result)
      (bidVolumeIndex<frontLineVolumeLength-1)?bidVolumeIndex++:bidVolumeIndex;


   //Print("askVolumeIndex: ", askVolumeIndex);
   //Print("bidVolumeIndex: ", bidVolumeIndex);

  }
//+------------------------------------------------------------------+
