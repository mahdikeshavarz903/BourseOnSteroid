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
public:
                     CMBookBtn();
   void              SetMarketBookSymbol(string symbol);
   void              Refresh();
   void              Event(int id,long lparam,double dparam,string sparam);
   void              Clear(void);
   virtual void      OnShow(void);
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
   m_book_area.Width(1500);
   m_elements.Add(&m_book_area);
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
               m_book_area.Show();
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
