//+------------------------------------------------------------------+
//|                                                  SignalBHRSI.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
#include <../Shared Projects/BourseOnSteroid/Indicators/CustomBHRSI.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of oscillator 'BHRSI'                              |
//| Type=SignalAdvanced                                              |
//| Name=BHRSI                                                       |
//| ShortName=BHRSI                                                  |
//| Class=CSignalBHRSI                                               |
//| Page=signal_macd                                                 |
//| Parameter=PeriodBHRSI,int,10,Period of calculation               |
//| Parameter=PeriodBHRSITotal,int,10,Period of calculation          |
//| Parameter=BhrsiThreshold,int,50,BHRSI threshold                  |
//| Parameter=BhrsiTotalThreshold,int,50,BHRSI total threshold       |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE,Prices series   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalBHRSI.                                               |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'BHRSI and BHRSITotal' oscillator. |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalBHRSI : public CExpertSignal
  {
protected:
   CiCustom          m_BHRSI;           // object-oscillator
   CustomBHRSI       o_BHRSI;
   
   //--- adjusted parameters
   int               m_period_bhrsi;         // the "period of bhrsi" parameter of the oscillator
   int               m_period_bhrsi_total;   // the "period of bhrsi total" parameter of the oscillator
   int               bhrsi_threshold;        // BHRSI Threshold
   int               bhrsi_total_threshold;  // BHRSI Total Threshold
   ENUM_APPLIED_PRICE m_applied;             // the "price series" parameter of the oscillator
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "BHRSI and BHRSITotal are above bhrsi_threshold and bhrsi_total_threshold"

   //--- variables
   double            m_extr_osc[10];   // array of values of extremums of the oscillator
   double            m_extr_pr[10];    // array of values of the corresponding extremums of price
   int               m_extr_pos[10];   // array of shifts of extremums (in bars)
   uint              m_extr_map;       // resulting bit-map of ratio of extremums of the oscillator and the price
   int               BHRSI_handle;

public:
                     CSignalBHRSI(void);
                    ~CSignalBHRSI(void);
   //--- methods of setting adjustable parameters
   void              PeriodBHRSI(int value)              { m_period_bhrsi=value;        }
   void              PeriodBHRSITotal(int value)         { m_period_bhrsi_total=value;  }
   void              BhrsiThreshold(int value)           { bhrsi_threshold=value;       }
   void              BhrsiTotalThreshold(int value)      { bhrsi_total_threshold=value; }
   void              Applied(ENUM_APPLIED_PRICE value)   { m_applied=value;             }
   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)              { m_pattern_0=value;             }
   void              Get_CustomBHRSI(CustomBHRSI *customBHRSI)             {customBHRSI = GetPointer(o_BHRSI);};

   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- method of initialization of the oscillator
   bool              InitBHRSI(CIndicators *indicators);
   //--- methods of getting data
   double            MainBHRSI(int ind)
     {
      int rates_total = Bars(_Symbol,PERIOD_M1);

      //double list[];
      //ArrayResize(list, rates_total);

      m_BHRSI.Refresh();

      //CopyBuffer(BHRSI_handle, 0, 0, rates_total, list);

      float result = m_BHRSI.GetData(0, ind);

      //Print(GetLastError());

      //return list[ArraySize(list)-1];
      return result;
     }
   double            MainBHRSITotal(int ind)
     {
      int rates_total = Bars(_Symbol,PERIOD_M1);

      //double list[];
      //ArrayResize(list, rates_total);

      m_BHRSI.Refresh();

      //CopyBuffer(BHRSI_handle, 4, 0, rates_total-1, list);
      //return list[ArraySize(list)-1];

      float result = m_BHRSI.GetData(4, ind);
      return result;
     }
   double            DiffMain(int ind)                 { return(MainBHRSI(ind)-MainBHRSI(ind+1));  }
   int               StateMain(int ind);
   double            State(int ind) { return(MainBHRSI(ind)-MainBHRSI(ind+1)); }
   bool              ExtState(int ind);
   bool              CompareMaps(int map,int count,bool minimax=false,int start=0);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalBHRSI::CSignalBHRSI(void) :
   m_period_bhrsi(10),
   m_period_bhrsi_total(10),
   bhrsi_threshold(70),
   bhrsi_total_threshold(70),
   m_applied(PRICE_CLOSE),
   m_pattern_0(100)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;

   string short_name=StringFormat("BHRSI(%d) - BHRSI Total(%d)",m_period_bhrsi,m_period_bhrsi_total);
   BHRSI_handle = ChartIndicatorGet(0, ChartWindowFind(), short_name);

   /*
   BHRSI_handle =iCustom(Symbol(),
                       0,
                       "\Indicators\Shared Projects\BourseOnSteroid\Indicators\BHRSI",
                       10,
                       10,
                       50,
                       50
                       );
    */
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalBHRSI::~CSignalBHRSI(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalBHRSI::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
   if(bhrsi_threshold>100 && bhrsi_threshold<0)
     {
      printf(__FUNCTION__+": BHRSI threshold must be between 100 and -100");
      return(false);
     }

   if(bhrsi_total_threshold>100 && bhrsi_total_threshold<0)
     {
      printf(__FUNCTION__+": BHRSI total threshold must be between 100 and -100");
      return(false);
     }

   if(m_period_bhrsi<=0)
     {
      printf(__FUNCTION__+": period bhrsi must be greater than 0");
      return(false);
     }

   if(m_period_bhrsi_total<=0)
     {
      printf(__FUNCTION__+": period bhrsi total must be greater than 0");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalBHRSI::InitIndicators(CIndicators *indicators)
  {
//--- check of pointer is performed in the method of the parent class
//---
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize MACD oscilator
   if(!InitBHRSI(indicators))
      return(false);

//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize MACD oscillators.                                     |
//+------------------------------------------------------------------+
bool CSignalBHRSI::InitBHRSI(CIndicators *indicators)
  {
  
   if(!indicators.Add(GetPointer(o_BHRSI)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- set parameters of the indicator
   MqlParam parameters[5];

   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="\Indicators\Shared Projects\BourseOnSteroid\Indicators\BHRSI";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=70;
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=70;
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=m_period_bhrsi;
   parameters[4].type=TYPE_INT;
   parameters[4].integer_value=m_period_bhrsi_total;

//--- object initialization
   if(!o_BHRSI.Create(m_symbol.Name(),0, 5, parameters))
     {
      printf(__FUNCTION__+": error initializing object   ");
      return(false);
     }
//--- number of buffers
   if(!o_BHRSI.NumBuffers(5))
      return(false);
//--- ok

   
   /*
//--- add object to collection
   if(!indicators.Add(GetPointer(m_BHRSI)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }

//--- set parameters of the indicator
   
   MqlParam parameters[5];

   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="\Indicators\Shared Projects\BourseOnSteroid\Indicators\BHRSI";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=70;
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=70;
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=m_period_bhrsi;
   parameters[4].type=TYPE_INT;
   parameters[4].integer_value=m_period_bhrsi_total;

//--- object initialization
   if(!m_BHRSI.Create(m_symbol.Name(),0,IND_CUSTOM,5,parameters))
     {
      printf(__FUNCTION__+": error initializing object   ");
      return(false);
     }
//--- number of buffers
   if(!m_BHRSI.NumBuffers(5))
      return(false);
//--- ok
   */
   
   return(true);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalBHRSI::LongCondition(void)
  {
   int result=0;
   int idx   =0;

//--- check direction of the main line
//if(DiffMain(idx)>0.0)
//{
   double BHRSIValue = MainBHRSI(idx);
   double BHRSITotal = MainBHRSITotal(idx);

//--- the main line is directed upwards, and it confirms the possibility of price growth
   if(IS_PATTERN_USAGE(0) &&  BHRSIValue>=bhrsi_threshold && MainBHRSITotal(idx)>=bhrsi_total_threshold)
     {
      result=MathCeil((BHRSIValue+BHRSITotal)/2);      // "confirming" signal number 0
      Print("LongCondition - BHRSI: ", BHRSIValue, " BHRSITotal: ", BHRSITotal);
     }
//}
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalBHRSI::ShortCondition(void)
  {
   int result=0;
   int idx   =0;
//--- check direction of the main line
//if(DiffMain(idx)<0.0)
//  {
   double BHRSIValue = MainBHRSI(idx);
   double BHRSITotal = MainBHRSITotal(idx);

//--- main line is directed downwards, confirming a possibility of falling of price
   if(IS_PATTERN_USAGE(0) &&  BHRSIValue<=(100-bhrsi_threshold) && BHRSITotal<=(100-bhrsi_total_threshold))
     {
      result=-1 * (100 - MathCeil((BHRSIValue+BHRSITotal)/2));      // "confirming" signal number 0
      Print("ShortCondition - BHRSI: ", BHRSIValue, " BHRSITotal: ", BHRSITotal);
     }
//  }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
