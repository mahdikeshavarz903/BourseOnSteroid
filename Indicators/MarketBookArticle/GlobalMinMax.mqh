//+------------------------------------------------------------------+
//|                                                       MinMax.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

struct Volume
   {
      int minH;   // Below thousand 
      int maxH;   // Below thousand 
      int minK;   // Min Thousand 
      int maxK;   // Max Thousand 
      int minM;   // Min Million    
      int maxM;   // Max Million
      int minB;   // Min Bilion
      int maxB;   // Max Bilion
   };
         
struct MinMax
{
   Volume pendingVolume;
   Volume buyerSellerVolume;
   Volume totalVolume;
   Volume snapshotsVolume;
};

MinMax minMaxStruct;