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
#include "GlobalMainTable.mqh"
#include "MBookGraphTable.mqh"
#include "TickGraph.mqh"
#include "../../Include/Scrolls.mqh"
#include "../../Include/Element.mqh"
#include "../../Include/Window.mqh"
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
   bool              CreateScrollV(void);
   void              ShiftList(void);
   void              ResetItemsColor(void);
   CScrollV          *GetScrollVPointer(void);
   bool              ScrollState(void);
   
   //--- Left mouse button state (pressed/released)
   bool              m_mouse_state;
   //--- Objects for creating a list
   CRectLabel        m_area;
   //CEdit             m_items[];
   CScrollV          m_scrollv;
   //--- Array of list values
   string            m_value_items[];
   //--- Sizes of the list and its visible part
   int               m_items_total;
   int               m_visible_items_total;
   //--- (1) Index and (2) text of the selected item
   int               m_selected_item_index;
   string            m_selected_item_text;
   //--- Properties of the list background
   int               m_area_zorder;
   color             m_area_border_color;
   //--- Pointer to the form to which the element is attached
   CWindow           *m_wnd;
   //--- Properties of the list items
   int               m_item_zorder;
   int               m_item_y_size;
   color             m_item_color;
   color             m_item_color_hover;
   color             m_item_color_selected;
   color             m_item_text_color;
   color             m_item_text_color_hover;
   color             m_item_text_color_selected;
protected:
   virtual void      OnXCoordChange(void);
   virtual void      OnYCoordChange(void);

public:
                     CMBookArea(void);
                     CMBookArea(CMarketBook *book);
   void              Update(CEventRefresh *event);
   void              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

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
//m_elements.Add(&m_tick_graf);
   m_elements.Add(&m_market_table);
   m_elements.Add(&m_scrollv);
   m_items_total = 200;
   m_visible_items_total = 36;

   //if(!CreateScrollV())
   //   Print("");

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
//+-------------------------------------------------------------------------------+
//| A function that determines the size of the volume                             |
//+-------------------------------------------------------------------------------+
CScrollV *CMBookArea::GetScrollVPointer(void)
  {
   return(::GetPointer(m_scrollv));
  }

//--- Scrollbar state
bool  CMBookArea::ScrollState(void)
  {
   return(m_scrollv.ScrollState());
  }
//+------------------------------------------------------------------+
//| Create vertical scroll bar                                       |
//+------------------------------------------------------------------+
bool CMBookArea::CreateScrollV(void)
  {
//--- If the number of items is greater than the list size,
//    set the vertical scrolling
   if(m_items_total<=m_visible_items_total)
      return(true);
//--- Store the form pointer
   m_scrollv.WindowPointer(m_market_table);
//--- Coordinates
   int x=1560;
   int y=30;
//--- Set properties
   m_scrollv.Id(0);
   m_scrollv.XSize(m_scrollv.ScrollWidth());
   m_scrollv.YSize(760);
   m_scrollv.AreaBorderColor(m_area_border_color);
   m_scrollv.IsDropdown(true);
//--- Create scrollbar
   if(!m_scrollv.CreateScroll(0,0,x,y,m_items_total,m_visible_items_total))
      return(false);
//---
   return(true);
  }

//+------------------------------------------------------------------+
//| Reset the list items color                                       |
//+------------------------------------------------------------------+
void CMBookArea::ResetItemsColor(void)
  {
//--- Get the current position of the scrollbar slider
   int v=m_scrollv.CurrentPos();
//--- Iterate over the visible part of the list
   for(int i=0; i<m_visible_items_total; i++)
     {
      //--- Increase the counter if the list view range has not been exceeded
      if(v>=0 && v<m_items_total)
         v++;
      //--- Skip the selected item
      if(m_selected_item_index==v-1)
         continue;
      //--- Setting the color (background, text)
      //m_items[i].BackColor(m_item_color);
      //m_items[i].Color(m_item_text_color);
     }
  }
//+------------------------------------------------------------------+
//| Moves the list view along the scrollbar                          |
//+------------------------------------------------------------------+
void CMBookArea::ShiftList(void)
  {
//--- Get the current position of the scrollbar slider
   int v=m_scrollv.CurrentPos();
//--- Iterate over the visible part of the list
   for(int i=0; i<m_visible_items_total; i++)
     {
      //--- If inside the range of the list view
      if(v>=0 && v<m_items_total)
        {
          m_market_table.ShiftCells(v, v+m_visible_items_total);
         //--- Moving the text, the background color and the text color
         //m_items[i].Description(m_value_items[v]);
         //m_items[i].BackColor((m_selected_item_index==v) ? m_item_color_selected : m_item_color);
         //m_items[i].Color((m_selected_item_index==v) ? m_item_text_color_selected : m_item_text_color);
         //--- Increase the counter
         v++;
        }
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CMBookArea::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Object click handling
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- If a button of the list scrollbar was pressed
      if(m_scrollv.OnClickScrollInc("MarketBook_scrollv_inc_0") || m_scrollv.OnClickScrollDec(sparam))
        {
         //--- Shift the list relative to the scrollbar
         ShiftList();
         return;
        }
     }
  }
//+------------------------------------------------------------------+
