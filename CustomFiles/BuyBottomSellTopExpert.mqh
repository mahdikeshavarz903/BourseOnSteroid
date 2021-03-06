//+------------------------------------------------------------------+
//|                                       BuyBottomSellTopExpert.mqh |
//|                                           Copyright 2016, denkir |
//|                             https://www.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, denkir"
#property link      "https://www.mql5.com/ru/users/denkir"
//---
#include <Expert\Expert.mqh>
#include <Trade\Trade.mqh>
#include <Expert\ExpertBase.mqh>
#include <Expert\ExpertTrade.mqh>
#include <Expert\ExpertSignal.mqh>
#include <Expert\ExpertMoney.mqh>
#include <Expert\ExpertTrailing.mqh>
//+------------------------------------------------------------------+
//| CBuyBottomSellTopExpert class.                                   |
//| Purpose: Class for EA that trades based on equidistant channel.  |
//| Derived from the CExper class.                                   |
//+------------------------------------------------------------------+
class CBuyBottomSellTopExpert : public CExpert
  {
   //--- === Data members === ---
private:
   //--- trading objects
   //CExpertTrade      *m_trade;                    // trading object


   //--- === Methods === ---
public:
   //--- constructor/destructor
   void              CBuyBottomSellTopExpert(void) {};
   void             ~CBuyBottomSellTopExpert(void) {};
   virtual void      OnTimer(void);
   virtual bool      InitTrade(ulong magic,CExpertTrade *trade=NULL);
   void              Get_Indicators(CIndicators *cIndicators) {cIndicators = GetPointer(m_indicators);};
   
protected:
   virtual bool      Processing(void);
   virtual bool      SelectPosition(void);

  };
//+------------------------------------------------------------------+
//| Main module                                                      |
//+------------------------------------------------------------------+
bool CBuyBottomSellTopExpert::Processing(void)
  {
//--- calculate signal direction once
   m_signal.SetDirection();
//--- check if open positions
   if(SelectPosition())
     {
      //--- open position is available
      //--- check the possibility of reverse the position
      if(CheckReverse())
         return(true);
      //--- check the possibility of closing the position/delete pending orders
      if(!CheckClose())
        {
         //--- check the possibility of modifying the position
         if(CheckTrailingStop())
            return(true);
         //--- return without operations
         return(false);
        }
     }
//--- check if plased pending orders
   int total=OrdersTotal();
   if(total!=0)
     {
      for(int i=total-1; i>=0; i--)
        {
         m_order.SelectByIndex(i);
         if(m_order.Symbol()!=m_symbol.Name())
            continue;
         if(m_order.OrderType()==ORDER_TYPE_BUY_LIMIT || m_order.OrderType()==ORDER_TYPE_BUY_STOP)
           {
            //--- check the ability to delete a pending order to buy
            if(CheckDeleteOrderLong())
               return(true);
            //--- check the possibility of modifying a pending order to buy
            if(CheckTrailingOrderLong())
               return(true);
           }
         else
           {
            //--- check the ability to delete a pending order to sell
            if(CheckDeleteOrderShort())
               return(true);
            //--- check the possibility of modifying a pending order to sell
            if(CheckTrailingOrderShort())
               return(true);
           }
         //--- return without operations
         return(false);
        }
     }
//--- check the possibility of opening a position/setting pending order
   if(CheckOpen())
      return(true);
//--- return without operations
   return(false);

  }

//+------------------------------------------------------------------+
//| OnTimer handler                                                  |
//+------------------------------------------------------------------+
void CBuyBottomSellTopExpert::OnTimer(void)
  {
//--- check process flag
   if(!m_on_timer_process)
      return;
   Processing();
  }

//+------------------------------------------------------------------+
//| Position select depending on netting or hedging                  |
//+------------------------------------------------------------------+
bool CBuyBottomSellTopExpert::SelectPosition(void)
  {
   bool res=false;
//---
   if(IsHedging())
      res=m_position.SelectByMagic(m_symbol.Name(),m_magic);
   else
      res=m_position.Select(m_symbol.Name());
//---
   return(res);
  }

//+------------------------------------------------------------------+
//| Initialization trade object                                      |
//+------------------------------------------------------------------+
bool CBuyBottomSellTopExpert::InitTrade(ulong magic,CExpertTrade *trade=NULL)
  {
//--- удаляем существующий объект
   if(m_trade!=NULL)
      delete m_trade;
//---
   if(trade==NULL)
     {
      if((m_trade=new CExpertTrade)==NULL)
         return(false);
     }
   else
      m_trade=trade;
//--- tune trade object
   m_trade.SetSymbol(GetPointer(m_symbol));
   m_trade.SetExpertMagicNumber(magic);
   m_trade.SetMarginMode();

//CustomCExpertTrade *expertTrade = new CustomCExpertTrade();
//expertTrade.m_request.action = TRADE_ACTION_PENDING;
//expertTrade.m_request.type = ORDER_TYPE_BUY_LIMIT;
//--- set default deviation for trading in adjusted points
   m_trade.SetDeviationInPoints((ulong)(3*m_adjusted_point/m_symbol.Point()));
//--- ok
   return(true);
  }

