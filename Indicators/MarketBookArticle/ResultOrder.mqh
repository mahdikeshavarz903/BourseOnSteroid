//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <Object.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CResultOrder : public CObject
  {
private:
   double            m_price;
   string            m_nsccode;
   int               m_orderType;
   string            m_caseType;
   string            m_time;
   int               m_currentVolumePosition;
   int               m_volumePosition;
   string            m_symbol;
   string            m_symbolId;
   double            m_lastTradePrice;
   string            m_coreTime;
   string            m_coreDate;
   string            m_customerid;
   string            m_providerName;
   string            m_providerId;
   string            m_orderId;
   string            m_ordervl;
   string            m_gtIate;
   string            m_gtdateMiladi;
   int               m_qunatity;
   int               m_expectedQuantity;
   int               m_excuted;
   int               m_status;
   int               m_visible;
   string            m_customername;
   string            m_orderFrom;
   int               m_minimumQuantity;
   string            m_maxShow;
   string            m_hostOrderId;
   string            m_orderEntryDate;
   int               m_state;
   int               m_errorcode;
   int               m_remain;

public:
                     CResultOrder();
                    
   void              SetPrice(double price)
     {
      m_price = price;
     }

   double               GetPrice()
     {
      return m_price;
     }

  };
//+------------------------------------------------------------------+
CResultOrder::CResultOrder()
  {}
//+------------------------------------------------------------------+
