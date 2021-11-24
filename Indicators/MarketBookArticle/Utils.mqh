//+------------------------------------------------------------------+
//|                                                        utils.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

class CUtils
{
   public:
      CUtils();
      string      CommaSeparator(string value);
};

CUtils::CUtils(void)
{}

string CUtils::CommaSeparator(string value)
  {
   uchar str[];
   string temp = "";
   int valLength;
   
   valLength = StringLen(value);
   StringToCharArray(IntegerToString(value), str);
   
   for(int i=valLength; i>0; i-=3)
     {
      temp = StringSubstr(value, (i-3>=0)?i-3:0, (i-3>=0)?3:i) + ((temp!="" && str[i-1]!= '-')?",":"") + temp;
     }
     
     return temp;
  }