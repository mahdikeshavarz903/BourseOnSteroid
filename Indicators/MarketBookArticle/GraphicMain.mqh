//+------------------------------------------------------------------+
//|                                                  GraphicMain.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <Graphics\Graphic.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
class CGraphicMain : public CGraphic
{
public:
   void SetMaxMinValues(double x_min, double x_max, double y_min, double y_max);
};
//+------------------------------------------------------------------+
//| Sets the scale of the two-dimensional chart, sets the minimum    |
//| and maximum values along the X and Y axes                        |
//+------------------------------------------------------------------+
void CGraphicMain::SetMaxMinValues(double xmin,double xmax,double ymin,double ymax)
{
   if(m_x.AutoScale())
     {
      m_x.Max(xmax);
      m_x.Min(xmin);
     }
   if(m_y.AutoScale())
     {
      m_y.Max(ymax);
      m_y.Min(ymin);
     }
   m_xupdate=true;
   m_yupdate=true;
}