//+------------------------------------------------------------------+
//|                                                      Scrolls.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Element.mqh"
#include "Window.mqh"
#include "../Indicators/MarketBookArticle/MBookGraphTable.mqh"
//+------------------------------------------------------------------+
//| Base class for creating scrollbar                                |
//+------------------------------------------------------------------+
class CScroll : public CElement
  {
protected:
   //--- Pointer to the form to which the element is attached
   CWindow          *m_wnd;
   CBookGraphTable  *cBookGraphTable;
   //--- Objects for creating the scrollbar
   CRectLabel        m_area;
   CRectLabel        m_bg;
   CBmpLabel         m_inc;
   CBmpLabel         m_dec;
   CRectLabel        m_thumb;
   //--- Properties of the general area of the scrollbar
   int               m_area_width;
   int               m_area_length;
   color             m_area_color;
   color             m_area_border_color;
   //--- Properties of the slider background
   int               m_bg_length;
   color             m_bg_border_color;
   //--- Button icons
   string            m_inc_file_on;
   string            m_inc_file_off;
   string            m_dec_file_on;
   string            m_dec_file_off;
   //--- Colors of the slider in different states
   color             m_thumb_color;
   color             m_thumb_color_hover;
   color             m_thumb_color_pressed;
   color             m_thumb_border_color;
   color             m_thumb_border_color_hover;
   color             m_thumb_border_color_pressed;
   //--- (1) Width of the slider, (2) length of the slider (3) and its minimal length
   int               m_thumb_width;
   int               m_thumb_length;
   int               m_thumb_min_length;
   //--- (1) Step of the slider and (2) the number of steps
   double            m_thumb_step_size;
   double            m_thumb_steps_total;
   //--- Priorities for clicking the left mouse button
   int               m_area_zorder;
   int               m_bg_zorder;
   int               m_arrow_zorder;
   int               m_thumb_zorder;
   //--- Variables related to the slider movement
   bool              m_scroll_state;
   int               m_thumb_size_fixing;
   int               m_thumb_point_fixing;
   //--- Current location of the slider
   int               m_current_pos;
   //--- To identify the area of pressing down the left mouse button
   ENUM_THUMB_MOUSE_STATE m_clamping_area_mouse;
   //---
public:
                     CScroll(void);
                    ~CScroll(void);
   //--- Methods for creating the scrollbar
   bool              CreateScroll(const long chart_id,const int subwin,const int x,const int y,const int items_total,const int visible_items_total);
   //---
private:
   bool              CreateArea(void);
   bool              CreateBg(void);
   bool              CreateInc(void);
   bool              CreateDec(void);
   bool              CreateThumb(void);
   //---
public:
   //--- (1) Stores the form pointer, (2) slider width
   void              WindowPointer(CWindow &object)           { m_wnd=::GetPointer(object);       }
   void              WindowPointer(CBookGraphTable &object)   { cBookGraphTable=::GetPointer(object);       }
   void              ScrollWidth(const int width)             { m_area_width=width;               }
   int               ScrollWidth(void)                  const { return(m_area_width);             }
   //--- (1) Color of the background, (2) of the background frame and (3) the internal frame of the background
   void              AreaColor(const color clr)               { m_area_color=clr;                 }
   void              AreaBorderColor(const color clr)         { m_area_border_color=clr;          }
   void              BgBorderColor(const color clr)           { m_bg_border_color=clr;            }
   //--- Setting icons for buttons
   void              IncFileOn(const string file_path)        { m_inc_file_on=file_path;          }
   void              IncFileOff(const string file_path)       { m_inc_file_off=file_path;         }
   void              DecFileOn(const string file_path)        { m_dec_file_on=file_path;          }
   void              DecFileOff(const string file_path)       { m_dec_file_off=file_path;         }
   //--- (1) Color of the slider background and (2) the frame of the slider background
   void              ThumbColor(const color clr)              { m_thumb_border_color=clr;         }
   void              ThumbColorHover(const color clr)         { m_thumb_border_color_hover=clr;   }
   void              ThumbColorPressed(const color clr)       { m_thumb_border_color_pressed=clr; }
   void              ThumbBorderColor(const color clr)        { m_thumb_border_color=clr;         }
   void              ThumbBorderColorHover(const color clr)   { m_thumb_border_color_hover=clr;   }
   void              ThumbBorderColorPressed(const color clr) { m_thumb_border_color_pressed=clr; }
   //--- Names of buttons objects
   string            ScrollIncName(void)                const { return(m_inc.Name());             }
   string            ScrollDecName(void)                const { return(m_dec.Name());             }
   //--- Button states
   bool              ScrollIncState(void)               const { return(m_inc.State());            }
   bool              ScrollDecState(void)               const { return(m_dec.State());            }
   //--- Scrollbar state (free/in slider movement mode)
   void              ScrollState(const bool scroll_state)     { m_scroll_state=scroll_state;      }
   bool              ScrollState(void)                  const { return(m_scroll_state);           }
   //--- Current location of the slider
   void              CurrentPos(const int pos)                { m_current_pos=pos;                }
   int               CurrentPos(void)                   const { return(m_current_pos);            }
   //--- Identifies the area of pressing down the left mouse button
   void              CheckMouseButtonState(const bool mouse_state);
   //--- Zeroing variables
   void              ZeroThumbVariables(void);
   //--- Change the slider size according to new conditions
   void              ChangeThumbSize(const int items_total,const int visible_items_total);
   //--- Calculation of the length of the scrollbar slider
   bool              CalculateThumbSize(void);
   //--- Changing the color of the scrollbar objects
   void              ChangeObjectsColor(void);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Timer
   virtual void      OnEventTimer(void) {}
   //--- Moving the control
   virtual void      Moving(const int x,const int y);
   //--- (1) Showing, (2) hiding, (3) resetting, (4) deleting
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   //--- (1) Setting, (2) resetting of priorities for left clicking on mouse
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   //--- Reset color
   virtual void      ResetColors(void) {}
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CScroll::CScroll(void) : m_current_pos(0),
                         m_area_width(15),
                         m_area_length(0),
                         m_inc_file_on(""),
                         m_inc_file_off(""),
                         m_dec_file_on(""),
                         m_dec_file_off(""),
                         m_thumb_width(0),
                         m_thumb_length(0),
                         m_thumb_min_length(15),
                         m_thumb_size_fixing(0),
                         m_thumb_point_fixing(0),
                         m_area_color(C'210,210,210'),
                         m_area_border_color(C'240,240,240'),
                         m_bg_border_color(C'210,210,210'),
                         m_thumb_color(C'190,190,190'),
                         m_thumb_color_hover(C'180,180,180'),
                         m_thumb_color_pressed(C'160,160,160'),
                         m_thumb_border_color(C'170,170,170'),
                         m_thumb_border_color_hover(C'160,160,160'),
                         m_thumb_border_color_pressed(C'140,140,140')
  {
//--- Set the priorities to the left mouse button clicks
   m_area_zorder  =8;
   m_bg_zorder    =9;
   m_arrow_zorder =10;
   m_thumb_zorder =11;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CScroll::~CScroll(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CScroll::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Leave, if the element is hidden
      if(!CElement::IsVisible())
         return;
      //---
      int x=(int)lparam;
      int y=(int)dparam;
      //--- Verifying the focus on the buttons
      m_inc.MouseFocus(x>m_inc.X() && x<m_inc.X2() && y>m_inc.Y() && y<m_inc.Y2());
      m_dec.MouseFocus(x>m_dec.X() && x<m_dec.X2() && y>m_dec.Y() && y<m_dec.Y2());
     }
  }
//+------------------------------------------------------------------+
//| Create the scrollbar                                             |
//+------------------------------------------------------------------+
bool CScroll::CreateScroll(const long chart_id,const int subwin,const int x,const int y,const int items_total,const int visible_items_total)
  {
//--- Leave, if there is no form pointer
   if(::CheckPointer(cBookGraphTable)==POINTER_INVALID)
     {
      ::Print(__FUNCTION__," > Before creating a scrollbar, the class has to be passed "
              "the form pointer: CScroll::WindowPointer(CWindow &object)");
      return(false);
     }
//--- Leave, if there is an attempt to use the base class of the scrollbar
   if(CElement::ClassName()=="")
     {
      ::Print(__FUNCTION__," > Use derived classes of the scrollbar (CScrollV or CScrollH).");
      return(false);
     }
//--- Initialization of variables
   m_chart_id          =chart_id;
   m_subwin            =subwin;
   m_x                 =x;
   m_y                 =y;
   m_area_width        =(CElement::ClassName()=="CScrollV")? CElement::XSize() : CElement::YSize();
   m_area_length       =(CElement::ClassName()=="CScrollV")? CElement::YSize() : CElement::XSize();
   m_thumb_width       =m_area_width-2;
   m_thumb_steps_total =items_total-visible_items_total+1;
//--- Indents from the edge point
   CElement::XGap(m_x-0);
   CElement::YGap(m_y-0);
//--- Create the button
   if(!CreateArea())
      return(false);
   if(!CreateBg())
      return(false);
   if(!CreateInc())
      return(false);
   if(!CreateDec())
      return(false);
   if(!CreateThumb())
      return(false);
//--- Hide the control if it is a dialog window or it is minimized
   //if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
   //   Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the common area of scrollbar                              |
//+------------------------------------------------------------------+
bool CScroll::CreateArea(void)
  {
//--- Formation of the object name
   string name      ="";
   string name_part =(CElement::ClassName()=="CScrollV")? "_scrollv_area_" : "_scrollh_area_";
//--- If index is not specified
   if(CElement::Index()==WRONG_VALUE)
      name=CElement::ProgramName()+name_part+(string)CElement::Id();
//--- If index is specified
   else
      name=CElement::ProgramName()+name_part+(string)CElement::Index()+"__"+(string)CElement::Id();
//--- Creating an object
   if(!m_area.Create(m_chart_id,name,m_subwin,m_x,m_y,m_x_size,m_y_size))
      return(false);
//--- Set properties
   m_area.BackColor(m_area_color);
   m_area.Color(m_area_border_color);
   m_area.BorderType(BORDER_FLAT);
   m_area.Corner(m_corner);
   m_area.Selectable(false);
   m_area.Z_Order(m_area_zorder);
   m_area.Tooltip("\n");
//--- Sizes
   m_area.XSize(m_x_size);
   m_area.YSize(m_y_size);
//--- Indents from the edge point
   m_area.XGap(m_x-0);
   m_area.YGap(m_y-0);
//--- Store the object pointer
   CElement::AddToArray(m_area);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the scrollbar background                                  |
//+------------------------------------------------------------------+
bool CScroll::CreateBg(void)
  {
//--- Formation of the object name
   string name      ="";
   string name_part =(CElement::ClassName()=="CScrollV")? "_scrollv_bg_" : "_scrollh_bg_";
//--- If index is not specified
   if(CElement::Index()==WRONG_VALUE)
      name=CElement::ProgramName()+name_part+(string)CElement::Id();
//--- If index is specified
   else
      name=CElement::ProgramName()+name_part+(string)CElement::Index()+"__"+(string)CElement::Id();
//--- Coordinates
   int x=0;
   int y=0;
//--- Sizes
   int x_size=0;
   int y_size=0;
//--- Setting properties considering the scrollbar type
   if(CElement::ClassName()=="CScrollV")
     {
      m_bg_length =CElement::YSize()-(m_thumb_width*2)-2;
      x           =CElement::X()+1;
      y           =CElement::Y()+m_thumb_width+1;
      x_size      =m_thumb_width;
      y_size      =m_bg_length;
     }
   else
     {
      m_bg_length =CElement::XSize()-(m_thumb_width*2)-2;
      x           =CElement::X()+m_thumb_width+1;
      y           =CElement::Y()+1;
      x_size      =m_bg_length;
      y_size      =m_thumb_width;
     }
//--- Creating an object
   if(!m_bg.Create(m_chart_id,name,m_subwin,x,y,x_size,y_size))
      return(false);
//--- Set properties
   m_bg.BackColor(m_area_color);
   m_bg.Color(m_bg_border_color);
   m_bg.BorderType(BORDER_FLAT);
   m_bg.Corner(m_corner);
   m_bg.Selectable(false);
   m_bg.Z_Order(m_bg_zorder);
   m_bg.Tooltip("\n");
//--- Store coordinates
   m_bg.X(x);
   m_bg.Y(y);
//--- Store margins
   m_bg.XGap(x-0);
   m_bg.YGap(y-0);
//--- Store the size
   m_bg.XSize(x_size);
   m_bg.YSize(y_size);
//--- Store the object pointer
   CElement::AddToArray(m_bg);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the up and left switch of the scrollbar                   |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Controls\\UpTransp_min.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\UpTransp_min_dark.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\LeftTransp_min.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\LeftTransp_min_dark.bmp"
//---
bool CScroll::CreateInc(void)
  {
//--- Formation of the object name
   string name      ="";
   string name_part =(CElement::ClassName()=="CScrollV")? "_scrollv_inc_" : "_scrollh_inc_";
//--- If index is not specified
   if(CElement::Index()==WRONG_VALUE)
      name=CElement::ProgramName()+name_part+(string)CElement::Id();
//--- If index is specified
   else
      name=CElement::ProgramName()+name_part+(string)CElement::Index()+"__"+(string)CElement::Id();
//--- Coordinates
   int x=m_x+1;
   int y=m_y+1;
//--- Setting properties considering the scrollbar type
   if(CElement::ClassName()=="CScrollV")
     {
      if(m_inc_file_on=="")
         m_inc_file_on="::Images\\EasyAndFastGUI\\Controls\\UpTransp_min_dark.bmp";
      if(m_inc_file_off=="")
         m_inc_file_off="::Images\\EasyAndFastGUI\\Controls\\UpTransp_min.bmp";
     }
   else
     {
      if(m_inc_file_on=="")
         m_inc_file_on="::Images\\EasyAndFastGUI\\Controls\\LeftTransp_min_dark.bmp";
      if(m_inc_file_off=="")
         m_inc_file_off="::Images\\EasyAndFastGUI\\Controls\\LeftTransp_min.bmp";
     }
//--- Creating an object
   if(!m_inc.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_inc.BmpFileOn(m_inc_file_on);
   m_inc.BmpFileOff(m_inc_file_off);
   m_inc.Corner(m_corner);
   m_inc.GetInteger(OBJPROP_ANCHOR,m_anchor);
   m_inc.Selectable(false);
   m_inc.Z_Order(m_arrow_zorder);
   m_inc.Tooltip("\n");
//--- Store coordinates
   m_inc.X(x);
   m_inc.Y(y);
//--- Store margins
   m_inc.XGap(x-0);
   m_inc.YGap(y-0);
//--- Store the size
   m_inc.XSize(m_inc.X_Size());
   m_inc.YSize(m_inc.Y_Size());
//--- Store the object pointer
   CElement::AddToArray(m_inc);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the down and right switch of the scrollbar                |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Controls\\DownTransp_min.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\DownTransp_min_dark.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\RightTransp_min.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\RightTransp_min_dark.bmp"
//---
bool CScroll::CreateDec(void)
  {
//--- Formation of the object name
   string name      ="";
   string name_part =(CElement::ClassName()=="CScrollV")? "_scrollv_dec_" : "_scrollh_dec_";
//--- If index is not specified
   if(CElement::Index()==WRONG_VALUE)
      name=CElement::ProgramName()+name_part+(string)CElement::Id();
//--- If index is specified
   else
      name=CElement::ProgramName()+name_part+(string)CElement::Index()+"__"+(string)CElement::Id();
//--- Coordinates
   int x=m_x+1;
   int y=m_y+m_bg.YSize()+m_thumb_width+1;
//--- Setting properties considering the scrollbar type
   if(CElement::ClassName()=="CScrollV")
     {
      x =m_x+1;
      y =m_y+m_bg.YSize()+m_thumb_width+1;
      //--- If the icon is not defined, set the default one
      if(m_dec_file_on=="")
         m_dec_file_on="::Images\\EasyAndFastGUI\\Controls\\DownTransp_min_dark.bmp";
      if(m_dec_file_off=="")
         m_dec_file_off="::Images\\EasyAndFastGUI\\Controls\\DownTransp_min.bmp";
     }
   else
     {
      x =m_x+m_bg.XSize()+m_thumb_width+1;
      y =m_y+1;
      //--- If the icon is not defined, set the default one
      if(m_dec_file_on=="")
         m_dec_file_on="::Images\\EasyAndFastGUI\\Controls\\RightTransp_min_dark.bmp";
      if(m_dec_file_off=="")
         m_dec_file_off="::Images\\EasyAndFastGUI\\Controls\\RightTransp_min.bmp";
     }
//--- Creating an object
   if(!m_dec.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_dec.BmpFileOn(m_dec_file_on);
   m_dec.BmpFileOff(m_dec_file_off);
   m_dec.Corner(m_corner);
   m_dec.GetInteger(OBJPROP_ANCHOR,m_anchor);
   m_dec.Selectable(false);
   m_dec.Z_Order(m_arrow_zorder);
   m_dec.Tooltip("\n");
//--- Store coordinates
   m_dec.X(x);
   m_dec.Y(y);
//--- Store margins
   m_dec.XGap(x-0);
   m_dec.YGap(y-0);
//--- Store the size
   m_dec.XSize(m_dec.X_Size());
   m_dec.YSize(m_dec.Y_Size());
//--- Store the object pointer
   CElement::AddToArray(m_dec);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the scrollbar slider                                      |
//+------------------------------------------------------------------+
bool CScroll::CreateThumb(void)
  {
//--- Formation of the object name  
   string name      ="";
   string name_part =(CElement::ClassName()=="CScrollV")? "_scrollv_thumb_" : "_scrollh_thumb_";
//--- If index is not specified
   if(CElement::Index()==WRONG_VALUE)
      name=CElement::ProgramName()+name_part+(string)CElement::Id();
//--- If index is specified
   else
      name=CElement::ProgramName()+name_part+(string)CElement::Index()+"__"+(string)CElement::Id();
//--- Coordinates
   int x=0;
   int y=0;
//--- Sizes
   int x_size=0;
   int y_size=0;
//--- Calculate the size of the scroll bar
   if(!CalculateThumbSize())
      return(true);
//--- Setting the property considering the scrollbar type
   if(CElement::ClassName()=="CScrollV")
     {
      x      =(m_thumb.X()>0) ? m_thumb.X() : m_x+1;
      y      =(m_thumb.Y()>0) ? m_thumb.Y() : m_y+m_thumb_width+1;
      x_size =m_thumb_width;
      y_size =m_thumb_length;
     }
   else
     {
      x      =(m_thumb.X()>0) ? m_thumb.X() : m_x+m_thumb_width+1;
      y      =(m_thumb.Y()>0) ? m_thumb.Y() : m_y+1;
      x_size =m_thumb_length;
      y_size =m_thumb_width;
     }
//--- Creating an object
   if(!m_thumb.Create(m_chart_id,name,m_subwin,x,y,x_size,y_size))
      return(false);
//--- Set properties
   m_thumb.BackColor(m_thumb_color);
   m_thumb.Color(m_thumb_border_color);
   m_thumb.BorderType(BORDER_FLAT);
   m_thumb.Corner(m_corner);
   m_thumb.Selectable(false);
   m_thumb.Z_Order(m_thumb_zorder);
   m_thumb.Tooltip("\n");
//--- Store coordinates
   m_thumb.X(x);
   m_thumb.Y(y);
//--- Store margins
   m_thumb.XGap(x-0);
   m_thumb.YGap(y-0);
//--- Store the size
   m_thumb.XSize(x_size);
   m_thumb.YSize(y_size);
//--- Store the object pointer
   CElement::AddToArray(m_thumb);
   return(true);
  }
//+------------------------------------------------------------------+
//| Calculation of the length of the scrollbar slider                |
//+------------------------------------------------------------------+
bool CScroll::CalculateThumbSize(void)
  {
//--- Calculation is not required if the length of the area for moving the slider is less than the minimal length of the slider
   if(m_bg_length<m_thumb_min_length)
      return(false);
//--- Calculate the size of the slider step
   m_thumb_step_size=(double)(m_bg_length-m_thumb_min_length)/m_thumb_steps_total;
//--- The step size cannot be less than 1
   m_thumb_step_size=(m_thumb_step_size<1)? 1 : m_thumb_step_size;
//--- Calculate the size of the working area for moving the slider
   double work_area=m_thumb_step_size*m_thumb_steps_total;
//--- If the size of the working area is less than the size of the whole area, get the size of the slider otherwise set the minimal size
   double thumb_size=(work_area<m_bg_length)? m_bg_length-work_area+m_thumb_step_size : m_thumb_min_length;
//--- Check of the slider size using the type casting
   m_thumb_length=((int)thumb_size<m_thumb_min_length)? m_thumb_min_length :(int)thumb_size;
   return(true);
  }
//+------------------------------------------------------------------+
//| Identifies the area of pressing the left mouse button            |
//+------------------------------------------------------------------+
void CScroll::CheckMouseButtonState(const bool mouse_state)
  {
//--- If the left mouse button is released
   if(!mouse_state)
     {
      //--- Zero variables
      ZeroThumbVariables();
      return;
     }
//--- If the button is pressed
   if(mouse_state)
     {
      //--- Leave, if the button is pressed down in another area
      if(m_clamping_area_mouse!=THUMB_NOT_PRESSED)
         return;
      //--- Outside of the slider area
      if(!m_thumb.MouseFocus())
         m_clamping_area_mouse=THUMB_PRESSED_OUTSIDE;
      //--- Inside the slider area
      else
        {
         m_clamping_area_mouse=THUMB_PRESSED_INSIDE;
         //--- If it is not a drop-down element
         if(!CElement::IsDropdown())
           {
            //--- Block the form and store the active element identifier
            m_wnd.IsLocked(true);
            m_wnd.IdActivatedElement(CElement::Id());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Zeroing variables connected with the slider movement             |
//+------------------------------------------------------------------+
void CScroll::ZeroThumbVariables(void)
  {
//--- If it is not a drop-down element
   if(!CElement::IsDropdown() && m_clamping_area_mouse==THUMB_PRESSED_INSIDE)
     {
      //--- Unblock the form and reset the active element identifier
      m_wnd.IsLocked(false);
      m_wnd.IdActivatedElement(WRONG_VALUE);
     }
//---
   m_thumb_size_fixing   =0;
   m_clamping_area_mouse =THUMB_NOT_PRESSED;
  }
//+------------------------------------------------------------------+
//| Changes the color of objects of the list view scrollbar          |
//+------------------------------------------------------------------+
void CScroll::ChangeObjectsColor(void)
  {
//--- Leave, if the form is blocked and the identifier of the currently active element differs
   //if(m_wnd.IsLocked() && m_wnd.IdActivatedElement()!=CElement::Id())
   //   return;
//--- Color of the buttons of the list view scrollbar
   if(!m_scroll_state)
     {
      m_inc.State(m_inc.MouseFocus());
      m_dec.State(m_dec.MouseFocus());
     }
//--- If the cursor is in the scrollbar area
   if(m_thumb.MouseFocus())
     {
      //--- If the left mouse button is released
      if(m_clamping_area_mouse==THUMB_NOT_PRESSED)
        {
         m_scroll_state=false;
         m_thumb.BackColor(m_thumb_color_hover);
         m_thumb.Color(m_thumb_border_color_hover);
        }
      //--- The left mouse button is pressed down on the slider
      else if(m_clamping_area_mouse==THUMB_PRESSED_INSIDE)
        {
         m_scroll_state=true;
         m_thumb.BackColor(m_thumb_color_pressed);
         m_thumb.Color(m_thumb_border_color_pressed);
        }
     }
//--- If the cursor is outside of the scrollbar area
   else
     {
      //--- Left mouse button is released
      if(m_clamping_area_mouse==THUMB_NOT_PRESSED)
        {
         m_scroll_state=false;
         m_thumb.BackColor(m_thumb_color);
         m_thumb.Color(m_thumb_border_color);
        }
     }
  }
//+------------------------------------------------------------------+
//| Change the slider size according to new conditions               |
//+------------------------------------------------------------------+
void CScroll::ChangeThumbSize(const int items_total,const int visible_items_total)
  {
//--- Leave, if the number of list items is not greater than the size of visible area of the list
   if(items_total<=visible_items_total)
      return;
//--- Get the number of steps for the slider
   m_thumb_steps_total=items_total-visible_items_total+1;
//--- Get the scrollbar size
   if(!CalculateThumbSize())
      return;
//--- Store the size
   if(CElement::ClassName()=="CScrollV")
     {
      CElement::YSize(m_thumb_length);
      m_thumb.YSize(m_thumb_length);
      m_thumb.Y_Size(m_thumb_length);
     }
   else
     {
      CElement::XSize(m_thumb_length);
      m_thumb.XSize(m_thumb_length);
      m_thumb.X_Size(m_thumb_length);
     }
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CScroll::Moving(const int x,const int y)
  {
//--- Leave, if the element is hidden
   if(!CElement::IsVisible())
      return;
//--- Storing coordinates in the element fields
   CElement::X(x+XGap());
   CElement::Y(y+YGap());
//--- Storing coordinates in the fields of the objects
   m_area.X(x+m_area.XGap());
   m_area.Y(y+m_area.YGap());
   m_bg.X(x+m_bg.XGap());
   m_bg.Y(y+m_bg.YGap());
   m_inc.X(x+m_inc.XGap());
   m_inc.Y(y+m_inc.YGap());
   m_dec.X(x+m_dec.XGap());
   m_dec.Y(y+m_dec.YGap());
   m_thumb.X(x+m_thumb.XGap());
   m_thumb.Y(y+m_thumb.YGap());
//--- Updating coordinates of graphical objects
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
   m_bg.X_Distance(m_bg.X());
   m_bg.Y_Distance(m_bg.Y());
   m_inc.X_Distance(m_inc.X());
   m_inc.Y_Distance(m_inc.Y());
   m_dec.X_Distance(m_dec.X());
   m_dec.Y_Distance(m_dec.Y());
   m_thumb.X_Distance(m_thumb.X());
   m_thumb.Y_Distance(m_thumb.Y());
  }
//+------------------------------------------------------------------+
//| Shows a menu item                                                |
//+------------------------------------------------------------------+
void CScroll::Show(void)
  {
   m_area.Timeframes(OBJ_ALL_PERIODS);
   m_bg.Timeframes(OBJ_ALL_PERIODS);
   m_inc.Timeframes(OBJ_ALL_PERIODS);
   m_dec.Timeframes(OBJ_ALL_PERIODS);
   m_thumb.Timeframes(OBJ_ALL_PERIODS);
  }
//+------------------------------------------------------------------+
//| Hides a menu item                                                |
//+------------------------------------------------------------------+
void CScroll::Hide(void)
  {
   m_area.Timeframes(OBJ_NO_PERIODS);
   m_bg.Timeframes(OBJ_NO_PERIODS);
   m_inc.Timeframes(OBJ_NO_PERIODS);
   m_dec.Timeframes(OBJ_NO_PERIODS);
   m_thumb.Timeframes(OBJ_NO_PERIODS);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CScroll::Reset(void)
  {
//--- Leave, if it is a drop-down element
   if(CElement::IsDropdown())
      return;
//--- Hide and show
   Hide();
   Show();
  }
//+------------------------------------------------------------------+
//| Deleting                                                         |
//+------------------------------------------------------------------+
void CScroll::Delete(void)
  {
//--- Deleting objects
   m_area.Delete();
   m_bg.Delete();
   m_inc.Delete();
   m_dec.Delete();
   m_thumb.Delete();
//--- Emptying the object array
   CElement::FreeObjectsArray();
  }
//+------------------------------------------------------------------+
//| Set priorities                                                   |
//+------------------------------------------------------------------+
void CScroll::SetZorders(void)
  {
   m_area.Z_Order(m_area_zorder);
   m_bg.Z_Order(m_bg_zorder);
   m_inc.Z_Order(m_arrow_zorder);
   m_dec.Z_Order(m_arrow_zorder);
   m_thumb.Z_Order(m_thumb_zorder);
//--- If vertical scroll bar
   if(CElement::ClassName()=="CScrollV")
     {
      m_inc.BmpFileOn(m_inc_file_on);
      m_dec.BmpFileOn(m_dec_file_on);
      return;
     }
//--- If horizontal scroll bar
   if(CElement::ClassName()=="CScrollH")
     {
      m_inc.BmpFileOn(m_inc_file_on);
      m_dec.BmpFileOn(m_dec_file_on);
      return;
     }
  }
//+------------------------------------------------------------------+
//| Reset priorities                                                 |
//+------------------------------------------------------------------+
void CScroll::ResetZorders(void)
  {
   m_area.Z_Order(0);
   m_bg.Z_Order(0);
   m_inc.Z_Order(0);
   m_dec.Z_Order(0);
   m_thumb.Z_Order(0);
//--- If vertical scroll bar
   if(CElement::ClassName()=="CScrollV")
     {
      m_inc.BmpFileOn(m_inc_file_off);
      m_dec.BmpFileOn(m_dec_file_off);
      return;
     }
//--- If horizontal scroll bar
   if(CElement::ClassName()=="CScrollH")
     {
      m_inc.BmpFileOn(m_inc_file_off);
      m_dec.BmpFileOn(m_dec_file_off);
      return;
     }
  }
//+------------------------------------------------------------------+
//| Class for managing the vertical scrollbar                        |
//+------------------------------------------------------------------+
class CScrollV : public CScroll
  {
public:
                     CScrollV(void);
                    ~CScrollV(void);
   //--- Managing the slider
   bool              ScrollBarControl(const int x,const int y,const bool mouse_state);
   //--- Calculation of the Y coordinate of the slider
   void              CalculateThumbY(void);
   //--- Set the new coordinate for the scrollbar
   void              XDistance(const int x);
   //--- Handling the pressing on the scrollbar buttons
   bool              OnClickScrollInc(const string clicked_object);
   bool              OnClickScrollDec(const string clicked_object);
   //---
private:
   //--- Moving the slider
   void              OnDragThumb(const int y);
   //--- Updating the location of the slider
   void              UpdateThumb(const int new_y_point);
   //--- Corrects the value of the slider position
   void              CalculateThumbPos(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CScrollV::CScrollV(void)
  {
//--- Store the name of the control class in the base class
   CElement::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CScrollV::~CScrollV(void)
  {
  }
//+------------------------------------------------------------------+
//| Managing the slider                                              |
//+------------------------------------------------------------------+
bool CScrollV::ScrollBarControl(const int x,const int y,const bool mouse_state)
  {
//--- If the form is not locked and the identifiers match
   //if(m_wnd.IsLocked() && m_wnd.IdActivatedElement()!=CElement::Id())
   //   return(false);
//--- Verifying the focus on the slider
   m_thumb.MouseFocus(x>m_thumb.X() && x<m_thumb.X2() && 
                      y>m_thumb.Y() && y<m_thumb.Y2());
//--- Verify and store the state of the mouse button
   CScroll::CheckMouseButtonState(mouse_state);
//--- Change the slider color
   CScroll::ChangeObjectsColor();
//--- If the management is passed to the scrollbar, identify the location of the scrollbar
   if(CScroll::ScrollState())
     {
      //--- Moving the slider
      OnDragThumb(y);
      //--- Changes he number of the slider position
      CalculateThumbPos();
      return(true);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Calculation of the Y coordinate of the scrollbar                 |
//+------------------------------------------------------------------+
void CScrollV::CalculateThumbY(void)
  {
//--- Identify current Y coordinate of the scrollbar
   int scroll_thumb_y=int(m_bg.Y()+(CScroll::CurrentPos()*CScroll::m_thumb_step_size));
//--- If the working area is exceeded upwards
   if(scroll_thumb_y<=m_bg.Y())
      scroll_thumb_y=m_bg.Y();
//--- If the working area is exceeded downwards
   if(scroll_thumb_y+CScroll::m_thumb_length>=m_bg.Y2() || 
      CScroll::CurrentPos()>=CScroll::m_thumb_steps_total-1)
     {
      scroll_thumb_y=int(m_bg.Y2()-CScroll::m_thumb_length);
     }
//--- Update the coordinate and margin along the Y axis
   m_thumb.Y(scroll_thumb_y);
   m_thumb.Y_Distance(scroll_thumb_y);
   m_thumb.YGap(m_thumb.Y()-0);
  }
//+------------------------------------------------------------------+
//| Change the X coordinate of the element                           |
//+------------------------------------------------------------------+
void CScrollV::XDistance(const int x)
  {
//--- Update the X coordinate of the element...
   int l_x=x+1;
   CElement::X(x);
//--- ...and all scrollbar objects
   m_area.X(CElement::X());
   m_bg.X(l_x);
   m_thumb.X(l_x);
   m_inc.X(l_x);
   m_dec.X(l_x);
//--- Set the coordinate to the objects
   m_area.X_Distance(CElement::X());
   m_bg.X_Distance(l_x);
   m_thumb.X_Distance(l_x);
   m_inc.X_Distance(l_x);
   m_dec.X_Distance(l_x);
//--- Update the margins of all element objects
   m_area.XGap(CElement::X()-m_wnd.X());
   m_bg.XGap(l_x-m_wnd.X());
   m_thumb.XGap(l_x-m_wnd.X());
   m_inc.XGap(l_x-m_wnd.X());
   m_dec.XGap(l_x-m_wnd.X());
  }
//+------------------------------------------------------------------+
//| Handling the pressing on the upwards/to the left button          |
//+------------------------------------------------------------------+
bool CScrollV::OnClickScrollInc(const string clicked_object)
  {
//--- Leave, if the pressing was not on this object or the scrollbar is inactive or the number of steps is not identified
   if(m_inc.Name()!=clicked_object || CScroll::ScrollState() || CScroll::m_thumb_steps_total<1)
      return(false);
//--- Decrease the value of the scrollbar position
   if(CScroll::CurrentPos()>0)
      CScroll::m_current_pos--;
//--- Calculation of the Y coordinate of the scrollbar
   CalculateThumbY();
//--- Set the state On
   m_inc.State(true);
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the pressing on the downwards/to the left right         |
//+------------------------------------------------------------------+
bool CScrollV::OnClickScrollDec(const string clicked_object)
  {
//--- Leave, if the pressing was not on this object or the scrollbar is inactive or the number of steps is not identified
   if(m_dec.Name()!=clicked_object || CScroll::ScrollState() || CScroll::m_thumb_steps_total<1)
      return(false);
//--- Increase the value of the scrollbar position
   if(CScroll::CurrentPos()<CScroll::m_thumb_steps_total-1)
      CScroll::m_current_pos++;
//--- Calculation of the Y coordinate of the scrollbar
   CalculateThumbY();
//--- Set the state On
   m_dec.State(true);
   return(true);
  }
//+------------------------------------------------------------------+
//| Moving the slider                                                |
//+------------------------------------------------------------------+
void CScrollV::OnDragThumb(const int y)
  {
//--- To identify the new Y coordinate
   int new_y_point=0;
//--- If the scrollbar is inactive, ...
   if(!CScroll::ScrollState())
     {
      //--- ...zero auxiliary variables for moving the slider
      CScroll::m_thumb_size_fixing  =0;
      CScroll::m_thumb_point_fixing =0;
      return;
     }
//--- If the fixation point is zero, store current coordinates of the cursor
   if(CScroll::m_thumb_point_fixing==0)
      CScroll::m_thumb_point_fixing=y;
//--- If the distance from the edge of the slider to the current coordinate of the cursor is zero, calculate it
   if(CScroll::m_thumb_size_fixing==0)
      CScroll::m_thumb_size_fixing=m_thumb.Y()-y;
//--- If the threshold is passed downwards in the pressed down state
   if(y-CScroll::m_thumb_point_fixing>0)
     {
      //--- Calculate the Y coordinate
      new_y_point=y+CScroll::m_thumb_size_fixing;
      //--- Update location of the slider
      UpdateThumb(new_y_point);
      return;
     }
//--- If the threshold is passed upwards in the pressed down state
   if(y-CScroll::m_thumb_point_fixing<0)
     {
      //--- Calculate the Y coordinate
      new_y_point=y-::fabs(CScroll::m_thumb_size_fixing);
      //--- Update location of the slider
      UpdateThumb(new_y_point);
      return;
     }
  }
//+------------------------------------------------------------------+
//| Updating of the location of the slider                           |
//+------------------------------------------------------------------+
void CScrollV::UpdateThumb(const int new_y_point)
  {
   int y=new_y_point;
//--- Zeroing the fixation point
   CScroll::m_thumb_point_fixing=0;
//--- Checking for exceeding the working area downwards and adjusting values
   if(new_y_point>m_bg.Y2()-CScroll::m_thumb_length)
     {
      y=m_bg.Y2()-CScroll::m_thumb_length;
      CScroll::CurrentPos(int(CScroll::m_thumb_steps_total));
     }
//--- Checking for exceeding the working area upwards and adjusting values
   if(new_y_point<=m_bg.Y())
     {
      y=m_bg.Y();
      CScroll::CurrentPos(0);
     }
//--- Update coordinates and margins
   m_thumb.Y(y);
   m_thumb.Y_Distance(y);
   m_thumb.YGap(m_thumb.Y()-(CElement::Y()-CElement::YGap()));
  }
//+------------------------------------------------------------------+
//| Corrects the value of the slider position                        |
//+------------------------------------------------------------------+
void CScrollV::CalculateThumbPos(void)
  {
//--- Leave, if the step is zero
   if(CScroll::m_thumb_step_size==0)
      return;
//--- Corrects the value of the position of the scrollbar
   CScroll::CurrentPos(int((m_thumb.Y()-m_bg.Y())/CScroll::m_thumb_step_size));
//--- Check for exceeding the working area downwards/upwards
   if(m_thumb.Y2()>=m_bg.Y2()-1)
      CScroll::CurrentPos(int(CScroll::m_thumb_steps_total-1));
   if(m_thumb.Y()<m_bg.Y())
      CScroll::CurrentPos(0);
  }
//+------------------------------------------------------------------+
//| Class for managing the horizontal scrollbar                      |
//+------------------------------------------------------------------+
class CScrollH : public CScroll
  {
public:
                     CScrollH(void);
                    ~CScrollH(void);
   //--- Managing the slider
   bool              ScrollBarControl(const int x,const int y,const bool mouse_state);
   //--- Calculation of the X coordinate of the slider
   void              CalculateThumbX(void);
   //--- Handling the pressing on the scrollbar buttons
   bool              OnClickScrollInc(const string clicked_object);
   bool              OnClickScrollDec(const string clicked_object);
   //---
private:
   //--- Moving the slider
   void              OnDragThumb(const int x);
   //--- Updating the location of the slider
   void              UpdateThumb(const int new_x_point);
   //--- Corrects the value of the slider position
   void              CalculateThumbPos(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CScrollH::CScrollH(void)
  {
//--- Store the name of the control class in the base class
   CElement::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CScrollH::~CScrollH(void)
  {
  }
//+------------------------------------------------------------------+
//| Managing the scrollbar                                           |
//+------------------------------------------------------------------+
bool CScrollH::ScrollBarControl(const int x,const int y,const bool mouse_state)
  {
   if(m_wnd.IsLocked() && m_wnd.IdActivatedElement()!=CElement::Id())
      return(false);
//--- Verifying the focus on the slider
   m_thumb.MouseFocus(x>m_thumb.X() && x<m_thumb.X2() && 
                      y>m_thumb.Y() && y<m_thumb.Y2());
//--- Verify and store the state of the mouse button
   CScroll::CheckMouseButtonState(mouse_state);
//--- Change the color of the list scrollbar
   CScroll::ChangeObjectsColor();
//--- If the management is passed to the scrollbar, identify the location of the scrollbar
   if(CScroll::ScrollState())
     {
      //--- Moving the slider
      OnDragThumb(x);
      //--- Changes he number of the slider position
      CalculateThumbPos();
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Calculation of the X coordinate of the slider                    |
//+------------------------------------------------------------------+
void CScrollH::CalculateThumbX(void)
  {
//--- Identify current X coordinate of the scrollbar
   int scroll_thumb_x=int(m_bg.X()+(CScroll::CurrentPos()*CScroll::m_thumb_step_size));
//--- If the working area is exceeded to the left
   if(scroll_thumb_x<=m_bg.X())
      scroll_thumb_x=m_bg.X();
//--- If the working area is exceeded to the right
   if(scroll_thumb_x+CScroll::m_thumb_length>=m_bg.X2() || 
      CScroll::CurrentPos()>=CScroll::m_thumb_steps_total-1)
     {
      scroll_thumb_x=int(m_bg.X2()-CScroll::m_thumb_length);
     }
//--- Update the coordinate and margin along the X axis
   m_thumb.X(scroll_thumb_x);
   m_thumb.X_Distance(scroll_thumb_x);
   m_thumb.XGap(m_thumb.X()-(m_x-CElement::XGap()));
  }
//+------------------------------------------------------------------+
//| Pressing the left switch                                         |
//+------------------------------------------------------------------+
bool CScrollH::OnClickScrollInc(const string clicked_object)
  {
//--- Leave, if the pressing was not on this object or the scrollbar is inactive or the number of steps is not identified
   if(m_inc.Name()!=clicked_object || CScroll::ScrollState() || CScroll::m_thumb_steps_total<0)
      return(false);
//--- Decrease the value of the scrollbar position
   if(CScroll::CurrentPos()>0)
      CScroll::m_current_pos--;
//--- Calculation of the X coordinate of the scrollbar
   CalculateThumbX();
//--- Set the state On
   m_inc.State(true);
   return(true);
  }
//+------------------------------------------------------------------+
//| Pressing the right switch                                        |
//+------------------------------------------------------------------+
bool CScrollH::OnClickScrollDec(const string clicked_object)
  {
//--- Leave, if the pressing was not on this object or the scrollbar is inactive or the number of steps is not identified
   if(m_dec.Name()!=clicked_object || CScroll::ScrollState() || CScroll::m_thumb_steps_total<0)
      return(false);
//--- Increase the value of the scrollbar position
   if(CScroll::CurrentPos()<CScroll::m_thumb_steps_total-1)
      CScroll::m_current_pos++;
//--- Calculation of the X coordinate of the scrollbar
   CalculateThumbX();
//--- Set the state On
   m_dec.State(true);
   return(true);
  }
//+------------------------------------------------------------------+
//| Moving the slider                                                |
//+------------------------------------------------------------------+
void CScrollH::OnDragThumb(const int x)
  {
//--- To identify the new X coordinate
   int new_x_point=0;
//--- If the scrollbar is inactive, ...
   if(!CScroll::ScrollState())
     {
      //--- ...zero auxiliary variables for moving the slider
      CScroll::m_thumb_size_fixing  =0;
      CScroll::m_thumb_point_fixing =0;
      return;
     }
//--- If the fixation point is zero, store current coordinates of the cursor
   if(CScroll::m_thumb_point_fixing==0)
      CScroll::m_thumb_point_fixing=x;
//--- If the distance from the edge of the slider to the current coordinate of the cursor is zero, calculate it
   if(CScroll::m_thumb_size_fixing==0)
      CScroll::m_thumb_size_fixing=m_thumb.X()-x;
//--- If the threshold is passed to the right in the pressed down state
   if(x-CScroll::m_thumb_point_fixing>0)
     {
      //--- Calculate the X coordinate
      new_x_point=x+CScroll::m_thumb_size_fixing;
      //--- Update the scroll bar position
      UpdateThumb(new_x_point);
      return;
     }
//--- If the threshold is passed to the left in the pressed down state
   if(x-CScroll::m_thumb_point_fixing<0)
     {
      //--- Calculate the X coordinate
      new_x_point=x-::fabs(CScroll::m_thumb_size_fixing);
      //--- Update the scroll bar position
      UpdateThumb(new_x_point);
      return;
     }
  }
//+------------------------------------------------------------------+
//| Update the scroll bar position                                   |
//+------------------------------------------------------------------+
void CScrollH::UpdateThumb(const int new_x_point)
  {
   int x=new_x_point;
//--- Zeroing the fixation point
   CScroll::m_thumb_point_fixing=0;
//--- Checking for exceeding the working area to the right and adjusting values
   if(new_x_point>m_bg.X2()-CScroll::m_thumb_length)
     {
      x=m_bg.X2()-CScroll::m_thumb_length;
      CScroll::CurrentPos(0);
     }
//--- Checking for exceeding the working area to the left and adjusting values
   if(new_x_point<=m_bg.X())
     {
      x=m_bg.X();
      CScroll::CurrentPos(int(CScroll::m_thumb_steps_total));
     }
//--- Update coordinates and margins
   m_thumb.X(x);
   m_thumb.X_Distance(x);
   m_thumb.XGap(m_thumb.X()-(m_x-CElement::XGap()));
  }
//+------------------------------------------------------------------+
//| Corrects the value of the slider position                        |
//+------------------------------------------------------------------+
void CScrollH::CalculateThumbPos(void)
  {
//--- Leave, if the step is zero
   if(CScroll::m_thumb_step_size==0)
      return;
//--- Corrects the value of the position of the scrollbar
   CScroll::CurrentPos(int((m_thumb.X()-m_bg.X())/CScroll::m_thumb_step_size));
//--- Check for exceeding the working area to the left/right
   if(m_thumb.X2()>=m_bg.X2()-1)
      CScroll::CurrentPos(int(CScroll::m_thumb_steps_total-1));
   if(m_thumb.X()<m_bg.X())
      CScroll::CurrentPos(0);
  }
//+------------------------------------------------------------------+
