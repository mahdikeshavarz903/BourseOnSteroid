//+------------------------------------------------------------------+
//|                                                  SignalBHRSI.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
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
   //--- adjusted parameters
   int               m_period_bhrsi;         // the "period of bhrsi" parameter of the oscillator
   int               m_period_bhrsi_total;   // the "period of bhrsi total" parameter of the oscillator
   int               bhrsi_threshold;        // BHRSI Threshold
   int               bhrsi_total_threshold;  // BHRSI Total Threshold
   ENUM_APPLIED_PRICE m_applied;             // the "price series" parameter of the oscillator
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "the oscillator has required direction"
   int               m_pattern_1;      // model 1 "reverse of the oscillator to required direction"
   int               m_pattern_2;      // model 2 "buy signal when a value greater than BHRSIThreshold"
   int               m_pattern_3;      // model 3 "sell signal when a value lower than -BHRSIThreshold"  
   int               m_pattern_4;      // model 4 "buy signal when a value greater than BHRSITotalThreshold"
   int               m_pattern_5;      // model 5 "sell signal when a value lower than -BHRSITotalThreshold"
   //--- variables
   double            m_extr_osc[10];   // array of values of extremums of the oscillator
   double            m_extr_pr[10];    // array of values of the corresponding extremums of price
   int               m_extr_pos[10];   // array of shifts of extremums (in bars)
   uint              m_extr_map;       // resulting bit-map of ratio of extremums of the oscillator and the price

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
   void              Pattern_1(int value)              { m_pattern_1=value;             }
   void              Pattern_2(int value)              { m_pattern_2=value;             }
   void              Pattern_3(int value)              { m_pattern_3=value;             }
   
   void              Pattern_4(int value)              { m_pattern_4=value;             }
   void              Pattern_5(int value)              { m_pattern_5=value;             }
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
   double            Main(int ind)                     { return(m_BHRSI.GetData(0, ind));      }
   double            Signal(int ind)                   { return(m_BHRSI.GetData(1, ind));    }
   double            DiffMain(int ind)                 { return(Main(ind)-Main(ind+1));  }
   int               StateMain(int ind);
   double            State(int ind) { return(Main(ind)-Signal(ind)); }
   bool              ExtState(int ind);
   bool              CompareMaps(int map,int count,bool minimax=false,int start=0);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalBHRSI::CSignalBHRSI(void) : 
                                 m_period_bhrsi(10),
                                 m_period_bhrsi_total(10),
                                 bhrsi_threshold(50),
                                 bhrsi_total_threshold(50),
                                 m_applied(PRICE_CLOSE),
                                 m_pattern_0(10),
                                 m_pattern_1(100),
                                 m_pattern_2(bhrsi_threshold),
                                 m_pattern_3(-bhrsi_threshold),
                                 m_pattern_4(bhrsi_total_threshold),
                                 m_pattern_5(-bhrsi_total_threshold)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_HIGH+USE_SERIES_LOW;
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
   if(bhrsi_threshold<=100 && bhrsi_threshold>=-100)
     {
      printf(__FUNCTION__+": BHRSI threshold must be between 100 and -100");
      return(false);
     }
     
     if(bhrsi_total_threshold<=100 && bhrsi_total_threshold>=-100)
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
    //--- add object to collection
    if(!indicators.Add(GetPointer(m_BHRSI)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
     
     //--- set parameters of the indicator
     MqlParam parameters[5];
   
    parameters[0].type=TYPE_STRING;
    parameters[0].string_value="Examples\\MACD.ex5";
    parameters[1].type=TYPE_INT;
    parameters[1].integer_value=m_period_bhrsi;
    parameters[2].type=TYPE_INT;
    parameters[2].integer_value=m_period_bhrsi_total;
    parameters[3].type=TYPE_INT;
    parameters[3].integer_value=bhrsi_threshold;
    parameters[4].type=TYPE_INT;
    parameters[4].integer_value=bhrsi_total_threshold;
      
   //--- object initialization
   if(!m_BHRSI.Create(m_symbol.Name(),0,IND_CUSTOM,5,parameters))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- number of buffers
   if(!m_BHRSI.NumBuffers(5)) return(false);
//--- ok

   return(true);
  }
//+------------------------------------------------------------------+
//| Check of the oscillator state.                                   |
//+------------------------------------------------------------------+
int CSignalBHRSI::StateMain(int ind)
  {
   int    res=0;
   double var;
//---
   for(int i=ind;;i++)
     {
      if(Main(i+1)==EMPTY_VALUE)
         break;
      var=DiffMain(i);
      if(res>0)
        {
         if(var<0)
            break;
         res++;
         continue;
        }
      if(res<0)
        {
         if(var>0)
            break;
         res--;
         continue;
        }
      if(var>0)
         res++;
      if(var<0)
         res--;
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Extended check of the oscillator state consists                  |
//| in forming a bit-map according to certain rules,                 |
//| which shows ratios of extremums of the oscillator and price.     |
//+------------------------------------------------------------------+
bool CSignalBHRSI::ExtState(int ind)
  {
//--- operation of this method results in a bit-map of extremums
//--- practically, the bit-map of extremums is an "array" of 4-bit fields
//--- each "element of the array" definitely describes the ratio
//--- of current extremums of the oscillator and the price with previous ones
//--- purpose of bits of an element of the analyzed bit-map
//--- bit 3 - not used (always 0)
//--- bit 2 - is equal to 1 if the current extremum of the oscillator is "more extreme" than the previous one
//---         (a higher peak or a deeper valley), otherwise - 0
//--- bit 1 - not used (always 0)
//--- bit 0 - is equal to 1 if the current extremum of price is "more extreme" than the previous one
//---         (a higher peak or a deeper valley), otherwise - 0
//--- in addition to them, the following is formed:
//--- array of values of extremums of the oscillator,
//--- array of values of price extremums and
//--- array of "distances" between extremums of the oscillator (in bars)
//--- it should be noted that when using the results of the extended check of state,
//--- you should consider, which extremum of the oscillator (peak or valley)
//--- is the "reference point" (i.e. was detected first during the analysis)
//--- if a peak is detected first then even elements of all arrays
//--- will contain information about peaks, and odd elements will contain information about valleys
//--- if a valley is detected first, then respectively in reverse
   int    pos=ind,off,index;
   uint   map;                 // intermediate bit-map for one extremum
//---
   m_extr_map=0;
   for(int i=0;i<10;i++)
     {
      off=StateMain(pos);
      if(off>0)
        {
         //--- minimum of the oscillator is detected
         pos+=off;
         m_extr_pos[i]=pos;
         m_extr_osc[i]=Main(pos);
         if(i>1)
           {
            m_extr_pr[i]=m_low.MinValue(pos-2,5,index);
            //--- form the intermediate bit-map
            map=0;
            if(m_extr_pr[i-2]<m_extr_pr[i])
               map+=1;  // set bit 0
            if(m_extr_osc[i-2]<m_extr_osc[i])
               map+=4;  // set bit 2
            //--- add the result
            m_extr_map+=map<<(4*(i-2));
           }
         else
            m_extr_pr[i]=m_low.MinValue(pos-1,4,index);
        }
      else
        {
         //--- maximum of the oscillator is detected
         pos-=off;
         m_extr_pos[i]=pos;
         m_extr_osc[i]=Main(pos);
         if(i>1)
           {
            m_extr_pr[i]=m_high.MaxValue(pos-2,5,index);
            //--- form the intermediate bit-map
            map=0;
            if(m_extr_pr[i-2]>m_extr_pr[i])
               map+=1;  // set bit 0
            if(m_extr_osc[i-2]>m_extr_osc[i])
               map+=4;  // set bit 2
            //--- add the result
            m_extr_map+=map<<(4*(i-2));
           }
         else
            m_extr_pr[i]=m_high.MaxValue(pos-1,4,index);
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Comparing the bit-map of extremums with pattern.                 |
//+------------------------------------------------------------------+
bool CSignalBHRSI::CompareMaps(int map,int count,bool minimax,int start)
  {
   int step =(minimax)?4:8;
   int total=step*(start+count);
//--- check input parameters for a possible going out of range of the bit-map
   if(total>32)
      return(false);
//--- bit-map of the patter is an "array" of 4-bit fields
//--- each "element of the array" definitely describes the desired ratio
//--- of current extremums of the oscillator and the price with previous ones
//--- purpose of bits of an elements of the pattern of the bit-map pattern
//--- bit 3 - is equal to if the ratio of extremums of the oscillator is insignificant for us
//---         is equal to 0 if we want to "find" the ratio of extremums of the oscillator determined by the value of bit 2
//--- bit 2 - is equal to 1 if we want to "discover" the situation when the current extremum of the "oscillator" is "more extreme" than the previous one
//---         (current peak is higher or current valley is deeper)
//---         is equal to 0 if we want to "discover" the situation when the current extremum of the oscillator is "less extreme" than the previous one
//---         (current peak is lower or current valley is less deep)
//--- bit 1 - is equal to 1 if the ratio of extremums is insignificant for us
//---         it is equal to 0 if we want to "find" the ratio of price extremums determined by the value of bit 0
//--- bit 0 - is equal to 1 if we want to "discover" the situation when the current price extremum is "more extreme" than the previous one
//---         (current peak is higher or current valley is deeper)
//---         it is equal to 0 if we want to "discover" the situation when the current price extremum is "less extreme" than the previous one
//---         (current peak is lower or current valley is less deep)
   uint inp_map,check_map;
   int  i,j;
//--- loop by extremums (4 minimums and 4 maximums)
//--- price and the oscillator are checked separately (thus, there are 16 checks)
   for(i=step*start,j=0;i<total;i+=step,j+=4)
     {
      //--- "take" two bits - patter of the corresponding extremum of the price
      inp_map=(map>>j)&3;
      //--- if the higher-order bit=1, then any ratio is suitable for us
      if(inp_map<2)
        {
         //--- "take" two bits of the corresponding extremum of the price (higher-order bit is always 0)
         check_map=(m_extr_map>>i)&3;
         if(inp_map!=check_map)
            return(false);
        }
      //--- "take" two bits - pattern of the corresponding oscillator extremum
      inp_map=(map>>(j+2))&3;
      //--- if the higher-order bit=1, then any ratio is suitable for us
      if(inp_map>=2)
         continue;
      //--- "take" two bits of the corresponding oscillator extremum (higher-order bit is always 0)
      check_map=(m_extr_map>>(i+2))&3;
      if(inp_map!=check_map)
         return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalBHRSI::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//--- check direction of the main line
   if(DiffMain(idx)>0.0)
     {
      //--- the main line is directed upwards, and it confirms the possibility of price growth
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;      // "confirming" signal number 0
      //--- if the model 1 is used, look for a reverse of the main line
      if(IS_PATTERN_USAGE(1) && DiffMain(idx+1)<0.0)
         result=m_pattern_1;      // signal number 1
      //--- if the model 2 is used, look for an intersection of the main and signal line
      if(IS_PATTERN_USAGE(2) && State(idx)>0.0 && State(idx+1)<0.0)
         result=m_pattern_2;      // signal number 2
      //--- if the model 3 is used, look for an intersection of the main line and the zero level
      if(IS_PATTERN_USAGE(3) && Main(idx)>0.0 && Main(idx+1)<0.0)
         result=m_pattern_3;      // signal number 3
      //--- if the models 4 or 5 are used and the main line turned upwards below the zero level, look for divergences
      if((IS_PATTERN_USAGE(4) || IS_PATTERN_USAGE(5)) && Main(idx)<0.0)
        {
         //--- perform the extended analysis of the oscillator state
         ExtState(idx);
         //--- if the model 4 is used, look for the "divergence" signal
         if(IS_PATTERN_USAGE(4) && CompareMaps(1,1)) // 0000 0001b
            result=m_pattern_4;   // signal number 4
         //--- if the model 5 is used, look for the "double divergence" signal
         if(IS_PATTERN_USAGE(5) && CompareMaps(0x11,2)) // 0001 0001b
            return(m_pattern_5);  // signal number 5
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalBHRSI::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//--- check direction of the main line
   if(DiffMain(idx)<0.0)
     {
      //--- main line is directed downwards, confirming a possibility of falling of price
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;      // "confirming" signal number 0
      //--- if the model 1 is used, look for a reverse of the main line
      if(IS_PATTERN_USAGE(1) && DiffMain(idx+1)>0.0)
         result=m_pattern_1;      // signal number 1
      //--- if the model 2 is used, look for an intersection of the main and signal line
      if(IS_PATTERN_USAGE(2) && State(idx)<0.0 && State(idx+1)>0.0)
         result=m_pattern_2;      // signal number 2
      //--- if the model 3 is used, look for an intersection of the main line and the zero level
      if(IS_PATTERN_USAGE(3) && Main(idx)<0.0 && Main(idx+1)>0.0)
         result=m_pattern_3;      // signal number 3
      //--- if the models 4 or 5 are used and the main line turned downwards above the zero level, look for divergences
      if((IS_PATTERN_USAGE(4) || IS_PATTERN_USAGE(5)) && Main(idx)>0.0)
        {
         //--- perform the extended analysis of the oscillator state
         ExtState(idx);
         //--- if the model 4 is used, look for the "divergence" signal
         if(IS_PATTERN_USAGE(4) && CompareMaps(1,1)) // 0000 0001b
            result=m_pattern_4;   // signal number 4
         //--- if the model 5 is used, look for the "double divergence" signal
         if(IS_PATTERN_USAGE(5) && CompareMaps(0x11,2)) // 0001 0001b
            return(m_pattern_5);  // signal number 5
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
