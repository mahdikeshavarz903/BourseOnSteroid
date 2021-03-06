//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Enumeration of window types                                      |
//+------------------------------------------------------------------+
enum ENUM_WINDOW_TYPE
  {
   W_MAIN   =0,
   W_DIALOG =1
  };
//+------------------------------------------------------------------+
//| Enumeration of the left mouse button states for the window       |
//+------------------------------------------------------------------+
enum ENUM_WMOUSE_STATE
  {
   NOT_PRESSED           =0,
   PRESSED_OUTSIDE       =1,
   PRESSED_INSIDE_WINDOW =2,
   PRESSED_INSIDE_HEADER =3
  };
//+------------------------------------------------------------------+
//| Enumeration of the menu item types                               |
//+------------------------------------------------------------------+
enum ENUM_TYPE_MENU_ITEM
  {
   MI_SIMPLE           =0,
   MI_HAS_CONTEXT_MENU =1,
   MI_CHECKBOX         =2,
   MI_RADIOBUTTON      =3
  };
//+------------------------------------------------------------------+
//| Enumeration of the separation line types                         |
//+------------------------------------------------------------------+
enum ENUM_TYPE_SEP_LINE
  {
   H_SEP_LINE =0,
   V_SEP_LINE =1
  };
//+------------------------------------------------------------------+
//| Enumeration of the menu attachment sides                         |
//+------------------------------------------------------------------+
enum ENUM_FIX_CONTEXT_MENU
  {
   FIX_RIGHT  =0,
   FIX_BOTTOM =1
  };
//+------------------------------------------------------------------+
//| Enumeration of the left mouse button states for the window       |
//+------------------------------------------------------------------+
enum ENUM_THUMB_MOUSE_STATE
  {
   THUMB_NOT_PRESSED     =0,
   THUMB_PRESSED_OUTSIDE =1,
   THUMB_PRESSED_INSIDE  =2
  };
//+------------------------------------------------------------------+
