//+------------------------------------------------------------------+
//|                                             IconButtonsGroup.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Element.mqh"
#include "Window.mqh"
//+------------------------------------------------------------------+
//| Class for creating groups of radio buttons                       |
//+------------------------------------------------------------------+
class CIconButtonsGroup : public CElement
  {
private:
   //--- Pointer to the form to which the element is attached
   CWindow          *m_wnd;
   //--- Objects for creating a button
   CButton           m_buttons[];
   CBmpLabel         m_icons[];
   CLabel            m_labels[];
   //--- Gradients of text labels
   struct IconButtonsGradients
     {
      color             m_back_color_array[];
      color             m_label_color_array[];
     };
   IconButtonsGradients   m_icon_buttons_total[];
   //--- Properties of buttons:
   //    Arrays for the unique properties of the buttons
   bool              m_buttons_state[];
   int               m_buttons_x_gap[];
   int               m_buttons_y_gap[];
   string            m_buttons_text[];
   int               m_buttons_width[];
   string            m_icon_file_on[];
   string            m_icon_file_off[];
   //--- Height of buttons
   int               m_buttons_y_size;
   //--- Background color in different modes
   color             m_back_color;
   color             m_back_color_off;
   color             m_back_color_hover;
   color             m_back_color_pressed;
   //--- Border Color
   color             m_border_color;
   color             m_border_color_off;
   //--- Label margins
   int               m_icon_x_gap;
   int               m_icon_y_gap;
   //--- Margins of the text label
   int               m_label_x_gap;
   int               m_label_y_gap;
   //--- The color of the text label in different modes
   color             m_label_color;
   color             m_label_color_off;
   color             m_label_color_hover;
   color             m_label_color_pressed;
   //--- (1) Text and (2) index of the selected button
   string            m_selected_button_text;
   int               m_selected_button_index;
   //--- General priority for non-clickable objects
   int               m_zorder;
   //--- Priority for clicking the left mouse button
   int               m_buttons_zorder;
   //--- Available/locked
   bool              m_icon_buttons_state;
   //---
public:
                     CIconButtonsGroup(void);
                    ~CIconButtonsGroup(void);
   //--- Methods for creating a button
   bool              CreateIconButtonsGroup(const long chart_id,const int window,const int x,const int y);
   //---
private:
   bool              CreateButton(const int index);
   bool              CreateIcon(const int index);
   bool              CreateLabel(const int index);
   //---
public:
   //--- (1) Stores the form pointer, (2) the button height, (3) the number of buttons,
   //    (4) general state of the button (available/locked)
   void              WindowPointer(CWindow &object)               { m_wnd=::GetPointer(object);      }
   void              ButtonsYSize(const int y_size)               { m_buttons_y_size=y_size;         }
   int               IconButtonsTotal(void)                 const { return(::ArraySize(m_icons));    }
   bool              IconButtonsState(void)                 const { return(m_icon_buttons_state);    }
   void              IconButtonsState(const bool state);
   //--- Button background colors
   void              BackColor(const color clr)                   { m_back_color=clr;                }
   void              BackColorOff(const color clr)                { m_back_color_off=clr;            }
   void              BackColorHover(const color clr)              { m_back_color_hover=clr;          }
   void              BackColorPressed(const color clr)            { m_back_color_pressed=clr;        }
   //--- Set the button frame color
   void              BorderColor(const color clr)                 { m_border_color=clr;              }
   void              BorderColorOff(const color clr)              { m_border_color_off=clr;          }
   //--- Label margins
   void              IconXGap(const int x_gap)                    { m_icon_x_gap=x_gap;              }
   void              IconYGap(const int y_gap)                    { m_icon_y_gap=y_gap;              }
   //--- Margins of the text label
   void              LabelXGap(const int x_gap)                   { m_label_x_gap=x_gap;             }
   void              LabelYGap(const int y_gap)                   { m_label_y_gap=y_gap;             }
   //--- Return (1) text and (2) index of the selected button
   string            SelectedButtonText(void)               const { return(m_selected_button_text);  }
   int               SelectedButtonIndex(void)              const { return(m_selected_button_index); }
   //--- Toggles the radio button by the specified index
   void              SelectedRadioButton(const int index);

   //--- Adds a button with the specified properties before creation
   void              AddButton(const int x_gap,const int y_gap,const string text,
                               const int width,const string icon_file_on,const string icon_file_off);
   //--- Changing the color
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
   //---
private:
   //--- Button click handling
   bool              OnClickButton(const string pressed_object);
   //--- Checking if the left mouse button was pressed over the buttons of the group
   void              CheckPressedOverButton(void);
   //--- Getting the identifier from the radio button name
   int               IdFromObjectName(const string object_name);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CIconButtonsGroup::CIconButtonsGroup(void) : m_icon_buttons_state(true),
                                             m_buttons_y_size(22),
                                             m_selected_button_text(""),
                                             m_selected_button_index(0),
                                             m_icon_x_gap(4),
                                             m_icon_y_gap(3),
                                             m_label_x_gap(25),
                                             m_label_y_gap(4),
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
   m_zorder         =0;
   m_buttons_zorder =1;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CIconButtonsGroup::~CIconButtonsGroup(void)
  {
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CIconButtonsGroup::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Leave, if the element is hidden
      if(!CElement::IsVisible())
         return;
      //--- Leave, if the buttons are locked
      if(!m_icon_buttons_state)
         return;
      //--- Identify the focus
      int x=(int)lparam;
      int y=(int)dparam;
      int icon_buttons_total=IconButtonsTotal();
      for(int i=0; i<icon_buttons_total; i++)
         m_buttons[i].MouseFocus(x>m_buttons[i].X() && x<m_buttons[i].X2() && y>m_buttons[i].Y() && y<m_buttons[i].Y2());
      //--- Leave, if the mouse button is not pressed
      if(sparam!="1")
         return;
      //--- Checking if the left mouse button was pressed over the buttons of the group
      CheckPressedOverButton();
      return;
     }
//--- Handling left mouse clicking event on an object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- Toggle the button
      if(OnClickButton(sparam))
         return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CIconButtonsGroup::OnEventTimer(void)
  {
//--- Change color, if the form is not locked
   if(!m_wnd.IsLocked())
      ChangeObjectsColor();
  }
//+------------------------------------------------------------------+
//| Create "buttons with icons" object group                         |
//+------------------------------------------------------------------+
bool CIconButtonsGroup::CreateIconButtonsGroup(const long chart_id,const int window,const int x,const int y)
  {
//--- Leave, if there is no form pointer
   if(::CheckPointer(m_wnd)==POINTER_INVALID)
     {
      ::Print(__FUNCTION__," > Before creating a group of buttons, the class has to be passed  "
              "the form pointer: CButtonsGroup::WindowPointer(CWindow &object)");
      return(false);
     }
//--- Initialization of variables
   m_id       =m_wnd.LastId()+1;
   m_chart_id =chart_id;
   m_subwin   =window;
   m_x        =x;
   m_y        =y;
//--- Set a button
   int icon_buttons_total=IconButtonsTotal();
   for(int i=0; i<icon_buttons_total; i++)
     {
      CreateButton(i);
      CreateIcon(i);
      CreateLabel(i);
      //---
      m_buttons[i].MouseFocus(false);
     }
//--- Hide the control if it is a dialog window or it is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create button area                                               |
//+------------------------------------------------------------------+
bool CIconButtonsGroup::CreateButton(const int index)
  {
//--- Formation of the object name
   string name=CElement::ProgramName()+"_icon_button_"+(string)index+"__"+(string)CElement::Id();
//--- Calculation of coordinates
   int x=m_x+m_buttons_x_gap[index];
   int y=m_y+m_buttons_y_gap[index];
//--- Set a button
   if(!m_buttons[index].Create(m_chart_id,name,m_subwin,x,y,m_buttons_width[index],m_buttons_y_size))
      return(false);
//--- Set properties
   m_buttons[index].Font(FONT);
   m_buttons[index].FontSize(FONT_SIZE);
   m_buttons[index].Color(m_back_color);
   m_buttons[index].Description("");
   m_buttons[index].BackColor(m_back_color);
   m_buttons[index].BorderColor(m_border_color);
   m_buttons[index].Corner(m_corner);
   m_buttons[index].Anchor(m_anchor);
   m_buttons[index].Selectable(false);
   m_buttons[index].Z_Order(m_buttons_zorder);
   m_buttons[index].Tooltip("\n");
//--- Store the size
   m_buttons[index].XSize(m_buttons_width[index]);
   m_buttons[index].YSize(m_buttons_width[index]);
//--- Indents from the edge point
   m_buttons[index].XGap(x-m_wnd.X());
   m_buttons[index].YGap(y-m_wnd.Y());
//--- Initializing the array gradient
   CElement::InitColorArray(m_back_color,m_back_color_hover,m_icon_buttons_total[index].m_back_color_array);
//--- Store the object pointer
   CElement::AddToArray(m_buttons[index]);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create icon                                                      |
//+------------------------------------------------------------------+
bool CIconButtonsGroup::CreateIcon(const int index)
  {
//--- If a label is not needed for the button, leave
   if(m_icon_file_on[index]=="" || m_icon_file_off[index]=="")
      return(true);
//--- Formation of the object name
   string name=CElement::ProgramName()+"_icon_button_bmp_"+(string)index+"__"+(string)CElement::Id();
//--- Calculation of coordinates
   int x=m_x+m_buttons_x_gap[index]+m_icon_x_gap;
   int y=m_y+m_buttons_y_gap[index]+m_icon_y_gap;
//--- Set the icon
   if(!m_icons[index].Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_icons[index].BmpFileOn("::"+m_icon_file_on[index]);
   m_icons[index].BmpFileOff("::"+m_icon_file_off[index]);
   m_icons[index].State(true);
   m_icons[index].Corner(m_corner);
   m_icons[index].GetInteger(OBJPROP_ANCHOR,m_anchor);
   m_icons[index].Selectable(false);
   m_icons[index].Z_Order(m_zorder);
   m_icons[index].Tooltip("\n");
//--- Indents from the edge point
   m_icons[index].XGap(x-m_wnd.X());
   m_icons[index].YGap(y-m_wnd.Y());
//--- Store the object pointer
   CElement::AddToArray(m_icons[index]);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create text label                                                |
//+------------------------------------------------------------------+
bool CIconButtonsGroup::CreateLabel(const int index)
  {
//--- Formation of the object name
   string name=CElement::ProgramName()+"_icon_button_lable_"+(string)index+"__"+(string)CElement::Id();
//--- Coordinates
   int x=m_x+m_buttons_x_gap[index]+m_label_x_gap;
   int y=m_y+m_buttons_y_gap[index]+m_label_y_gap;
//--- Set the text label
   if(!m_labels[index].Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_labels[index].Description(m_buttons_text[index]);
   m_labels[index].Font(FONT);
   m_labels[index].FontSize(FONT_SIZE);
   m_labels[index].Color(m_label_color);
   m_labels[index].Corner(m_corner);
   m_labels[index].Anchor(m_anchor);
   m_labels[index].Selectable(false);
   m_labels[index].Z_Order(m_zorder);
   m_labels[index].Tooltip("\n");
//--- Indents from the edge point
   m_labels[index].XGap(x-m_wnd.X());
   m_labels[index].YGap(y-m_wnd.Y());
//--- Initializing the array gradient
   CElement::InitColorArray(m_label_color,m_label_color_hover,m_icon_buttons_total[index].m_label_color_array);
//--- Store the object pointer
   CElement::AddToArray(m_labels[index]);
   return(true);
  }
//+------------------------------------------------------------------+
//| Add a button                                                     |
//+------------------------------------------------------------------+
void CIconButtonsGroup::AddButton(const int x_gap,const int y_gap,const string text,
                                  const int width,const string icon_file_on,const string icon_file_off)
  {
//--- Increase the size of the arrays by one element
   int array_size=::ArraySize(m_buttons_text);
   ::ArrayResize(m_buttons,array_size+1);
   ::ArrayResize(m_icons,array_size+1);
   ::ArrayResize(m_labels,array_size+1);
   ::ArrayResize(m_buttons_x_gap,array_size+1);
   ::ArrayResize(m_buttons_y_gap,array_size+1);
   ::ArrayResize(m_buttons_state,array_size+1);
   ::ArrayResize(m_buttons_text,array_size+1);
   ::ArrayResize(m_buttons_width,array_size+1);
   ::ArrayResize(m_icon_file_on,array_size+1);
   ::ArrayResize(m_icon_file_off,array_size+1);
   ::ArrayResize(m_icon_buttons_total,array_size+1);
//--- Store the values of passed parameters
   m_buttons_x_gap[array_size] =x_gap;
   m_buttons_y_gap[array_size] =y_gap;
   m_buttons_text[array_size]  =text;
   m_buttons_width[array_size] =width;
   m_icon_file_on[array_size]  =icon_file_on;
   m_icon_file_off[array_size] =icon_file_off;
   m_buttons_state[array_size] =false;
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CIconButtonsGroup::Moving(const int x,const int y)
  {
//--- Leave, if the element is hidden
   if(!CElement::IsVisible())
      return;
//--- Storing coordinates in the element fields
   CElement::X(x+XGap());
   CElement::Y(y+YGap());
//--- Storing coordinates in the fields of the objects
   int icon_buttons_total=IconButtonsTotal();
   for(int i=0; i<icon_buttons_total; i++)
     {
      m_buttons[i].X(x+m_buttons[i].XGap());
      m_buttons[i].Y(y+m_buttons[i].YGap());
      m_icons[i].X(x+m_icons[i].XGap());
      m_icons[i].Y(y+m_icons[i].YGap());
      m_labels[i].X(x+m_labels[i].XGap());
      m_labels[i].Y(y+m_labels[i].YGap());
     }
//--- Updating coordinates of graphical objects
   for(int i=0; i<icon_buttons_total; i++)
     {
      m_buttons[i].X_Distance(m_buttons[i].X());
      m_buttons[i].Y_Distance(m_buttons[i].Y());
      m_icons[i].X_Distance(m_icons[i].X());
      m_icons[i].Y_Distance(m_icons[i].Y());
      m_labels[i].X_Distance(m_labels[i].X());
      m_labels[i].Y_Distance(m_labels[i].Y());
     }
  }
//+------------------------------------------------------------------+
//| Changing of the object color when hovering the cursor over it    |
//+------------------------------------------------------------------+
void CIconButtonsGroup::ChangeObjectsColor(void)
  {
   int icon_buttons_total=IconButtonsTotal();
   for(int i=0; i<icon_buttons_total; i++)
     {
      color label_color=(m_buttons_state[i]) ? m_label_color : m_label_color_off;
      ChangeObjectColor(m_labels[i].Name(),m_buttons[i].MouseFocus(),
                        OBJPROP_COLOR,label_color,m_label_color_pressed,m_icon_buttons_total[i].m_label_color_array);
      ChangeObjectColor(m_buttons[i].Name(),m_buttons[i].MouseFocus(),
                        OBJPROP_BGCOLOR,m_back_color,m_back_color_hover,m_icon_buttons_total[i].m_back_color_array);
     }
  }
//+------------------------------------------------------------------+
//| Set priorities                                                   |
//+------------------------------------------------------------------+
void CIconButtonsGroup::SetZorders(void)
  {
   int icon_buttons_total=IconButtonsTotal();
   for(int i=0; i<icon_buttons_total; i++)
     {
      m_buttons[i].Z_Order(m_buttons_zorder);
      m_icons[i].Z_Order(m_zorder);
      m_labels[i].Z_Order(m_zorder);
     }
  }
//+------------------------------------------------------------------+
//| Reset priorities                                                 |
//+------------------------------------------------------------------+
void CIconButtonsGroup::ResetZorders(void)
  {
   int icon_buttons_total=IconButtonsTotal();
   for(int i=0; i<icon_buttons_total; i++)
     {
      m_buttons[i].Z_Order(-1);
      m_icons[i].Z_Order(-1);
      m_labels[i].Z_Order(-1);
     }
  }
//+------------------------------------------------------------------+
//| Show button                                                      |
//+------------------------------------------------------------------+
void CIconButtonsGroup::Show(void)
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
void CIconButtonsGroup::Hide(void)
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
void CIconButtonsGroup::Reset(void)
  {
//--- Leave, if this is a drop-down control 
   if(CElement::IsDropdown())
      return;
//--- Hide and show
   Hide();
   Show();
  }
//+------------------------------------------------------------------+
//| Deleting                                                         |
//+------------------------------------------------------------------+
void CIconButtonsGroup::Delete(void)
  {
//--- Deleting objects
   int icon_buttons_total=IconButtonsTotal();
   for(int i=0; i<icon_buttons_total; i++)
     {
      m_buttons[i].Delete();
      m_icons[i].Delete();
      m_labels[i].Delete();
     }
//--- Emptying the element arrays
   ::ArrayFree(m_buttons_x_gap);
   ::ArrayFree(m_buttons_y_gap);
   ::ArrayFree(m_buttons_width);
   ::ArrayFree(m_buttons_state);
   ::ArrayFree(m_buttons_text);
//--- Emptying the object array
   CElement::FreeObjectsArray();
//--- Initializing of variables by default values
   CElement::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Change state of the buttons                                      |
//+------------------------------------------------------------------+
void CIconButtonsGroup::IconButtonsState(const bool state)
  {
   m_icon_buttons_state=state;
//---
   int icon_buttons_total=IconButtonsTotal();
   for(int i=0; i<icon_buttons_total; i++)
     {
      m_icons[i].State(state && i==m_selected_button_index);
      m_labels[i].Color((state && i==m_selected_button_index)? m_label_color_pressed : m_label_color_off);
      m_buttons[i].BackColor((state && i==m_selected_button_index)? m_back_color_pressed : m_back_color_off);
     }
  }
//+------------------------------------------------------------------+
//| Indicate the radio button to be selected                         |
//+------------------------------------------------------------------+
void CIconButtonsGroup::SelectedRadioButton(const int index)
  {
//--- Get the number of buttons
   int icon_buttons_total=IconButtonsTotal();
//--- Notify if there are no radio buttons in the group
   if(icon_buttons_total<1)
     {
      ::Print(__FUNCTION__," > This method is to be called, "
              "when the group has at least one button! Use the method CIconButtonsGroup::AddButton()");
     }
//--- Adjust the index value if it is out of range
   int correct_index=(index>=icon_buttons_total)? icon_buttons_total-1 : (index<0)? 0 : index;
//--- Toggle the button
   for(int i=0; i<icon_buttons_total; i++)
     {
      if(i==correct_index)
        {
         m_buttons_state[i]=true;
         m_icons[i].State(true);
         m_labels[i].Color(m_label_color_hover);
         m_buttons[i].BackColor(m_back_color_pressed);
         CElement::InitColorArray(m_label_color,m_label_color_hover,m_icon_buttons_total[i].m_label_color_array);
        }
      else
        {
         m_buttons_state[i]=false;
         m_icons[i].State(false);
         m_labels[i].Color(m_label_color_off);
         m_buttons[i].BackColor(m_back_color_off);
         CElement::InitColorArray(m_label_color_off,m_label_color_hover,m_icon_buttons_total[i].m_label_color_array);
        }
      //---
      m_buttons[i].State(false);
     }
//--- Save its text and index
   m_selected_button_index =correct_index;
   m_selected_button_text  =m_buttons_text[correct_index];
  }
//+------------------------------------------------------------------+
//| Radio button click                                               |
//+------------------------------------------------------------------+
bool CIconButtonsGroup::OnClickButton(const string pressed_object)
  {
//--- Leave, if the clicking was not on the menu item
   if(::StringFind(pressed_object,CElement::ProgramName()+"_icon_button_",0)<0)
      return(false);
//--- Get the identifier and the index from the object name
   int id=IdFromObjectName(pressed_object);
//--- Leave, if the identifiers do not match
   if(id!=CElement::Id())
      return(false);
//--- Check index
   int check_index=WRONG_VALUE;
//--- Get the number of buttons
   int icon_buttons_total=IconButtonsTotal();
//--- Leave, if the buttons are locked
   if(!m_icon_buttons_state)
     {
      for(int i=0; i<icon_buttons_total; i++)
         m_buttons[i].State(false);
      //---
      return(false);
     }
//--- If it was pressed, store the index
   for(int i=0; i<icon_buttons_total; i++)
     {
      if(m_buttons[i].Name()==pressed_object)
        {
         check_index=i;
         break;
        }
     }
//--- Leave, if no button of the group was pressed or
//    if this already is the selected button
   if(check_index==WRONG_VALUE || check_index==m_selected_button_index)
     {
      m_buttons[check_index].State(false);
      return(false);
     }
//--- Toggle the button
   SelectedRadioButton(check_index);
//--- Send a signal about it
   ::EventChartCustom(m_chart_id,ON_CLICK_BUTTON,CElement::Id(),m_selected_button_index,m_selected_button_text);
   return(true);
  }
//+------------------------------------------------------------------+
//| Check if left mouse button was pressed over buttons of group     |
//+------------------------------------------------------------------+
void CIconButtonsGroup::CheckPressedOverButton(void)
  {
   int buttons_total=IconButtonsTotal();
//--- Set the color depending on the location of the pressed left mouse button
   for(int i=0; i<buttons_total; i++)
     {
      //--- If there is focus, then the color of the pressed button
      if(m_buttons[i].MouseFocus())
         m_buttons[i].BackColor(m_back_color_pressed);
      //--- If there is no focus...
      else
        {
         //--- ...if a button of the group is not pressed, assign a background color
         if(!m_buttons_state[i])
            m_buttons[i].BackColor(m_back_color);
        }
     }
  }
//+------------------------------------------------------------------+
//| Extract the identifier from the object name                      |
//+------------------------------------------------------------------+
int CIconButtonsGroup::IdFromObjectName(const string object_name)
  {
//--- Get the id from the object name
   int    length =::StringLen(object_name);
   int    pos    =::StringFind(object_name,"__",0);
   string id     =::StringSubstr(object_name,pos+2,length-1);
//--- Return the item id
   return((int)id);
  }
//+------------------------------------------------------------------+
