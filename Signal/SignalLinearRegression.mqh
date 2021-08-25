//+------------------------------------------------------------------+
//|                                       SignalLinearRegression.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+--------------------------------------------------------------------------------+
//| Description of the class                                                       |
//| Title=Signals of oscillator 'LinearRegression'                                 |
//| Type=SignalAdvanced                                                            |
//| Name=LinearRegression                                                          |
//| ShortName=LR                                                                   |
//| Class=CSignalLinearRegression                                                  |
//| Page=signal_macd                                                               |
//| Parameter=periodLinearRegression,int,10,Period of calculation                  |
//| Parameter=SellerVanishingTimeThreshold,int,50, Seller vanishing time threshold |
//| Parameter=BuyerVanishingTimeThreshold,int,50,Buyer vanishing time threshold    |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE,Prices series                 |
//+--------------------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalLinearRegression.                                   |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'LinearRegression' oscillator.                      |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalLinearRegression : public CExpertSignal
  {
protected:
   CiCustom          m_LinearRegression;           // object-oscillator
   //--- adjusted parameters
   int               m_period_linearregression;        // the "period of linearregression" parameter of the oscillator
   int               seller_vanishing_time_threshold;        // vanishing time threshold
   int               buyer_vanishing_time_threshold;        // vanishing time threshold
   ENUM_APPLIED_PRICE m_applied;             // the "price series" parameter of the oscillator
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "If vanishing time in the buffer is less than vanishing time threshold it sends buy or sell signal"

   //--- variables
   double            m_extr_osc[10];   // array of values of extremums of the oscillator
   double            m_extr_pr[10];    // array of values of the corresponding extremums of price
   int               m_extr_pos[10];   // array of shifts of extremums (in bars)
   uint              m_extr_map;       // resulting bit-map of ratio of extremums of the oscillator and the price
   int linearregression_handle;

public:
                     CSignalLinearRegression(void);
                    ~CSignalLinearRegression(void);
   //--- methods of setting adjustable parameters
   void              PeriodLinearRegression(int value)              { m_period_linearregression=value;        }
   void              SellerVanishingTimeThreshold(int value)           { seller_vanishing_time_threshold=value;       }
   void              BuyerVanishingTimeThreshold(int value)           { buyer_vanishing_time_threshold=value;       }
   void              Applied(ENUM_APPLIED_PRICE value)   { m_applied=value;             }
   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)              { m_pattern_0=value;             }
   
   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- method of initialization of the oscillator
   bool              InitLinearRegression(CIndicators *indicators);
   //--- methods of getting data
   double            SellerLinearRegression(int ind)
     {
     m_LinearRegression.Refresh();
     
     float result = m_LinearRegression.GetData(0, ind);      
     
      return result;
     }
   double            BuyerLinearRegression(int ind)
     {
      m_LinearRegression.Refresh();         
     
      float result = m_LinearRegression.GetData(1, ind);
      return result;
     }
   double            DiffMain(int ind)                 { return(SellerLinearRegression(ind)-SellerLinearRegression(ind+1));  }
   int               StateMain(int ind);
   double            State(int ind) { return(SellerLinearRegression(ind)-SellerLinearRegression(ind+1)); }
   bool              ExtState(int ind);
   bool              CompareMaps(int map,int count,bool minimax=false,int start=0);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalLinearRegression::CSignalLinearRegression(void) :
   m_period_linearregression(10),
   seller_vanishing_time_threshold(5),
   buyer_vanishing_time_threshold(5),
   m_applied(PRICE_CLOSE),
   m_pattern_0(100)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
   
   string short_name=StringFormat("LinearRegression(%d)",m_period_linearregression);
   linearregression_handle = ChartIndicatorGet(0, ChartWindowFind(), short_name);

    /*
    linearregression_handle =iCustom(Symbol(),
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
CSignalLinearRegression::~CSignalLinearRegression(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalLinearRegression::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
   if(seller_vanishing_time_threshold<0)
     {
      printf(__FUNCTION__+": The vanishing time threshold must be greater than 0");
      return(false);
     }

   if(m_period_linearregression<=0)
     {
      printf(__FUNCTION__+": period linearregression must be greater than 0");
      return(false);
     }

//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalLinearRegression::InitIndicators(CIndicators *indicators)
  {
//--- check of pointer is performed in the method of the parent class
//---
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize MACD oscilator
   if(!InitLinearRegression(indicators))
      return(false);
      
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize MACD oscillators.                                     |
//+------------------------------------------------------------------+
bool CSignalLinearRegression::InitLinearRegression(CIndicators *indicators)
  {
//--- add object to collection
   if(!indicators.Add(GetPointer(m_LinearRegression)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
     
//--- set parameters of the indicator
   MqlParam parameters[2];

   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="\Indicators\Shared Projects\BourseOnSteroid\Indicators\linearregression";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=m_period_linearregression;
   
//--- object initialization
   if(!m_LinearRegression.Create(m_symbol.Name(),0,IND_CUSTOM,2,parameters))
     {
      printf(__FUNCTION__+": error initializing object   ");
      return(false);
     }
//--- number of buffers
   if(!m_LinearRegression.NumBuffers(1))
      return(false);
//--- ok
   
   return(true);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalLinearRegression::LongCondition(void)
  {
   int result=0;
   int idx   =0;

//--- check direction of the main line
//if(DiffMain(idx)>0.0)
//{
   double linearRegression = BuyerLinearRegression(idx);
   
   Print("* LinearRegression: ", linearRegression);
   
//--- the main line is directed upwards, and it confirms the possibility of price growth
   if(IS_PATTERN_USAGE(0) &&  linearRegression<=buyer_vanishing_time_threshold)
      result=m_pattern_0;      // "confirming" signal number 0
//}
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalLinearRegression::ShortCondition(void)
  {
   int result=0;
   int idx   =0;
//--- check direction of the main line
   //if(DiffMain(idx)<0.0)
   //  {
      double linearRegression = SellerLinearRegression(idx);
   
      //--- main line is directed downwards, confirming a possibility of falling of price
      if(IS_PATTERN_USAGE(0) &&  linearRegression<=seller_vanishing_time_threshold)
         result=m_pattern_0;      // "confirming" signal number 0

   //  }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+

