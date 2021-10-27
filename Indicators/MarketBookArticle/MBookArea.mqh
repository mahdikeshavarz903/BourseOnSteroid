//+------------------------------------------------------------------+
//|                                                    MBookArea.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <../Shared Projects/BourseOnSteroid/Include/Panel/ElChart.mqh>
#include <../Shared Projects/BourseOnSteroid/Include/Trade/MarketBook.mqh>
#include "GlobalMarketBook.mqh"
#include "MBookGraphTable.mqh"
#include "TickGraph.mqh"
//+------------------------------------------------------------------+
//| Marks a global graphical area for drawing a tick chart and       |
//| the order book of the Market Depth                               |
//+------------------------------------------------------------------+
class CMBookArea : public CElChart
  {
private:
   CElTickGraph      m_tick_graf;       // Tick chart
   CBookGraphTable   m_market_table;    // The order book table
   virtual void      OnShow(void);
   virtual void      OnRefresh(CEventRefresh *event);
protected:
   virtual void      OnXCoordChange(void);
   virtual void      OnYCoordChange(void);

public:
                     CMBookArea(void);
                     CMBookArea(CMarketBook *book);
           void      Update(CEventRefresh *event);
   
   //virtual void   Event(CEvent* event);
  };
//+------------------------------------------------------------------+
//| Positions Market Depth objects                                   |
//+------------------------------------------------------------------+
CMBookArea::CMBookArea(void) : CElChart(OBJ_EDIT)
  {
   m_market_table.Width(300);
   m_market_table.BorderType(BORDER_FLAT);
   m_market_table.BackgroundColor(clrWhite);
   m_market_table.BorderColor(clrWhite);
   m_tick_graf.Width(550);
   m_tick_graf.Height(602);
   m_elements.Add(&m_tick_graf);
   m_elements.Add(&m_market_table);
  }
//+------------------------------------------------------------------+
//| Positioning internal elements along the X axes                   |
//+------------------------------------------------------------------+
void CMBookArea::OnXCoordChange(void)
  {
   m_market_table.XCoord(XCoord()+Width()-700);
   m_tick_graf.XCoord(XCoord()+10);
  }
//+------------------------------------------------------------------+
//| Positioning internal elements along the Y axes                   |
//+------------------------------------------------------------------+
void CMBookArea::OnYCoordChange(void)
  {
   m_market_table.YCoord(YCoord()+1);
   m_tick_graf.YCoord(YCoord()+10);
  }
//+------------------------------------------------------------------+
//| Adjusts the height depending on the number of orders             |
//| In the Market Depth                                              |
//+------------------------------------------------------------------+
void CMBookArea::OnShow(void)
  {
   CElChart::OnShow();
   CEventRefresh *event=new CEventRefresh();
   OnRefresh(event);
   delete event;
  }
//+------------------------------------------------------------------+
//| Positions the Market Depth along Y so as its middle is           |
//| always at the same level, i.e. approximately at the middle of    |
//| the canvas                                                       |
//+------------------------------------------------------------------+
void CMBookArea::OnRefresh(CEventRefresh *event)
  {
   m_market_table.YCoord(YCoord()+1);
   long y_coord = m_market_table.YCoord();
   long central = m_market_table.YCenterDelta();
   //long need_central=(this.Height()/10);
   long need_central=65;
   long delta= need_central-central;
   long cons = YCoord()+1+delta;
   m_market_table.YCoord(YCoord()+1+delta);
  }

/*void CMBookArea::Event(CEvent *event)
{
   CElChart::Event(event)
   if(event.EventType() == EVENT_CHART_USER)
}*/
//+------------------------------------------------------------------+
void CMBookArea::Update(CEventRefresh *event)
{
   m_market_table.OnShow();
   m_market_table.OnRefresh(event);
}