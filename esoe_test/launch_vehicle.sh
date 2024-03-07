#!/bin/bash -e
#---------------------------------------------------------
# File: launch_vehicle.sh
# Name: Mike Benjamin
# Date: May 8th, 2019
# Note: Goal of general pavilion vehicle launch script
#---------------------------------------------------------
#  Part 1: Initialize configurable variables with defaults
#---------------------------------------------------------
TIME_WARP=1
JUST_MAKE="no"
HELP="no"
SIM="false"
INDEX=0
STARTPOS="0,0,180"
RETURN_POS="5,0"
INTERACTIVE="true"

# The Shore IP is MIT Pavilion shore computer. 
# The pShare port is by convention always 9200.
SHORE_IPADDR=192.168.0.85  
SHORE_PSHARE=9200

M200_IP=192.168.0.101
VNAME=ntu
BOT_PSHARE="9201"
BOT_MOOSDB="9001"

#---------------------------------------------------------
#  Part 2: Check for and handle command-line arguments
#---------------------------------------------------------
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
	HELP="yes"
    elif [ "${ARGI//[^0-9]/}" = "$ARGI" -a "$TIME_WARP" = 1 ]; then
        TIME_WARP=$ARGI
    elif [ "${ARGI}" = "--just_make" -o "${ARGI}" = "-j" ] ; then
        JUST_MAKE="yes"
    elif [ "${ARGI}" = "--sim" -o "${ARGI}" = "-s" ] ; then
        SIM="true"
    elif [ "${ARGI}" = "--noui" ] ; then
        INTERACTIVE="false"
    elif [ "${ARGI:0:12}" = "--start_pos=" ] ; then
        START_POS="${ARGI#--start_pos=*}"
    elif [ "${ARGI:0:10}" = "--shoreip=" ] ; then
        SHORE_IPADDR="${ARGI#--shoreip=*}"
    elif [ "${ARGI:0:10}" = "--shoreps=" ] ; then
        SHORE_PSHARE="${ARGI#--shoreps=*}"
    else
        echo "Bad arg:" $ARGI "Run with -h for help. Exiting (1)."
        exit 1
    fi
done

#---------------------------------------------------------
#  Part 3: Produce the help message if it was requested
#---------------------------------------------------------
if [ ${HELP} = "yes" ] ; then
    echo "$0 [SWITCHES] [WARP]"
    echo "  --help, -h         Show this help message            "        
    echo "  --just_make, -j    Just make targ files, dont launch "
    echo "  --sim, -s          Simulation mode                   "
    echo "  --noui             Non-interactive, no uMAC launched "
    echo "  --shoreip=<addr>   Try IP address for shoreside      "
    echo "  --shoreps=<addr>   Try shoreside pshare port (Def 9200) "
    echo "  --startpos=<pos>   For example 10,10,90  "
    exit 0;
fi

#---------------------------------------------------------
#  Part 4: Handle Ill-formed command-line arguments
#---------------------------------------------------------
if [ ${SIM} = "false" -a ! "$TIME_WARP" = 1 ] ; then
    echo "Time Warp must be 1 unless in sim mode. Exiting (2)."
    exit 2
fi
    

#---------------------------------------------------------
#  Part 5: Build out key shell vars based on vehicle index
#---------------------------------------------------------

#---------------------------------------------------------
#  Part 6: Create the .moos and .bhv files.
#    Note: Failed nsplug will abort launch due to bash -e on line 1
#    Note: Undef macros will be aletered to user with nsplug -i flag
#---------------------------------------------------------
nsplug meta_vehicle.moos targ_${VNAME}.moos -f -i              \
       WARP=$TIME_WARP             VNAME=$VNAME                \
       BOT_PSHARE=$BOT_PSHARE      SHORE_PSHARE=$SHORE_PSHARE  \
       BOT_MOOSDB=$BOT_MOOSDB      SHORE_IPADDR=$SHORE_IPADDR  \
       START_POS=$START_POS        HOSTIP_FORCE="localhost"    \
       M200_IP=$M200_IP            SIM=$SIM          

nsplug meta_vehicle.bhv targ_${VNAME}.bhv -f -i \
       RETURN_POS=${RETURN_POS}


#---------------------------------------------------------
#  Part 7: Possibly exit now if we're just building targ files
#---------------------------------------------------------
if [ ${JUST_MAKE} = "yes" ] ; then
    echo "Files assembled; vehicle not launched; exiting per request."
    echo "  Local variable set: "
    echo "                 SIM:"$SIM
    echo "             M200_IP:"$M200_IP
    echo "        Vehicle name:"$VNAME
    echo " Vehicle MOOSDB Port:"$BOT_MOOSDB
    echo " Vehicle pshare port:"$BOT_PSHARE
    echo "     Try Shoresie IP:"$SHORE_IPADDR
    echo "Note: If you were trying to launch Jing, use -J (not -j)"
    exit 0
fi

#---------------------------------------------------------
#  Part 8: Launch the processes
#---------------------------------------------------------

echo "Launching $VNAME MOOS Community "
pAntler targ_${VNAME}.moos >& /dev/null &

if [ "${INTERACTIVE}" = "true" ] ; then
    uMAC targ_${VNAME}.moos
    echo "Killing all processes ..."
    kill -- -$$
    echo "Done killing processes."
fi

