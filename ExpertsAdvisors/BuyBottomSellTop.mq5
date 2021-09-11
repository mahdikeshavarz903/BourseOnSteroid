//+------------------------------------------------------------------+
//|                                                       Expert.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalBHRSI.mqh>
#include <Expert\Signal\SignalLinearRegression.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
#include <../Shared Projects/BourseOnSteroid/CustomFiles/BuyBottomSellTopExpert.mqh>
//#include <../Shared Projects/BourseOnSteroid/Indicators/BHRSI.mqh>
//#include <../Shared Projects/BourseOnSteroid/Indicators/GlobalCustomBHRSI.mqh>
#include "../Indicators/GlobalCustomBHRSI.mqh"

 
//#import "../Indicators/Shared Projects/BourseOnSteroid/Indicators/BHRSI.ex5"
//void CustomOnTimer(int n);
//#import

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                          ="Expert";    // Document name
ulong                    Expert_MagicNumber                    =24510;       //
bool                     Expert_EveryTick                      =true;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen                  =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose                 =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel                     =0.0;         // Price level to execute a deal
input double             Signal_StopLevel                      =20.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel                      =20.0;        // Take Profit level (in points)
input int                Signal_Expiration                     =4;           // Expiration of pending orders (in bars)
input int                Signal_BHRSI_PeriodBHRSI              =10;          // BHRSI(10,10,50,50,...) Period of calculation
input int                Signal_BHRSI_PeriodBHRSITotal         =10;          // BHRSI(10,10,50,50,...) Period of calculation
input int                Signal_BHRSI_BhrsiThreshold           =70;          // BHRSI(10,10,50,50,...) BHRSI threshold
input int                Signal_BHRSI_BhrsiTotalThreshold      =70;          // BHRSI(10,10,50,50,...) BHRSI total threshold
input ENUM_APPLIED_PRICE Signal_BHRSI_Applied                  =PRICE_CLOSE; // BHRSI(10,10,50,50,...) Prices series
input double             Signal_BHRSI_Weight                   =1.0;         // BHRSI(10,10,50,50,...) Weight [0...1.0]
input int                Signal_LR_periodLinearRegression      =10;          // LinearRegression(10,50,50,...) Period of calculation
input int                Signal_LR_SellerVanishingTimeThreshold=5;          // LinearRegression(10,50,50,...) Seller vanishing time threshold
input int                Signal_LR_BuyerVanishingTimeThreshold =5;          // LinearRegression(10,50,50,...) Buyer vanishing time threshold
input ENUM_APPLIED_PRICE Signal_LR_Applied                     =PRICE_CLOSE; // LinearRegression(10,50,50,...) Prices series--------------------------------------------------
input double             Signal_LR_Weight                      =1.0;         // LinearRegression(10,50,50,...) Weight [0...1.0]
//--- inputs for money
input double             Money_FixLot_Percent                  =10.0;        // Percent
input double             Money_FixLot_Lots                     =600;         // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CBuyBottomSellTopExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {    
    EventSetTimer(1);
    ExtExpert.OnTimerProcess(true);
    
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalBHRSI
   CSignalBHRSI *filter0=new CSignalBHRSI;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodBHRSI(Signal_BHRSI_PeriodBHRSI);
   filter0.PeriodBHRSITotal(Signal_BHRSI_PeriodBHRSITotal);
   filter0.BhrsiThreshold(Signal_BHRSI_BhrsiThreshold);
   filter0.BhrsiTotalThreshold(Signal_BHRSI_BhrsiTotalThreshold);
   filter0.Applied(Signal_BHRSI_Applied);
   filter0.Weight(Signal_BHRSI_Weight);
//--- Creating filter CSignalLinearRegression
   CSignalLinearRegression *filter1=new CSignalLinearRegression;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodLinearRegression(Signal_LR_periodLinearRegression);
   filter1.SellerVanishingTimeThreshold(Signal_LR_SellerVanishingTimeThreshold);
   filter1.BuyerVanishingTimeThreshold(Signal_LR_BuyerVanishingTimeThreshold);
   filter1.Applied(Signal_LR_Applied);
   filter1.Weight(Signal_LR_Weight);
//--- Creation of trailing object
   CTrailingNone *trailing=new CTrailingNone;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
//--- Creation of money object
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Percent(Money_FixLot_Percent);
   money.Lots(Money_FixLot_Lots);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
     
     CIndicators indicators;
     
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
     
     //CiCustom *c = (CiCustom *) indicators.At(3);
     //c.bhrsiCalculation();
     
     //customBHRSI = indicators.At(3);
          
     //int x = customBHRSI.GetBHRSICloseBuffer(0);
     //customBHRSI.DoOnInit(10, 10, 70, 70);
     
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
   //customBHRSI.DoOnTimer(); 
  }
//+------------------------------------------------------------------+
