//+------------------------------------------------------------------+
//|                                                   MBookPanel.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <Object.mqh>
///
/// Defines event type
///
enum ENUM_EVENT_TYPE
{
   EVENT_FREFRESH,
   EVENT_CHART_OBJECT_CLICK,
   EVENT_CHART_END_EDIT,
   EVENT_CHART_CUSTOM,            // An arbitrary user event
   EVENT_CHART_MOUSE_MOVE,
   EVENT_CHART_LIST_CHANGED,      // Selected element in the drop-down list has changed
   EVENT_CHART_PBAR_CHANGED,      // The value of the progress bar should be changed
   EVENT_CHART_CONSOLE_ADD,       // The event adds a new message to the console
   EVENT_CHART_CONSOLE_CHANGE,    // The event replaces a line in the console with the given one
   EVENT_CHART_CONSOLE_CHLAST     // The event replaces the last line in the console with the given one
};
///
/// Basic event type
///
class CEvent
{
private:
   ENUM_EVENT_TYPE m_event_type;    // Event type
protected:
   CEvent(ENUM_EVENT_TYPE event_type);
   int   m_user_event_id;           // The index of the user event
public:
   ENUM_EVENT_TYPE EventType();
};
///
/// Creates an event of the predefined type
///
CEvent::CEvent(ENUM_EVENT_TYPE event_type)
{
   m_event_type = event_type;
}
///
/// Returns an event type
///
ENUM_EVENT_TYPE CEvent::EventType(void)
{
   return m_event_type;
}
