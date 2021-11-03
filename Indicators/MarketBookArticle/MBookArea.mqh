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
   int               m_visible_items_total;
   int               m_items_total; 
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
   //--- Scrollbar state
   bool              ScrollState(void)                             const { return(m_scrollv.ScrollState()); };
   void              ShowScrollbar(void);
   void              ShiftList(void);
   void              ChangeItemsColor(const int x,const int y);
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
   m_items_total=37;
   m_visible_items_total = 36;

   if(!CreateScrollV())
      Print("");

   ShowScrollbar();
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
   if(m_items_total_size!=m_items_total && m_items_total_size!=2)
    {
      m_items_total = m_items_total_size;
      m_scrollv.ChangeThumbSize(m_items_total, m_visible_items_total);
   }
   
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

   startIndex = v;
   endIndex = v+m_visible_items_total;
   
   m_market_table.ShiftCells(v, v+m_visible_items_total, true);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CMBookArea::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Coordinates and the state of the left mouse button
      int x=(int)lparam;
      int y=(int)dparam;
      m_mouse_state=(bool)int(sparam);
      
      //--- Shift the list if the scroll box control is active
      if(m_scrollv.ScrollBarControl(x,y,m_mouse_state))
         ShiftList();
         
      //--- Change the color of list items when hovered
      //ChangeItemsColor(x,y);
      return;
     }

//--- Object click handling
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- If a button of the list scrollbar was pressed
      if(m_scrollv.OnClickScrollInc(sparam) || m_scrollv.OnClickScrollDec(sparam))
        {
         //--- Shift the list relative to the scrollbar
         ShiftList();
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//| Changing color of the list view item when hovered                |
//+------------------------------------------------------------------+
void CMBookArea::ChangeItemsColor(const int x,const int y)
  {
//--- Leave, if the highlighting of the item when the cursor is hovering over it is disabled or the scrollbar is active
   if(m_scrollv.ScrollState())
      return;

//--- Get the current position of the scrollbar slider
   int v=m_scrollv.CurrentPos();
   
//--- Identify over which item the cursor is over and highlight it
   for(int i=0; i<m_visible_items_total; i++)
     {
      //--- Increase the counter if the list view range has not been exceeded
      if(v>=0 && v<m_items_total)
         v++;
     }
  }  
//+------------------------------------------------------------------+
//| Show the list                                                    |
//+------------------------------------------------------------------+
void CMBookArea::ShowScrollbar(void)
  {
//--- Show the scrollbar
   //m_scrollv.Show();
  }

/*
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CListView::Moving(const int x,const int y)
  {
//--- Leave, if the element is hidden
   if(!CElement::IsVisible())
      return;
//--- Storing indents in the element fields
   CElement::X(x+XGap());
   CElement::Y(y+YGap());
//--- Storing coordinates in the fields of the objects
   m_area.X(x+m_area.XGap());
   m_area.Y(y+m_area.YGap());
//--- Updating coordinates of graphical objects
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
//---
   for(int r=0; r<m_visible_items_total; r++)
     {
      //--- Storing coordinates in the fields of the objects
      m_items[r].X(x+m_items[r].XGap());
      m_items[r].Y(y+m_items[r].YGap());
      //--- Updating coordinates of graphical objects
      m_items[r].X_Distance(m_items[r].X());
      m_items[r].Y_Distance(m_items[r].Y());
     }
  }
*/
//+------------------------------------------------------------------+
