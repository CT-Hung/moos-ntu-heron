/************************************************************/
/*    NAME: Mike Benjamin                                   */
/*    ORGN: MIT, Cambridge MA                               */
/*    FILE: MapMarkers.cpp                                  */
/*    DATE: September 25th, 2023                            */
/************************************************************/

#include <iterator>
#include "MBUtils.h"
#include "ACTable.h"
#include "MapMarkers.h"
#include "XYFormatUtilsMarker.h"

using namespace std;

//---------------------------------------------------------
// Constructor()

MapMarkers::MapMarkers()
{
  // Config vars
  m_marker_size  = 5;
  m_show_markers = false;
  m_refresh_needed = true;
  m_default_marker_color = "light_green";
  m_default_marker_size = 3;
  
  // State vars
  m_post_markers_utc = 0;
}

//---------------------------------------------------------
// Procedure: OnNewMail()

bool MapMarkers::OnNewMail(MOOSMSG_LIST &NewMail)
{
  AppCastingMOOSApp::OnNewMail(NewMail);

  MOOSMSG_LIST::iterator p;
  for(p=NewMail.begin(); p!=NewMail.end(); p++) {
    CMOOSMsg &msg = *p;
    string key  = msg.GetKey();
    string sval = msg.GetString(); 

#if 0 // Keep these around just for template
    string comm  = msg.GetCommunity();
    double dval  = msg.GetDouble();
    string msrc  = msg.GetSource();
    double mtime = msg.GetTime();
    bool   mdbl  = msg.IsDouble();
    bool   mstr  = msg.IsString();
#endif

    bool handled = false;
    if(key == "MAP_MARKERS") {
      bool prev_show_markers = m_show_markers;	
      handled = setBooleanOnString(m_show_markers, sval);
      if(prev_show_markers != m_show_markers)
	m_post_markers_utc = 0;
    }
    else if(key == "MM_KEY") {
      bool prev_show_markers = m_show_markers;
      m_show_markers = false;
      sval = tolower(sval);
      if((m_map_marker_key == sval) || (sval == "all"))
	m_show_markers = true;
      m_post_markers_utc = 0;
      if(m_show_markers != prev_show_markers)
	m_refresh_needed = true;
    }
    
    else if(key == "APPCAST_REQ")
      handled = true;
    
    else if(!handled) 
      reportRunWarning("Unhandled Mail: " + key);
  }
  
  return(true);
}

//---------------------------------------------------------
// Procedure: OnConnectToServer()

bool MapMarkers::OnConnectToServer()
{
   registerVariables();
   return(true);
}

//---------------------------------------------------------
// Procedure: Iterate()

bool MapMarkers::Iterate()
{
  AppCastingMOOSApp::Iterate();

  postMarkers();

  AppCastingMOOSApp::PostReport();
  return(true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()

bool MapMarkers::OnStartUp()
{
  AppCastingMOOSApp::OnStartUp();

  STRING_LIST sParams;
  m_MissionReader.EnableVerbatimQuoting(false);
  if(!m_MissionReader.GetConfiguration(GetAppName(), sParams))
    reportConfigWarning("No config block found for " + GetAppName());

  STRING_LIST::iterator p;
  for(p=sParams.begin(); p!=sParams.end(); p++) {
    string orig  = *p;
    string line  = *p;
    string param = tolower(biteStringX(line, '='));
    string value = line;
    cout << "param=" << param << endl;

    bool handled = false;
    if(param == "opfield") {
      cout << "Handling opfield...." << endl;
      handled = m_opfield.config(value);
    }
    else if(param == "show_markers") 
      handled = setBooleanOnString(m_show_markers, value);

    else if(param == "default_marker_color") 
      handled = setColorOnString(m_default_marker_color, value);

    else if(param == "marker_key") {
      m_map_marker_key = value;
      handled = true;
    }

    if(!handled)
      reportUnhandledConfigWarning(orig);

  }
  
  registerVariables();	
  return(true);
}

//---------------------------------------------------------
// Procedure: registerVariables()

void MapMarkers::registerVariables()
{
  AppCastingMOOSApp::RegisterVariables();
  Register("MAP_MARKERS", 0);
  Register("MM_KEY", 0);
}

//---------------------------------------------------------
// Procedure: addMarker()

bool MapMarkers::addMarker(string str)
{
  XYMarker marker = string2Marker(str);
  if(!marker.is_set_x() || !marker.is_set_y())
    return(false);
  
  string label = marker.get_label();
  if(label == "") 
    label = "m_" + uintToString(m_map_markers.size());

  m_map_markers[label] = marker;
  return(true);
}

//---------------------------------------------------------
// Procedure: postMarkers()

void MapMarkers::postMarkers()
{
  double elapsed = m_curr_time - m_post_markers_utc;
  if(m_iteration < 100) {
    if(elapsed < 5)
      return;
  }
  else if(!m_refresh_needed)
    return;
  
  vector<string> aliases = m_opfield.getPtAliases();
  for(unsigned int i=0; i<aliases.size(); i++) {
    string alias = aliases[i];

    string spec;
    if(!m_show_markers)
      spec = "x=0,y=0,active=false,label=" + alias;
    else {
      XYPoint pt = m_opfield.getPoint(alias);
      XYMarker marker;
      marker.set_vx(pt.x());
      marker.set_vy(pt.y());
      marker.set_label(alias);
      marker.set_type("triangle");
      string color = m_opfield.getColor(alias);
      if(color == "")
	color = m_default_marker_color;
      marker.set_color("primary_color", color);
      marker.set_width(m_default_marker_size);
      spec = marker.get_spec();
    }
    Notify("VIEW_MARKER", spec);
  }
	
  m_post_markers_utc = m_curr_time;  
  m_refresh_needed = false;
}


//------------------------------------------------------------
// Procedure: buildReport()

bool MapMarkers::buildReport() 
{
  m_msgs << "Points: " << uintToString(m_opfield.size()) << endl;
  m_msgs << "Show Markers: " << boolToString(m_show_markers) << endl;
  m_msgs << "Default Color: " << m_default_marker_color << endl;
  m_msgs << "Default Size: " << m_default_marker_size << endl;
  m_msgs << "Marker Key: " << m_map_marker_key << endl;
  m_msgs << endl;

  ACTable actab(4);
  actab << "Alias | Point | Alias | Point";
  actab.addHeaderLines();

  vector<string> aliases = m_opfield.getPtAliases();
  for(unsigned int i=0; i<aliases.size(); i++) {
    string alias = aliases[i];
    XYPoint pt = m_opfield.getPoint(alias);
    actab << alias << pt.get_spec();
  }

  m_msgs << actab.getFormattedString();

  return(true);
}




