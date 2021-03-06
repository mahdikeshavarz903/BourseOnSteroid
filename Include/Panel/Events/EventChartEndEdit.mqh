#include "Event.mqh"
///
///
///
class CEventChartEndEdit : public CEvent
{
private:
   string m_obj_name;
   
public:
   CEventChartEndEdit(string obj_name);
   string ObjectName(void);
};
///
/// Constructor
///
CEventChartEndEdit::CEventChartEndEdit(string obj_name) : CEvent(EVENT_CHART_END_EDIT)
{
   m_obj_name = obj_name;
}
///
/// Returns the name of the clicked object
///
string CEventChartEndEdit::ObjectName(void)
{
   return m_obj_name;
}