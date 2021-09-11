//+------------------------------------------------------------------+
//|                                              GlobalMainTable.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//#include "MainTable.mqh"


struct MainTable
  {
   int               volume;
   double            price;
   int               sellerVol;
   int               buyerVol;
   int               domRowId;
  };

MainTable mainTable[];