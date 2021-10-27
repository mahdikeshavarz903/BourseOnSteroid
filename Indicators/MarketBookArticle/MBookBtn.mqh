//+------------------------------------------------------------------+
//|                                                   MBookBtn.mqh   |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <../Shared Projects/BourseOnSteroid/Include/Trade/MarketBook.mqh>
#include <../Shared Projects/BourseOnSteroid/Include/Panel/ElButton.mqh>
#include <../Shared Projects/BourseOnSteroid/Include/Panel/Events/EventRefresh.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Scrolls.mqh>
#include "MBookGraphTable.mqh"
#include "MBookArea.mqh"
input int XDistance = 120;
input int YDistance = 0;

//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (100)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//--- for the indication area
#define EDIT_HEIGHT                         (20)      // size by Y coordinate
//--- for group controls
#define GROUP_WIDTH                         (150)     // size by X coordinate
#define LIST_HEIGHT                         (179)     // size by Y coordinate
#define RADIO_HEIGHT                        (56)      // size by Y coordinate
#define CHECK_HEIGHT                        (93)      // size by Y coordinate
//+------------------------------------------------------------------+
//| The class represents a button on chart top, a click on it        |
//| shows the panel with a tick chart and an order book .            |
//| A repeated click on it hides the panel.                          |
//+------------------------------------------------------------------+
class CMBookBtn : public CElButton
  {
private:
   CMBookArea        m_book_area;
   bool              m_showed_book;
   CScrollH          *m_scroll_v;                     // CScrollH object
   int               counter;
public:
                     CMBookBtn();
   void              SetMarketBookSymbol(string symbol);
   void              Refresh();
   void              Event(int id,long lparam,double dparam,string sparam);
   void              Clear(void);
   virtual void      OnShow(void);
   //--- handlers of the dependent controls events
   void              OnScrollInc(void);
   void              OnScrollDec(void);
   bool              CreateScrollsH(void);
  };

//+------------------------------------------------------------------+
//| When creating an instance, no need to specify required properties|
//+------------------------------------------------------------------+
CMBookBtn::CMBookBtn()
  {
   m_showed_book=false;
   Width(100);
   Height(30);
   XCoord(XDistance);
   YCoord(YDistance);
   TextFont("Webdings");
   Text(CharToString(0x36));
   m_book_area.XCoord(10);
   m_book_area.YCoord(20);
   m_book_area.Height(1000);
   m_book_area.Width(1800);
   m_elements.Add(&m_book_area);
   counter = 0;
  }
//+------------------------------------------------------------------+
//| Intercept the mouse click on the button.   If the button after   |
//| the click is in the pressed state, show the panel. If it is      |
//| unpressed - hide the panel                                       |
//+------------------------------------------------------------------+
void CMBookBtn::Event(int id,long lparam,double dparam,string sparam)
  {
   switch(id)
     {
      case CHARTEVENT_OBJECT_CLICK:
        {
         if(sparam==m_name)
           {
            if(State()==PUSH_ON)
              {
               m_book_area.Show();
              }
            else
               m_book_area.Hide();
            m_showed_book=!m_showed_book;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Refresh graphics with a direct command                           |
//+------------------------------------------------------------------+
void CMBookBtn::Refresh()
  {
   CEventRefresh *refresh=new CEventRefresh();
   m_book_area.Event(refresh);
   m_book_area.Update(refresh);
   delete refresh;

   if(ArraySize(MarketBook.MarketBook)!=0 && State()==PUSH_ON)
      //if(State()==PUSH_ON)
     {
      if(counter==10)
        {
         //if(!CreateScrollsH())
         //   Print("");
         
         updateTableFlag=true;
         
         counter++;
        }
      else if(counter==20)
      {
         enterOnShowFunction=false;
         counter++;
      }
      else
         if(counter<=100)
           {
            counter++;
           }
     }
  }
//+------------------------------------------------------------------+
//| Halt the output of child elements (of market depth) till clicking|
//| on the panel show/hide button. Thus   at the moment of launch    |
//| the panel does not open.                                         |
//+------------------------------------------------------------------+
void CMBookBtn::OnShow(void)
  {
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Create the CScrollsH object                                      |
//+------------------------------------------------------------------+
bool CMBookBtn::CreateScrollsH(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+3*BUTTON_WIDTH;
   int y2=y1+18;
//--- create
   if(!m_scroll_v.Create(0,"Controls",0,40,40,380,344))
      return(false);
//--- set up the scrollbar
   m_scroll_v.MinPos(0);
//--- set up the scrollbar
   m_scroll_v.MaxPos(10);
   if(!m_book_area.AddElement(m_scroll_v))
      return(false);
   Comment("Position of the scrollbar ",m_scroll_v.CurrPos());
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CMBookBtn::OnScrollInc(void)
  {
   Comment("Position of the scrollbar ",m_scroll_v.CurrPos());
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CMBookBtn::OnScrollDec(void)
  {
   Comment("Position of the scrollbar ",m_scroll_v.CurrPos());
  }
//+------------------------------------------------------------------+
