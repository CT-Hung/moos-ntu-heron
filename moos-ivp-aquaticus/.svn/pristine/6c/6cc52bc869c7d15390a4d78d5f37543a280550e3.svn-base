#!/bin/bash
#---------------------------------------------------------------
#   Script: launch.sh
#  Mission: a1_aquaticus
#   Author: Mike Benjamin
#   LastEd: Oct 2023
#-------------------------------------------------------------- 
#  Part 1: Define a convenience function for producing terminal
#          debugging/status output depending on the verbosity.
#-------------------------------------------------------------- 
vecho() { if [ "$VERBOSE" != "" ]; then echo "$ME: $1"; fi }

#---------------------------------------------------------------
#  Part 2: Set global var defaults
#---------------------------------------------------------------
ME=`basename "$0"`
GRN=$(tput setaf 2) # Green 
NC=$(tput setaf 0)  # Reset

TIME_WARP=1
JUST_MAKE="no"
VERBOSE=""
AUTO_LAUNCHED="no"
CMD_ARGS=""

IP_ADDR="localhost"
MOOS_PORT="9001"
PSHARE_PORT="9201"

SHORE_IP="localhost"
SHORE_PSHARE="9200"
VNAME="abe"
INDEX="1"
XMODE="M300"
VTEAM="red"
LCLOCK="false"

./jerop.sh > region_info.txt
source region_info.txt

SPEED=1
MAXSPD=2
START_POS=""
RETURN_POS=""
LOITER_POS="x=100,y=-180"
GRAB_POS=""
UNTAG_POS=""
DEFEND_POS=""

#-------------------------------------------------------
#  Part 3: Check for and handle command-line arguments
#-------------------------------------------------------
for ARGI; do
    CMD_ARGS+="${ARGI} "
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
	echo "$ME [OPTIONS] [time_warp]                        "
	echo "                                                 " 
	echo "Options:                                         "
	echo "  --help, -h                                     " 
	echo "    Print this help message and exit             "
	echo "  --just_make, -j                                " 
	echo "    Just make targ files, but do not launch      "
	echo "  --verbose, -v                                  " 
	echo "    Verbose output, confirm before launching     "
	echo "                                                 "
	echo "  --ip=<localhost>                               " 
	echo "    Force pHostInfo to use this IP Address       "
	echo "  --mport=<9001>                                 "
	echo "    Port number of this vehicle's MOOSDB port    "
	echo "  --pshare=<9201>                                " 
	echo "    Port number of this vehicle's pShare port    "
	echo "                                                 "
	echo "  --shore=<localhost>                            " 
	echo "    IP address location of shoreside             "
	echo "    Shortcut: --sip same as --shore=192.168.1.37 "
	echo "  --shore_pshare=<9200>                          " 
	echo "    Port on which shoreside pShare is listening  "
	echo "  --vname=<abe>                                  " 
	echo "    Name of the vehicle being launched           " 
	echo "  --vteam=<red>                                  "
	echo "    Set team name {red,blue}                     "
	echo "                                                 "
	echo "  --start=<X,Y,H>                                " 
	echo "    Start position chosen by script launching    "
	echo "    this script (to ensure separation)           "
	echo "  --speed=meters/sec                             " 
	echo "    The speed use for transiting/loitering       "
	echo "  --maxspd=meters/sec                            " 
	echo "    Max speed of vehicle (for sim and in-field)  "
	echo "                                                 "
	
	echo "  --logclean, -l    Clean logs before launching  "
	echo "  --sim, -s         Sim mode (XMODE=sim)         "
	exit 0;
    elif [ "${ARGI//[^0-9]/}" = "$ARGI" -a "$TIME_WARP" = 1 ]; then
        TIME_WARP=$ARGI
    elif [ "${ARGI}" = "--just_make" -o "${ARGI}" = "-j" ]; then
	JUST_MAKE="yes"
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
        VERBOSE="yes"
    elif [ "${ARGI}" = "--auto" -o "${ARGI}" = "-a" ]; then
        AUTO_LAUNCHED="yes" 
    elif [ "${ARGI}" = "--logclean" -o "${ARGI}" = "-l" ]; then
	LOG_CLEAN="yes"

    elif [ "${ARGI:0:5}" = "--ip=" ]; then
        IP_ADDR="${ARGI#--ip=*}"
    elif [ "${ARGI:0:7}" = "--mport" ]; then
	MOOS_PORT="${ARGI#--mport=*}"
    elif [ "${ARGI:0:9}" = "--pshare=" ]; then
        PSHARE_PORT="${ARGI#--pshare=*}"

    elif [ "${ARGI:0:8}" = "--shore=" ]; then
        SHORE_IP="${ARGI#--shore=*}"
    elif [ "${ARGI}" = "--sip" -o "${ARGI}" = "-sip" ]; then
	SHORE_IP="192.168.1.37"
    elif [ "${ARGI:0:15}" = "--shore_pshare=" ]; then
        SHORE_PSHARE="${ARGI#--shore_pshare=*}"
    elif [ "${ARGI:0:8}" = "--vname=" ]; then
        VNAME="${ARGI#--vname=*}"
    elif [ "${ARGI:0:8}" = "--vteam=" ]; then
        VTEAM="${ARGI#--vteam=*}"
    elif [ "${ARGI:0:8}" = "--color=" ]; then
        COLOR="${ARGI#--color=*}"
    elif [ "${ARGI:0:8}" = "--index=" ]; then
        INDEX="${ARGI#--index=*}"

    elif [ "${ARGI:0:9}" = "--region=" ]; then
        REGION="${ARGI#--region=*}"
    elif [ "${ARGI:0:5}" = "--bh=" ]; then
        BH="${ARGI#--bh=*}"
    elif [ "${ARGI:0:5}" = "--rh=" ]; then
        BH="${ARGI#--rh=*}"
	
    elif [ "${ARGI:0:8}" = "--start=" ]; then
        START_POS="${ARGI#--start=*}"
    elif [ "${ARGI:0:8}" = "--speed=" ]; then
        SPEED="${ARGI#--speed=*}"
    elif [ "${ARGI:0:9}" = "--maxspd=" ]; then
        MAXSPD="${ARGI#--maxspd=*}"
	
    elif [ "${ARGI}" = "--lclock" -o "${ARGI}" = "-l" ] ; then
        LCLOCK="true"

    elif [ "${ARGI}" = "--sim" -o "${ARGI}" = "-s" ] ; then
        XMODE="SIM"
        echo "Simulation mode ON."
    else
	echo "$ME: Bad Arg:[$ARGI]. Exit Code 1."
	exit 1
    fi
done

if [ "${XMODE}" = "sim" -a "$TIME_WARP" != 1 ]; then
    echo "WARP other than 1 can only be used in sim. Exit code 2."
    exit 2
fi

#--------------------------------------------------------------
#  Part 3A: If Heron hardware, set key info based on IP address
#--------------------------------------------------------------
if [ "${XMODE}" = "M300" ]; then
    COLOR=`get_heron_info.sh --color --hint=$COLOR`
    IP_ADDR=`get_heron_info.sh --ip`
    FSEAT_IP=`get_heron_info.sh --fseat`
    VNAME=`get_heron_info.sh --name`
    if [ $? != 0 ]; then
	echo "$ME: Problem getting Heron Info. Exit Code 3"
	exit 3
    fi
fi
     
    
#-------------------------------------------------------
# Part 3B: Set Team specific parameters
#-------------------------------------------------------
if [ "${VTEAM}" = "red" ]; then
    GRAB_POS=$BFT
    RETURN_POS=$RFT
    UNTAG_POS=$RFT     
    DEFEND_POS=$NCM
    HFLD=$HOME_IS_NORTH
elif [ "${VTEAM}" = "blue" ]; then
    GRAB_POS=$RFT
    RETURN_POS=$BFT
    UNTAG_POS=$BFT 
    DEFEND_POS=$SCM 
    HFLD=$HOME_IS_SOUTH
else
    echo "Bad or no vehicle team: [${VTEAM}]";
    exit 4
fi


#---------------------------------------------------------------
#  Part 4: If verbose, show vars and confirm before launching
#---------------------------------------------------------------
if [ "${VERBOSE}" != "" ]; then 
    echo "=================================="
    echo "   launch_vehicle.sh SUMMARY      "
    echo "=================================="
    echo "$ME"
    echo "CMD_ARGS =      [${CMD_ARGS}]     "
    echo "TIME_WARP =     [${TIME_WARP}]    "
    echo "AUTO_LAUNCHED = [${AUTO_LAUNCHED}]"
    echo "JUST_MAKE =     [${JUST_MAKE}]    "
    echo "LOG_CLEAN =     [${LOG_CLEAN}]    "
    echo "----------------------------------"
    echo "IP_ADDR =       [${IP_ADDR}]      "
    echo "MOOS_PORT =     [${MOOS_PORT}]    "
    echo "PSHARE_PORT =   [${PSHARE_PORT}]  "
    echo "----------------------------------"
    echo "SHORE_IP =      [${SHORE_IP}]     "
    echo "SHORE_PSHARE =  [${SHORE_PSHARE}] "
    echo "VNAME =         [${VNAME}]        "
    echo "VTEAM =         [${VTEAM}]        "
    echo "COLOR =         [${COLOR}]        "
    echo "----------------------------------"
    echo "XMODE =         [${XMODE}]        "
    echo "FSEAT_IP =      [${FSEAT_IP}]     "
    echo "REGION =        [${REGION}]       "
    echo "WANG =          [${WANG}]         "
    echo "DANG =          [${DANG}]         "
    echo "RED_ZONE =      [${RED_ZONE}]     "
    echo "BLUE_ZONE =     [${BLUE_ZONE}]    "
    echo "----------------------------------"
    echo "START_POS =     [${START_POS}]    "
    echo "SPEED =         [${SPEED}]        "
    echo "MAXSPD =        [${MAXSPD}]       "
    echo "----------------------------------"
    echo "GRAB_POS =      [${GRAB_POS}]     "
    echo "RETURN_POS =    [${RETURN_POS}]   "
    echo "UNTAG_POS =     [${UNTAG_POS}]    "
    echo "DEFEND_POS =    [${DEFEND_POS}]   "
    echo -n "Hit any key to continue with launching ${VNAME}"
    read ANSWER
fi


#-------------------------------------------------------
#  Part 4: Create the .moos and .bhv files.
#-------------------------------------------------------
NSFLAGS="-s -f"
if [ "${AUTO}" = "" ]; then
    NSFLAGS="-i -f"
fi

nsplug meta_vehicle.moos targ_${VNAME}.moos $NSFLAGS WARP=$TIME_WARP \
       PSHARE_PORT=$PSHARE_PORT     VNAME=$VNAME           \
       IP_ADDR=$IP_ADDR             SHORE_IP=$SHORE_IP     \
       SHORE_PSHARE=$SHORE_PSHARE   MOOS_PORT=$MOOS_PORT   \
       FSEAT_IP=$FSEAT_IP           XMODE=$XMODE           \
       MAXSPD=$MAXSPD               START_POS=$START_POS   \
       COLOR=$COLOR                 REGION=$REGION         \
       VTYPE="kayak"                $HFLD                  \
       VTEAM=$VTEAM                 $FLDS
    
printf "Assembling BHV file targ_${VNAME}.bhv\n"
nsplug meta_vehicle.bhv targ_${VNAME}.bhv $NSFLAGS $FLDS\
       RETURN_POS=${RETURN_POS}     VTEAM=$VTEAM   \
       TRAIL_RANGE=$TRAIL_RANGE     VNAME=$VNAME   \
       TRAIL_ANGLE=$TRAIL_ANGLE     LCLOCK=$LCLOCK \
       GRAB_POS=$GRAB_POS           DANG=$DANG     \
       DEFEND_POS=$DEFEND_POS       WANG=$WANG     \
       DANGX=$DANGX                 WANGX=$WANGX   \
       UNTAG_POS=$UNTAG_POS         $HFLD

if [ ! -e targ_${VNAME}.moos ]; then
    echo "no targ_${VNAME}.moos";
    exit 5;
fi
if [ ! -e targ_${VNAME}.bhv ]; then
    echo "no targ_${VNAME}.bhv";
    exit 6;
fi

if [ ${JUST_MAKE} = "yes" ] ; then
    echo "Files assembled; nothing launched; exiting per request."
    exit 0
fi

#--------------------------------------------------------------
#  Part 6: Launch the processes
#--------------------------------------------------------------

echo "$GRN Launching $VNAME MOOS Community. WARP=$TIME_WARP $NC"
pAntler targ_${VNAME}.moos >& /dev/null &
echo "$GRN Done Launching $VNAME MOOS Community $NC"

#---------------------------------------------------------------
#  Part 7: If launched from script, we're done, exit now
#---------------------------------------------------------------
if [ "${AUTO_LAUNCHED}" = "yes" ]; then
    exit 0
fi

#---------------------------------------------------------------
# Part 8: Launch uMAC until the mission is quit
#---------------------------------------------------------------
uMAC targ_$VNAME.moos
kill -- -$$
