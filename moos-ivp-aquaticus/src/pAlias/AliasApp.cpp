/************************************************************/
/*    NAME: Mike Benjamin                                   */
/*    ORGN: MIT, Cambridge MA                               */
/*    FILE: AliasApp.cpp                                    */
/*    DATE: December 29th, 1963                             */
/************************************************************/

#include <iterator>
#include "MBUtils.h"
#include "ACTable.h"
#include "AliasApp.h"
#include "VarDataPairUtils.h"

using namespace std;

//---------------------------------------------------------
// Constructor()

AliasApp::AliasApp()
{
}

//---------------------------------------------------------
// Procedure: OnNewMail()

bool AliasApp::OnNewMail(MOOSMSG_LIST &NewMail)
{
  AppCastingMOOSApp::OnNewMail(NewMail);

  MOOSMSG_LIST::iterator p;
  for(p=NewMail.begin(); p!=NewMail.end(); p++) {
    CMOOSMsg &msg = *p;
    string key    = msg.GetKey();
    string sval  = msg.GetString(); 
    string msrc  = msg.GetSource();
    string maux  = msg.GetSourceAux();

#if 0 // Keep these around just for template
    string comm  = msg.GetCommunity();
    double dval  = msg.GetDouble();
    double mtime = msg.GetTime();
    bool   mdbl  = msg.IsDouble();
    bool   mstr  = msg.IsString();
#endif

    if(key == "XALIAS") 
      handleMailXAlias(sval);
    
     else if(key != "APPCAST_REQ") // handled by AppCastingMOOSApp
       reportRunWarning("Unhandled Mail: " + key);
   }
	
   return(true);
}

//---------------------------------------------------------
// Procedure: OnConnectToServer()

bool AliasApp::OnConnectToServer()
{
   registerVariables();
   return(true);
}

//---------------------------------------------------------
// Procedure: Iterate()

bool AliasApp::Iterate()
{
  AppCastingMOOSApp::Iterate();

  AppCastingMOOSApp::PostReport();
  return(true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()

bool AliasApp::OnStartUp()
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
    if(param == "alias") 
      handled = handleConfigAlias(value);

    if(!handled)
      reportUnhandledConfigWarning(orig);

  }
  
  registerVariables();	
  return(true);
}

//---------------------------------------------------------
// Procedure: registerVariables()

void AliasApp::registerVariables()
{
  AppCastingMOOSApp::RegisterVariables();
  Register("XALIAS", 0);
}

//---------------------------------------------------------
// Procedure: handleConfigAlias()

bool AliasApp::handleConfigAlias(string alias_entry)
{
  string alias = biteStringX(alias_entry, '#');
  string pair_str = alias_entry;
  
  VarDataPair pair;
  bool ok = setVarDataPairOnString(pair, pair_str);
  if(!ok)
    return(false);

  // ToDo: Check for duplicate entries
  m_map_aliases[alias].push_back(pair);
  return(true);
}


//---------------------------------------------------------
// Procedure: handleMailXAlias()

bool AliasApp::handleMailXAlias(string alias)
{
  if(m_map_aliases.count(alias) == 0)
    return(false);

  vector<VarDataPair> pairs = m_map_aliases[alias];
  for(unsigned int i=0; i<pairs.size(); i++ ) {
    postFlag(pairs[i]);
  }
  return(true);
}

  
//---------------------------------------------------------
// Procedure: postFlag()

bool AliasApp::postFlag(const VarDataPair& flag)
{

  // Get the variable name and initialize the sdata/ddata fields. A
  // non-empty-string sdata will mean this is a string posting
  string var = flag.get_var();
  string sdata;
  double ddata = 0;
  
  // Detect if posting is a stand-alone macro. If it is,
  // and it expands to a numerical value, post it as a number not a
  // string.

  if(flag.is_solo_macro()) {
    string tmp_sdata = flag.get_sdata();
    tmp_sdata = expandMacros(tmp_sdata);
    if(isNumber(tmp_sdata))
      ddata = atof(tmp_sdata.c_str());
    else
      sdata = tmp_sdata;
  }
  else if(flag.is_string()) {
    sdata = flag.get_sdata();
    sdata = expandMacros(sdata);
  }
  else
    ddata = flag.get_ddata();

  if(sdata != "")
    Notify(var, sdata);
  else
    Notify(var, ddata);

  return(true);
}
  
//------------------------------------------------------------
// Procedure: expandMacros()

string AliasApp::expandMacros(string str) 
{
  return(str);
}

//------------------------------------------------------------
// Procedure: buildReport()

bool AliasApp::buildReport() 
{
  m_msgs << "Total Aliases: " << m_map_aliases.size() << endl;
    
  ACTable actab(3);
  actab << "Alias | Num | Posting ";
  actab.addHeaderLines();

  map<string, vector<VarDataPair> >::iterator p;
  for(p=m_map_aliases.begin(); p!=m_map_aliases.end(); p++) {
    string alias = p->first;
    vector<VarDataPair> pairs = p->second;
    string num = uintToString(pairs.size());
    string pair1_str = "none/err";
    if(pairs.size() > 0) {
      VarDataPair pair1 = pairs[0];
      pair1_str = pair1.getPrintable();
    }
    actab << alias << num << pair1_str;
  }
  m_msgs << actab.getFormattedString();

  return(true);
}




