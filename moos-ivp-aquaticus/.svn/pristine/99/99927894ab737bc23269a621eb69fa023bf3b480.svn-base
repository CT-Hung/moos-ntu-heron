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
TIME_WARP=1
JUST_MAKE=""
VERBOSE=""

REGION="pavlab"
CLEAN="no"
CMD_ARGS=""

ABE="no"
BEN="no"
CAL="no"
DEB="no"

RANDSTART="true"

VNAMES=""
VLAUNCH_ARGS=" --auto --region=$REGION --sim --vname=$VNAME1 --index=1 "
SLAUNCH_ARGS=" --auto --region=$REGION --sim "

./jerop.sh > region_info.txt
source region_info.txt

#---------------------------------------------------------------
#  Part 3: Check for and handle command-line arguments
#---------------------------------------------------------------
for ARGI; do
    CMD_ARGS+="${ARGI} "
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "$ME [OPTIONS] [time_warp]                      "
	echo "                                               "
	echo "Options:                                       "
	echo "  --help, -h                                   "
	echo "    Show this help message                     "
	echo "  --just_make, -j                              "
	echo "    Just make targ files, no launch            "
	echo "  --verbose, -v                                "

	echo "    Increase verbosity,  confirm before launch "
	echo "  --clean, -c                                  "
	echo "    Run clean.sh and ktm prior to launch       "
	echo "  --norand                                     " 
	echo "    Do not randomly generate vpositions.txt.   "

	echo "  --abe   Launch the vehicle ABE           " 
	echo "  --ben   Launch the vehicle BEN           " 
	echo "  --cal   Launch the vehicle CAL           " 
	echo "  --deb   Launch the vehicle DEB           " 
	echo "  --red   Launch the RED Team ABE,BEN      " 
	echo "  --blue  Launch the BLUE Team, CAL,DEB    " 
	exit 0
    elif [ "${ARGI//[^0-9]/}" = "$ARGI" -a "$TIME_WARP" = 1 ]; then
        TIME_WARP=$ARGI
    elif [ "${ARGI}" = "--just_make" -o "${ARGI}" = "-j" ]; then
	JUST_MAKE=$ARGI
    elif [ "${ARGI}" = "--verbose" -o "${ARGI}" = "-v" ]; then
	VERBOSE=$ARGI
    elif [ "${ARGI}" = "--clean" -o "${ARGI}" = "-cc" ]; then
	CLEAN="yes"
    elif [ "${ARGI}" = "--abe" ]; then
        ABE="yes"
    elif [ "${ARGI}" = "--ben" ]; then
        BEN="yes"
    elif [ "${ARGI}" = "--cal" ]; then
        CAL="yes"
    elif [ "${ARGI}" = "--deb" ]; then
        DEB="yes"
    elif [ "${ARGI}" = "--red" -o "${ARGI}" = "-r" ]; then
        ABE="yes"
        BEN="yes"
    elif [ "${ARGI}" = "--blue" -o "${ARGI}" = "-b" ]; then
        CAL="yes"
        DEB="yes"
    elif [ "${ARGI}" = "--all" -o "${ARGI}" = "-a" ]; then
        ABE="yes"
        BEN="yes"
        CAL="yes"
        DEB="yes"
    else
        echo "$ME: Bad arg:" $ARGI "Exit Code 1."
        exit 1
    fi
done

VLAUNCH_ARGS+=" $VERBOSE $JUST_MAKE $TIME_WARP "
SLAUNCH_ARGS+=" $VERBOSE $JUST_MAKE $TIME_WARP "

#---------------------------------------------------------------
#  Part 4: If verbose, show vars and confirm before launching
#---------------------------------------------------------------
if [ "${VERBOSE}" != "" ]; then 
    echo "======================================="
    echo "  launch.sh SUMMARY                    "
    echo "======================================="
    echo "$ME"
    echo "CMD_ARGS =   [${CMD_ARGS}]             "
    echo "TIME_WARP =  [${TIME_WARP}]            "
    echo "---------------------------------------"
    echo "SANG = [${WANG}]                       "
    echo "DANG = [${DANG}]                       "
    echo "---------------------------------------"
    echo "ABE = [${ABE}]                         "
    echo "BEN = [${BEN}]                         "
    echo "CAL = [${CAL}]                         "
    echo "DEB = [${DEB}]                         "
    echo -n "Hit the RETURN key to continue with launching"
    read ANSWER
fi

#-------------------------------------------------------------
# Part 5: If Cleaning enabled, clean first
#-------------------------------------------------------------
vecho "Running ./clean.sh and ktm prior to launch"
if [ "${CLEAN}" = "yes" ]; then
    ./clean.sh; ktm
fi

#-----------------------------------------------
# Part 6: Set the Vehicle random positions
#-----------------------------------------------
POS=(`pickpos --amt=2 --polygon=$BLUE_ZONE --hdg=$CCT,0 --format=terse` )
ABE_POS=${POS[0]}
BEN_POS=${POS[1]}
POS=(`pickpos --amt=2 --polygon=$RED_ZONE --hdg=$CCT,0 --format=terse`)
CAL_POS=${POS[0]}
DEB_POS=${POS[1]}

#-----------------------------------------------
# Part 7: Launch the vehicles
#-----------------------------------------------
VARGS="--sim --auto $JUST_MAKE --speed=2 --maxspd=3"
VARGS+=" $NOCONFIRM $VERBOSE $TIME_WARP"

# Launch Abe and check for results (BLUE #1)
if [ ${ABE} = "yes" ]; then
    ./launch_vehicle.sh $VARGS --color=blue         \
    --vname=abe    --vteam=blue  --start=$ABE_POS   \
    --mport=9001   --pshare=9201 --lclock  

    if [ "${VNAMES}" != "" ]; then VNAMES+=":"; fi
    VNAMES+="abe"
    
    if [ $? -ne 0 ]; then echo "Launch of ABE failed"; exit 1; fi
fi

# Launch Ben and check for results (BLUE #2)
if [ ${BEN} = "yes" ]; then
    ./launch_vehicle.sh $VARGS --color=blue         \
    --vname=ben    --vteam=blue  --start=$BEN_POS   \
    --mport=9002   --pshare=9202 --lclock          

    if [ "${VNAMES}" != "" ]; then VNAMES+=":"; fi
    VNAMES+="ben"

    if [ $? -ne 0 ]; then echo "Launch of BEN failed"; exit 1; fi
fi
    
# Launch Cal and check for results (RED #1)
if [ ${CAL} = "yes" ]; then
    ./launch_vehicle.sh $VARGS  --color=red       \
    --vname=cal    --vteam=red  --start=$CAL_POS  \
    --mport=9003   --pshare=9203 --lclock          

    if [ "${VNAMES}" != "" ]; then VNAMES+=":"; fi
    VNAMES+="cal"

    if [ $? -ne 0 ]; then echo "Launch of BEN failed"; exit 1; fi
fi
    
# Launch Deb and check for results (RED #2)
if [ ${DEB} = "yes" ]; then
    ./launch_vehicle.sh $VARGS   --color=red       \
    --vname=deb    --vteam=red   --start=$DEB_POS  \
    --mport=9004   --pshare=9204 --lclock          

    if [ "${VNAMES}" != "" ]; then VNAMES+=":"; fi
    VNAMES+="deb"

    if [ $? -ne 0 ]; then echo "Launch of DEB failed"; exit 1; fi
fi

#---------------------------------------------------------------
#  Part 8: Launch the shoreside
#---------------------------------------------------------------
echo "$ME: Launching Shoreside ..."
./launch_shoreside.sh $SLAUNCH_ARGS --vnames=$VNAMES

#---------------------------------------------------------------
#  Part 9: If launched from script, we're done, exit now
#---------------------------------------------------------------
if [ "${AUTO_LAUNCHED}" = "yes" -o "${JUST_MAKE}" != "" ]; then
    exit 0
fi

#---------------------------------------------------------------
# Part 10: Launch uMAC until the mission is quit
#---------------------------------------------------------------
uMAC targ_shoreside.moos
kill -- -$$

