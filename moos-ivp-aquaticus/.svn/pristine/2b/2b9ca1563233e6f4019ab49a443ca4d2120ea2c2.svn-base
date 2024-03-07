/************************************************************/
/*    NAME: Michael Novitzky                                */
/*    ORGN: MIT/USMA                                        */
/*    FILE: AquaticusStateMgr.h                            */
/*    UPDATE: June 12th, 2022                               */
/************************************************************/

#ifndef AquaticusStateMgr_HEADER
#define AquaticusStateMgr_HEADER

#include "MOOS/libMOOS/Thirdparty/AppCasting/AppCastingMOOSApp.h"
#include "MBUtils.h"
#include "NodeRecord.h"
#include "XYPolygon.h"

class AquaticusStateMgr : public AppCastingMOOSApp
{
 public:
   AquaticusStateMgr();
   ~AquaticusStateMgr();

 protected: // Standard MOOSApp functions to overload  
   bool OnNewMail(MOOSMSG_LIST &NewMail);
   bool Iterate();
   bool OnConnectToServer();
   bool OnStartUp();

 protected: // Standard AppCastingMOOSApp function to overload 
   bool buildReport();

 protected:
   void registerVariables();
  bool handleTeamAssignment(std::string orig);
  // bool handleZoneAssignment(std::string orig);
  bool handlePointsAssignment(std::string orig);
  bool handleHighValuePoint(std::string value);
  void handleMailNodeReport(std::string report);

 private: // Configuration variables
  std::string m_ownship;
  std::string m_self_team;
  std::string m_tagged_vehicles;

  int m_self_score;
  int m_opponent_score;

  double m_self_x;
  double m_self_y;

  // double m_min_x;
  // double m_min_y;
  // double m_max_x;
  // double m_max_y;
  // double theta_1_a;
  // double theta_1_b;
  // double theta_2_a;
  // double theta_2_b;
  // double theta_3_a;
  // double theta_3_b;
  // double theta_4_a;
  // double theta_4_b;
  // double theta_1;
  // double theta_2;
  // double theta_3;
  // double theta_4;
  double x1;
  double y1;
  double x2;
  double y2;
  double x3;
  double y3;
  double x4;
  double y4;
  std::string m_in_zone;
  bool m_high_value_point_set;
  double m_high_value_point_x;
  double m_high_value_point_y;
  std::string m_contact_track;

 private: // State variables
  XYPolygon m_poly;
  std::map<std::string, NodeRecord> m_map_node_records;
  std::map<std::string, double  > m_map_intruders_x;
  std::map<std::string, double  > m_map_intruders_y;
  std::map<std::string, bool  > m_map_contacts_in_zone;
  std::map<std::string, std::string> m_map_intruders_name;
};

#endif 
