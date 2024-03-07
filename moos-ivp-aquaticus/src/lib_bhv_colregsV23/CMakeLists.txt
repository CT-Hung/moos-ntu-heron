#--------------------------------------------------------
# The CMakeLists.txt for:              lib_bhv_colregsV23
# Author(s):                                Mike Benjamin     
#--------------------------------------------------------
#                                       BHV_AvdColregsV23
#--------------------------------------------------------
ADD_LIBRARY(BHV_AvdColregsV23 SHARED 
  BHV_AvdColregsV23.cpp
  AOF_CPA.cpp
  AOF_R13.cpp
  AOF_R14.cpp
  AOF_R16.cpp
  AOF_R17.cpp
  VelocityFilter.cpp
  )
TARGET_LINK_LIBRARIES(BHV_AvdColregsV23
   helmivp
   behaviors 
   ivpbuild
   contacts
   logic 
   ivpcore 
   bhvutil 
   mbutil 
   geometry 
)

