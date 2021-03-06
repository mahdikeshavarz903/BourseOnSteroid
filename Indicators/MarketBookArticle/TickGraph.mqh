//+------------------------------------------------------------------+
//|                                                         Graf.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <../Shared Projects/BourseOnSteroid/Include/Panel/ElChart.mqh>
#include <../Shared Projects/BourseOnSteroid/Include/RingBuffer/RiBuffDbl.mqh>
#include <../Shared Projects/BourseOnSteroid/Include/RingBuffer/RiBuffInt.mqh>
#include <../Shared Projects/BourseOnSteroid/Include/RingBuffer/RiMaxMin.mqh>
#include "GlobalMarketBook.mqh"
#include "GraphicMain.mqh"
#include "EventNewTick.mqh"

input int TicksHistoryTotal=200;
input bool ScaleTiksWithBook=true;
//+------------------------------------------------------------------+
//| Determines the number of a curve in the CGraphic object          |
//+------------------------------------------------------------------+
enum ENUM_TICK_LINES
  {
   ASK_LINE,
   BID_LINE,
   LAST_BUY,
   LAST_SELL,
   LAST_LINE,
   VOL_LINE
  };
//+------------------------------------------------------------------+
//| Graphic element displaying the tick chart                        |
//+------------------------------------------------------------------+
class CElTickGraph : public CElChart
  {
private:

   CGraphicMain      m_graf;
/* Key buffers for fast operation with the tick stream*/
   CRiMaxMin         m_ask;
   CRiMaxMin         m_bid;
   CRiMaxMin         m_last;
   CRiBuffDbl        m_last_buy;
   CRiMaxMin         m_last_sell;
   CRiBuffInt        m_vol;
   CRiBuffInt        m_flags;

   double            m_xpoints[];  // An array of indexes
   void              RefreshCurves();
   void              SetMaxMin(void);
public:
                     CElTickGraph(void);
   virtual void      Event(CEvent *event);
   void              SetTiksTotal(int tiks);
   int               GetTiksTotal(void);
   void              Redraw(void);
   virtual void      Show(void);
   virtual void      OnHide(void);
   virtual void      OnRefresh(CEventRefresh *refresh);
   void              AddLastTick();
  };
//+------------------------------------------------------------------+
//| Chart initialization                                             |
//+------------------------------------------------------------------+
CElTickGraph::CElTickGraph(void) : CElChart(OBJ_RECTANGLE_LABEL)
  {
   double y[]={0};
   y[0]=MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);
   double x[]={0};

   CCurve *cur=m_graf.CurveAdd(x,y,CURVE_LINES,"Ask");
   cur.Color(ColorToARGB(clrLightCoral,255));

   cur=m_graf.CurveAdd(x,y,CURVE_LINES,"Bid");
   cur.Color(ColorToARGB(clrCornflowerBlue,255));

   cur=m_graf.CurveAdd(x,y,CURVE_POINTS,"Buy");
   cur.PointsType(POINT_TRIANGLE_DOWN);
   cur.PointsColor(ColorToARGB(clrCornflowerBlue, 255));
   cur.Color(ColorToARGB(clrBlue, 255));
   cur.PointsFill(true);
   cur.PointsSize(20);


   cur=m_graf.CurveAdd(x,y,CURVE_POINTS,"Sell");
   cur.PointsType(POINT_TRIANGLE);
   cur.PointsColor(ColorToARGB(clrLightCoral, 255));
   cur.Color(ColorToARGB(clrRed, 255));
   cur.PointsFill(true);
   cur.PointsSize(20);

   m_graf.CurvePlotAll();
   m_graf.IndentRight(1);
   m_graf.GapSize(1);
   SetTiksTotal(TicksHistoryTotal);
  }
//+------------------------------------------------------------------+
//| Sets the number of ticks in t he chart window                    |
//+------------------------------------------------------------------+
void CElTickGraph::SetTiksTotal(int tiks)
  {
   m_last.SetMaxTotal(tiks);
   m_last_buy.SetMaxTotal(tiks);
   m_last_sell.SetMaxTotal(tiks);
   m_ask.SetMaxTotal(tiks);
   m_bid.SetMaxTotal(tiks);
   m_vol.SetMaxTotal(tiks);
   ArrayResize(m_xpoints,tiks);
//MqlTick tiks[];
//CopyTicks(Symbol(), tiks, COPY_TICKS_ALL, 0, tiks); 
   for(int i=0; i<ArraySize(m_xpoints); i++)
      m_xpoints[i]=i;
  }
//+------------------------------------------------------------------+
//| Updates tick lines                                               |
//+------------------------------------------------------------------+
void CElTickGraph::RefreshCurves(void)
  {
   int total_last= m_last.GetTotal();
   int total_ask = m_ask.GetTotal();
   int total_bid = m_bid.GetTotal();
   int total = 10;
   for(int i = 0; i < m_graf.CurvesTotal(); i++)
     {
      CCurve *curve=m_graf.CurveGetByIndex(i);
      double y_points[];
      double x_points[];
      switch(i)
        {
         case LAST_LINE:
           {
            m_last.ToArray(y_points);
            if(ArraySize(x_points)<ArraySize(y_points))
               ArrayCopy(x_points,m_xpoints,0,0,ArraySize(y_points));
            curve.Update(x_points,y_points);
            break;
           }
         case ASK_LINE:
            m_ask.ToArray(y_points);
            if(ArraySize(x_points)<ArraySize(y_points))
               ArrayCopy(x_points,m_xpoints,0,0,ArraySize(y_points));
            curve.Update(x_points,y_points);
            break;
         case BID_LINE:
            m_bid.ToArray(y_points);
            if(ArraySize(x_points)<ArraySize(y_points))
               ArrayCopy(x_points,m_xpoints,0,0,ArraySize(y_points));
            curve.Update(x_points,y_points);
            break;
         case LAST_BUY:
           {
            m_last_buy.ToArray(y_points);
            CPoint2D points[];
            ArrayResize(points,ArraySize(y_points));
            int k=0;
            for(int p=0; p<ArraySize(y_points);p++)
              {
               if(y_points[p]==-1)
                  continue;
               points[k].x = p;
               points[k].y = y_points[p];
               k++;
              }
            if(k>0)
              {
               ArrayResize(points,k);
               curve.Update(points);
              }
            break;
           }
         case LAST_SELL:
           {
            m_last_sell.ToArray(y_points);
            CPoint2D points[];
            ArrayResize(points,ArraySize(y_points));
            int k=0;
            for(int p=0; p<ArraySize(y_points);p++)
              {
               if(y_points[p]==-1)
                  continue;
               points[k].x = p;
               points[k].y = y_points[p];
               k++;
              }
            if(k>0)
              {
               ArrayResize(points,k);
               curve.Update(points);
              }
            break;
           }
        }
     }

  }
//+------------------------------------------------------------------+
//| Returns the number of ticks in the chart window                  |
//+------------------------------------------------------------------+
int CElTickGraph::GetTiksTotal(void)
  {
   return m_ask.GetMaxTotal();
  }
//+------------------------------------------------------------------+
//| Updates the chart during order book update                       |
//+------------------------------------------------------------------+
void CElTickGraph::OnRefresh(CEventRefresh *refresh)
  {
//Draw the last received ticks on the chart
   int dbg=5;
   int total = ArraySize(MarketBook.LastTicks);
   for(int i = 0; i < ArraySize(MarketBook.LastTicks); i++)
     {
      MqlTick tick=MarketBook.LastTicks[i];
      if((tick.flags  &TICK_FLAG_BUY)==TICK_FLAG_BUY)
        {
         m_last_buy.AddValue(tick.last);
         m_last_sell.AddValue(-1);
         m_ask.AddValue(tick.last);
         m_bid.AddValue(tick.bid);
        }
      if((tick.flags  &TICK_FLAG_SELL)==TICK_FLAG_SELL)
        {
         m_last_sell.AddValue(tick.last);
         m_last_buy.AddValue(-1);
         m_bid.AddValue(tick.last);
         m_ask.AddValue(tick.ask);
        }
      if((tick.flags & TICK_FLAG_ASK)==TICK_FLAG_ASK ||
         (tick.flags & TICK_FLAG_BID)==TICK_FLAG_BID)
        {
         m_last_sell.AddValue(-1);
         m_last_buy.AddValue(-1);
         m_bid.AddValue(tick.bid);
         m_ask.AddValue(tick.ask);
        }
     }
   MqlTick tick;
   if(!SymbolInfoTick(Symbol(),tick))
      return;
   if(ArraySize(MarketBook.LastTicks)>0)
     {
      RefreshCurves();
      if(ScaleTiksWithBook)
         SetMaxMin();
      m_graf.Redraw(!ScaleTiksWithBook);
      m_graf.Update();
     }
  }
//+------------------------------------------------------------------+
//| Intercept the "New tick" event                                   |
//+------------------------------------------------------------------+
void CElTickGraph::Event(CEvent *event)
  {
   CElChart::Event(event);
   if(event.EventType()!=EVENT_CHART_CUSTOM)
      return;
   CEventNewTick *ent=dynamic_cast<CEventNewTick*>(event);
   if(ent==NULL)
      return;
   MqlTick tick;
   ent.GetNewTick(tick);
   if((tick.flags  &TICK_FLAG_BUY)==TICK_FLAG_BUY)
     {
      int last = m_last_buy.GetTotal()-1;
      if(last >= 0)
         m_last_buy.ChangeValue(last,tick.last);
     }
  }
//+------------------------------------------------------------------+
//| Calculates the scale along axes so that the current price is     |
//| always in the middle of the price chart                          |
//+------------------------------------------------------------------+
void CElTickGraph::SetMaxMin(void)
  {
   double max = m_ask.MaxValue();
   double min = m_bid.MinValue();
   int i_buy=m_ask.GetTotal()-1;
   int i_sell=m_bid.GetTotal()-1;
   if(i_buy<0 || i_sell<0)
      return;
   double curr=(m_ask.GetValue(i_buy)+m_bid.GetValue(i_sell))/2.0;
   double max_delta = max - curr;
   double min_delta = curr - min;
   if(max_delta>min_delta)
      m_graf.SetMaxMinValues(0,m_ask.GetTotal(),(max-max_delta*2.0),max);
   else
      m_graf.SetMaxMinValues(0,m_ask.GetTotal(),min,(min+min_delta*2.0));
  }
//+------------------------------------------------------------------+
//| Refreshes the chart                                              |
//+------------------------------------------------------------------+
void CElTickGraph::Redraw(void)
  {
   m_graf.Redraw(true);
   m_graf.Update();
  }
//+------------------------------------------------------------------+
//| Intercepts chart display and changes display priority            |
//+------------------------------------------------------------------+
void CElTickGraph::Show(void)
  {
   BackgroundColor(clrNONE);
   BorderColor(clrBlack);
   Text("Ticks:");
//m_graf.BackgroundColor(clrWhiteSmoke);
   m_graf.Create(ChartID(), "Ticks", 0, (int)XCoord()+20, (int)YCoord()+30, 600, 700);
   m_graf.Redraw(true);
   m_graf.Update();
   CElChart::Show();
  }
//+------------------------------------------------------------------+
//| At the time of display we show the chart                         |
//+------------------------------------------------------------------+
void CElTickGraph::OnHide(void)
  {
   m_graf.Destroy();
   CNode::OnHide();
  }
//+------------------------------------------------------------------+
