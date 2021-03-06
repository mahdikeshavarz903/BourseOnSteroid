//+------------------------------------------------------------------+
//|                                                    MBookArea.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#define KEY_UP 38
#define KEY_I 73
#define KEY_J 74
#define KEY_L 76

#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <../Shared Projects/BourseOnSteroid/Include/Panel/ElChart.mqh>
#include <../Shared Projects/BourseOnSteroid/Include/Trade/MarketBook.mqh>
#include "GlobalMarketBook.mqh"
#include "GlobalMainTable.mqh"
#include "MBookGraphTable.mqh"
#include "TickGraph.mqh"
#include "GlobalUtils.mqh"
#include "../../Include/Scrolls.mqh"
#include "../../Include/Element.mqh"
#include "../../Include/Window.mqh"
//#include <Controls\Label.mqh>

bool scrollBarMoving=false;
bool changePositionOfScrollBar=true;
bool automaticScrolling=true;
int scrollBarX=0;
int scrollBarY=0;

int bidsPowerX=0;
int bidsPowerY=0;
int asksPowerX=0;
int asksPowerY=0;

int buyerPowerX=0;
int buyerPowerY=0;
int sellerPowerX=0;
int sellerPowerY=0;

int snapshotBidsPowerX=0;
int snapshotBidsPowerY=0;
int snapshotAsksPowerX=0;
int snapshotAsksPowerY=0;

int highestPricePowerX=0;
int highestPricePowerY=0;
int lowestPricePowerX=0;
int lowestPricePowerY=0;

int POWER_METERS_HEIGHT=500;
//int POWER_METERS_HEIGHT=700;
//+------------------------------------------------------------------+
//| Marks a global graphical area for drawing a tick chart and       |
//| the order book of the Market Depth                               |
//+------------------------------------------------------------------+
class CMBookArea : public CElChart
  {
private:
   CElTickGraph      m_tick_graf;       // Tick chart
   CBookGraphTable   m_market_table;    // The order book table
   CEdit             m_edit;            // CEdit object

   CLabel            m_label;           // CLabel object
   CLabel            m_portfolioLabel;  // CLabel object
   CLabel            m_portfolioValue;  // CLabel object
   CLabel            m_ninetyAverageVolumeLabel;  // CLabel object
   CLabel            m_ninetyAverageVolumeValue;  // CLabel object
   CLabel            m_sessionVolumeLabel;  // CLabel object
   CLabel            m_sessionVolumeValue;  // CLabel object
   CLabel            m_closingPriceLabel;  // CLabel object
   CLabel            m_closingPriceValue;  // CLabel object
   CLabel            m_yesterdayClosingPriceLabel;  // CLabel object
   CLabel            m_yesterdayClosingPriceValue;  // CLabel object
   CLabel            m_tomorrowHighLabel;  // CLabel object
   CLabel            m_tomorrowHighValue;  // CLabel object
   CLabel            m_tomorrowLowLabel;  // CLabel object
   CLabel            m_tomorrowLowValue;  // CLabel object
   CLabel            m_cashLabel;  // CLabel object
   CLabel            m_cashValue;  // CLabel object
   CLabel            m_lossProfitLabel;  // CLabel object
   CLabel            m_lossProfitValue;  // CLabel object

   CBookCell         *bidsPower;
   CBookCell         *asksPower;

   CBookCell         *sellerPower;
   CBookCell         *buyerPower;

   CBookCell         *snapshotBidsPower;
   CBookCell         *snapshotAsksPower;

   CBookCell         *highestPricePower;
   CBookCell         *lowestPricePower;

   virtual void      OnShow(void);
   virtual void      OnRefresh(CEventRefresh *event);
   bool              CreateScrollV(void);
   void              ResetItemsColor(void);
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
   CScrollV          *GetScrollVPointer(void)                       { return(::GetPointer(m_scrollv)); }
   CEdit             *GetEditBoxPointer(void)                       { return(::GetPointer(m_edit)); }
   bool              CreateEdit(void);
   bool              CreateLabel(void);
   //virtual void   Event(CEvent* event);
  };

//+------------------------------------------------------------------+
//| Positions Market Depth objects                                   |
//+------------------------------------------------------------------+
CMBookArea::CMBookArea(void) : CElChart(OBJ_EDIT)
  {
   terminalScreenWidth = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS, 0);
   terminalScreenHeight = ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS, 0);

   m_market_table.Width(300);
   m_market_table.BorderType(BORDER_FLAT);
   m_market_table.BackgroundColor(clrWhite);
   m_market_table.BorderColor(clrWhite);
   m_tick_graf.Width(550);
   m_tick_graf.Height(602);
//m_elements.Add(&m_tick_graf);
   m_elements.Add(&m_market_table);
   m_elements.Add(&m_scrollv);
//m_elements.Add(&m_edit);
   m_items_total=37;
   m_visible_items_total = 36;

   if(!CreateScrollV())
      Print("There is an Error in creating ScrollV");

   ShowScrollbar();

  }
//+------------------------------------------------------------------+
//| Create the "CLabel"                                              |
//+------------------------------------------------------------------+
bool CMBookArea::CreateLabel(void)
  {
//--- coordinates
   int x1=30;
   int y1=40;
//--- create
   if(!m_label.Create(ChartID(),m_name+"Label",0,x1,y1))
      return(false);

   m_label.FontSize(12);
   m_label.Color(clrWhite);
   m_label.Description("Shares : ");

   x1=30;
   y1=100;

   if(!m_portfolioLabel.Create(ChartID(),m_name+"PortfolioLabel",0,x1,y1))
      return(false);

   m_portfolioLabel.FontSize(12);
   m_portfolioLabel.Color(clrWhite);
   m_portfolioLabel.Description("Portfolio : ");

   x1=120;
   y1=100;

   if(!m_portfolioValue.Create(ChartID(),m_name+"PortfolioValue",0,x1,y1))
      return(false);

   m_portfolioValue.FontSize(12);
   m_portfolioValue.Color(clrRed);
   m_portfolioValue.Description("0");

   x1=30;
   y1=150;

   if(!m_sessionVolumeLabel.Create(ChartID(),m_name+"sessionVolumeLabel",0,x1,y1))
      return(false);

   m_sessionVolumeLabel.FontSize(12);
   m_sessionVolumeLabel.Color(clrWhite);
   m_sessionVolumeLabel.Description("Volume : ");

   x1=120;
   y1=150;

   if(!m_sessionVolumeValue.Create(ChartID(),m_name+"sessionVolumeValue",0,x1,y1))
      return(false);

   m_sessionVolumeValue.FontSize(12);
   m_sessionVolumeValue.Color(clrRed);
   m_sessionVolumeValue.Width(50);

   x1=30;
   y1=200;

   if(!m_ninetyAverageVolumeLabel.Create(ChartID(),m_name+"ninetyAverageVolumeLabel",0,x1,y1))
      return(false);

   m_ninetyAverageVolumeLabel.FontSize(12);
   m_ninetyAverageVolumeLabel.Color(clrWhite);
   m_ninetyAverageVolumeLabel.Description("Avg Vol : ");

   x1=120;
   y1=200;

   if(!m_ninetyAverageVolumeValue.Create(ChartID(),m_name+"ninetyAverageVolumeValue",0,x1,y1))
      return(false);

   m_ninetyAverageVolumeValue.FontSize(12);
   m_ninetyAverageVolumeValue.Color(clrRed);
   m_ninetyAverageVolumeValue.Width(50);

   x1=30;
   y1=250;

   if(!m_closingPriceLabel.Create(ChartID(),m_name+"closingPriceLabel",0,x1,y1))
      return(false);

   m_closingPriceLabel.FontSize(12);
   m_closingPriceLabel.Color(clrWhite);
   m_closingPriceLabel.Description("PC : ");

   x1=120;
   y1=250;

   if(!m_closingPriceValue.Create(ChartID(),m_name+"closingPriceValue",0,x1,y1))
      return(false);

   m_closingPriceValue.FontSize(12);
   m_closingPriceValue.Color(clrRed);
   m_closingPriceValue.Width(50);
   m_closingPriceValue.Description("0");

   x1=30;
   y1=300;

   if(!m_yesterdayClosingPriceLabel.Create(ChartID(),m_name+"yesterdayClosingPriceLabel",0,x1,y1))
      return(false);

   m_yesterdayClosingPriceLabel.FontSize(12);
   m_yesterdayClosingPriceLabel.Color(clrWhite);
   m_yesterdayClosingPriceLabel.Description("PY : ");

   x1=120;
   y1=300;

   if(!m_yesterdayClosingPriceValue.Create(ChartID(),m_name+"yesterdayClosingPriceValue",0,x1,y1))
      return(false);

   m_yesterdayClosingPriceValue.FontSize(12);
   m_yesterdayClosingPriceValue.Color(clrRed);
   m_yesterdayClosingPriceValue.Width(50);
   m_yesterdayClosingPriceValue.Description("0");

   x1=30;
   y1=350;

   if(!m_tomorrowHighLabel.Create(ChartID(),m_name+"tomorrowHighLabel",0,x1,y1))
      return(false);

   m_tomorrowHighLabel.FontSize(12);
   m_tomorrowHighLabel.Color(clrWhite);
   m_tomorrowHighLabel.Description("TH : ");

   x1=120;
   y1=350;

   if(!m_tomorrowHighValue.Create(ChartID(),m_name+"tomorrowHighValue",0,x1,y1))
      return(false);

   m_tomorrowHighValue.FontSize(12);
   m_tomorrowHighValue.Color(clrRed);
   m_tomorrowHighValue.Width(50);
   m_tomorrowHighValue.Description("0");

   x1=30;
   y1=400;

   if(!m_tomorrowLowLabel.Create(ChartID(),m_name+"tomorrowLowLabel",0,x1,y1))
      return(false);

   m_tomorrowLowLabel.FontSize(12);
   m_tomorrowLowLabel.Color(clrWhite);
   m_tomorrowLowLabel.Description("TL : ");

   x1=120;
   y1=400;

   if(!m_tomorrowLowValue.Create(ChartID(),m_name+"tomorrowLowValue",0,x1,y1))
      return(false);

   m_tomorrowLowValue.FontSize(12);
   m_tomorrowLowValue.Color(clrRed);
   m_tomorrowLowValue.Width(50);
   m_tomorrowLowValue.Description("0");

   x1=30;
   y1=450;

   if(!m_cashLabel.Create(ChartID(),m_name+"cashLabel",0,x1,y1))
      return(false);

   m_cashLabel.FontSize(12);
   m_cashLabel.Color(clrWhite);
   m_cashLabel.Description("Cash : ");

   x1=120;
   y1=450;

   if(!m_cashValue.Create(ChartID(),m_name+"cashValue",0,x1,y1))
      return(false);

   m_cashValue.FontSize(12);
   m_cashValue.Color(clrRed);
   m_cashValue.Width(50);
   m_cashValue.Description("1000000");

   x1=30;
   y1=500;

   if(!m_lossProfitLabel.Create(ChartID(),m_name+"lossProfitLabel",0,x1,y1))
      return(false);

   m_lossProfitLabel.FontSize(12);
   m_lossProfitLabel.Color(clrWhite);
   m_lossProfitLabel.Description("PNL : ");

   x1=120;
   y1=500;

   if(!m_lossProfitValue.Create(ChartID(),m_name+"lossProfitValue",0,x1,y1))
      return(false);

   m_lossProfitValue.FontSize(12);
   m_lossProfitValue.Color(clrRed);
   m_lossProfitValue.Width(50);
   m_lossProfitValue.Description("0");
//*************************************************************************************
   CEventRefresh *refresh=new CEventRefresh();

   asksPowerX=terminalScreenWidth-150;
   asksPowerY=50;

   asksPower = new CBookCell(4, asksPowerX, asksPowerY, "1", 0, "asksPower");
   asksPower.BackgroundColor(clrRed);
   asksPower.Width(30);
   asksPower.Height(POWER_METERS_HEIGHT/2);
   asksPower.BorderType(BORDER_RAISED);
   m_elements.Add(asksPower);
   asksPower.Show();
   asksPower.OnRefresh2(refresh);

   bidsPowerX=terminalScreenWidth-150;
   bidsPowerY=50+POWER_METERS_HEIGHT;

   bidsPower = new CBookCell(4, bidsPowerX, bidsPowerY, "1", 1, "bidsPower");
   bidsPower.BackgroundColor(clrBlue);
   bidsPower.Align(ALIGN_LEFT);
   bidsPower.Width(30);
   bidsPower.Height(-POWER_METERS_HEIGHT/2);
   bidsPower.BorderType(BORDER_RAISED);
   m_elements.Add(bidsPower);
   bidsPower.Show();
   bidsPower.OnRefresh2(refresh);

   sellerPowerX=terminalScreenWidth-200;
   sellerPowerY=50;

   sellerPower = new CBookCell(4, sellerPowerX, sellerPowerY, "1", 1, "sellerPower");
   sellerPower.Show();
   sellerPower.BackgroundColor(clrRed);
   sellerPower.Align(ALIGN_LEFT);
   sellerPower.Width(30);
   sellerPower.Height(POWER_METERS_HEIGHT/2);
   sellerPower.BorderType(BORDER_RAISED);
   m_elements.Add(sellerPower);
   sellerPower.OnRefresh2(refresh);

   buyerPowerX=terminalScreenWidth-200;
   buyerPowerY=50+POWER_METERS_HEIGHT;

   buyerPower = new CBookCell(4, buyerPowerX, buyerPowerY, "1", 0, "buyerPower");
   buyerPower.Show();
   buyerPower.BackgroundColor(clrBlue);
   buyerPower.Width(30);
   buyerPower.Height(-POWER_METERS_HEIGHT/2);
   buyerPower.BorderType(BORDER_RAISED);
   m_elements.Add(buyerPower);
   buyerPower.OnRefresh2(refresh);

   snapshotAsksPowerX=terminalScreenWidth-100;
   snapshotAsksPowerY=50;

   snapshotAsksPower = new CBookCell(4, snapshotAsksPowerX, snapshotAsksPowerY, "1", 0, "snapshotAsksPower");
   snapshotAsksPower.BackgroundColor(clrRed);
   snapshotAsksPower.Width(30);
   snapshotAsksPower.Height(POWER_METERS_HEIGHT/2);
   snapshotAsksPower.BorderType(BORDER_RAISED);
   m_elements.Add(snapshotAsksPower);
   snapshotAsksPower.Show();
   snapshotAsksPower.OnRefresh2(refresh);

   snapshotBidsPowerX=terminalScreenWidth-100;
   snapshotBidsPowerY=50+POWER_METERS_HEIGHT;

   snapshotBidsPower = new CBookCell(4, snapshotBidsPowerX, snapshotBidsPowerY, "1", 1, "snapshotBidsPower");
   snapshotBidsPower.BackgroundColor(clrBlue);
   snapshotBidsPower.Align(ALIGN_LEFT);
   snapshotBidsPower.Width(30);
   snapshotBidsPower.Height(-POWER_METERS_HEIGHT/2);
   snapshotBidsPower.BorderType(BORDER_RAISED);
   m_elements.Add(snapshotBidsPower);
   snapshotBidsPower.Show();
   snapshotBidsPower.OnRefresh2(refresh);

   highestPricePowerX=terminalScreenWidth-50;
   highestPricePowerY=50;

   highestPricePower = new CBookCell(4, highestPricePowerX, highestPricePowerY, "0", 0, "highestPricePower");
   highestPricePower.BackgroundColor(clrRed);
   highestPricePower.Width(30);
   highestPricePower.Height(POWER_METERS_HEIGHT/2);
   highestPricePower.BorderType(BORDER_RAISED);
   m_elements.Add(highestPricePower);
   highestPricePower.Show();
   highestPricePower.OnRefresh2(refresh);

   lowestPricePowerX=terminalScreenWidth-50;
   lowestPricePowerY=50+POWER_METERS_HEIGHT;

   lowestPricePower = new CBookCell(4, lowestPricePowerX, lowestPricePowerY, "0", 1, "lowestPricePower");
   lowestPricePower.BackgroundColor(clrBlue);
   lowestPricePower.Align(ALIGN_LEFT);
   lowestPricePower.Width(30);
   lowestPricePower.Height(-POWER_METERS_HEIGHT/2);
   lowestPricePower.BorderType(BORDER_RAISED);
   m_elements.Add(lowestPricePower);
   lowestPricePower.Show();
   lowestPricePower.OnRefresh2(refresh);

//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMBookArea::CreateEdit(void)
  {
//--- coordinates
   int x1=120;
   int y1=30;
   int x2=100;
   int y2=40;

//--- create
   if(!m_edit.Create(ChartID(),m_name+"Edit",0,x1,y1,x2,y2))
      return(false);
//--- allow editing the content
   if(!m_edit.ReadOnly(false))
      return(false);

   m_edit.BackColor(clrWhite);
   m_edit.FontSize(10);
   m_edit.Description("1000");
   m_edit.Color(clrBlack);
   m_edit.BorderColor(clrWhite);
   m_edit.TextAlign(ALIGN_CENTER);

//--- succeed
   return(true);
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
//int x=1180;
   int x=terminalScreenWidth-250;
   int y=30;
//--- Set properties
   m_scrollv.Id(0);
   m_scrollv.XSize(m_scrollv.ScrollWidth());
   m_scrollv.YSize(terminalScreenHeight-50);
   m_scrollv.AreaBorderColor(m_area_border_color);
   m_scrollv.IsDropdown(true);
//--- Create scrollbar
   if(!m_scrollv.CreateScroll(0,0,x,y,m_items_total,m_visible_items_total))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Positioning internal elements along the X axes                   |
//+------------------------------------------------------------------+
void CMBookArea::OnXCoordChange(void)
  {
//m_market_table.XCoord(XCoord()+Width()-1100);
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
}
*/
//+------------------------------------------------------------------+
void CMBookArea::Update(CEventRefresh *event)
  {
   double keys[];
   CMainTable *values[];
   cMainTable.CopyTo(keys, values, 0);

   int totalBidsVolumes = MarketBook.InfoGetInteger(MBOOK_BID_VOLUME_TOTAL);
   int totalAsksVolumes = MarketBook.InfoGetInteger(MBOOK_ASK_VOLUME_TOTAL);

   CMainTable *value;
   CEventRefresh *refresh = new CEventRefresh();

   if(asksPower!=NULL && (totalAsksVolumes!=0 || totalBidsVolumes!=0))
     {
      int asksPowerHeight=((float) totalAsksVolumes/(totalAsksVolumes+totalBidsVolumes))*POWER_METERS_HEIGHT;
      int bidsPowerHeight=asksPowerHeight-POWER_METERS_HEIGHT;

      asksPower.Hide();
      bidsPower.Hide();

      if(asksPowerHeight>=MathAbs(bidsPowerHeight))
        {
         asksPower.SetVariables(4, asksPowerX, asksPowerY, IntegerToString(totalAsksVolumes), 0);
         asksPower.Height(asksPowerHeight);
         asksPower.Show();
         asksPower.OnRefresh2(refresh);

         bidsPower.SetVariables(4, bidsPowerX, bidsPowerY, IntegerToString(totalBidsVolumes), 1);
         bidsPower.Height(bidsPowerHeight);
         bidsPower.Show();
         bidsPower.OnRefresh2(refresh);
        }
      else
        {
         bidsPower.SetVariables(4, bidsPowerX, bidsPowerY, IntegerToString(totalBidsVolumes), 1);
         bidsPower.Height(bidsPowerHeight);
         bidsPower.Show();
         bidsPower.OnRefresh2(refresh);

         asksPower.SetVariables(4, asksPowerX, asksPowerY, IntegerToString(totalAsksVolumes), 0);
         asksPower.Height(asksPowerHeight);
         asksPower.Show();
         asksPower.OnRefresh2(refresh);
        }

     }

   if(buyerPower!=NULL && (globalBuyerPower!=0 || globalSellerPower!=0))
     {

      double askPrice = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);
      double bidPrice = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);

      if(askPrice==lowAllowedPrice)
        {
         globalSellerPower=values[ArraySize(keys)-1].GetAskVolume();
        }
      else
         if(bidPrice==highAllowedPrice)
           {
            globalBuyerPower=values[0].GetAskVolume();
           }

      int sellerPowerHeight=((float) globalSellerPower/(globalBuyerPower+globalSellerPower))*POWER_METERS_HEIGHT;
      int buyerPowerHeight=sellerPowerHeight-POWER_METERS_HEIGHT;

      sellerPower.Hide();
      buyerPower.Hide();

      if(sellerPowerHeight>=MathAbs(buyerPowerHeight))
        {
         sellerPower.SetVariables(4, sellerPowerX, sellerPowerY, IntegerToString(globalSellerPower), 0);
         sellerPower.Height(sellerPowerHeight);
         sellerPower.Show();
         sellerPower.OnRefresh2(refresh);

         buyerPower.SetVariables(4, buyerPowerX, buyerPowerY, IntegerToString(globalBuyerPower), 1);
         buyerPower.Height(buyerPowerHeight);
         buyerPower.Show();
         buyerPower.OnRefresh2(refresh);
        }
      else
        {
         buyerPower.SetVariables(4, buyerPowerX, buyerPowerY, IntegerToString(globalBuyerPower), 1);
         buyerPower.Height(buyerPowerHeight);
         buyerPower.Show();
         buyerPower.OnRefresh2(refresh);

         sellerPower.SetVariables(4, sellerPowerX, sellerPowerY, IntegerToString(globalSellerPower), 0);
         sellerPower.Height(sellerPowerHeight);
         sellerPower.Show();
         sellerPower.OnRefresh2(refresh);
        }
     }

   if(snapshotBidsPower!=NULL && (globalSnapshotBidPower!=0 || globalSnapshotAskPower!=0))
     {
      int snapshotAskHeight;
      int snapshotBidHeight;

      snapshotAskHeight = ((float) MathAbs(globalSnapshotAskPower)/(MathAbs(globalSnapshotAskPower)+MathAbs(globalSnapshotBidPower)))*POWER_METERS_HEIGHT;
      snapshotBidHeight = snapshotAskHeight-POWER_METERS_HEIGHT;

      snapshotAsksPower.Hide();
      snapshotBidsPower.Hide();

      if(snapshotAskHeight>=MathAbs(snapshotBidHeight))
        {
         snapshotAsksPower.SetVariables(4, snapshotAsksPowerX, snapshotAsksPowerY, IntegerToString(globalSnapshotAskPower), 0);
         snapshotAsksPower.Height(snapshotAskHeight);
         snapshotAsksPower.Show();
         snapshotAsksPower.OnRefresh2(refresh);

         snapshotBidsPower.SetVariables(4, snapshotBidsPowerX, snapshotBidsPowerY, IntegerToString(globalSnapshotBidPower), 1);
         snapshotBidsPower.Height(snapshotBidHeight);
         snapshotBidsPower.Show();
         snapshotBidsPower.OnRefresh2(refresh);
        }
      else
        {
         snapshotBidsPower.SetVariables(4, snapshotBidsPowerX, snapshotBidsPowerY, IntegerToString(globalSnapshotBidPower), 1);
         snapshotBidsPower.Height(snapshotBidHeight);
         snapshotBidsPower.Show();
         snapshotBidsPower.OnRefresh2(refresh);

         snapshotAsksPower.SetVariables(4, snapshotAsksPowerX, snapshotAsksPowerY, IntegerToString(globalSnapshotAskPower), 0);
         snapshotAsksPower.Height(snapshotAskHeight);
         snapshotAsksPower.Show();
         snapshotAsksPower.OnRefresh2(refresh);
        }
     }

   if(highestPricePower!=NULL && (globalHighestPriceVolume!=-1 || globalLowestPriceVolume!=-1))
     {
      int highestPricePowerHeight = ((float) globalHighestPriceVolume/(globalLowestPriceVolume+globalHighestPriceVolume))*POWER_METERS_HEIGHT;
      int lowestPricePowerHeight = highestPricePowerHeight-POWER_METERS_HEIGHT;

      highestPricePower.Hide();
      lowestPricePower.Hide();

      if(globalHighestPriceVolume==-1 && values[0].GetAskVolume()!=-1 && values[0].GetAskVolume()!=globalHighestPriceVolume)
         globalHighestPriceVolume = values[0].GetAskVolume();

      if(globalLowestPriceVolume==-1 && values[ArraySize(keys)-1].GetBidVolume()!=-1 && values[ArraySize(keys)-1].GetBidVolume()!=globalLowestPriceVolume)
         globalLowestPriceVolume = values[ArraySize(keys)-1].GetBidVolume();

      if(globalHighestPriceVolume==-1)
         globalHighestPriceVolume=0;

      if(globalLowestPriceVolume==-1)
         globalLowestPriceVolume=0;

      if(highestPricePowerHeight>=MathAbs(lowestPricePowerHeight))
        {
         highestPricePower.SetVariables(4, highestPricePowerX, highestPricePowerY, IntegerToString(globalHighestPriceVolume), 0);
         highestPricePower.Height(highestPricePowerHeight);
         highestPricePower.Show();
         highestPricePower.OnRefresh2(refresh);

         lowestPricePower.SetVariables(4, lowestPricePowerX, lowestPricePowerY, IntegerToString(globalLowestPriceVolume), 1);
         lowestPricePower.Height(lowestPricePowerHeight);
         lowestPricePower.Show();
         lowestPricePower.OnRefresh2(refresh);
        }
      else
        {
         lowestPricePower.SetVariables(4, lowestPricePowerX, lowestPricePowerY, IntegerToString(globalLowestPriceVolume), 1);
         lowestPricePower.Height(lowestPricePowerHeight);
         lowestPricePower.Show();
         lowestPricePower.OnRefresh2(refresh);

         highestPricePower.SetVariables(4, highestPricePowerX, highestPricePowerY, IntegerToString(globalHighestPriceVolume), 0);
         highestPricePower.Height(highestPricePowerHeight);
         highestPricePower.Show();
         highestPricePower.OnRefresh2(refresh);
        }
     }

   ChartRedraw();
   delete(refresh);

   int volume = SymbolInfoDouble(Symbol(), SYMBOL_SESSION_VOLUME);

   string result = utils.CommaSeparator(IntegerToString(volume));
   m_sessionVolumeValue.Description(result);

   result = utils.CommaSeparator(IntegerToString(ninetyAverageVolume));
   m_ninetyAverageVolumeValue.Description(result);

   result = utils.CommaSeparator(DoubleToString(balance, Digits()));
   m_cashValue.Description(result);

   result = utils.CommaSeparator(IntegerToString(totalLossProfit));
   m_lossProfitValue.Description(result);

   result = utils.CommaSeparator(IntegerToString(closingPrice));
   m_closingPriceValue.Description(result + " (" + closingPricePercentage + "%" + ")");

   result = utils.CommaSeparator(IntegerToString(yesterdayPrice));
   m_yesterdayClosingPriceValue.Description(result);

   result = utils.CommaSeparator(IntegerToString(tomorrowHigh));
   m_tomorrowHighValue.Description(result);

   result = utils.CommaSeparator(IntegerToString(tomorrowLow));
   m_tomorrowLowValue.Description(result);

   m_portfolioValue.Description(m_portfolio.numberOfshares);


   int v=m_scrollv.CurrentPos();

   if(changePositionOfScrollBar && startIndex!=0)
     {
      //--- Get the current position of the scrollbar slider
      m_scrollv.CurrentPos(startIndex);
      m_scrollv.CalculateThumbY();

      changePositionOfScrollBar=false;
     }

   if(ArraySize(keys)-1>0 && ArraySize(MarketBook.MarketBook)-1>0
      && values[startIndex].GetPrice()>=MarketBook.MarketBook[0].price
      && values[endIndex].GetPrice()<=MarketBook.MarketBook[ArraySize(MarketBook.MarketBook)-1].price
      && MarketBook.InfoGetDouble(MBOOK_LAST_BID_PRICE) > (lowAllowedPrice+3*m_market_table.GetTickSize())
      && MarketBook.InfoGetDouble(MBOOK_LAST_ASK_PRICE) < (highAllowedPrice-3*m_market_table.GetTickSize())
      && automaticScrolling
     )
     {
      cMainTable.TryGetValue(keys[startIndex+3], value);

      if(MarketBook.MarketBook[0].price>=value.GetPrice())
        {
         if(startIndex-1 >= 0)
           {
            startIndex -= 1;
            endIndex -= 1;

            m_scrollv.CurrentPos((v-1>=0)?v-1:v);
           }
         else
            m_scrollv.CurrentPos(startIndex);

         m_scrollv.CalculateThumbY();

         ShiftList();
        }

      cMainTable.TryGetValue(keys[endIndex-3], value);

      if(MarketBook.MarketBook[ArraySize(MarketBook.MarketBook)-1].price<=value.GetPrice())
        {
         if(endIndex+1 <= m_items_total_size)
           {
            startIndex += 1;
            endIndex += 1;

            m_scrollv.CurrentPos((v+1<=m_items_total_size)?v+1:v);

           }
         else
            m_scrollv.CurrentPos(startIndex);

         m_scrollv.CalculateThumbY();

         ShiftList();
        }
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

   m_scrollv.CurrentPos(startIndex);
   m_scrollv.CalculateThumbY();
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CMBookArea::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_KEYDOWN)
     {
      double askPrice = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);
      double bidPrice = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);

      if(bidPrice<lowAllowedPrice)
         bidPrice=lowAllowedPrice;

      if(askPrice>highAllowedPrice)
         askPrice=highAllowedPrice;

      switch(lparam)
        {
         case KEY_I:
           {
            automaticScrolling=true;

            double keys[];
            CMainTable *values[];
            cMainTable.CopyTo(keys, values, 0);

            CMainTable *value;

            for(int i=0; i<ArraySize(keys)-1; i++)
               m_market_table.CenterOfCustomDepth(i, values[i].GetPrice(), m_items_total_size);

            m_market_table.ShiftCells(startIndex, endIndex, true);
            m_scrollv.CurrentPos(startIndex);
            m_scrollv.CalculateThumbY();

            break;
           }
         case KEY_J:
           {
            bool result = m_market_table.NewOrder(askPrice, bidPrice, askPrice, BID_COLUMN, StringToInteger(m_edit.Description()));

            if(result)
              {
               m_market_table.ShiftCells(startIndex, endIndex, true);
               m_scrollv.CurrentPos(startIndex);
               m_scrollv.CalculateThumbY();
              }

            break;
           }
         case KEY_L:
           {
            bool result = m_market_table.NewOrder(bidPrice, bidPrice, askPrice, ASK_COLUMN, StringToInteger(m_edit.Description()));

            if(result)
              {
               m_market_table.ShiftCells(startIndex, endIndex, true);
               m_scrollv.CurrentPos(startIndex);
               m_scrollv.CalculateThumbY();
              }

            break;
           }
        }
     }

//--- Object click handling
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      int x=(int)lparam;
      int y=(int)dparam;

      bool result = m_market_table.CheckClickedPoint(x, y, StringToInteger(m_edit.Description()));

      if(result)
        {
         m_market_table.ShiftCells(startIndex, endIndex, true);
         m_scrollv.CurrentPos(startIndex);
         m_scrollv.CalculateThumbY();
        }

      //--- If a button of the list scrollbar was pressed
      if(m_scrollv.OnClickScrollInc(sparam) || m_scrollv.OnClickScrollDec(sparam))
        {
         //--- Shift the list relative to the scrollbar
         ShiftList();
         return;
        }
     }

   if(id==CHARTEVENT_MOUSE_MOVE || id==1 || id==CHARTEVENT_MOUSE_WHEEL)
     {
      //--- Coordinates and the state of the left mouse button

      scrollBarX=(int)lparam;
      scrollBarY=(int)dparam;

      //Print(scrollBarX, "-", scrollBarY);

      m_mouse_state=(bool)int(sparam);

      if(sparam=="MarketBook_scrollv_thumb_0" || sparam=="MarketBook_scrollv_bg_0")
         m_mouse_state=true;

      //--- Shift the list if the scroll box control is active
      if(m_scrollv.ScrollBarControl(scrollBarX,scrollBarY,m_mouse_state))
         scrollBarMoving=true;

      if(id==1)
        {
         Print(sparam);

         if(m_scrollv.ScrollBarControl(scrollBarX,scrollBarY,m_mouse_state))
            scrollBarMoving=true;

         ShiftList();
         scrollBarMoving=false;
         automaticScrolling=false;
        }

      //--- Change the color of list items when hovered
      //ChangeItemsColor(x,y);
      return;
     }
  }
//+------------------------------------------------------------------+
//| Show the list                                                    |
//+------------------------------------------------------------------+
void CMBookArea::ShowScrollbar(void)
  {
//--- Show the scrollbar
   m_scrollv.Show();
  }
//+------------------------------------------------------------------+
