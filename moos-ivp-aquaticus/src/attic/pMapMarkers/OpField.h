/************************************************************/
/*    NAME: Mike Benjamin                                   */
/*    ORGN: MIT, Cambridge MA                               */
/*    FILE: OpField.h                                       */
/*    DATE: Sep 25th, 2023                                  */
/************************************************************/

#ifndef OP_FIELD_HEADER
#define OP_FIELD_HEADER

#include <string> 
#include <map>
#include "XYPoint.h"
#include "XYPolygon.h"
#include "XYSegList.h"

class OpField
{
public:
  OpField() ;
  ~OpField() {};

public: 
  bool config(std::string);

  std::vector<std::string> getPtAliases() const;
  XYPoint getPoint(std::string alias) const;
  std::string getColor(std::string alias) const;
  
  unsigned int size() const;
  unsigned int ptSize() const {return(m_map_pts.size());}
  unsigned int polySize() const {return(m_map_polys.size());}
  unsigned int seglSize() const {return(m_map_segls.size());}

protected:
  bool addPoint(std::string alias, std::string point);
  
private: 
  std::map<std::string, XYPoint>   m_map_pts;
  std::map<std::string, XYPolygon> m_map_polys;
  std::map<std::string, XYSegList> m_map_segls;

  std::map<std::string, std::string> m_map_colors;

};

#endif 
