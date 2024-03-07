#--------------------------------------------------------
# The CMakeLists.txt for:              pAquaticusStateMgr
# Author(s):  Kevin Becker, Adapted from Michael Novitzky
#--------------------------------------------------------

SET(SRC
  AquaticusStateMgr.cpp
  AquaticusStateMgr_Info.cpp
  main.cpp
)

ADD_EXECUTABLE(pAquaticusStateMgr ${SRC})

TARGET_LINK_LIBRARIES(pAquaticusStateMgr
  ${MOOS_LIBRARIES}
  geometry
  contacts
   apputil
   mbutil
   geometry
   contacts
   m
   pthread)

