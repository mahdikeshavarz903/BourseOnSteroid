//+------------------------------------------------------------------+
//|                                                   MBookPanel.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <../Shared Projects/BourseOnSteroid/Include/Panel/Events/Event.mqh>
//+------------------------------------------------------------------+
//| "New tick" user event                                            |
//+------------------------------------------------------------------+
class CEventNewTick : public CEvent
{
private:
   MqlTick     m_tick;
public:
               CEventNewTick(void);
               CEventNewTick(MqlTick& tick);
   void        SetNewTick(MqlTick& tick);
   void        GetNewTick(MqlTick& tick);
   
};
//+------------------------------------------------------------------+
//| "New tick" user event                                            |
//+------------------------------------------------------------------+
CEventNewTick::CEventNewTick(void) : CEvent(EVENT_CHART_CUSTOM)
{
}
//+------------------------------------------------------------------+
//| "New tick" user event                                            |
//+------------------------------------------------------------------+
CEventNewTick::CEventNewTick(MqlTick& tick) : CEvent(EVENT_CHART_CUSTOM)
{
   m_tick = tick;
}
void CEventNewTick::GetNewTick(MqlTick &tick)
{
   tick = m_tick;
}
void CEventNewTick::SetNewTick(MqlTick &tick)
{
   m_tick = tick;
}