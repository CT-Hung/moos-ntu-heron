/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: RoleChooser.h                                          */
/*    DATE: December 29th, 1963                             */
/************************************************************/

#ifndef RoleChooser_HEADER
#define RoleChooser_HEADER

#include "MOOS/libMOOS/Thirdparty/AppCasting/AppCastingMOOSApp.h"
#include <time.h>

class RoleChooser : public AppCastingMOOSApp
{
 public:
   RoleChooser();
   ~RoleChooser();

 protected: // Standard MOOSApp functions to overload  
   bool OnNewMail(MOOSMSG_LIST &NewMail);
   bool Iterate();
   bool OnConnectToServer();
   bool OnStartUp();

 protected: // Standard AppCastingMOOSApp function to overload 
   bool buildReport();

 protected:
   void registerVariables();
  bool handleOverrideTimer(std::string value);

 private: // Configuration variables

 private: // State variables
  float m_override_timer;
  std::string m_ownship_role;
  std::string m_audio_to_play;

  bool m_ownship_tagged;
  bool m_teammate_tagged;
  bool m_teammate_w_flag;
  int  m_blue_one_quad;
  int  m_ownship_quad;
  int  m_red_one_quad;
  int  m_red_two_quad;
  bool m_red_one_w_flag;
  bool m_red_two_w_flag;
  float m_override_timer_interval;
  bool m_override_timer_active;
  time_t m_override_timer_activated_wall_time;
  double m_override_timer_elapse;
};

#endif 
