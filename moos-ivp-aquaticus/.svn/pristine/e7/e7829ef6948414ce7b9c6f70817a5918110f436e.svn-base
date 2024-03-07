/************************************************************/
/*    NAME: Mike Benjamin                                   */
/*    ORGN: MIT, Cambridge MA                               */
/*    FILE: MapMarkers.h                                    */
/*    DATE: Sep 25th, 2023                                  */
/************************************************************/

#ifndef MAP_MARKERS_HEADER
#define MAP_MARKERS_HEADER

#include "MOOS/libMOOS/Thirdparty/AppCasting/AppCastingMOOSApp.h"
#include <string> 
#include <map> 
#include "XYMarker.h"
#include "OpField.h"

class MapMarkers : public AppCastingMOOSApp
{
 public:
  MapMarkers() ;
  ~MapMarkers() {};

 protected: // Standard MOOSApp functions to overload  
  bool OnNewMail(MOOSMSG_LIST &NewMail);
  bool Iterate();
  bool OnConnectToServer();
  bool OnStartUp();

 protected: // Standard AppCastingMOOSApp function to overload 
  bool buildReport();

  bool addMarker(std::string);
  void postMarkers();
  
 protected:
  void registerVariables();
  
 private: // Configuration variables

  std::map<std::string, XYMarker>    m_map_markers;
  
  bool         m_show_markers;
  bool         m_refresh_needed;
  unsigned int m_marker_size;

  std::string  m_map_marker_key;
  std::string  m_default_marker_color;

  unsigned int m_default_marker_size;
  
  OpField m_opfield;
  
 private: // State variables

  double m_post_markers_utc;
};

#endif 
