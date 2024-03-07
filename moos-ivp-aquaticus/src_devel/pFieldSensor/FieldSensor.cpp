/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: FieldSensor.cpp                                        */
/*    DATE:                                                 */
/************************************************************/

#include <iterator>
#include "MBUtils.h"
#include "ACTable.h"
#include "FieldSensor.h"
#include "NodeRecordUtils.h"

using namespace std;

//---------------------------------------------------------
// Constructor

FieldSensor::FieldSensor()
{
  
}

//---------------------------------------------------------
// Destructor

FieldSensor::~FieldSensor()
{
}

//---------------------------------------------------------
// Procedure: OnNewMail

bool FieldSensor::OnNewMail(MOOSMSG_LIST &NewMail)
{
  AppCastingMOOSApp::OnNewMail(NewMail);

  MOOSMSG_LIST::iterator p;
  for(p=NewMail.begin(); p!=NewMail.end(); p++) {
    CMOOSMsg &msg = *p;
    string key    = msg.GetKey();

#if 0 // Keep these around just for template
    string comm  = msg.GetCommunity();
    double dval  = msg.GetDouble();
    string sval  = msg.GetString(); 
    string msrc  = msg.GetSource();
    double mtime = msg.GetTime();
    bool   mdbl  = msg.IsDouble();
    bool   mstr  = msg.IsString();
#endif

     if(key == "FOO") 
       cout << "great!";
     else if (key == "NODE_REPORT" || key == "NODE_REPORT_LOCAL"){
       std::string sval = msg.GetString();
       handleMailNodeReport(sval);
     }
     else if (key == "NAV_X"){
       m_my_x = msg.GetDouble();
       
     }
     else if (key == "NAV_Y"){
       m_my_y = msg.GetDouble();
 
     }
     else if(key != "APPCAST_REQ") // handled by AppCastingMOOSApp
       reportRunWarning("Unhandled Mail: " + key);
   }
	
   return(true);
}

//---------------------------------------------------------
// Procedure: OnConnectToServer

bool FieldSensor::OnConnectToServer()
{
   registerVariables();
   return(true);
}

//---------------------------------------------------------
// Procedure: Iterate()
//            happens AppTick times per second

bool FieldSensor::Iterate()
{
  AppCastingMOOSApp::Iterate();
  // Do your thing here!
  map<string, NodeRecord>::const_iterator p;
  bool foundIntrudingContact = false;
  for(p=m_map_node_records.begin(); p!=m_map_node_records.end();p++) {
    std::string contact_name = p->first;
    NodeRecord node_record = p->second;

    //is contact name from opfor?
    //    bool followContact = strContains(contact_name, m_op_for);


      //extract location and check if within bounds
      double node_x = node_record.getX();
      double node_y = node_record.getY();

      //  upper_y
      // left_x     right_x
      //   lower_y
      //midpoint for left_x, right_x
      m_middle_x = (m_left_x + m_right_x) /2.0;
      m_middle_y = (m_upper_y + m_lower_y) /2.0;

      double quadrant = 0;
      
      if(node_y >= m_middle_y ) // upper half of field
	{
	  if(node_x >= m_middle_x) // on right side of field
	    {
	      quadrant = 1;
	    }
	  else if(node_x < m_middle_x){
	    quadrant = 2;
	  }
	}
      else if ( node_y < m_middle_y) //lower half of field
	{
	  if(node_x >= m_middle_x)
	    {
	      quadrant = 4;
	    }
	  else if (node_x < m_middle_x)
	    {
	      quadrant = 3;
	    }
	}

      m_map_quad[contact_name] = quadrant;

      //Let's notify via variable publication
      //vname + quadrant
      std::string var_name = contact_name + "_quadrant";
      Notify(var_name, quadrant);
      
  }


  AppCastingMOOSApp::PostReport();
  return(true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()
//            happens before connection is open

bool FieldSensor::OnStartUp()
{
  AppCastingMOOSApp::OnStartUp();

  m_ownship = m_host_community;

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

    bool handled = false;
    if(param == "foo") {
      handled = true;
    }
    else if(param == "bar") {
      handled = true;
    }
    else if(param == "uppery"){
      handled = handleUpperY(value);
    }
    else if(param == "lowery"){
      handled = handleLowerY(value);
    }
    else if(param == "leftx"){
      handled = handleLeftX(value);
    }
    else if(param == "rightx"){
      handled = handleRightX(value);
    }

    if(!handled)
      reportUnhandledConfigWarning(orig);

  }
  
  registerVariables();	
  return(true);
}

//---------------------------------------------------------
// Procedure: registerVariables

void FieldSensor::registerVariables()
{
  AppCastingMOOSApp::RegisterVariables();
  Register("NODE_REPORT",0); //for all contacts other than myself
  Register("NODE_REPORT_LOCAL",0);
  Register("NAV_X",0); //my own X
  Register("NAV_Y",0); //my own Y

  // Register("FOOBAR", 0);
}


//------------------------------------------------------------
// Procedure: buildReport()

bool FieldSensor::buildReport() 
{
  m_msgs << "============================================ \n";
  m_msgs << "Ownship: " << m_ownship << endl;
  m_msgs << "left x: " << m_left_x << " right x: " << m_right_x << endl;
  m_msgs << "upper y: " << m_upper_y << " lower y: " << m_lower_y << endl;
  //show contacts and in or out of state
  m_msgs << "============================================ \n";
  m_msgs << "In Zone: " << m_in_zone << endl;
  m_msgs << "Contacts:" << endl;
  map<std::string, NodeRecord>::const_iterator p;
  for(p=m_map_node_records.begin(); p!=m_map_node_records.end();p++){
    std::string contact_name = p->first;
    NodeRecord node_record = p->second;
    std::string x = doubleToString(node_record.getX());
    std::string y = doubleToString(node_record.getY());

    m_msgs << contact_name << " x: " << x << " y: " << y << endl;
  }
  map<std::string, double>::const_iterator q;
  for(q=m_map_quad.begin();q!=m_map_quad.end();q++){
    std::string contact_name = q->first;
    double quadrant = q->second;
    std::string quad = doubleToString(quadrant);
    m_msgs<< contact_name << " quadrant: " << quad << endl;
  }
  
  return(true);
}

//---------------------------------------------------------
// Procedure: handleUpperY

bool FieldSensor::handleUpperY(std::string orig)
{
  //expecting float 
  m_upper_y = std::stod(orig);
  return true;
}

//---------------------------------------------------------
// Procedure: handleLowerY

bool FieldSensor::handleLowerY(std::string orig)
{
  //expecting a float
  m_lower_y = std::stod(orig);
 return true;
}

//---------------------------------------------------------
// Procedure: handleLeftX

bool FieldSensor::handleLeftX(std::string value)
{
  m_left_x = std::stod(value);

  return true;
}

//---------------------------------------------------------
// Procedure: handleRightX

bool FieldSensor::handleRightX(std::string report)
{
  m_right_x = std::stod(report);
  return true;
}


//----------------------------------------------------------
// Procedure: handleNodeRecord

void FieldSensor::handleMailNodeReport(std::string report)
{
  NodeRecord new_node_record = string2NodeRecord(report, true);

  //if incoming node matches own ship, we just ignore it
  std::string vname = new_node_record.getName();

  //  if(vname == m_ownship)
  //   return;

  m_map_node_records[vname] = new_node_record;
}
