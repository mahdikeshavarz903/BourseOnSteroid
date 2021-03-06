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
   long terminalScreenHeight = TerminalInfoInteger(TERMINAL_SCREEN_HEIGHT);
   long terminalScreenWidth = TerminalInfoInteger(TERMINAL_SCREEN_WIDTH);

   terminalScreenWidth = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS, 0);
   terminalScreenHeight = ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS, 0);

   m_showed_book=false;
   Width(100);
   Height(30);
   XCoord(XDistance);
   YCoord(YDistance);
   TextFont("Webdings");
   Text(CharToString(0x36));
   m_book_area.XCoord(10);
   m_book_area.YCoord(20);
   m_book_area.Height(terminalScreenHeight);
   m_book_area.Width(terminalScreenWidth);
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
      case CHARTEVENT_KEYDOWN:
        {
         m_book_area.OnEvent(id, lparam, dparam, sparam);
         break;
        }
      case CHARTEVENT_MOUSE_MOVE:
        {
         m_book_area.OnEvent(id, lparam, dparam, sparam);
         break;
        }
      case CHARTEVENT_MOUSE_WHEEL:
        {
         m_book_area.OnEvent(id, lparam, dparam, sparam);
         break;
        }
      case CHARTEVENT_OBJECT_CLICK:
        {
         m_book_area.OnEvent(id, lparam, dparam, sparam);

         if(sparam==m_name)
           {
            if(State()==PUSH_ON)
              {
               m_book_area.Show();

               if(!m_book_area.CreateEdit())
                  Print("There is an Error in creating EditBox");

               if(!m_book_area.CreateLabel())
                  Print("There is an Error in creating LabelBox");
              }
            else
               m_book_area.Hide();
            m_showed_book=!m_showed_book;
           }

         break;
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
     {
      if(counter==10)
        {
         updateTableFlag=true;
         counter++;
        }
      else
         if(counter==20)
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
