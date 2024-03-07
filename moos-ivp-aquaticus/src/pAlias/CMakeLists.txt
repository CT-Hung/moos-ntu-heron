#--------------------------------------------------------
# The CMakeLists.txt for:                          pAlias
# Author(s):                                Mike Benjamin
#--------------------------------------------------------

SET(SRC
  AliasApp.cpp
  Alias_Info.cpp
  main.cpp
)

ADD_EXECUTABLE(pAlias ${SRC})

TARGET_LINK_LIBRARIES(pAlias
   ${MOOS_LIBRARIES}
   apputil
   mbutil
   m
   pthread)

