/************************************************************/
/*    NAME: Mike Benjamin                                   */
/*    ORGN: MIT, Cambridge MA                               */
/*    FILE: OpField.cpp                                     */
/*    DATE: September 25th, 2023                            */
/************************************************************/

#include <iterator>
#include "MBUtils.h"
#include "OpField.h"

using namespace std;

//---------------------------------------------------------
// Constructor()

OpField::OpField()
{
}

//---------------------------------------------------------
// Procedure: getPtAliases()

vector<string> OpField::getPtAliases() const
{
  vector<string> svector;
  map<string,XYPoint>::const_iterator p;
  for(p=m_map_pts.begin(); p!= m_map_pts.end(); p++)
    svector.push_back(p->first);
  
  return(svector);
}

//---------------------------------------------------------
// Procedure: getPoint()

XYPoint OpField::getPoint(string alias) const
{
  XYPoint null_pt;
  
  map<string,XYPoint>::const_iterator p = m_map_pts.find(alias);

  if(p == m_map_pts.end())
    return(null_pt);

  return(p->second);
}

//---------------------------------------------------------
// Procedure: getColor()

string OpField::getColor(string alias) const
{
  map<string,string>::const_iterator p = m_map_colors.find(alias);
  if(p == m_map_colors.end())
    return("");

  return(p->second);
}

//---------------------------------------------------------
// Procedure: size()

unsigned int OpField::size() const
{
  return(ptSize() + polySize() + seglSize());
}

//---------------------------------------------------------
// Procedure: config()
// Examples:  sw=0,0 # se=100,0 # ne=100,100 # nw=0,100
//            redzone=pts={0,0:10,0:5,5} # nw=160,0

bool OpField::config(string str)
{
  bool all_ok = true;
  if(isQuoted(str))
    str = stripQuotes(str);
  
  vector<string> svector = parseString(str, '#');
  for(unsigned int i=0; i<svector.size(); i++) {
    string entry = svector[i];

    string alias = biteStringX(entry,'=');
    string value = entry;

    cout << "alias=" << alias << endl;
    cout << "value=" << value << endl;

    if(isColor(value)) 
      m_map_colors[alias] = value;
    else {
      bool ok = addPoint(alias, value);
      cout << "ok=" << boolToString(ok) << endl;
      if(!ok)
	all_ok = false;
    }
  }
  return(all_ok);
}


//---------------------------------------------------------
// Procedure: addPoint()
// Examples:  sw=0,0 
//            foo=2,3    

bool OpField::addPoint(string alias, string ptstr)
{
  ptstr = findReplace(ptstr, "x=", "");
  ptstr = findReplace(ptstr, "y=", "");
  
  string x = biteStringX(ptstr, ',');
  string y = ptstr;
  if((alias == "") || !isNumber(x) || !isNumber(y)) 
    return(false);

  double xval = atof(x.c_str());
  double yval = atof(y.c_str());
  XYPoint pt(xval,yval);
  m_map_pts[alias] = pt;

  return(true);
}
