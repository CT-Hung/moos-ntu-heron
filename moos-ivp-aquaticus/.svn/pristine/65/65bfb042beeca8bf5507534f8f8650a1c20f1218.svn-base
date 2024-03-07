/************************************************************/
/*    NAME:                                                 */
/*    ORGN: MIT                                             */
/*    FILE: RoleChooser.cpp                                 */
/*    DATE:                                                 */
/************************************************************/

#include <iterator>
#include "MBUtils.h"
#include "ACTable.h"
#include "RoleChooser.h"
#include "NodeMessage.h"

using namespace std;

//---------------------------------------------------------
// Constructor

RoleChooser::RoleChooser()
{
  m_ownship_role = "DEFEND";
  m_audio_to_play = "";
  m_override_timer_interval = 10.0; //seconds
  m_override_timer_active = false;
  m_override_timer_elapse = 0.0;
  m_ownship_tagged = false;
  m_teammate_tagged = false;
  m_teammate_w_flag = false;
  m_blue_one_quad = 0;
  m_ownship_quad = 0;
  m_red_one_quad = 0;
  m_red_two_quad = 0;
  m_red_one_w_flag = false;
  m_red_two_w_flag = false;
}

//---------------------------------------------------------
// Destructor

RoleChooser::~RoleChooser()
{
}

//---------------------------------------------------------
// Procedure: OnNewMail

bool RoleChooser::OnNewMail(MOOSMSG_LIST &NewMail)
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
     else if(key=="TAGGED"){
       std::string sval = msg.GetString();
       if(sval =="TRUE" || sval == "true"){
	   m_ownship_tagged = true;
	 }
       else{
	 m_ownship_tagged = false;
       }
     }
     else if(key=="LED_TAGGED_BLUE_ONE"){
       std::string sval = msg.GetString();
       if(sval == "TRUE"){
         m_teammate_tagged = true;
       }
       else if(sval =="FALSE"){
         m_teammate_tagged = false;
       }
     }
     else if(key=="LED_HAVE_FLAG_BLUE_ONE"){
       std::string sval = msg.GetString();
       if(sval == "TRUE"){
	 m_teammate_w_flag = true;
       }
       else {
	 m_teammate_w_flag = false;
       }
     }
     else if(key=="blue_one_quadrant"){
       double dval = msg.GetDouble();
       int quad =dval;
       m_blue_one_quad = quad;
     }
     else if(key=="blue_two_quadrant"){
       double dval = msg.GetDouble();
       int quad = dval ;
       m_ownship_quad = quad;
     }
     else if(key=="red_one_quadrant"){
       double dval = msg.GetDouble();
       int quad = dval;
       m_red_one_quad = quad;
     }
     else if(key=="red_two_quadrant"){
       double dval = msg.GetDouble();
       int quad = dval;
       m_red_two_quad = quad;
     }
     else if(key=="LED_HAVE_FLAG_RED_ONE"){
       std::string sval = msg.GetString();
       if(sval == "TRUE" || sval =="true") {
	 m_red_one_w_flag = true;
       }
       else {
	 m_red_one_w_flag = false;
       }
     }
     else if(key =="LED_HAVE_FLAG_RED_TWO"){
       std::string sval = msg.GetString();
       if(sval == "TRUE" || sval == "true") {
	 m_red_two_w_flag = true;
       }
       else {
	 m_red_two_w_flag = false;
       }
     }
     else if(key == "HUMAN_OVERRIDE") {
       std::string sval = msg.GetString();
       if(sval == "TRUE" ||  sval == "true"){
	 //role action button has been pushed by the human -- activate override timer
	 m_override_timer_active = true;
	 m_override_timer_elapse = 0.0;
	 //get time that message was received
	 time(&m_override_timer_activated_wall_time);
	 m_audio_to_play = "";
	 reportRunWarning("Override activated");

	 
       }
     }
  

     else if(key != "APPCAST_REQ") // handled by AppCastingMOOSApp
       reportRunWarning("Unhandled Mail: " + key);
   }
	
   return(true);
}

//---------------------------------------------------------
// Procedure: OnConnectToServer

bool RoleChooser::OnConnectToServer()
{
   registerVariables();
   return(true);
}

//---------------------------------------------------------
// Procedure: Iterate()
//            happens AppTick times per second

bool RoleChooser::Iterate()
{
  AppCastingMOOSApp::Iterate();
  // Do your thing here!
  std::string temp_role;
  std::string temp_audio;

  //did the human push the action override button? and now we are in time out?
  if(m_override_timer_active == true) {

    time_t  curr_time;
    time(&curr_time);
    double seconds_diff = difftime(curr_time, m_override_timer_activated_wall_time);
    if(seconds_diff > m_override_timer_interval){
      m_override_timer_active = false;
      m_override_timer_elapse = 0.0;
    }
    else {
      m_override_timer_elapse = seconds_diff;
    }

  }
  else if (m_ownship_tagged) {
    m_ownship_role = "UNTAGGING";
    Notify("TAGGED","true");
    //for consistency in AppCast output
    m_audio_to_play = "untagging.wav";
    
  }
 else {
  //Given the state of the field -- choose role for ownship
  //1.	If bot tagged – get untagged
  //Verbal Cue – “Blue 2 getting untagged.”
  //if(m_ownship_tagged) {
  //  Notify("TAGGED","true");
  //  m_ownship_role = "UNTAG";
  //}
  //2.	If user gets tagged, Blue 2 defends. 
  //Verbal Cue- “Blue 2 shifting to defense.”
  if(m_teammate_tagged){
    temp_role = "DEFEND";
    temp_audio = "blue_two_shifting_to_defense.wav";
  }
  //3.	If user grabs flag, Blue 2 covers.
  //Verbal Cue- “Blue 2 covering.”
  else if(m_teammate_w_flag){
    temp_role = "COVER";
    temp_audio = "blue_two_covering.wav";
  }
  //4.	If user in opponent side of field, Blue 2 defends.
  //Verbal Cue- “Blue 2 shifting to defense.”
  else if(m_blue_one_quad == 1 || m_blue_one_quad == 4){
    temp_role = "DEFEND";
    temp_audio = "blue_two_shfiting_to_defense.wav";
  }
  //5.	If both enemies are in one quadrant (anywhere on field), Blue 2 pursues //flag from different quadrant. (If in top 2 quadrants, pursue in bottom 2 qud//rants... If in bottom 2 quadrants pursue in top 2 quadrants)
  //Verbal Cue- “Blue 2 pursuing flag. Please defend.”
  else if(m_red_one_quad == m_red_two_quad) {
    if(m_red_one_quad == 1 || m_red_one_quad == 2) { //it means upper half of the field
      temp_role = "ATTACK_RIGHT";
      temp_audio = "blue_two_pursuing_the_flag_please_defend.wav";
    }
    else if(m_red_one_quad == 3 || m_red_one_quad == 4) { //it means lower half of the field
      temp_role = "ATTACK_LEFT";
      temp_audio = "blue_two_pursuing_the_flag_please_defend.wav";
    }
  }
  //7.	If red grabs flag and bot on own side of field, blue 2 pursues to tag f//lag carrier.
  //Verbal Cue- “Enemy has flag, Blue 2 in pursuit.”
  else if(m_red_one_w_flag || m_red_two_w_flag) {
    //to keep things moving and not reporting empty m_role and m_audio
    temp_role = m_ownship_role;
    temp_audio = m_audio_to_play;
      
    //check to see if bot on own side of the field
    if(m_ownship_quad == 2 || m_ownship_quad == 3) {
    temp_role = "DEFEND"; //MUST ATTACK FLAG CARRIER
    temp_audio = "enemy_has_the_flag_blue_2_in_pursuit.wav";
    //identify flag carrier and publish contact information
    std::string proper_form;
    proper_form = "contact=";
    if(m_red_one_w_flag == true) {
      proper_form += "red_one";
    }
    else if (m_red_two_w_flag == true) {
      proper_form += "red_two";
    }
    Notify("AGGRESSIVE", "TRUE");
    Notify("AGGRESSIVE_CONTACT", proper_form);
    Notify("CR_INTERCEPT_UPDATES", proper_form);
    }
  }

  //6.	If both enemies on bot’s own side of field, Blue 2 pursues flag.
  //Verbal Cue- “Blue 2 pursuing flag. Please defend.”
  else if((m_red_one_quad == 2 || m_red_one_quad == 3) && (m_red_two_quad == 2 || m_red_two_quad == 3)) {
    temp_role = "ATTACK";
    temp_audio = "blue_two_pursuing_the_flag_please_defend.wav";
  }
  //8.	Else defend
  else {
    temp_role = "DEFEND";
    temp_audio = "blue_two_defending";
  }

  if(m_audio_to_play != temp_audio) {
    m_audio_to_play = temp_audio;
    
    std::string to_send;
    to_send +="file=";
    to_send +=  m_audio_to_play;
    NodeMessage node_message;
    node_message.setSourceNode("blue_two");
    node_message.setDestNode("blue_one");
    node_message.setVarName("SAY_MOOS");
    node_message.setStringVal(to_send);

    std::string msg = node_message.getSpec();

    //NODE_MESSAGE_LOCAL = src_node=alpha,dest_node=bravo,var_name=INFO,string_val=good,bad,ugly
    Notify("NODE_MESSAGE_LOCAL",msg);

      m_ownship_role = temp_role;
  if(m_ownship_role == "DEFEND") {
    m_ownship_role = "PROTECT";
  }
  Notify("ACTION",m_ownship_role);

  }

 }
  AppCastingMOOSApp::PostReport();
  return(true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()
//            happens before connection is open

bool RoleChooser::OnStartUp()
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

    bool handled = false;
    if(param == "foo") {
      handled = true;
    }
    else if(param == "bar") {
      handled = true;
    }
    else if(param == "override_timer") {
      handled = handleOverrideTimer(line);
    }

    if(!handled)
      reportUnhandledConfigWarning(orig);

  }
  
  registerVariables();	
  return(true);
}

//---------------------------------------------------------
// Procedure: registerVariables

void RoleChooser::registerVariables()
{
  AppCastingMOOSApp::RegisterVariables();

  //ownship tagged?
  Register("TAGGED",0);

  //blue_one gets tagged?
  Register("LED_TAGGED_BLUE_ONE",0);
  

  //blue_one grabs flag
  Register("LED_HAVE_FLAG_BLUE_ONE",0);

  //everyone's quadrants
  Register("blue_one_quadrant",0);
  Register("blue_two_quadrant",0);
  Register("red_one_quadrant",0);
  Register("red_two_quadrant",0);
  
  //red team grabs flag
  Register("LED_HAVE_FLAG_RED_ONE",0);
  Register("LED_HAVE_FLAG_RED_TWO",0);

  //override from human buttons?
  Register("HUMAN_OVERRIDE", 0);
  
}


//------------------------------------------------------------
// Procedure: buildReport()

bool RoleChooser::buildReport() 
{
  
  m_msgs << "============================================ \n";
  m_msgs << "Ownship Role: " << m_ownship_role << endl;
  m_msgs << "============================================ \n";
  m_msgs << "Human Override Timer Interval: " << m_override_timer_interval << endl;
  m_msgs << "Human Override Timer Active ";
  if(m_override_timer_active == true) {
    m_msgs << " ON " ; }
  else {
    m_msgs << " OFF "; }
  m_msgs << endl;
  m_msgs << "Human Override Timer Elapse " << to_string(m_override_timer_elapse) << endl;
  m_msgs << "============================================\n";
  m_msgs << "Tag Status \n";
  m_msgs << "Blue One: " << m_teammate_tagged << endl;
  m_msgs << "Ownship/Blue Two: " << m_ownship_tagged << endl;
  m_msgs << "============================================ \n";
  m_msgs << "Flag Status \n";
  m_msgs << "Blue One: " << m_teammate_w_flag << endl;
  m_msgs << "Red one: " << m_red_one_w_flag << endl;
  m_msgs << "Red Two: " << m_red_two_w_flag << endl;
  m_msgs << "============================================ \n";
  m_msgs << "Vehicle Quadrants \n";
  m_msgs << "Blue One: " << m_blue_one_quad << endl;
  m_msgs << "Ownship/Blue Two: " << m_ownship_quad << endl;
  m_msgs << "Red one: " << m_red_one_quad << endl;
  m_msgs << "Red Two: " << m_red_two_quad << endl;
  
  return(true);
}


bool RoleChooser::handleOverrideTimer(std::string value)
{
  m_override_timer_interval = std::stod(value);
  return true;
}
