//+------------------------------------------------------------------+
//|                                             GlobalMainTable2.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Generic/HashMap.mqh>
#include "MainTable.mqh"
 
//CMainTable *cMainTable[];
CHashMap<double,CMainTable *>cMainTable;
CHashMap<int,double>mapDomRowIdToPrice;
CHashMap<double, int>mapPriceToDomRowId;
CMainTable *cOldMainTable[];