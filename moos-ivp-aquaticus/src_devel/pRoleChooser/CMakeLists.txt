#--------------------------------------------------------
# The CMakeLists.txt for:                       pRoleChooser
# Author(s):                              
#--------------------------------------------------------

SET(SRC
  RoleChooser.cpp
  RoleChooser_Info.cpp
  main.cpp
)

ADD_EXECUTABLE(pRoleChooser ${SRC})

TARGET_LINK_LIBRARIES(pRoleChooser
   ${MOOS_LIBRARIES}
   apputil
   mbutil
   m
   pthread)

