//+------------------------------------------------------------------+
//|                                                 BufferStruct.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
struct Buffers
     {
      double         BHRSICloseBuffer[];  // Indicator buffer for holding BHRSI close value
      double         BHRSIHighBuffer[];   // Indicator buffer for holding BHRSI high value
      double         BHRSILowBuffer[];    // Indicator buffer for holding BHRSI low value
      double         BHRSIOpenBuffer[];   // Indicator buffer for holding BHRSI open value
      double         BHRSITOTALBuffer[];  // Indicator buffer for holding BHRSI Total value
     };