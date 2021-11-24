//+------------------------------------------------------------------+
//|                                             GlobalMainTable2.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Generic/HashMap.mqh>
#include "MainTable.mqh"
 
CHashMap<double,CMainTable *>cMainTable;
CHashMap<int,double>mapDomRowIdToPrice;
CHashMap<double, int>mapPriceToDomRowId;   

int  globalSellerPower=0;
int  globalBuyerPower=0;
int  globalSnapshotBidPower=0;
int  globalSnapshotAskPower=0;
int  globalHighestPriceVolume=-1;       // This variable hold volume at the highest price of today
int  globalLowestPriceVolume=-1;        // This variable hold volume at the lowest price of today
