//+------------------------------------------------------------------+
//|                                                 RequestOrder.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <Object.mqh>

enum OrderType
  {
   LIMIT=0,
   STOP_LIMIT=1,
   MARKET=2
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CRequestOrder : public CObject
  {
private:
   bool              m_cautionAgreementSelected;
   int               m_financialProviderId;
   bool              m_isSymbolCautionAgreement;
   bool              m_isSymbolSepahAgreement;
   bool              m_sepahAgreementSelected;
   string            m_isin;
   int               m_maxShow;
   int               m_minimumQuantity;
   int               m_orderCount;
   string            m_orderId;
   double            m_price;
   string            m_orderSide;
   int               m_orderValidity;
   string            m_orderValidityDate;
   int               m_shortSellIncentivePercent;
   bool              m_shortSellIsEnabled;
   OrderType         m_orderType;
   
public:
                     CRequestOrder();
   
   void              SetOrderType(OrderType orderType)
     {
      m_orderType = orderType;
     }

   OrderType               GetOrderType()
     {
      return m_orderType;
     }
     
   void              SetPrice(double price)
     {
      m_price = price;
     }

   double               GetPrice()
     {
      return m_price;
     }

   void              SetCautionAgreementSelected(bool cautionAgreementSelected)
     {
      m_cautionAgreementSelected = cautionAgreementSelected;
     }

   bool              GetCautionAgreementSelected()
     {
      return m_cautionAgreementSelected;
     }

   void              SetFinancialProviderId(bool financialProviderId)
     {
      m_financialProviderId = financialProviderId;
     }

   bool              GetFinancialProviderId()
     {
      return m_financialProviderId;
     }

   void              SetIsSymbolCautionAgreement(bool isSymbolCautionAgreement)
     {
      m_isSymbolCautionAgreement = isSymbolCautionAgreement;
     }

   bool              GetIsSymbolCautionAgreement()
     {
      return m_isSymbolCautionAgreement;
     }

   void              SetSepahAgreementSelected(bool sepahAgreementSelected)
     {
      m_sepahAgreementSelected = sepahAgreementSelected;
     }

   bool              GetSepahAgreementSelected()
     {
      return m_sepahAgreementSelected;
     }
   
   void              SetIsSymbolSepahAgreement(bool isSymbolSepahAgreement)
     {
      m_isSymbolSepahAgreement = isSymbolSepahAgreement;
     }

   bool              GetIsSymbolSepahAgreement()
     {
      return m_isSymbolSepahAgreement;
     }
     
   void              SetIsin(string isin)
     {
      m_isin = isin;
     }

   string              GetIsin()
     {
      return m_isin;
     }

   void              SetMaxShow(int maxShow)
     {
      m_maxShow = maxShow;
     }

   int               GetMaxShow()
     {
      return m_maxShow;
     }

   void              SetMinimumQuantity(int minimumQuantity)
     {
      m_minimumQuantity = minimumQuantity;
     }

   int               GetMinimumQuantity()
     {
      return m_minimumQuantity;
     }

   void              SetOrderCount(int orderCount)
     {
      m_orderCount = orderCount;
     }

   int               GetOrderCount()
     {
      return m_orderCount;
     }

   void              SetOrderId(string orderId)
     {
      m_orderId = orderId;
     }

   string             GetOrderId()
     {
      return m_orderId;
     }

   void              SetOrderSide(string orderSide)
     {
      m_orderSide = orderSide;
     }

   string             GetOrderSide()
     {
      return m_orderSide;
     }

   void              SetOrderValidity(int orderValidity)
     {
      m_orderValidity = orderValidity;
     }

   int               GetOrderValidity()
     {
      return m_orderValidity;
     }

   void              SetOrderValidityDate(string orderValidityDate)
     {
      m_orderValidityDate = orderValidityDate;
     }

   string             GetOrderValidityDate()
     {
      return m_orderValidityDate;
     }

   void              SetShortSellIncentivePercent(int shortSellIncentivePercent)
     {
      m_shortSellIncentivePercent = shortSellIncentivePercent;
     }

   int               GetShortSellIncentivePercent()
     {
      return m_shortSellIncentivePercent;
     }

      void              SetShortSellIsEnabled(bool shortSellIsEnabled)
     {
      m_shortSellIsEnabled = shortSellIsEnabled;
     }

   bool               GetShortSellIsEnabled()
     {
      return m_shortSellIsEnabled;
     }
     
  };
//+------------------------------------------------------------------+
CRequestOrder::CRequestOrder()
{}