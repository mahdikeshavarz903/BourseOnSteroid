//+------------------------------------------------------------------+
//|                                                   IconButton.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Element.mqh"
#include "Window.mqh"
//+------------------------------------------------------------------+
//| Class for creating an icon button                                |
//+------------------------------------------------------------------+
class CIconButton : public CElement
  {
private:
   //--- Pointer to the form to which the element is attached
   CWindow          *m_wnd;
   //--- Objects for creating a button
   CButton           m_button;
   CBmpLabel         m_icon;
   CLabel            m_label;
   //--- button properties:
   //    Size and priority for clicking the left mouse button
   int               m_button_x_size;
   int               m_button_y_size;
   int               m_button_zorder;
   //--- Background color in different modes
   color             m_back_color;
   color             m_back_color_off;
   color             m_back_color_hover;
   color             m_back_color_pressed;
   color             m_back_color_array[];
   //--- Border Color
   color             m_border_color;
   color             m_border_color_off;
   //--- Button labels in active and locked modes
   string            m_icon_file_on;
   string            m_icon_file_off;
   //--- Label margins
   int               m_icon_x_gap;
   int               m_icon_y_gap;
   //--- Text and margins of the text label
   string            m_label_text;
   int               m_label_x_gap;
   int               m_label_y_gap;
   //--- The color of the text label in different modes
   color             m_label_color;
   color             m_label_color_off;
   color             m_label_color_hover;
   color             m_label_color_pressed;
   color             m_label_color_array[];
   //--- General priority for non-clickable objects
   int               m_zorder;
   //--- Two-state mode of the button
   bool              m_two_state;
   //--- Available/locked
   bool              m_button_state;
   //--- "Only icon", when the button consists of BmpLabel object only
   bool              m_only_icon;
   //---
public:
                     CIconButton(void);
                    ~CIconButton(void);
   //--- Methods for creating a button
   bool              CreateIconButton(const long chart_id,const int subwin,const string button_text,const int x,const int y);
   //---
private:
   bool              CreateButton(void);
   bool              CreateIcon(void);
   bool              CreateLabel(void);
   //---
public:
   //--- (1) Stores the form pointer, (2) sets the button mode, (3) sets the "Only icon" mode
   //    (4) general state of the button (available/locked)
   void              WindowPointer(CWindow &object)           { m_wnd=::GetPointer(object);     }
   void              TwoState(const bool flag)                { m_two_state=flag;               }
   void              OnlyIcon(const bool flag)                { m_only_icon=flag;               }
   bool              IsPressed(void)                    const { return(m_button.State());       }
   bool              ButtonState(void)                  const { return(m_button_state);         }
   void              ButtonState(const bool state);
   //--- (1) Getting button text, (2) button size
   string            Text(void)                         const { return(m_label_text);           }
   void              ButtonXSize(const int x_size)            { m_button_x_size=x_size;         }
   void              ButtonYSize(const int y_size)            { m_button_y_size=y_size;         }
   //--- Set labels for the button in active and locked modes
   void              IconFileOn(const string file_path)       { m_icon_file_on=file_path;       }
   void              IconFileOff(const string file_path)      { m_icon_file_off=file_path;      }
   //--- Label margins
   void              IconXGap(const int x_gap)                { m_icon_x_gap=x_gap;             }
   void              IconYGap(const int y_gap)                { m_icon_y_gap=y_gap;             }
   //--- Button background colors
   void              BackColor(const color clr)               { m_back_color=clr;               }
   void              BackColorOff(const color clr)            { m_back_color_off=clr;           }
   void              BackColorHover(const color clr)          { m_back_color_hover=clr;         }
   void              BackColorPressed(const color clr)        { m_back_color_pressed=clr;       }
   //--- Set the button frame color
   void              BorderColor(const color clr)             { m_border_color=clr;             }
   void              BorderColorOff(const color clr)          { m_border_color_off=clr;         }
   //--- Margins of the text label
   void              LabelXGap(const int x_gap)               { m_label_x_gap=x_gap;            }
   void              LabelYGap(const int y_gap)               { m_label_y_gap=y_gap;            }
   //--- Set the button text color
   void              LabelColor(const color clr)              { m_label_color=clr;              }
   void              LabelColorOff(const color clr)           { m_label_color_off=clr;          }
   void              LabelColorHover(const color clr)         { m_label_color_hover=clr;        }
   void              LabelColorPressed(const color clr)       { m_label_color_pressed=clr;      }

   //--- Change the element color
   void              ChangeObjectsColor(void);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Timer
   virtual void      OnEventTimer(void);
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
   virtual void      ResetColors(void);
   //---
private:
   //--- Button click handling
   bool              OnClickButton(const string clicked_object);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CIconButton::CIconButton(void) : m_icon_x_gap(4),
                                 m_icon_y_gap(3),
                                 m_label_x_gap(25),
                                 m_label_y_gap(4),
                                 m_icon_file_on(""),
                                 m_icon_file_off(""),
                                 m_button_state(true),
                                 m_two_state(false),
                                 m_only_icon(false),
                                 m_button_y_size(18),
                                 m_back_color(clrLightGray),
                                 m_back_color_off(clrLightGray),
                                 m_back_color_hover(clrSilver),
                                 m_back_color_pressed(clrBlack),
                                 m_border_color(clrWhite),
                                 m_border_color_off(clrDarkGray),
                                 m_label_color(clrBlack),
                                 m_label_color_off(clrDarkGray),
                                 m_label_color_hover(clrBlack),
                                 m_label_color_pressed(clrBlack)
  {
//--- Store the name of the control class in the base class  
   CElement::ClassName(CLASS_NAME);
//--- Set the priorities to the left mouse button clicks
   m_zorder        =0;
   m_button_zorder =1;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CIconButton::~CIconButton(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CIconButton::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Leave, if the element is hidden
      if(!CElement::IsVisible())
         return;
      //--- Identify the focus
      int x=(int)lparam;
      int y=(int)dparam;
      CElement::MouseFocus(x>X() && x<X2() && y>Y() && y<Y2());
      m_icon.MouseFocus(x>m_icon.X() && x<m_icon.X2() && y>m_icon.Y() && y<m_icon.Y2());
      //--- Leave, if the form is locked
      if(m_wnd.IsLocked())
         return;
      //--- Leave, if the button is released
      if(sparam=="0")
         return;
      //--- Leave, if the button is locked
      if(!m_button_state)
         return;
      //--- If there is no focus
      if(!CElement::MouseFocus())
        {
         //--- If the button is released
         if(!m_button.State())
            m_button.BackColor(m_back_color);
         //---
         return;
        }
      //--- If there is a focus
      else
        {
         m_label.Color(m_label_color_pressed);
         m_button.BackColor(m_back_color_pressed);
         return;
        }
      //---
      return;
     }
//--- Handling left mouse clicking event on an object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(OnClickButton(sparam))
         return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CIconButton::OnEventTimer(void)
  {
//--- If it is a drop-down element
   if(CElement::IsDropdown())
      ChangeObjectsColor();
   else
     {
      //--- If the form and the button are not locked
      if(!m_wnd.IsLocked() && m_button_state)
         ChangeObjectsColor();
     }
  }
//+------------------------------------------------------------------+
//| Create "Button" control                                          |
//+------------------------------------------------------------------+
bool CIconButton::CreateIconButton(const long chart_id,const int subwin,const string button_text,const int x,const int y)
  {
//--- Leave, if there is no form pointer
   if(::CheckPointer(m_wnd)==POINTER_INVALID)
     {
      ::Print(__FUNCTION__," > Before creating a button, the class has to be passed "
              "the form pointer: CIconButton::WindowPointer(CWindow &object)");
      return(false);
     }
//--- Initialization of variables
   m_id         =m_wnd.LastId()+1;
   m_chart_id   =chart_id;
   m_subwin     =subwin;
   m_x          =x;
   m_y          =y;
   m_label_text =button_text;
//--- Indents from the edge point
   CElement::XGap(m_x-m_wnd.X());
   CElement::YGap(m_y-m_wnd.Y());
//--- Create the button
   if(!CreateButton())
      return(false);
   if(!CreateIcon())
      return(false);
   if(!CreateLabel())
      return(false);
//--- Hide the control if it is a dialog window or it is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create button background                                         |
//+------------------------------------------------------------------+
bool CIconButton::CreateButton(void)
  {
//--- Leave, if "Only icon" mode is enabled
   if(m_only_icon)
      return(true);
//--- Formation of the object name
   string name=CElement::ProgramName()+"_icon_button_"+(string)CElement::Id();
//--- Set a button
   if(!m_button.Create(m_chart_id,name,m_subwin,m_x,m_y,m_button_x_size,m_button_y_size))
      return(false);
//--- Set properties
   m_button.Font(FONT);
   m_button.FontSize(FONT_SIZE);
   m_button.Color(m_back_color);
   m_button.Description("");
   m_button.BorderColor(m_border_color);
   m_button.BackColor(m_back_color);
   m_button.Corner(m_corner);
   m_button.Anchor(m_anchor);
   m_button.Selectable(false);
   m_button.Z_Order(m_button_zorder);
   m_button.Tooltip("\n");
//--- Store the size
   CElement::XSize(m_button_x_size);
   CElement::YSize(m_button_y_size);
//--- Indents from the edge point
   m_button.XGap(m_x-m_wnd.X());
   m_button.YGap(m_y-m_wnd.Y());
//--- Initializing the array gradient
   CElement::InitColorArray(m_back_color,m_back_color_hover,m_back_color_array);
//--- Store the object pointer
   CElement::AddToArray(m_button);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create button icon                                               |
//+------------------------------------------------------------------+
bool CIconButton::CreateIcon(void)
  {
//--- If the "Only icon" mode is disabled
   if(!m_only_icon)
     {
      //--- If a label is not needed for the button, leave
      if(m_icon_file_on=="" || m_icon_file_off=="")
         return(true);
     }
//--- If "Only icon" mode is enabled 
   else
     {
      //--- If the label was not defined, print a message and leave
      if(m_icon_file_on=="" || m_icon_file_off=="")
        {
         ::Print(__FUNCTION__," > Icon must be defined in the \"Only icon\" mode.");
         return(false);
        }
     }
//--- Formation of the object name
   string name=CElement::ProgramName()+"_icon_button_bmp_"+(string)CElement::Id();
//--- Coordinates
   int x =(!m_only_icon)? m_x+m_icon_x_gap : m_x;
   int y =(!m_only_icon)? m_y+m_icon_y_gap : m_y;
//--- Set the label
   if(!m_icon.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_icon.BmpFileOn("::"+m_icon_file_on);
   m_icon.BmpFileOff("::"+m_icon_file_off);
   m_icon.State(true);
   m_icon.Corner(m_corner);
   m_icon.GetInteger(OBJPROP_ANCHOR,m_anchor);
   m_icon.Selectable(false);
   m_icon.Z_Order((!m_only_icon)? m_zorder : m_button_zorder);
   m_icon.Tooltip((!m_only_icon)? "\n" : m_label_text);
//--- Store coordinates
   m_icon.X(x);
   m_icon.Y(y);
//--- Store the size
   m_icon.XSize(m_icon.X_Size());
   m_icon.YSize(m_icon.Y_Size());
//--- Indents from the edge point
   m_icon.XGap(x-m_wnd.X());
   m_icon.YGap(y-m_wnd.Y());
//--- Store the object pointer
   CElement::AddToArray(m_icon);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create button text                                               |
//+------------------------------------------------------------------+
bool CIconButton::CreateLabel(void)
  {
//--- Leave, if "Only icon" mode is enabled
   if(m_only_icon)
      return(true);
//--- Formation of the object name
   string name=CElement::ProgramName()+"_icon_button_lable_"+(string)CElement::Id();
//--- Coordinates
   int x =m_x+m_label_x_gap;
   int y =m_y+m_label_y_gap;
//--- Set the text label
   if(!m_label.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_label.Description(m_label_text);
   m_label.Font(FONT);
   m_label.FontSize(FONT_SIZE);
   m_label.Color(m_label_color);
   m_label.Corner(m_corner);
   m_label.Anchor(m_anchor);
   m_label.Selectable(false);
   m_label.Z_Order(m_zorder);
   m_label.Tooltip("\n");
//--- Indents from the edge point
   m_label.XGap(x-m_wnd.X());
   m_label.YGap(y-m_wnd.Y());
//--- Initializing the array gradient
   CElement::InitColorArray(m_label_color,m_label_color_hover,m_label_color_array);
//--- Store the object pointer
   CElement::AddToArray(m_label);
   return(true);
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CIconButton::Moving(const int x,const int y)
  {
//--- Leave, if the element is hidden
   if(!CElement::IsVisible())
      return;
//--- Storing coordinates in the element fields
   CElement::X(x+XGap());
   CElement::Y(y+YGap());
//--- Storing coordinates in the fields of the objects
   m_button.X(x+m_button.XGap());
   m_button.Y(y+m_button.YGap());
   m_icon.X(x+m_icon.XGap());
   m_icon.Y(y+m_icon.YGap());
   m_label.X(x+m_label.XGap());
   m_label.Y(y+m_label.YGap());
//--- Updating coordinates of graphical objects
   m_button.X_Distance(m_button.X());
   m_button.Y_Distance(m_button.Y());
   m_icon.X_Distance(m_icon.X());
   m_icon.Y_Distance(m_icon.Y());
   m_label.X_Distance(m_label.X());
   m_label.Y_Distance(m_label.Y());
  }
//+------------------------------------------------------------------+
//| Show button                                                      |
//+------------------------------------------------------------------+
void CIconButton::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElement::IsVisible())
      return;
//--- Make all the objects visible
   for(int i=0; i<CElement::ObjectsElementTotal(); i++)
      CElement::Object(i).Timeframes(OBJ_ALL_PERIODS);
//--- Visible state
   CElement::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Hide button                                                      |
//+------------------------------------------------------------------+
void CIconButton::Hide(void)
  {
//--- Leave, if the element is hidden
   if(!CElement::IsVisible())
      return;
//--- Hide all objects
   for(int i=0; i<CElement::ObjectsElementTotal(); i++)
      CElement::Object(i).Timeframes(OBJ_NO_PERIODS);
//--- Visible state
   CElement::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CIconButton::Reset(void)
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
void CIconButton::Delete(void)
  {
//--- Deleting objects
   m_button.Delete();
   m_icon.Delete();
   m_label.Delete();
//--- Emptying the object array
   CElement::FreeObjectsArray();
//--- Initializing of variables by default values
   CElement::MouseFocus(false);
   CElement::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Set priorities                                                   |
//+------------------------------------------------------------------+
void CIconButton::SetZorders(void)
  {
   m_label.Z_Order(m_zorder);
   m_button.Z_Order(m_button_zorder);
   m_icon.Z_Order((!m_only_icon)? m_zorder : m_button_zorder);
  }
//+------------------------------------------------------------------+
//| Reset priorities                                                 |
//+------------------------------------------------------------------+
void CIconButton::ResetZorders(void)
  {
   m_button.Z_Order(-1);
   m_icon.Z_Order(-1);
   m_label.Z_Order(-1);
//--- 
   m_icon.MouseFocus(false);
   ChangeObjectsColor();
  }
//+------------------------------------------------------------------+
//| Reset color                                                      |
//+------------------------------------------------------------------+
void CIconButton::ResetColors(void)
  {
//--- Leave, if two-state mode and button is pressed
   if(m_two_state && m_button_state)
      return;
//--- Reset color
   m_button.BackColor(m_back_color);
//--- Zero the focus
   m_button.MouseFocus(false);
   CElement::MouseFocus(false);
  }
//+------------------------------------------------------------------+
//| Changing of the object color when hovering the cursor over it    |
//+------------------------------------------------------------------+
void CIconButton::ChangeObjectsColor(void)
  {
   if(m_only_icon)
      m_icon.State(m_icon.MouseFocus());
//---
   ChangeObjectColor(m_button.Name(),MouseFocus(),OBJPROP_BGCOLOR,m_back_color,m_back_color_hover,m_back_color_array);
   ChangeObjectColor(m_label.Name(),MouseFocus(),OBJPROP_COLOR,m_label_color,m_label_color_hover,m_label_color_array);
  }
//+------------------------------------------------------------------+
//| Change state of the button                                       |
//+------------------------------------------------------------------+
void CIconButton::ButtonState(const bool state)
  {
   m_button_state=state;
//--- Set the colors of the objects according to the current state
   m_icon.State(state);
   m_label.Color((state)? m_label_color : m_label_color_off);
   m_button.State(false);
   m_button.BackColor((state)? m_back_color : m_back_color_off);
   m_button.BorderColor((state)? m_border_color : m_border_color_off);
  }
//+------------------------------------------------------------------+
//| Button click                                                     |
//+------------------------------------------------------------------+
bool CIconButton::OnClickButton(const string clicked_object)
  {
//--- If "Only icon" mode is disabled
   if(!m_only_icon)
     {
      //--- Leave, if different object name
      if(m_button.Name()!=clicked_object)
         return(false);
      //--- Leave, if the button is locked
      if(!m_button_state)
        {
         m_button.State(false);
         return(false);
        }
      //--- If it is self-releasing button
      if(!m_two_state)
        {
         m_button.State(false);
         m_button.BackColor(m_back_color);
         m_label.Color(m_label_color);
        }
      //--- If it is the button with two states
      else
        {
         if(m_button.State())
           {
            m_button.State(true);
            m_label.Color(m_label_color_pressed);
            m_button.BackColor(m_back_color_pressed);
            CElement::InitColorArray(m_back_color_pressed,m_back_color_pressed,m_back_color_array);
           }
         else
           {
            m_button.State(false);
            m_label.Color(m_label_color);
            m_button.BackColor(m_back_color);
            CElement::InitColorArray(m_back_color,m_back_color_hover,m_back_color_array);
           }
        }
     }
//--- If "Only icon" mode is enabled  
   else
     {
      //--- Leave, if different object name
      if(m_icon.Name()!=clicked_object)
         return(false);
      //--- Set the state On
      m_icon.State(true);
     }
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_CLICK_BUTTON,CElement::Id(),CElement::Index(),m_label_text);
   return(true);
  }
//+------------------------------------------------------------------+
