/************************************************************/
/*    NAME: Michael Novitzky                                */
/*    ORGN: MIT/USMA                                        */
/*    FILE: AquaticusStateMgr.cpp                          */
/*    DATE: June 12th, 2022                                 */
/************************************************************/

#include "AquaticusStateMgr.h"
#include "ACTable.h"
#include "MBUtils.h"
#include "NodeRecordUtils.h"
#include <iterator>
#include <math.h>
#include <stdlib.h>

using namespace std;

//---------------------------------------------------------
// Constructor

AquaticusStateMgr::AquaticusStateMgr() {
  m_high_value_point_set = false;
  m_contact_track = "";
  m_self_x=0;
  m_self_y=0;
}

//---------------------------------------------------------
// Destructor

AquaticusStateMgr::~AquaticusStateMgr() {}

//---------------------------------------------------------
// Procedure: OnNewMail

bool AquaticusStateMgr::OnNewMail(MOOSMSG_LIST &NewMail) {
  AppCastingMOOSApp::OnNewMail(NewMail);

  MOOSMSG_LIST::iterator p;
  for (p = NewMail.begin(); p != NewMail.end(); p++) {
    CMOOSMsg &msg = *p;
    string key = msg.GetKey();

#if 0 // Keep these around just for template
    string comm  = msg.GetCommunity();op_for_x
    double dval  = msg.GetDouble();
    string sval  = msg.GetString(); 
    string msrc  = msg.GetSource();
    double mtime = msg.GetTime();
    bool   mdbl  = msg.IsDouble();
    bool   mstr  = msg.IsString();
#endif

    if (key == "NODE_REPORT") {
      std::string sval = msg.GetString();
      handleMailNodeReport(sval);
    } else if (key == "NAV_X") {
      m_self_x = msg.GetDouble();
    } else if (key == "NAV_Y") {
      m_self_y = msg.GetDouble();
    } else if (key == "TAGGED_VEHICLES") {
      m_tagged_vehicles = msg.GetString();
    } else if (key == "RED_SCORES") {
      if (m_self_team == "red")
        m_self_score = int(msg.GetDouble());
      else
        m_opponent_score = int(msg.GetDouble());
    } else if (key == "BLUE_SCORES") {      
      if (m_self_team == "blue")
        m_self_score = int(msg.GetDouble());
      else
        m_opponent_score = int(msg.GetDouble());
    } else if (key != "APPCAST_REQ") // handled by AppCastingMOOSApp
      reportRunWarning("Unhandled Mail: " + key);
  }

  return (true);
}

//---------------------------------------------------------
// Procedure: OnConnectToServer

bool AquaticusStateMgr::OnConnectToServer() {
  registerVariables();
  return (true);
}

//---------------------------------------------------------
// Procedure: Iterate()
//            happens AppTick times per second

bool AquaticusStateMgr::Iterate() {
  AppCastingMOOSApp::Iterate();
  // Do your thing here!
  map<string, NodeRecord>::const_iterator p;
  bool foundIntrudingContact = false;

  if (!(m_self_x == m_self_y && m_self_x == 0)){
      if (m_poly.contains(m_self_x, m_self_y)) {
        Notify("SELF_IN_MY_ZONE", "true");
      } else {
        Notify("SELF_IN_MY_ZONE", "false");
      }
  }

  if (m_self_score > m_opponent_score){
    Notify("WINNING", "true");
    // Notify("ACTION", "defend");
  }
  else{
    Notify("WINNING", "false");
    // Notify("ACTION", "attack");
  }

  for (p = m_map_node_records.begin(); p != m_map_node_records.end(); p++) {
    std::string contact_name = p->first;
    NodeRecord node_record = p->second;

    // is contact name from opfor?
    bool followContact = strContains(contact_name, m_self_team);
    bool taggedVehicle = !strContains(m_tagged_vehicles, contact_name);
    
// TAGGED_VEHICLES asdfasdfasdfs

    if (!followContact) {
      // not a contact of opposing force
      continue;
    }
    if (!taggedVehicle) {
      // not a tagged vehicle
      continue;
    }

    // extract location and check if within bounds
    double op_for_x = node_record.getX();
    double op_for_y = node_record.getY();


    if (m_poly.contains(op_for_x, op_for_y)) {
      foundIntrudingContact = true;
      Notify("ENEMY_IN_ZONE", "true");
      Notify("ENEMY_IN_ZONE_CONTACT", contact_name);
      m_in_zone = "true";
      m_map_contacts_in_zone[contact_name] = true;
      if (m_high_value_point_set) {
        // we keep intruder location for high value threat
        m_map_intruders_x[contact_name] = op_for_x;
        m_map_intruders_y[contact_name] = op_for_y;
        m_map_intruders_name[contact_name] =
            contact_name; // used for convenience
      }
    } else {
      m_map_contacts_in_zone[contact_name] = false;
      // means a contact may previously exist and should be removed
      if (m_high_value_point_set) {
        m_map_intruders_x.erase(contact_name);
        m_map_intruders_y.erase(contact_name);
        m_map_intruders_name.erase(contact_name);
      }
    }
  }

  if (!foundIntrudingContact) {
    Notify("ENEMY_IN_ZONE", "false");
    m_in_zone = "false";
    m_contact_track = "";
  } else {
    // means we have found an intruding contact
    // do we check against high value point?
    if (m_high_value_point_set) {
      // should be tracking
      if (m_map_intruders_x.size() == 1) {
        // only contact means only contact
        std::map<string, string>::iterator it = m_map_intruders_name.begin();
        std::string close_contact = it->second;
        std::string proper_form = "contact=";
        proper_form += close_contact;
        Notify("ENEMY_IN_ZONE_INTERCEPT_UPDATES", proper_form);
        m_contact_track = proper_form;
      } else {
        std::string close_contact;
        // we assume at most 2 contacts
        std::map<std::string, double>::iterator it_x =
            m_map_intruders_x.begin();
        std::map<std::string, double>::iterator it_y =
            m_map_intruders_y.begin();
        std::map<std::string, std::string>::iterator it_name =
            m_map_intruders_name.begin();

        double temp_x_1 = it_x->second;
        double temp_y_1 = it_y->second;
        std::string temp_name_1 = it_name->second;
        // calculate range to high value point
        double temp_range_1 = sqrt(pow(temp_x_1 - m_high_value_point_x, 2) +
                                   pow(temp_y_1 - m_high_value_point_y, 2));

        it_x++;
        it_y++;
        it_name++;

        double temp_x_2 = it_x->second;
        double temp_y_2 = it_y->second;
        std::string temp_name_2 = it_name->second;
        // calculate range to high value point
        double temp_range_2 = sqrt(pow(temp_x_2 - m_high_value_point_x, 2) +
                                   pow(temp_y_2 - m_high_value_point_y, 2));

        std::string proper_form = "contact=";
        // now let's compare the ranges
        if (temp_range_1 <= temp_range_2) {
          proper_form += temp_name_1;
          Notify("ENEMY_IN_ZONE_INTERCEPT_UPDATES", proper_form);
          m_contact_track = proper_form;
        } else {
          proper_form += temp_name_2;
          Notify("ENEMY_IN_ZONE_INTERCEPT_UPDATES", proper_form);
          m_contact_track = proper_form;
        }
      }
    }
  }

  AppCastingMOOSApp::PostReport();
  return (true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()
//            happens before connection is open

bool AquaticusStateMgr::OnStartUp() {
  AppCastingMOOSApp::OnStartUp();

  m_ownship = m_host_community;

  STRING_LIST sParams;
  m_MissionReader.EnableVerbatimQuoting(false);
  if (!m_MissionReader.GetConfiguration(GetAppName(), sParams))
    reportConfigWarning("No config block found for " + GetAppName());

  STRING_LIST::iterator p;
  for (p = sParams.begin(); p != sParams.end(); p++) {
    string orig = *p;
    string line = *p;
    string param = tolower(biteStringX(line, '='));
    string value = line;

    bool handled = false;
    if (param == "home_zone") {
      handled = handlePointsAssignment(orig);
    } else if (param == "team_name") {
      handled = handleTeamAssignment(value);
    } else if (param == "high_value_pt") {
      handled = handleHighValuePoint(value);
    }

    if (!handled)
      reportUnhandledConfigWarning(orig);
  }

  registerVariables();
  return (true);
}

//---------------------------------------------------------
// Procedure: registerVariables

void AquaticusStateMgr::registerVariables() {
  AppCastingMOOSApp::RegisterVariables();
  Register("NODE_REPORT", 0);
  Register("NAV_X", 0);
  Register("NAV_Y", 0);

  Register("TAGGED_VEHICLES", 0);
  Register("RED_SCORES", 0);
  Register("BLUE_SCORES", 0);
}

//------------------------------------------------------------
// Procedure: buildReport()

bool AquaticusStateMgr::buildReport() {
  m_msgs << "============================================ \n";
  m_msgs << "Ownship: " << m_ownship << endl;
  m_msgs << "Self team: " << m_self_team << endl;
  m_msgs << "Pt 1 Corner: x = " << x1 << " y = " << y1 << endl;
  m_msgs << "Pt 2 Corner: x = " << x2 << " y = " << y2 << endl;
  m_msgs << "Pt 3 Corner: x = " << x3 << " y = " << y3 << endl;
  m_msgs << "Pt 4 Corner: x = " << x4 << " y = " << y4 << endl;
  if (m_high_value_point_set) {
    m_msgs << "high value point x: " << m_high_value_point_x
           << " y: " << m_high_value_point_y << endl;
  }
  // show contacts and in or out of state
  m_msgs << "============================================ \n";
  m_msgs << "In Zone: " << m_in_zone << endl;
  m_msgs << "Contacts:" << endl;
  map<std::string, NodeRecord>::const_iterator p;
  for (p = m_map_node_records.begin(); p != m_map_node_records.end(); p++) {
    std::string contact_name = p->first;
    NodeRecord node_record = p->second;
    std::string x = doubleToString(node_record.getX());
    std::string y = doubleToString(node_record.getY());

    m_msgs << contact_name << " x: " << x << " y: " << y
           << " in zone: " << to_string(m_map_contacts_in_zone[contact_name])
           << endl;
  }
  m_msgs << "Contact Tracking: " << m_contact_track << endl;
  return (true);
}

//---------------------------------------------------------
// Procedure: handleTeamAssignment

bool AquaticusStateMgr::handleTeamAssignment(std::string orig) {
  // expecting in .moos parameter file opfor = blue or red
  // TODO: error checking?
  m_self_team = orig;
  return true;
}

//---------------------------------------------------------
// Procedure: handlePointsAssignment

bool AquaticusStateMgr::handlePointsAssignment(std::string orig) {
  // expecting in .moos parameter file: pts={x1,y1:x2,y2:x3,y3:x4,y4}
  std::string ptsString = biteStringX(orig, '=');
  vector<std::string> str_vector = parseString(orig, ',');
  if (str_vector.size() != 8) {
    reportUnhandledConfigWarning("8 != " + to_string(str_vector.size()));
    return false;
  }

  // we will convert strings to double
  x1 = atof(str_vector[0].c_str());
  y1 = atof(str_vector[1].c_str());
  x2 = atof(str_vector[2].c_str());
  y2 = atof(str_vector[3].c_str());
  x3 = atof(str_vector[4].c_str());
  y3 = atof(str_vector[5].c_str());
  x4 = atof(str_vector[6].c_str());
  y4 = atof(str_vector[7].c_str());

  bool isConvex = true;
  m_poly = XYPolygon();
  m_poly.add_vertex(x1, y1);
  m_poly.add_vertex(x2, y2);
  m_poly.add_vertex(x3, y3);
  isConvex = isConvex && m_poly.add_vertex(x4, y4);

  return isConvex;

  return true;
}

//---------------------------------------------------------
// Procedure: handleHighValuePoint

bool AquaticusStateMgr::handleHighValuePoint(std::string value) {
  // expecting 1 point1 point
  // expecting in .moos parameter file: point = x,y
  vector<std::string> str_vector = parseString(value, ',');
  if (str_vector.size() != 2) {
    return false;
  }

  // we will convert strings to double
  m_high_value_point_x = atof(str_vector[0].c_str());
  m_high_value_point_y = atof(str_vector[1].c_str());
  m_high_value_point_set = true;

  return true;
}

//---------------------------------------------------------
// Procedure: handleMailNodeReport

void AquaticusStateMgr::handleMailNodeReport(std::string report) {
  NodeRecord new_node_record = string2NodeRecord(report, true);

  // if incoming node matches own ship, we just ignore it
  std::string vname = new_node_record.getName();

  if (vname == m_ownship)
    return;

  m_map_node_records[vname] = new_node_record;
}
