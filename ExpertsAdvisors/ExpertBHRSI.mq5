//+------------------------------------------------------------------+
//|                                                  ExpertBHRSI.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+ ------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalBHRSI.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                    ="ExpertBHRSI"; // Document name
ulong                    Expert_MagicNumber              =1330;          //
bool                     Expert_EveryTick                =false;         //
//--- inputs for main signal
input int                Signal_ThresholdOpen            =10;            // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose           =10;            // Signal threshold value to close [0...100]
input double             Signal_PriceLevel               =0.0;           // Price level to execute a deal
input double             Signal_StopLevel                =50.0;          // Stop Loss level (in points)
input double             Signal_TakeLevel                =50.0;          // Take Profit level (in points)
input int                Signal_Expiration               =4;             // Expiration of pending orders (in bars)
input int                Signal_BHRSI_PeriodBHRSI        =10;            // BHRSI(10,10,50,50,...) Period of calculation
input int                Signal_BHRSI_PeriodBHRSITotal   =10;            // BHRSI(10,10,50,50,...) Period of calculation
input int                Signal_BHRSI_BhrsiThreshold     =70;            // BHRSI(10,10,50,50,...) BHRSI threshold
input int                Signal_BHRSI_BhrsiTotalThreshold=70;            // BHRSI(10,10,50,50,...) BHRSI total threshold
input ENUM_APPLIED_PRICE Signal_BHRSI_Applied            =PRICE_CLOSE;   // BHRSI(10,10,50,50,...) Prices series
input double             Signal_BHRSI_Weight             =1.0;           // BHRSI(10,10,50,50,...) Weight [0...1.0]
//--- inputs for money
input double             Money_FixLot_Percent            =10.0;          // Percent
input double             Money_FixLot_Lots               =2800.0;        // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
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
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
     
     CIndicators       m_indicators;
     CIndicators *indicators_ptr=GetPointer(m_indicators);
     filter0.InitIndicators(indicators_ptr);
     CObject *ci = new CObject;
     ci.Prev(indicators_ptr);
     Print("");
     
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
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
  }
//+------------------------------------------------------------------+
