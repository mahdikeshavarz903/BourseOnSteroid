//+------------------------------------------------------------------+
//|                                                      Tooltip.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Element.mqh"
#include "Window.mqh"
//+------------------------------------------------------------------+
//| Class for creating a tooltip                                     |
//+------------------------------------------------------------------+
class CTooltip : public CElement
  {
private:
   //--- Pointer to the form to which the element is attached
   CWindow          *m_wnd;
   //--- Pointer to the control to which the tooltip is attached
   CElement         *m_element;
   //--- Objects for creating a tooltip
   CRectCanvas       m_canvas;
   //--- Properties:
   //    Header
   string            m_header;
   //--- Array of the tooltip text lines
   string            m_tooltip_lines[];
   //--- Alpha channel value (tooltip transparency)
   uchar             m_alpha;
   //--- Colors of (1) text, (2) header and (3) background border
   color             m_text_color;
   color             m_header_color;
   color             m_border_color;
   //--- Background gradient colors
   color             m_gradient_top_color;
   color             m_gradient_bottom_color;
   //--- Background gradient array
   color             m_array_color[];
   //---
public:
                     CTooltip(void);
                    ~CTooltip(void);
   //--- Methods for creating a tooltip
   bool              CreateTooltip(const long chart_id,const int subwin);
   //---
private:
   //--- Create a canvas for drawing a tooltip
   bool              CreateCanvas(void);
   //--- (1) Draws vertical gradient and (2) border
   void              VerticalGradient(const uchar alpha);
   void              Border(const uchar alpha);
   //---
public:
   //--- (1) Stores the form pointer, (2) stores the control pointer, (3) the tooltip header
   void              WindowPointer(CWindow &object)   { m_wnd=::GetPointer(object);     }
   void              ElementPointer(CElement &object) { m_element=::GetPointer(object); }
   void              Header(const string text)        { m_header=text;                  }
   //--- Adds a string to the tooltip
   void              AddString(const string text);

   //--- (1) Shows and (2) hides the tooltip
   void              ShowTooltip(void);
   void              FadeOutTooltip(void);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Moving the control
   virtual void      Moving(const int x,const int y);
   //--- (1) Showing, (2) hiding, (3) resetting, (4) deleting
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTooltip::CTooltip(void) : m_header(""),
                           m_alpha(0),
                           m_text_color(clrDimGray),
                           m_header_color(C'50,50,50'),
                           m_border_color(C'118,118,118'),
                           m_gradient_top_color(clrWhite),
                           m_gradient_bottom_color(C'208,208,235')
  {
//--- Store the name of the control class in the base class  
   CElement::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTooltip::~CTooltip(void)
  {
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CTooltip::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Leave, if the element is hidden
      if(!CElement::IsVisible())
         return;
      //--- Leave, if the tooltip button is disabled on the form
      if(!m_wnd.TooltipBmpState())
         return;
      //--- If the form is locked
      if(m_wnd.IsLocked())
        {
         //--- Hide the tooltip
         FadeOutTooltip();
         return;
        }
      //--- If there is a focus on the control
      if(m_element.MouseFocus())
         //--- Show the tooltip
         ShowTooltip();
      //--- If there is no focus
      else
      //--- Hide the tooltip
         FadeOutTooltip();
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
//| Create Tooltip object                                            |
//+------------------------------------------------------------------+
bool CTooltip::CreateTooltip(const long chart_id,const int subwin)
  {
//--- Leave, if there is no form pointer
   if(::CheckPointer(m_wnd)==POINTER_INVALID)
     {
      ::Print(__FUNCTION__," > Before creating a tooltip, the class has to be passed  "
              "the form pointer: CTooltip::WindowPointer(CWindow &object).");
      return(false);
     }
//--- Leave, if there is no element pointer
   if(::CheckPointer(m_element)==POINTER_INVALID)
     {
      ::Print(__FUNCTION__," > Before creating a tooltip, the class has to be passed  "
              "the element pointer: CTooltip::ElementPointer(CElement &object).");
      return(false);
     }
//--- Initialization of variables
   m_id       =m_wnd.LastId()+1;
   m_chart_id =chart_id;
   m_subwin   =subwin;
   m_x        =m_element.X();
   m_y        =m_element.Y2()+1;
//--- Indents from the edge point
   CElement::XGap(m_x-m_wnd.X());
   CElement::YGap(m_y-m_wnd.Y());
//--- Creates a tooltip
   if(!CreateCanvas())
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create canvas for drawing                                        |
//+------------------------------------------------------------------+
bool CTooltip::CreateCanvas(void)
  {
//--- Formation of the object name
   string name=CElement::ProgramName()+"_help_tooltip_"+(string)CElement::Id();
//--- Create a tooltip
   if(!m_canvas.CreateBitmapLabel(m_chart_id,m_subwin,name,m_x,m_y,m_x_size,m_y_size,COLOR_FORMAT_ARGB_NORMALIZE))
      return(false);
//--- Attach to the chart
   if(!m_canvas.Attach(m_chart_id,name,m_subwin,1))
      return(false);
//--- Set properties
   m_canvas.Background(false);
   m_canvas.Tooltip("\n");
//--- Indents from the edge point
   m_canvas.XGap(m_x-m_wnd.X());
   m_canvas.YGap(m_y-m_wnd.Y());
//--- Setting the gradient array size for the tooltip background
   CElement::GradientColorsTotal(m_y_size);
   ::ArrayResize(m_array_color,m_y_size);
//--- Initializing the array gradient
   CElement::InitColorArray(m_gradient_top_color,m_gradient_bottom_color,m_array_color);
//--- Clear the drawing canvas
   m_canvas.Erase(::ColorToARGB(clrNONE,0));
   m_canvas.Update();
   m_alpha=0;
//--- Store the object pointer
   CElement::AddToArray(m_canvas);
   return(true);
  }
//+------------------------------------------------------------------+
//| Add string                                                       |
//+------------------------------------------------------------------+
void CTooltip::AddString(const string text)
  {
//--- Increase the size of the arrays by one element
   int array_size=::ArraySize(m_tooltip_lines);
   ::ArrayResize(m_tooltip_lines,array_size+1);
//--- Store the values of passed parameters
   m_tooltip_lines[array_size]=text;
  }
//+------------------------------------------------------------------+
//| Vertical gradient                                                |
//+------------------------------------------------------------------+
void CTooltip::VerticalGradient(const uchar alpha)
  {
//--- X-coordinates
   int x1=0;
   int x2=m_x_size;
//--- Draw a gradient
   for(int y=0; y<m_y_size; y++)
      m_canvas.Line(x1,y,x2,y,::ColorToARGB(m_array_color[y],alpha));
  }
//+------------------------------------------------------------------+
//| Border                                                           |
//+------------------------------------------------------------------+
void CTooltip::Border(const uchar alpha)
  {
//--- Border Color
   color clr=m_border_color;
//--- Boundaries
   int x_size =m_canvas.X_Size()-1;
   int y_size =m_canvas.Y_Size()-1;
//--- Coordinates: Top/Right/Bottom/Left
   int x1[4]; x1[0]=0;      x1[1]=x_size; x1[2]=0;      x1[3]=0;
   int y1[4]; y1[0]=0;      y1[1]=0;      y1[2]=y_size; y1[3]=0;
   int x2[4]; x2[0]=x_size; x2[1]=x_size; x2[2]=x_size; x2[3]=0;
   int y2[4]; y2[0]=0;      y2[1]=y_size; y2[2]=y_size; y2[3]=y_size;
//--- Draw the border by the specified coordinates
   for(int i=0; i<4; i++)
      m_canvas.Line(x1[i],y1[i],x2[i],y2[i],::ColorToARGB(clr,alpha));
//--- Round the corners by one pixel
   clr=clrBlack;
   m_canvas.PixelSet(0,0,::ColorToARGB(clr,0));
   m_canvas.PixelSet(0,m_y_size-1,::ColorToARGB(clr,0));
   m_canvas.PixelSet(m_x_size-1,0,::ColorToARGB(clr,0));
   m_canvas.PixelSet(m_x_size-1,m_y_size-1,::ColorToARGB(clr,0));
//--- Draw pixel at the specified coordinates
   clr=C'180,180,180';
   m_canvas.PixelSet(1,1,::ColorToARGB(clr,alpha));
   m_canvas.PixelSet(1,m_y_size-2,::ColorToARGB(clr,alpha));
   m_canvas.PixelSet(m_x_size-2,1,::ColorToARGB(clr,alpha));
   m_canvas.PixelSet(m_x_size-2,m_y_size-2,::ColorToARGB(clr,alpha));
  }
//+------------------------------------------------------------------+
//| Show tooltip                                                     |
//+------------------------------------------------------------------+
void CTooltip::ShowTooltip(void)
  {
//--- Leave, if the tooltip is visible at 100%
   if(m_alpha>=255)
      return;
//--- Coordinates and offset for header
   int  x        =5;
   int  y        =5;
   int  y_offset =15;
//--- Draw a gradient
   VerticalGradient(255);
//--- Draw border
   Border(255);
//--- Draw header (if set)
   if(m_header!="")
     {
      //--- Set the font parameters
      m_canvas.FontSet(FONT,-80,FW_BLACK);
      //--- Draw the header text
      m_canvas.TextOut(x,y,m_header,::ColorToARGB(m_header_color),TA_LEFT|TA_TOP);
     }
//--- Coordinates for the main text of the tooltip (provided the header exists)
   x=(m_header!="")? 15 : 5;
   y=(m_header!="")? 25 : 5;
//--- Set the font parameters
   m_canvas.FontSet(FONT,-80,FW_THIN);
//--- Draw the main text of the tooltip
   int lines_total=::ArraySize(m_tooltip_lines);
   for(int i=0; i<lines_total; i++)
     {
      m_canvas.TextOut(x,y,m_tooltip_lines[i],::ColorToARGB(m_text_color),TA_LEFT|TA_TOP);
      y=y+y_offset;
     }
//--- Update the canvas
   m_canvas.Update();
//--- Sign of a fully visible tooltip
   m_alpha=255;
  }
//+------------------------------------------------------------------+
//| Tooltip fade out                                                 |
//+------------------------------------------------------------------+
void CTooltip::FadeOutTooltip(void)
  {
//--- Leave, if the tooltip is hidden at 100%
   if(m_alpha<1)
      return;
//--- Offset for header
   int y_offset=15;
//--- Transparency step
   uchar fadeout_step=7;
//--- Tooltip fade out
   for(uchar a=m_alpha; a>=0; a-=fadeout_step)
     {
      //--- If the next step is in the negative, terminate the loop
      if(a-fadeout_step<0)
        {
         a=0;
         m_canvas.Erase(::ColorToARGB(clrNONE,0));
         m_canvas.Update();
         m_alpha=0;
         break;
        }
      //--- Coordinates for header
      int x =5;
      int y =5;
      //--- Draw gradient and border
      VerticalGradient(a);
      Border(a);
      //--- Draw header (if set)
      if(m_header!="")
        {
         //--- Set the font parameters
         m_canvas.FontSet(FONT,-80,FW_BLACK);
         //--- Draw the header text
         m_canvas.TextOut(x,y,m_header,::ColorToARGB(m_header_color,a),TA_LEFT|TA_TOP);
        }
      //--- Coordinates for the main text of the tooltip (provided the header exists)
      x=(m_header!="")? 15 : 5;
      y=(m_header!="")? 25 : 5;
      //--- Set the font parameters
      m_canvas.FontSet(FONT,-80,FW_THIN);
      //--- Draw the main text of the tooltip
      int lines_total=::ArraySize(m_tooltip_lines);
      for(int i=0; i<lines_total; i++)
        {
         m_canvas.TextOut(x,y,m_tooltip_lines[i],::ColorToARGB(m_text_color,a),TA_LEFT|TA_TOP);
         y=y+y_offset;
        }
      //--- Update the canvas
      m_canvas.Update();
     }
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CTooltip::Moving(const int x,const int y)
  {
//--- Leave, if the element is hidden
   if(!CElement::IsVisible())
      return;
//--- Storing coordinates in the element fields
   CElement::X(x+XGap());
   CElement::Y(y+YGap());
//--- Storing coordinates in the fields of the objects
   m_canvas.X(x+m_canvas.XGap());
   m_canvas.Y(y+m_canvas.YGap());
//--- Updating coordinates of graphical objects
   m_canvas.X_Distance(m_canvas.X());
   m_canvas.Y_Distance(m_canvas.Y());
  }
//+------------------------------------------------------------------+
//| Shows the element                                                |
//+------------------------------------------------------------------+
void CTooltip::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElement::IsVisible())
      return;
//--- Make all the objects visible
   m_canvas.Timeframes(OBJ_ALL_PERIODS);
//--- Visible state
   CElement::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Hide the element                                                 |
//+------------------------------------------------------------------+
void CTooltip::Hide(void)
  {
//--- Leave, if the element is hidden
   if(!CElement::IsVisible())
      return;
//--- Hide all objects
   m_canvas.Timeframes(OBJ_NO_PERIODS);
//--- Visible state
   CElement::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CTooltip::Reset(void)
  {
   Hide();
   Show();
  }
//+------------------------------------------------------------------+
//| Deleting                                                         |
//+------------------------------------------------------------------+
void CTooltip::Delete(void)
  {
//--- Deleting objects
   m_canvas.Delete();
//--- Emptying the element arrays
   ::ArrayFree(m_tooltip_lines);
//--- Emptying the object array
   CElement::FreeObjectsArray();
  }
//+------------------------------------------------------------------+
