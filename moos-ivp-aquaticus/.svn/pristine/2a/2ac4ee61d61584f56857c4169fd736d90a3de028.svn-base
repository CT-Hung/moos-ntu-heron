/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: FieldSensor.h                                          */
/*    DATE: December 29th, 1963                             */
/************************************************************/

#ifndef FieldSensor_HEADER
#define FieldSensor_HEADER

#include "MOOS/libMOOS/Thirdparty/AppCasting/AppCastingMOOSApp.h"
#include "MBUtils.h"
#include "NodeRecord.h"

class FieldSensor : public AppCastingMOOSApp
{
 public:
   FieldSensor();
   ~FieldSensor();

 protected: // Standard MOOSApp functions to overload  
   bool OnNewMail(MOOSMSG_LIST &NewMail);
   bool Iterate();
   bool OnConnectToServer();
   bool OnStartUp();

 protected: // Standard AppCastingMOOSApp function to overload 
   bool buildReport();

 protected:
   void registerVariables();
  bool handleUpperY(std::string orig);
  bool handleLowerY(std::string orig);
  bool handleLeftX(std::string value);
  bool handleRightX(std::string report);
  void handleMailNodeReport(std::string report);

 private: // Configuration variables
  std::string m_ownship;
  double m_left_x;
  double m_lower_y;
  double m_right_x;
  double m_upper_y;
  double m_middle_x;
  double m_middle_y;
  double m_my_x;
  double m_my_y;
  std::string m_in_zone;
  bool m_high_value_point_set;
  double m_high_value_point_x;
  double m_high_value_point_y;

 private: // State variables
  std::map<std::string, NodeRecord> m_map_node_records;
  std::map<std::string, double> m_map_quad;
  std::map<std::string, double  > m_map_intruders_x;
  std::map<std::string, double  > m_map_intruders_y;
  std::map<std::string, std::string> m_map_intruders_name;
};

#endif 
