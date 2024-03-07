#--------------------------------------------------------
# The CMakeLists.txt for:                       pFieldSensor
# Author(s):                              
#--------------------------------------------------------

SET(SRC
  FieldSensor.cpp
  FieldSensor_Info.cpp
  main.cpp
)

ADD_EXECUTABLE(pFieldSensor ${SRC})

TARGET_LINK_LIBRARIES(pFieldSensor
  ${MOOS_LIBRARIES}
  geometry
  contacts
   apputil
   mbutil
   geometry
   contacts
   m
   pthread)

