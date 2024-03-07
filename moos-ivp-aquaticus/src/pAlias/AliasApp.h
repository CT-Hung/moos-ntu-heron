/************************************************************/
/*    NAME: Mike Benjamin                                   */
/*    ORGN: MIT, Cambridge MA                               */
/*    FILE: AliasApp.h                                      */
/*    DATE: September 28th, 2023                            */
/************************************************************/

#ifndef ALIAS_APP_HEADER
#define ALIAS_APP_HEADER

#include <map>
#include <string>
#include "MOOS/libMOOS/Thirdparty/AppCasting/AppCastingMOOSApp.h"

#include "VarDataPair.h"

class AliasApp : public AppCastingMOOSApp
{
public:
  AliasApp();
  ~AliasApp() {};
  
protected: // Standard MOOSApp functions to overload  
  bool OnNewMail(MOOSMSG_LIST &NewMail);
  bool Iterate();
  bool OnConnectToServer();
  bool OnStartUp();
  
protected: // Standard AppCastingMOOSApp function to overload 
  bool buildReport();
  bool handleConfigAlias(std::string);
  bool handleMailXAlias(std::string);

  bool postFlag(const VarDataPair&); 
  std::string expandMacros(std::string);
  
protected:
  void registerVariables();
  
 private: // Configuration variables
  
  std::map<std::string, std::vector<VarDataPair> > m_map_aliases;
  
private: // State variables
};

#endif 
