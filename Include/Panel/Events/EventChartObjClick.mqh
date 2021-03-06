#include "Event.mqh"
///
///
///
class CEventChartObjClick : public CEvent
{
private:
   string m_obj_name;
   
public:
   CEventChartObjClick(string obj_name);
   string ObjectName(void);
};
///
/// Constructor
///
CEventChartObjClick::CEventChartObjClick(string obj_name) : CEvent(EVENT_CHART_OBJECT_CLICK)
{
   m_obj_name = obj_name;
}
///
/// Returns the name of the clicked object
///
string CEventChartObjClick::ObjectName(void)
{
   return m_obj_name;
}