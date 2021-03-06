//+------------------------------------------------------------------+
//|                                                 SimpleButton.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Element.mqh"
#include "Window.mqh"
//+------------------------------------------------------------------+
//| Class for creating simple button                                 |
//+------------------------------------------------------------------+
class CSimpleButton : public CElement
  {
private:
   //--- Pointer to the form to which the element is attached
   CWindow          *m_wnd;
   //--- Object for creating a button
   CButton           m_button;
   //--- button properties:
   //    (1) Text, (2) sizes
   string            m_button_text;
   int               m_button_x_size;
   int               m_button_y_size;
   //--- Background color
   color             m_back_color;
   color             m_back_color_off;
   color             m_back_color_hover;
   color             m_back_color_pressed;
   color             m_back_color_array[];
   //--- Border Color
   color             m_border_color;
   color             m_border_color_off;
   //--- Text color
   color             m_text_color;
   color             m_text_color_off;
   color             m_text_color_pressed;
   //--- Priority for clicking the left mouse button
   int               m_button_zorder;
   //--- Two-state mode of the button
   bool              m_two_state;
   //--- Available/locked
   bool              m_button_state;
   //---
public:
                     CSimpleButton(void);
                    ~CSimpleButton(void);
   //--- Methods for creating a simple button
   bool              CreateSimpleButton(const long chart_id,const int subwin,const string button_text,const int x,const int y);
   //---
private:
   bool              CreateButton(void);
   //---
public:
   //--- (1) Stores the form pointer, (2) sets the button mode,
   //    (3) general state of the button (available/locked)
   void              WindowPointer(CWindow &object)          { m_wnd=::GetPointer(object);     }
   void              TwoState(const bool flag)               { m_two_state=flag;               }
   bool              IsPressed(void)                   const { return(m_button.State());       }
   bool              ButtonState(void)                 const { return(m_button_state);         }
   void              ButtonState(const bool state);
   //--- Button size
   void              ButtonXSize(const int x_size)           { m_button_x_size=x_size;         }
   void              ButtonYSize(const int y_size)           { m_button_y_size=y_size;         }
   //--- (1) returns the button text, (2) sets the button text color
   string            Text(void)                        const { return(m_button.Description()); }
   void              TextColor(const color clr)              { m_text_color=clr;               }
   void              TextColorOff(const color clr)           { m_text_color_off=clr;           }
   void              TextColorPressed(const color clr)       { m_text_color_pressed=clr;       }
   //--- Set the button background color
   void              BackColor(const color clr)              { m_back_color=clr;               }
   void              BackColorOff(const color clr)           { m_back_color_off=clr;           }
   void              BackColorHover(const color clr)         { m_back_color_hover=clr;         }
   void              BackColorPressed(const color clr)       { m_back_color_pressed=clr;       }
   //--- Set the button frame color
   void              BorderColor(const color clr)            { m_border_color=clr;             }
   void              BorderColorOff(const color clr)         { m_border_color_off=clr;         }

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
CSimpleButton::CSimpleButton(void) : m_button_state(true),
                                     m_two_state(false),
                                     m_button_x_size(50),
                                     m_button_y_size(22),
                                     m_text_color(clrBlack),
                                     m_text_color_off(clrDarkGray),
                                     m_text_color_pressed(clrWhite),
                                     m_back_color(clrSilver),
                                     m_back_color_off(clrLightGray),
                                     m_back_color_hover(clrLightGray),
                                     m_back_color_pressed(clrGray),
                                     m_border_color(clrWhite),
                                     m_border_color_off(clrWhite)
  {
//--- Store the name of the control class in the base class
   CElement::ClassName(CLASS_NAME);
//--- Set the priority to the left mouse button clicks
   m_button_zorder=1;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSimpleButton::~CSimpleButton(void)
  {
  }
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
void CSimpleButton::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
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
      //--- Leave, if the form is locked
      if(m_wnd.IsLocked())
         return;
      //--- Leave, if the mouse button is released
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
           {
            m_button.Color(m_text_color);
            m_button.BackColor(m_back_color);
           }
         //---
         return;
        }
      //--- If there is a focus
      else
        {
         m_button.Color(m_text_color_pressed);
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
void CSimpleButton::OnEventTimer(void)
  {
//--- If it is a drop-down element
   if(CElement::IsDropdown())
      ChangeObjectsColor();
   else
     {
      //--- If the form is not locked
      if(!m_wnd.IsLocked())
         ChangeObjectsColor();
     }
  }
//+------------------------------------------------------------------+
//| Create Button object                                             |
//+------------------------------------------------------------------+
bool CSimpleButton::CreateSimpleButton(const long chart_id,const int subwin,const string button_text,const int x,const int y)
  {
//--- Leave, if there is no form pointer
   if(::CheckPointer(m_wnd)==POINTER_INVALID)
     {
      ::Print(__FUNCTION__," > Before creating a button, the class has to be passed "
              "the form pointer: CSimpleButton::WindowPointer(CWindow &object)");
      return(false);
     }
//--- Initialization of variables
   m_id          =m_wnd.LastId()+1;
   m_chart_id    =chart_id;
   m_subwin      =subwin;
   m_x           =x;
   m_y           =y;
   m_button_text =button_text;
//--- Indents from the edge point
   CElement::XGap(m_x-m_wnd.X());
   CElement::YGap(m_y-m_wnd.Y());
//--- Create the button
   if(!CreateButton())
      return(false);
//--- Hide the control if it is a dialog window or it is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create button                                                    |
//+------------------------------------------------------------------+
bool CSimpleButton::CreateButton(void)
  {
//--- Formation of the object name
   string name="";
//--- If index is not specified
   if(m_index==WRONG_VALUE)
      name=CElement::ProgramName()+"_simple_button_"+(string)CElement::Id();
//--- If index is specified
   else
      name=CElement::ProgramName()+"_simple_button_"+(string)CElement::Index()+"__"+(string)CElement::Id();
//--- Set a button
   if(!m_button.Create(m_chart_id,name,m_subwin,m_x,m_y,m_button_x_size,m_button_y_size))
      return(false);
//--- Set properties
   m_button.Font(FONT);
   m_button.FontSize(FONT_SIZE);
   m_button.Color(m_text_color);
   m_button.Description(m_button_text);
   m_button.BackColor(m_back_color);
   m_button.BorderColor(m_border_color);
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
//| Changing of the object color when hovering the cursor over it    |
//+------------------------------------------------------------------+
void CSimpleButton::ChangeObjectsColor(void)
  {
   ChangeObjectColor(m_button.Name(),CElement::MouseFocus(),OBJPROP_BGCOLOR,m_back_color,m_back_color_hover,m_back_color_array);
  }
//+------------------------------------------------------------------+
//| Reset color                                                      |
//+------------------------------------------------------------------+
void CSimpleButton::ResetColors(void)
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
//| Change state of the button                                       |
//+------------------------------------------------------------------+
void CSimpleButton::ButtonState(const bool state)
  {
   m_button_state=state;
   m_button.State(false);
   m_button.Color((state)? m_text_color : m_text_color_off);
   m_button.BackColor((state)? m_back_color : m_back_color_off);
   m_button.BorderColor((state)? m_border_color : m_border_color_off);
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CSimpleButton::Moving(const int x,const int y)
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
//--- Updating coordinates of graphical objects
   m_button.X_Distance(m_button.X());
   m_button.Y_Distance(m_button.Y());
  }
//+------------------------------------------------------------------+
//| Set priorities                                                   |
//+------------------------------------------------------------------+
void CSimpleButton::SetZorders(void)
  {
   m_button.Z_Order(m_button_zorder);
  }
//+------------------------------------------------------------------+
//| Reset priorities                                                 |
//+------------------------------------------------------------------+
void CSimpleButton::ResetZorders(void)
  {
   m_button.Z_Order(-1);
  }
//+------------------------------------------------------------------+
//| Show button                                                      |
//+------------------------------------------------------------------+
void CSimpleButton::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElement::IsVisible())
      return;
//--- Make all the objects visible
   m_button.Timeframes(OBJ_ALL_PERIODS);
//--- Visible state
   CElement::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Hide button                                                      |
//+------------------------------------------------------------------+
void CSimpleButton::Hide(void)
  {
//--- Leave, if the element is hidden
   if(!CElement::IsVisible())
      return;
//--- Hide all objects
   m_button.Timeframes(OBJ_NO_PERIODS);
//--- Visible state
   CElement::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CSimpleButton::Reset(void)
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
void CSimpleButton::Delete(void)
  {
//--- Deleting objects
   m_button.Delete();
//--- Emptying the object array
   CElement::FreeObjectsArray();
//--- Initializing of variables by default values
   CElement::MouseFocus(false);
   CElement::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Button click handling                                            |
//+------------------------------------------------------------------+
bool CSimpleButton::OnClickButton(const string clicked_object)
  {
//--- Check by the object name
   if(m_button.Name()!=clicked_object)
      return(false);
//--- If the button is locked
   if(!m_button_state)
     {
      m_button.State(false);
      return(false);
     }
//--- If button mode with one state
   if(!m_two_state)
     {
      m_button.State(false);
      m_button.Color(m_text_color);
      m_button.BackColor(m_back_color);
     }
//--- If button mode with two states
   else
     {
      //--- If the button is pressed
      if(m_button.State())
        {
         //--- Change the button color 
         m_button.State(true);
         m_button.Color(m_text_color_pressed);
         m_button.BackColor(m_back_color_pressed);
         CElement::InitColorArray(m_back_color_pressed,m_back_color_pressed,m_back_color_array);
        }
      //--- If the button is released
      else
        {
         //--- Change the button color 
         m_button.State(false);
         m_button.Color(m_text_color);
         m_button.BackColor(m_back_color);
         CElement::InitColorArray(m_back_color,m_back_color_hover,m_back_color_array);
        }
     }
//--- Send a signal about it
   ::EventChartCustom(m_chart_id,ON_CLICK_BUTTON,CElement::Id(),CElement::Index(),m_button.Description());
   return(true);
  }
//+------------------------------------------------------------------+
