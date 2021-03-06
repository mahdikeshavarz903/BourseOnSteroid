//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//--- Class name
#define CLASS_NAME ::StringSubstr(__FUNCTION__,0,::StringFind(__FUNCTION__,"::"))
//--- Program name
#define PROGRAM_NAME ::MQLInfoString(MQL_PROGRAM_NAME)
//--- Program type
#define PROGRAM_TYPE (ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)
//--- Prevention of exceeding the array size
#define PREVENTING_OUT_OF_RANGE __FUNCTION__," > Prevention of exceeding the array size."

//--- Font
#define FONT      ("Calibri")
#define FONT_SIZE (8)

//--- Timer step (milliseconds)
#define TIMER_STEP_MSC (16)
//--- Delay before activation of the counter rewind (milliseconds)
#define SPIN_DELAY_MSC (-450)

//--- Events
#define ON_WINDOW_UNROLL          (1)  // Maximizing the form
#define ON_WINDOW_ROLLUP          (2)  // Minimizing the form
#define ON_CLICK_MENU_ITEM        (4)  // Clicking on the menu item
#define ON_CLICK_CONTEXTMENU_ITEM (5)  // Clicking on the menu item in a context menu
#define ON_HIDE_CONTEXTMENUS      (6)  // Hide all context menus
#define ON_HIDE_BACK_CONTEXTMENUS (7)  // Hide context menus below the current menu item
#define ON_CLICK_BUTTON           (8)  // Clicking on the button
#define ON_CLICK_FREEMENU_ITEM    (9)  // Clicking on the menu item in a free context menu
#define ON_CLICK_LABEL            (10) // Clicking on the text label
#define ON_OPEN_DIALOG_BOX        (11) // Opening the dialog box event
#define ON_CLOSE_DIALOG_BOX       (12) // Closing the dialog box event
#define ON_RESET_WINDOW_COLORS    (13) // Reset the window color
#define ON_ZERO_PRIORITIES        (14) // Reset the priorities for mouse button clicking
#define ON_SET_PRIORITIES         (15) // Restore the priorities for mouse button clicking
#define ON_CLICK_LIST_ITEM        (16) // Select the item in the list
#define ON_CLICK_COMBOBOX_ITEM    (17) // Select the item in the combo box list
//+------------------------------------------------------------------+
