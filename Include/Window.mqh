//+------------------------------------------------------------------+
//|                                                       Window.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Element.mqh"
#include <Charts\Chart.mqh>
//--- Button indents from the right edge of the window
#define CLOSE_BUTTON_OFFSET   (20)
#define ROLL_BUTTON_OFFSET    (36)
#define TOOLTIP_BUTTON_OFFSET (53)
//+------------------------------------------------------------------+
//| Class for creating a form for controls                           |
//+------------------------------------------------------------------+
class CWindow : public CElement
  {
private:
   CChart            m_chart;
   //--- Objects for creating a form
   CRectLabel        m_bg;
   CRectLabel        m_caption_bg;
   CBmpLabel         m_icon;
   CLabel            m_label;
   CBmpLabel         m_button_tooltip;
   CBmpLabel         m_button_unroll;
   CBmpLabel         m_button_rollup;
   CBmpLabel         m_button_close;
   //--- Identifier of the last control
   int               m_last_id;
   //--- Identifier of the activated control
   int               m_id_activated_element;
   //--- Index of the previous active window
   int               m_prev_active_window_index;
   //--- Possibility to move a window on the chart
   bool              m_movable;
   //--- Status of the minimized window
   bool              m_is_minimized;
   //--- Status of a blocked window
   bool              m_is_locked;
   //--- Window type
   ENUM_WINDOW_TYPE  m_window_type;
   //--- Mode of a set height of the sub-window (for indicators)
   bool              m_height_subwindow_mode;
   //--- Mode of minimizing the form in the indicator sub-window
   bool              m_rollup_subwindow_mode;
   //--- Height of the indicator sub-window
   int               m_subwindow_height;
   //--- Properties of the background
   int               m_bg_zorder;
   color             m_bg_color;
   int               m_bg_full_height;
   //--- Properties of the header
   int               m_caption_zorder;
   string            m_caption_text;
   int               m_caption_height;
   color             m_caption_bg_color;
   color             m_caption_bg_color_hover;
   color             m_caption_bg_color_off;
   color             m_caption_color_bg_array[];
   //--- Properties of buttons
   int               m_button_zorder;
   //--- Color of the form frame (background, header)
   color             m_border_color;
   //--- Form icon
   string            m_icon_file;
   //--- Presence of the button for the mode of displaying tooltips
   bool              m_tooltips_button;

   //--- Chart size
   int               m_chart_width;
   int               m_chart_height;

   //--- For identifying the capture area boundaries in the window header
   int               m_right_limit;
   //--- Variables connected with the displacement
   int               m_prev_x;
   int               m_prev_y;
   int               m_size_fixing_x;
   int               m_size_fixing_y;

   //--- State of the mouse button considering the position where it was clicked
   ENUM_WMOUSE_STATE m_clamping_area_mouse;
   //--- To control the chart state
   bool              m_custom_event_chart_state;
   //---
public:
                     CWindow(void);
                    ~CWindow(void);
   //--- Methods for creating a window
   bool              CreateWindow(const long chart_id,const int window,const string caption_text,const int x,const int y);
   //---
private:
   bool              CreateBackground(void);
   bool              CreateCaption(void);
   bool              CreateIcon(void);
   bool              CreateLabel(void);
   bool              CreateButtonClose(void);
   bool              CreateButtonRollUp(void);
   bool              CreateButtonUnroll(void);
   bool              CreateButtonTooltip(void);
   //--- Changing the color of the form objects
   void              ChangeObjectsColor(void);
   //---
public:
   //--- Methods for storing and obtaining the id of the last created control
   int               LastId(void)                                      const { return(m_last_id);                  }
   void              LastId(const int id)                                    { m_last_id=id;                       }
   //--- Methods for storing and obtaining the id of the activated control
   int               IdActivatedElement(void)                          const { return(m_id_activated_element);     }
   void              IdActivatedElement(const int id)                        { m_id_activated_element=id;          }
   //--- (1) Getting and storing the pointer to the previous active window
   int               PrevActiveWindowIndex(void)                       const { return(m_prev_active_window_index); }
   void              PrevActiveWindowIndex(const int index)                  { m_prev_active_window_index=index;   }
   //--- Window type
   ENUM_WINDOW_TYPE  WindowType(void)                                  const { return(m_window_type);              }
   void              WindowType(const ENUM_WINDOW_TYPE flag)                 { m_window_type=flag;                 }
   //--- Default icon
   string            DefaultIcon(void);
   //--- (1) custom icon of the window, (2) limitation of the capture area of the header
   void              IconFile(const string file_path)                        { m_icon_file=file_path;              }
   void              RightLimit(const int value)                             { m_right_limit=value;                }
   //--- (1) Use the tooltips button, (2) check the tooltip display mode
   void              UseTooltipsButton(void)                                 { m_tooltips_button=true;             }
   bool              TooltipBmpState(void)                             const { return(m_button_tooltip.State());   }
   
   //--- Possibility of moving the window
   bool              Movable(void)                                     const { return(m_movable);                  }
   void              Movable(const bool flag)                                { m_movable=flag;                     }
   //--- Status of the minimized window
   bool              IsMinimized(void)                                 const { return(m_is_minimized);             }
   void              IsMinimized(const bool flag)                            { m_is_minimized=flag;                }
   //--- Status of a blocked window
   bool              IsLocked(void)                                    const { return(m_is_locked);                }
   void              IsLocked(const bool flag)                               { m_is_locked=flag;                   }
   //--- Properties of the header
   void              CaptionText(const string text);
   string            CaptionText(void)                                 const { return(m_caption_text);             }
   void              CaptionHeight(const int height)                         { m_caption_height=height;            }
   int               CaptionHeight(void)                               const { return(m_caption_height);           }
   void              CaptionBgColor(const color clr)                         { m_caption_bg_color=clr;             }
   color             CaptionBgColor(void)                              const { return(m_caption_bg_color);         }
   void              CaptionBgColorHover(const color clr)                    { m_caption_bg_color_hover=clr;       }
   color             CaptionBgColorHover(void)                         const { return(m_caption_bg_color_hover);   }
   void              CaptionBgColorOff(const color clr)                      { m_caption_bg_color_off=clr;         }
   //--- Window properties
   void              WindowBgColor(const color clr)                          { m_bg_color=clr;                     }
   color             WindowBgColor(void)                                     { return(m_bg_color);                 }
   void              WindowBorderColor(const color clr)                      { m_border_color=clr;                 }
   color             WindowBorderColor(void)                                 { return(m_border_color);             }
   
   //--- Set the window state
   void              State(const bool flag);
   //--- The indicator sub-window minimization mode
   void              RollUpSubwindowMode(const bool flag,const bool height_mode);
   //--- Managing sizes
   void              ChangeWindowWidth(const int width);
   void              ChangeSubwindowHeight(const int height);

   //--- Getting chart size
   void              SetWindowProperties(void);
   //--- Converts the Y coordinate into a relative one
   int               YToRelative(const int y);
   //--- Checking the cursor in the header area 
   bool              CursorInsideCaption(const int x,const int y);
   //--- Zeroing variables
   void              ZeroPanelVariables(void);

   //--- Verifying the state of the left mouse button
   void              CheckMouseButtonState(const int x,const int y,const string state);
   //--- Verifying the mouse focus
   void              CheckMouseFocus(const int x,const int y,const int subwin);
   //--- Setting the chart mode
   void              SetChartState(const int subwindow_number);
   //--- Updating the form coordinates
   void              UpdateWindowXY(const int x,const int y);
   
   void              CustomEventChartState(const bool state)                 { m_custom_event_chart_state=state;    }

   //--- Closing the main window
   bool              CloseWindow(const string pressed_object);
   //--- Closing the dialog box
   void              CloseDialogBox(void);
   
   //--- Changing the window state
   bool              ChangeWindowState(const string pressed_object);
   //--- Methods for (1) minimizing and (2) maximizing the window
   void              RollUp(void);
   void              Unroll(void);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Timer
   virtual void      OnEventTimer(void);
   //--- Moving the control
   virtual void      Moving(const int x,const int y);
   //--- Showing, hiding, resetting, deleting
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   //--- Setting, resetting of priorities for left clicking on mouse
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   //--- Reset color
   virtual void      ResetColors(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CWindow::CWindow(void) : m_last_id(0),
                         m_id_activated_element(WRONG_VALUE),
                         m_prev_active_window_index(0),
                         m_subwindow_height(0),
                         m_rollup_subwindow_mode(false),
                         m_height_subwindow_mode(false),
                         m_movable(false),
                         m_is_locked(false),
                         m_is_minimized(false),
                         m_tooltips_button(false),
                         m_window_type(W_MAIN),
                         m_icon_file(""),
                         m_right_limit(0),
                         m_clamping_area_mouse(NOT_PRESSED),
                         m_caption_height(20),
                         m_caption_bg_color(C'88,157,255'),
                         m_caption_bg_color_off(clrSilver),
                         m_caption_bg_color_hover(C'118,177,255'),
                         m_bg_color(C'15,15,15'),
                         m_border_color(clrLightGray)

  {
//--- Store the name of the control class in the base class
   CElement::ClassName(CLASS_NAME);
//--- Changing the color of the element objects
   m_bg_zorder      =0;
   m_caption_zorder =1;
   m_button_zorder  =2;
//--- Get the ID of the current chart
   m_chart.Attach();
//--- Get the chart window size
   SetWindowProperties();
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CWindow::~CWindow(void)
  {
   m_chart.Detach();
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CWindow::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handling the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      int      x      =(int)lparam; // Coordinate of the X axis
      int      y      =(int)dparam; // Coordinate of the Y axis
      int      subwin =WRONG_VALUE; // Window number, in which the cursor is located
      datetime time   =NULL;        // Time corresponding to the X coordinate
      double   level  =0.0;         // Level (price) corresponding to the Y coordinate
      int      rel_y  =0;           // For identification of the relative Y coordinate
      //--- Get the cursor location
      if(!::ChartXYToTimePrice(m_chart_id,x,y,subwin,time,level))
         return;
      //--- Get the relative Y coordinate
      rel_y=YToRelative(y);
      //--- Verify and store the state of the mouse button
      CheckMouseButtonState(x,rel_y,sparam);
      //--- Verifying the mouse focus
      CheckMouseFocus(x,rel_y,subwin);
      //--- Set the chart state
      SetChartState(subwin);
      //--- Leave, if this form is locked
      if(m_is_locked)
         return;
      //--- If the management is delegated to the window, identify its location
      if(m_clamping_area_mouse==PRESSED_INSIDE_HEADER)
        {
         //--- Updating window coordinates
         UpdateWindowXY(x,rel_y);
        }
      //---
      return;
     }
//--- Handling event of clicking on an object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- Close the window
      CloseWindow(sparam);
      //--- Minimize/Maximize the window
      ChangeWindowState(sparam);
      return;
     }
//--- Event of changing the chart properties
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      //--- If the button is released
      if(m_clamping_area_mouse==NOT_PRESSED)
        {
         //--- Get the chart window size
         SetWindowProperties();
         //--- Adjustment of coordinates
         UpdateWindowXY(m_x,m_y);
        }
      return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CWindow::OnEventTimer(void)
  {
//--- If the window is not blocked
   if(!m_is_locked)
     {
      //--- Changing the color of the form objects
      ChangeObjectsColor();
     }
  }
//+------------------------------------------------------------------+
//| Creates a form for controls                                      |
//+------------------------------------------------------------------+
bool CWindow::CreateWindow(const long chart_id,const int subwin,const string caption_text,const int x,const int y)
  {
   if(CElement::Id()==WRONG_VALUE)
     {
      ::Print(__FUNCTION__," > Before creating a window, its pointer has to be stored in the base: CWndContainer::AddWindow(CWindow &object)");
      return(false);
     }
//--- Initialization of variables
   m_chart_id       =chart_id;
   m_subwin         =subwin;
   m_caption_text   =caption_text;
   m_x              =x;
   m_y              =y;
   m_bg_full_height =m_y_size;
//--- Creating all object of the window
   if(!CreateBackground())
      return(false);
   if(!CreateCaption())
      return(false);
   if(!CreateLabel())
      return(false);
   if(!CreateIcon())
      return(false);
   if(!CreateButtonClose())
      return(false);
   if(!CreateButtonRollUp())
      return(false);
   if(!CreateButtonUnroll())
      return(false);
   if(!CreateButtonTooltip())
      return(false);
//--- If this program is an indicator
   if(CElement::ProgramType()==PROGRAM_INDICATOR)
     {
      //--- If the mode of a set height of the sub-window is set
      if(m_height_subwindow_mode)
        {
         m_subwindow_height=m_bg_full_height+3;
         ChangeSubwindowHeight(m_subwindow_height);
        }
     }
//--- Hide the window, if it is a dialog window
   if(m_window_type==W_DIALOG)
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the window background                                    |
//+------------------------------------------------------------------+
bool CWindow::CreateBackground(void)
  {
//--- Formation of the object name
   string name=CElement::ProgramName()+"_window_bg_"+(string)CElement::Id();
//--- Size of the window depends on its state (minimized/maximized)
   int y_size=0;
   if(m_is_minimized)
     {
      y_size=m_caption_height;
      CElement::YSize(m_caption_height);
     }
   else
     {
      y_size=m_bg_full_height;
      CElement::YSize(m_bg_full_height);
     }
//--- Set the window background
   if(!m_bg.Create(m_chart_id,name,m_subwin,m_x,m_y,m_x_size,y_size))
      return(false);
//--- Set properties
   m_bg.BackColor(m_bg_color);
   m_bg.Color(m_border_color);
   m_bg.BorderType(BORDER_FLAT);
   m_bg.Corner(m_corner);
   m_bg.Selectable(false);
   m_bg.Z_Order(m_bg_zorder);
   m_bg.Tooltip("\n");
//--- Store the object pointer
   CElement::AddToArray(m_bg);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the window header                                        |
//+------------------------------------------------------------------+
bool CWindow::CreateCaption(void)
  {
//--- Formation of the object name  
   string name=CElement::ProgramName()+"_window_caption_"+(string)CElement::Id();
//--- Set the window header
   if(!m_caption_bg.Create(m_chart_id,name,m_subwin,m_x,m_y,m_x_size,m_caption_height))
      return(false);
//--- Set properties
   m_caption_bg.BackColor(m_caption_bg_color);
   m_caption_bg.Color(m_border_color);
   m_caption_bg.BorderType(BORDER_FLAT);
   m_caption_bg.Corner(m_corner);
   m_caption_bg.Selectable(false);
   m_caption_bg.Z_Order(m_caption_zorder);
   m_caption_bg.Tooltip("\n");
//--- Store coordinates
   m_caption_bg.X(m_x);
   m_caption_bg.Y(m_y);
//--- Store sizes (in object)
   m_caption_bg.XSize(m_caption_bg.X_Size());
   m_caption_bg.YSize(m_caption_bg.Y_Size());
//--- Initializing the array gradient
   CElement::InitColorArray(m_caption_bg_color,m_caption_bg_color_hover,m_caption_color_bg_array);
//--- Store the object pointer
   CElement::AddToArray(m_caption_bg);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the program icon                                         |
//+------------------------------------------------------------------+
//--- Icons (by default) symbolizing the program type
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\advisor.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\indicator.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\script.bmp"
//---
bool CWindow::CreateIcon(void)
  {
   string name=CElement::ProgramName()+"_window_icon_"+(string)CElement::Id();
//--- Object coordinates
   int x=m_x+5;
   int y=m_y+2;
//--- Set the window icon
   if(!m_icon.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Default icon, if not specified by the user
   if(m_icon_file=="")
      m_icon_file=DefaultIcon();
//--- Set properties
   m_icon.BmpFileOn("::"+m_icon_file);
   m_icon.BmpFileOff("::"+m_icon_file);
   m_icon.Corner(m_corner);
   m_icon.Selectable(false);
   m_icon.Z_Order(m_button_zorder);
   m_icon.Tooltip("\n");
//--- Store coordinates
   m_icon.X(x);
   m_icon.Y(y);
//--- Indents from the edge point
   m_icon.XGap(x-m_x);
   m_icon.YGap(y-m_y);
//--- Store the size
   m_icon.XSize(m_icon.X_Size());
   m_icon.YSize(m_icon.Y_Size());
//--- Store the object pointer
   CElement::AddToArray(m_icon);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the text label of the header                             |
//+------------------------------------------------------------------+
bool CWindow::CreateLabel(void)
  {
   string name=CElement::ProgramName()+"_window_label_"+(string)CElement::Id();
//--- Object coordinates
   int x=m_x+24;
   int y=m_y+4;
//--- Set the text label
   if(!m_label.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_label.Description(m_caption_text);
   m_label.Font(FONT);
   m_label.FontSize(FONT_SIZE);
   m_label.Color(clrBlack);
   m_label.Corner(m_corner);
   m_label.Selectable(false);
   m_label.Z_Order(m_button_zorder);
   m_label.Tooltip("\n");
//--- Store coordinates
   m_label.X(x);
   m_label.Y(y);
//--- Indents from the edge point
   m_label.XGap(x-m_x);
   m_label.YGap(y-m_y);
//--- Store the size
   m_label.XSize(m_label.X_Size());
   m_label.YSize(m_label.Y_Size());
//--- Store the object pointer
   CElement::AddToArray(m_label);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the button for closing the program                       |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Controls\\Close_red.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\Close_black.bmp"
//---
bool CWindow::CreateButtonClose(void)
  {
//--- If the program type is "script", leave
   if(CElement::ProgramType()==PROGRAM_SCRIPT)
      return(true);
//--- Formation of the object name
   string name=CElement::ProgramName()+"_window_close_"+(string)CElement::Id();
//--- Object coordinates
   int x=m_x+m_x_size-CLOSE_BUTTON_OFFSET;
   int y=m_y+2;
//--- Increase the capture area
   m_right_limit+=20;
//--- Set a button
   if(!m_button_close.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_button_close.BmpFileOn("::Images\\EasyAndFastGUI\\Controls\\Close_red.bmp");
   m_button_close.BmpFileOff("::Images\\EasyAndFastGUI\\Controls\\Close_black.bmp");
   m_button_close.Corner(m_corner);
   m_button_close.Selectable(false);
   m_button_close.Z_Order(m_button_zorder);
   m_button_close.Tooltip("Close");
//--- Store coordinates
   m_button_close.X(x);
   m_button_close.Y(y);
//--- Indents from the edge point
   m_button_close.XGap(x-m_x);
   m_button_close.YGap(y-m_y);
//--- Store the size
   m_button_close.XSize(m_button_close.X_Size());
   m_button_close.YSize(m_button_close.Y_Size());
//--- Store the object pointer
   CElement::AddToArray(m_button_close);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the button for minimizing the window                     |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Controls\\DropOn_black.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\DropOn_white.bmp"
//---
bool CWindow::CreateButtonRollUp(void)
  {
//--- If the program type is "script", leave
   if(CElement::ProgramType()==PROGRAM_SCRIPT)
      return(true);
//--- This button is not required, if the window is a dialog window
   if(m_window_type==W_DIALOG)
      return(true);
//--- Formation of the object name
   string name=CElement::ProgramName()+"_window_rollup_"+(string)CElement::Id();
//--- Object coordinates
   int x=m_x+m_x_size-ROLL_BUTTON_OFFSET;
   int y=m_y+3;
//--- Increase the capture area, if the window is maximized
   if(!m_is_minimized)
      m_right_limit+=20;
//--- Set a button
   if(!m_button_rollup.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_button_rollup.BmpFileOn("::Images\\EasyAndFastGUI\\Controls\\DropOn_white.bmp");
   m_button_rollup.BmpFileOff("::Images\\EasyAndFastGUI\\Controls\\DropOn_black.bmp");
   m_button_rollup.Corner(m_corner);
   m_button_rollup.Selectable(false);
   m_button_rollup.Z_Order(m_button_zorder);
   m_button_rollup.Tooltip("Roll Up");
//--- Store coordinates
   m_button_rollup.X(x);
   m_button_rollup.Y(y);
//--- Indents from the edge point
   m_button_rollup.XGap(x-m_x);
   m_button_rollup.YGap(y-m_y);
//--- Store sizes (in object)
   m_button_rollup.XSize(m_button_rollup.X_Size());
   m_button_rollup.YSize(m_button_rollup.Y_Size());
//--- Hide the object
   if(m_is_minimized)
      m_button_rollup.Timeframes(OBJ_NO_PERIODS);
//--- Add objects to the group array
   CElement::AddToArray(m_button_rollup);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the button for maximizing the window                     |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Controls\\DropOff_black.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\DropOff_white.bmp"
//---
bool CWindow::CreateButtonUnroll(void)
  {
//--- If the program type is "script", leave
   if(PROGRAM_TYPE==PROGRAM_SCRIPT)
      return(true);
//--- This button is not required, if the window is a dialog window
   if(m_window_type==W_DIALOG)
      return(true);
//--- Formation of the object name
   string name=CElement::ProgramName()+"_window_unroll_"+(string)CElement::Id();
//--- Object coordinates
   int x=m_x+m_x_size-ROLL_BUTTON_OFFSET;
   int y=m_y+3;
//--- Increase the capture area, if the window is minimized
   if(m_is_minimized)
      m_right_limit+=20;
//--- Set a button
   if(!m_button_unroll.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_button_unroll.BmpFileOn("::Images\\EasyAndFastGUI\\Controls\\DropOff_white.bmp");
   m_button_unroll.BmpFileOff("::Images\\EasyAndFastGUI\\Controls\\DropOff_black.bmp");
   m_button_unroll.Corner(m_corner);
   m_button_unroll.Selectable(false);
   m_button_unroll.Z_Order(m_button_zorder);
   m_button_unroll.Tooltip("Unroll");
//--- Store coordinates
   m_button_unroll.X(x);
   m_button_unroll.Y(y);
//--- Indents from the edge point
   m_button_unroll.XGap(x-m_x);
   m_button_unroll.YGap(y-m_y);
//--- Store sizes (in object)
   m_button_unroll.XSize(m_button_unroll.X_Size());
   m_button_unroll.YSize(m_button_unroll.Y_Size());
//--- Add objects to the group array
   CElement::AddToArray(m_button_unroll);
//--- Hide the object
   if(!m_is_minimized)
      m_button_unroll.Timeframes(OBJ_NO_PERIODS);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the tooltip button                                       |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Controls\\Help_dark.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\Help_light.bmp"
//---
bool CWindow::CreateButtonTooltip(void)
  {
//--- If the program type is "script", leave
   if(PROGRAM_TYPE==PROGRAM_SCRIPT)
      return(true);
//--- This button is not required, if the window is a dialog window
   if(m_window_type==W_DIALOG)
      return(true);
//--- Leave, if this button is not required
   if(!m_tooltips_button)
      return(true);
//--- Formation of the object name
   string name=CElement::ProgramName()+"_window_tooltip_"+(string)CElement::Id();
//--- Object coordinates
   int x=m_x+m_x_size-TOOLTIP_BUTTON_OFFSET;
   int y=m_y+2;
//--- Increase the capture area
   m_right_limit+=20;
//--- Set a button
   if(!m_button_tooltip.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_button_tooltip.BmpFileOn("::Images\\EasyAndFastGUI\\Controls\\Help_light.bmp");
   m_button_tooltip.BmpFileOff("::Images\\EasyAndFastGUI\\Controls\\Help_dark.bmp");
   m_button_tooltip.Corner(m_corner);
   m_button_tooltip.Selectable(false);
   m_button_tooltip.Z_Order(m_button_zorder);
   m_button_tooltip.Tooltip("Tooltips");
//--- Store coordinates
   m_button_tooltip.X(x);
   m_button_tooltip.Y(y);
//--- Indents from the edge point
   m_button_tooltip.XGap(x-m_x);
   m_button_tooltip.YGap(y-m_y);
//--- Store sizes (in object)
   m_button_tooltip.XSize(m_button_tooltip.X_Size());
   m_button_tooltip.YSize(m_button_tooltip.Y_Size());
//--- Add objects to the group array
   CElement::AddToArray(m_button_tooltip);
   return(true);
  }
//+------------------------------------------------------------------+
//| Edits the header text                                            |
//+------------------------------------------------------------------+
void CWindow::CaptionText(const string text)
  {
   m_caption_text=text;
   m_label.Description(text);
  }
//+------------------------------------------------------------------+
//| Identifying the default icon                                     |
//+------------------------------------------------------------------+
string CWindow::DefaultIcon(void)
  {
   string path="Images\\EasyAndFastGUI\\Icons\\bmp16\\advisor.bmp";
//---
   switch(CElement::ProgramType())
     {
      case PROGRAM_SCRIPT:
        {
         path="Images\\EasyAndFastGUI\\Icons\\bmp16\\script.bmp";
         break;
        }
      case PROGRAM_EXPERT:
        {
         path="Images\\EasyAndFastGUI\\Icons\\bmp16\\advisor.bmp";
         break;
        }
      case PROGRAM_INDICATOR:
        {
         path="Images\\EasyAndFastGUI\\Icons\\bmp16\\indicator.bmp";
         break;
        }
     }
//---
   return(path);
  }
//+------------------------------------------------------------------+
//| Mode of indicator sub-window minimization                        |
//+------------------------------------------------------------------+
void CWindow::RollUpSubwindowMode(const bool rollup_mode=false,const bool height_mode=false)
  {
   if(CElement::m_program_type!=PROGRAM_INDICATOR)
      return;
//---
   m_rollup_subwindow_mode =rollup_mode;
   m_height_subwindow_mode =height_mode;
//---
   if(m_height_subwindow_mode)
      ChangeSubwindowHeight(m_subwindow_height);
  }
//+------------------------------------------------------------------+
//| Changes the height of the indicator sub-window                   |
//+------------------------------------------------------------------+
void CWindow::ChangeSubwindowHeight(const int height)
  {
   if(CElement::m_subwin<=0 || CElement::m_program_type!=PROGRAM_INDICATOR)
      return;
//---
   if(height>0)
      ::IndicatorSetInteger(INDICATOR_HEIGHT,height);
  }
//+------------------------------------------------------------------+
//| Changes the width of the window                                  |
//+------------------------------------------------------------------+
void CWindow::ChangeWindowWidth(const int width)
  {
//--- If the width has not changed, leave
   if(width==m_bg.XSize())
      return;
//--- Update the width for the background and the header
   CElement::XSize(width);
   m_bg.XSize(width);
   m_bg.X_Size(width);
   m_caption_bg.XSize(width);
   m_caption_bg.X_Size(width);
//--- Update coordinates and margins for all buttons:
//    Closing button
   int x=CElement::X2()-CLOSE_BUTTON_OFFSET;
   m_button_close.X(x);
   m_button_close.XGap(x-m_x);
   m_button_close.X_Distance(x);
//--- Maximizing button
   x=CElement::X2()-ROLL_BUTTON_OFFSET;
   m_button_unroll.X(x);
   m_button_unroll.XGap(x-m_x);
   m_button_unroll.X_Distance(x);
//--- Minimizing button
   m_button_rollup.X(x);
   m_button_rollup.XGap(x-m_x);
   m_button_rollup.X_Distance(x);
//--- Tooltip button (if enabled)
   if(m_tooltips_button)
     {
      x=CElement::X2()-TOOLTIP_BUTTON_OFFSET;
      m_button_tooltip.X(x);
      m_button_tooltip.XGap(x-m_x);
      m_button_tooltip.X_Distance(x);
     }
  }
//+------------------------------------------------------------------+
//| Getting chart size                                               |
//+------------------------------------------------------------------+
void CWindow::SetWindowProperties(void)
  {
//--- Get width and height of the chart window
   m_chart_width  =m_chart.WidthInPixels();
   m_chart_height =m_chart.HeightInPixels(m_subwin);
  }
//+------------------------------------------------------------------+
//| Converts the Y coordinate into a relative one                    |
//+------------------------------------------------------------------+
int CWindow::YToRelative(const int y)
  {
//--- Get the distance from the top of the chart to the indicator sub-window
   int chart_y_distance=m_chart.SubwindowY(m_subwin);
//--- Convert the Y coordinate into a relative one
   return(y-chart_y_distance);
  }
//+------------------------------------------------------------------+
//| Verifying the cursor location in the area of the window title    |
//+------------------------------------------------------------------+
bool CWindow::CursorInsideCaption(const int x,const int y)
  {
   return(x>m_x && x<X2()-m_right_limit && y>m_y && y<m_caption_bg.Y2());
  }
//+------------------------------------------------------------------+
//| Zeroing variables connected with displacement of the window and  |
//| the state of the left mouse button                               |
//+------------------------------------------------------------------+
void CWindow::ZeroPanelVariables(void)
  {
   m_prev_x              =0;
   m_prev_y              =0;
   m_size_fixing_x       =0;
   m_size_fixing_y       =0;
   m_clamping_area_mouse =NOT_PRESSED;
  }
//+------------------------------------------------------------------+
//| Verifies the state of the mouse button                           |
//+------------------------------------------------------------------+
void CWindow::CheckMouseButtonState(const int x,const int y,const string state)
  {
//--- If the button is released
   if(state=="0")
     {
      //--- Zero variables
      ZeroPanelVariables();
      return;
     }
//--- If the button is pressed
   if(state=="1")
     {
      //--- Leave, if the state is recorded
      if(m_clamping_area_mouse!=NOT_PRESSED)
         return;
      //--- Outside of the panel area
      if(!CElement::MouseFocus())
         m_clamping_area_mouse=PRESSED_OUTSIDE;
      //--- Inside the panel area
      else
        {
         //--- If inside the header
         if(CursorInsideCaption(x,y))
           {
            m_clamping_area_mouse=PRESSED_INSIDE_HEADER;
            return;
           }
         //--- If inside the window area
         m_clamping_area_mouse=PRESSED_INSIDE_WINDOW;
        }
     }
  }
//+------------------------------------------------------------------+
//| Verifying the mouse focus                                        |
//+------------------------------------------------------------------+
void CWindow::CheckMouseFocus(const int x,const int y,const int subwin)
  {
//--- If the cursor is in the area of the program window
   if(subwin==m_subwin)
     {
      //--- If currently not in the form displacement mode
      if(m_clamping_area_mouse!=PRESSED_INSIDE_HEADER)
        {
         //--- Verify the cursor location
         CElement::MouseFocus(x>m_x && x<X2() && y>m_y && y<Y2());
         //---
         m_button_close.MouseFocus(x>m_button_close.X() && x<m_button_close.X2() && 
                                   y>m_button_close.Y() && y<m_button_close.Y2());
         m_button_rollup.MouseFocus(x>m_button_rollup.X() && x<m_button_rollup.X2() && 
                                    y>m_button_rollup.Y() && y<m_button_rollup.Y2());
         m_button_unroll.MouseFocus(x>m_button_unroll.X() && x<m_button_unroll.X2() && 
                                    y>m_button_unroll.Y() && y<m_button_unroll.Y2());
        }
     }
   else
     {
      CElement::MouseFocus(false);
     }
  }
//+------------------------------------------------------------------+
//| Set the chart state                                              |
//+------------------------------------------------------------------+
void CWindow::SetChartState(const int subwindow_number)
  {
//--- If (the cursor is in the panel area and the mouse button is released) or
//    the mouse button was pressed inside the area of the form or header
   if((CElement::MouseFocus() && m_clamping_area_mouse==NOT_PRESSED) || 
      m_clamping_area_mouse==PRESSED_INSIDE_WINDOW ||
      m_clamping_area_mouse==PRESSED_INSIDE_HEADER ||
      m_custom_event_chart_state)
     {
      //--- Disable scroll and management of trading levels
      m_chart.MouseScroll(false);
      m_chart.SetInteger(CHART_DRAG_TRADE_LEVELS,false);
     }
//--- Enable management, if the cursor is outside of the window area
   else
     {
      m_chart.MouseScroll(true);
      m_chart.SetInteger(CHART_DRAG_TRADE_LEVELS,true);
     }
  }
//+------------------------------------------------------------------+
//| Updating window coordinates                                      |
//+------------------------------------------------------------------+
void CWindow::UpdateWindowXY(const int x,const int y)
  {
//--- If the mode of fixed form is set
   if(!m_movable)
      return;
//---  
   int new_x_point =0; // New X coordinate
   int new_y_point =0; // New Y coordinate
//--- Limits
   int limit_top    =0;
   int limit_left   =0;
   int limit_bottom =0;
   int limit_right  =0;
//--- If the mouse button is pressed
   if((bool)m_clamping_area_mouse)
     {
      //--- Store current XY coordinates of the cursor
      if(m_prev_y==0 || m_prev_x==0)
        {
         m_prev_y=y;
         m_prev_x=x;
        }
      //--- Store the distance from the edge point of the form to the cursor
      if(m_size_fixing_y==0 || m_size_fixing_x==0)
        {
         m_size_fixing_y=m_y-m_prev_y;
         m_size_fixing_x=m_x-m_prev_x;
        }
     }
//--- Set limits
   limit_top    =y-::fabs(m_size_fixing_y);
   limit_left   =x-::fabs(m_size_fixing_x);
   limit_bottom =m_y+m_caption_height;
   limit_right  =m_x+m_x_size;
//--- If the boundaries of the chart are not exceeded downwards/upwards/right/left
   if(limit_bottom<m_chart_height && limit_top>=0 && 
      limit_right<m_chart_width && limit_left>=0)
     {
      new_y_point =y+m_size_fixing_y;
      new_x_point =x+m_size_fixing_x;
     }
//--- If the boundaries of the chart were exceeded
   else
     {
      if(limit_bottom>m_chart_height) // > downwards
        {
         new_y_point =m_chart_height-m_caption_height;
         new_x_point =x+m_size_fixing_x;
        }
      if(limit_top<0) // > upwards
        {
         new_y_point =0;
         new_x_point =x+m_size_fixing_x;
        }
      if(limit_right>m_chart_width) // > right
        {
         new_x_point =m_chart_width-m_x_size;
         new_y_point =y+m_size_fixing_y;
        }
      if(limit_left<0) // > left
        {
         new_x_point =0;
         new_y_point =y+m_size_fixing_y;
        }
     }
//--- Update coordinates, if there was a displacement
   if(new_x_point>0 || new_y_point>0)
     {
      //--- Adjust the form coordinates
      m_x =(new_x_point<=0)? 1 : new_x_point;
      m_y =(new_y_point<=0)? 1 : new_y_point;
      //---
      if(new_x_point>0)
         m_x=(m_x>m_chart_width-m_x_size-1) ? m_chart_width-m_x_size-1 : m_x;
      if(new_y_point>0)
         m_y=(m_y>m_chart_height-m_caption_height-1) ? m_chart_height-m_caption_height-2 : m_y;
      //--- Zero the fixed points
      m_prev_x=0;
      m_prev_y=0;
     }
  }
//+------------------------------------------------------------------+
//| Set the state of the window                                      |
//+------------------------------------------------------------------+
void CWindow::State(const bool flag)
  {
//--- If the window needs to be closed
   if(!flag)
     {
      //--- Set the status
      m_is_locked=true;
      //--- Set the header color
      m_caption_bg.BackColor(m_caption_bg_color_off);
      //--- Signal to reset the color. The other controls will also be reset.
      ::EventChartCustom(m_chart_id,ON_RESET_WINDOW_COLORS,(long)CElement::Id(),0,"");
     }
//--- If the window needs to be unlocked
   else
     {
      //--- Set the status
      m_is_locked=false;
      //--- Set the header color
      m_caption_bg.BackColor(m_caption_bg_color);
      //--- Focus reset
      CElement::MouseFocus(false);
     }
  }
//+------------------------------------------------------------------+
//| Reset the window color                                           |
//+------------------------------------------------------------------+
void CWindow::ResetColors(void)
  {
   if(!m_is_locked)
     {
      m_is_locked=true;
      m_caption_bg.BackColor(m_caption_bg_color);
     }
  }
//+------------------------------------------------------------------+
//| Moving the window                                                |
//+------------------------------------------------------------------+
void CWindow::Moving(const int x,const int y)
  {
//--- Storing coordinates in variables
   m_bg.X(x);
   m_bg.Y(y);
   m_caption_bg.X(x);
   m_caption_bg.Y(y);
   m_icon.X(x+m_icon.XGap());
   m_icon.Y(y+m_icon.YGap());
   m_label.X(x+m_label.XGap());
   m_label.Y(y+m_label.YGap());
   m_button_close.X(x+m_button_close.XGap());
   m_button_close.Y(y+m_button_close.YGap());
   m_button_unroll.X(x+m_button_unroll.XGap());
   m_button_unroll.Y(y+m_button_unroll.YGap());
   m_button_rollup.X(x+m_button_rollup.XGap());
   m_button_rollup.Y(y+m_button_rollup.YGap());
   m_button_tooltip.X(x+m_button_tooltip.XGap());
   m_button_tooltip.Y(y+m_button_tooltip.YGap());
//--- Updating coordinates of graphical objects
   m_bg.X_Distance(m_bg.X());
   m_bg.Y_Distance(m_bg.Y());
   m_caption_bg.X_Distance(m_caption_bg.X());
   m_caption_bg.Y_Distance(m_caption_bg.Y());
   m_icon.X_Distance(m_icon.X());
   m_icon.Y_Distance(m_icon.Y());
   m_label.X_Distance(m_label.X());
   m_label.Y_Distance(m_label.Y());
   m_button_close.X_Distance(m_button_close.X());
   m_button_close.Y_Distance(m_button_close.Y());
   m_button_unroll.X_Distance(m_button_unroll.X());
   m_button_unroll.Y_Distance(m_button_unroll.Y());
   m_button_rollup.X_Distance(m_button_rollup.X());
   m_button_rollup.Y_Distance(m_button_rollup.Y());
   m_button_tooltip.X_Distance(m_button_tooltip.X());
   m_button_tooltip.Y_Distance(m_button_tooltip.Y());
  }
//+------------------------------------------------------------------+
//| Deleting                                                         |
//+------------------------------------------------------------------+
void CWindow::Delete(void)
  {
//--- Zeroing variables
   m_right_limit=0;
//--- Deleting objects
   m_bg.Delete();
   m_caption_bg.Delete();
   m_icon.Delete();
   m_label.Delete();
   m_button_close.Delete();
   m_button_rollup.Delete();
   m_button_unroll.Delete();
   m_button_tooltip.Delete();
//--- Emptying the object array
   CElement::FreeObjectsArray();
//--- Zeroing the control focus
   CElement::MouseFocus(false);
  }
//+------------------------------------------------------------------+
//| Changing of the object color when hovering the cursor over it    |
//+------------------------------------------------------------------+
void CWindow::ChangeObjectsColor(void)
  {
//--- Changing icons in the buttons
   m_button_close.State(m_button_close.MouseFocus());
   m_button_rollup.State(m_button_rollup.MouseFocus());
   m_button_unroll.State(m_button_unroll.MouseFocus());
//--- Changing the color in the header
   CElement::ChangeObjectColor(m_caption_bg.Name(),CElement::MouseFocus(),OBJPROP_BGCOLOR,
                               m_caption_bg_color,m_caption_bg_color_hover,m_caption_color_bg_array);
  }
//+------------------------------------------------------------------+
//| Shows the window                                                 |
//+------------------------------------------------------------------+
void CWindow::Show(void)
  {
//--- Make all the objects visible
   for(int i=0; i<CElement::ObjectsElementTotal(); i++)
      Object(i).Timeframes(OBJ_ALL_PERIODS);
//--- Visible state
   CElement::IsVisible(true);
//--- Zeroing the focus
   CElement::MouseFocus(false);
   m_button_close.MouseFocus(false);
   m_button_close.State(false);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_OPEN_DIALOG_BOX,(long)CElement::Id(),0,m_program_name);
  }
//+------------------------------------------------------------------+
//| Hides window                                                     |
//+------------------------------------------------------------------+
void CWindow::Hide(void)
  {
//--- Hide all objects
   for(int i=0; i<CElement::ObjectsElementTotal(); i++)
      Object(i).Timeframes(OBJ_NO_PERIODS);
//--- Visible state
   CElement::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing of all window objects                                  |
//+------------------------------------------------------------------+
void CWindow::Reset(void)
  {
//--- Hide all objects of the form
   Hide();
//--- Reflect in the sequence of their creation
   for(int i=0; i<CElement::ObjectsElementTotal(); i++)
      Object(i).Timeframes(OBJ_ALL_PERIODS);
//--- Depending on the mode, display the required button
   if(m_is_minimized)
      m_button_rollup.Timeframes(OBJ_NO_PERIODS);
   else
      m_button_unroll.Timeframes(OBJ_NO_PERIODS);
//--- Visible state
   CElement::IsVisible(true);
//--- Focus reset
   CElement::MouseFocus(false);
  }
//+------------------------------------------------------------------+
//| Set priorities                                                   |
//+------------------------------------------------------------------+
void CWindow::SetZorders(void)
  {
   m_bg.Z_Order(m_bg_zorder);
   m_caption_bg.Z_Order(m_bg_zorder);
   m_icon.Z_Order(m_button_zorder);
   m_label.Z_Order(m_button_zorder);
   m_button_tooltip.Z_Order(m_button_zorder);
   m_button_unroll.Z_Order(m_button_zorder);
   m_button_rollup.Z_Order(m_button_zorder);
   m_button_close.Z_Order(m_button_zorder);
  }
//+------------------------------------------------------------------+
//| Reset priorities                                                 |
//+------------------------------------------------------------------+
void CWindow::ResetZorders(void)
  {
   m_bg.Z_Order(0);
   m_caption_bg.Z_Order(0);
   m_icon.Z_Order(0);
   m_label.Z_Order(0);
   m_button_tooltip.Z_Order(-1);
   m_button_unroll.Z_Order(-1);
   m_button_rollup.Z_Order(-1);
   m_button_close.Z_Order(-1);
  }
//+------------------------------------------------------------------+
//| Closing the dialog window or the program                         |
//+------------------------------------------------------------------+
bool CWindow::CloseWindow(const string pressed_object)
  {
//--- If the click was not on the button for closing the window
   if(pressed_object!=m_button_close.Name())
      return(false);
//--- If this is the main window
   if(m_window_type==W_MAIN)
     {
      //--- If the program is of the "Expert Advisor" type
      if(CElement::ProgramType()==PROGRAM_EXPERT)
        {
         string text="Do you want the program to be deleted from the chart?";
         //--- Open a dialog window
         int mb_res=::MessageBox(text,NULL,MB_YESNO|MB_ICONQUESTION);
         //--- If the button "Yes" is pressed, delete the program from the chart
         if(mb_res==IDYES)
           {
            ::Print(__FUNCTION__," > The program was deleted from the chart due to your decision!");
            //--- Deleting the Expert Advisor from the chart
            ::ExpertRemove();
            return(true);
           }
        }
      //--- If the program is of the "Indicator" type
      else if(CElement::ProgramType()==PROGRAM_INDICATOR)
        {
         //--- Deleting the indicator from the chart
         if(::ChartIndicatorDelete(m_chart_id,m_subwin,CElement::ProgramName()))
           {
            ::Print(__FUNCTION__," > The program was deleted from the chart due to your decision!");
            return(true);
           }
        }
     }
//--- If this is a dialog window
   else if(m_window_type==W_DIALOG)
     {
      //--- Close it
      CloseDialogBox();
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Closing the dialog box                                           |
//+------------------------------------------------------------------+
void CWindow::CloseDialogBox(void)
  {
//--- Visible state
   CElement::IsVisible(false);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_CLOSE_DIALOG_BOX,CElement::Id(),m_prev_active_window_index,m_caption_text);
  }
//+------------------------------------------------------------------+
//| Check for the window minimization/maximization event             |
//+------------------------------------------------------------------+
bool CWindow::ChangeWindowState(const string pressed_object)
  {
//--- If the button "Minimize the window" was pressed
   if(pressed_object==m_button_rollup.Name())
     {
      RollUp();
      return(true);
     }
//--- If the button "Maximize the window" was pressed
   if(pressed_object==m_button_unroll.Name())
     {
      Unroll();
      return(true);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Minimizes the window                                             |
//+------------------------------------------------------------------+
void CWindow::RollUp(void)
  {
//--- Change the button
   m_button_rollup.Timeframes(OBJ_NO_PERIODS);
   m_button_unroll.Timeframes(OBJ_ALL_PERIODS);
//--- Set and store the size
   m_bg.Y_Size(m_caption_height);
   CElement::YSize(m_caption_height);
//--- Disable the button
   m_button_unroll.MouseFocus(false);
   m_button_unroll.State(false);
//--- State of the form "Minimized"
   m_is_minimized=true;
//--- If this is an indicator with a set height and with the sub-window minimization mode,
//    set the size of the indicator sub-window
   if(m_height_subwindow_mode)
      if(m_rollup_subwindow_mode)
         ChangeSubwindowHeight(m_caption_height+3);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_WINDOW_ROLLUP,CElement::Id(),m_subwin,"");
  }
//+------------------------------------------------------------------+
//| Maximizes the window                                             |
//+------------------------------------------------------------------+
void CWindow::Unroll(void)
  {
//--- Change the button
   m_button_unroll.Timeframes(OBJ_NO_PERIODS);
   m_button_rollup.Timeframes(OBJ_ALL_PERIODS);
//--- Set and store the size
   m_bg.Y_Size(m_bg_full_height);
   CElement::YSize(m_bg_full_height);
//--- Disable the button
   m_button_rollup.MouseFocus(false);
   m_button_rollup.State(false);
//--- State of the form "Maximized"
   m_is_minimized=false;
//--- If this is an indicator with a set height and with the sub-window minimization mode,
//    set the size of the indicator sub-window
   if(m_height_subwindow_mode)
      if(m_rollup_subwindow_mode)
         ChangeSubwindowHeight(m_subwindow_height);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_WINDOW_UNROLL,CElement::Id(),m_subwin,"");
  }
//+------------------------------------------------------------------+
