#!/bin/bash 
#-------------------------------------------------------------- 
#   Script: jerop.sh    
#   Author: Michael Benjamin   
#   LastEd: Sep 2023
#-------------------------------------------------------------- 
#  Part 1: Set global var defaults
#-------------------------------------------------------------- 
ME=`basename "$0"`
WID=160
DEP=80

WID_HALF=$((WID/2))
WID_QTR=$((WID/4))
DEP_HALF=$((DEP/2))
WPA=$(((WID/2)/4))

NWX=0
NWY=150
ANG="149"
ANG_M90="59"
ANG_180="329"

#-------------------------------------------------------
#  Part 2: Check for and handle command-line arguments
#-------------------------------------------------------
for ARGI; do
    CMD_ARGS+=" ${ARGI}"
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ]; then
	echo "$ME: [OPTIONS]                        " 
        echo "                                                       "
        echo "Synopsis:                                              "
        echo "  $ME will generate corners of a rectangular op region "
        echo "  based on base corner. The defaults are based on the  "
        echo "  Jervis Bay Op Area, but can be used for any area     "
        echo "  by overriding the defaults.                          "
        echo "  The default base corner is the NW corner. Default    "
        echo "  base angle is 149 degrees which represents the       "
        echo "  the angle from the NW to SW corner. 149 degrees      "
        echo "  is the rough angle of the shoreline, from the NW     "
        echo "  corner.                                              "
        echo "                                                       "
        echo "Options:                                               "
        echo "  --help, -h                                           "
        echo "    Display this help message                          "
        echo "  --wid=N                                              "
        echo "    Width of oparea (aligned w/ shore) (Default 160)   "
        echo "  --dep=N                                              "
        echo "    Depth of oparea (perp to shore) (Default 80)       "
        echo "  --nex=N                                              "
        echo "    Northeast corner x-coordinate (Default 0)          "
        echo "  --ney=N                                              "
        echo "    Northeast corner y-coordinate (Default 150)        "
        echo "                                                       "
        echo "Examples:                                              "
        echo " $ ./jerop.sh                                          "
        echo " $ ./jerop.sh --wid=150 --dep=90                       "
        echo " $ ./jerop.sh --nex=70 --ney=20                        "
	exit 0;
    elif [ "${ARGI:0:6}" = "--wid=" ]; then
        WID="${ARGI#--wid=*}/"
    elif [ "${ARGI:0:6}" = "--dep=" ]; then
        DEP="${ARGI#--dep=*}/"
    elif [ "${ARGI:0:6}" = "--nex=" ]; then
        NEX="${ARGI#--nex=*}/"
    elif [ "${ARGI:0:6}" = "--ney=" ]; then
        NEY="${ARGI#--ney=*}/"
    else
        echo "$ME Bad Arg:" $ARGI " Exit Code 1"
        exit 1
    fi
done

#-----------------------------------------------------
# Part 3: Calculate the Whole Field coordinates
#-----------------------------------------------------

SWX=`projpt $NWX $NWY  $ANG $WID | cut -d" " -f1`
SWY=`projpt $NWX $NWY  $ANG $WID | cut -d" " -f2`

NEX=`projpt $NWX $NWY  $ANG_M90 $DEP | cut -d" " -f1`
NEY=`projpt $NWX $NWY  $ANG_M90 $DEP | cut -d" " -f2`

SEX=`projpt $NEX $NEY  $ANG $WID | cut -d" " -f1`
SEY=`projpt $NEX $NEY  $ANG $WID | cut -d" " -f2`

echo "NW=\"x=$NWX,y=$NWY\""
echo "SW=\"x=$SWX,y=$SWY\""
echo "SE=\"x=$SEX,y=$SEY\""
echo "NE=\"x=$NEX,y=$NEY\""

echo "NWT=\"$NWX,$NWY\""
echo "SWT=\"$SWX,$SWY\""
echo "SET=\"$SEX,$SEY\""
echo "NET=\"$NEX,$NEY\""

echo "REGION=\"pts={$NWX,$NWY:$NEX,$NEY:$SEX,$SEY:$SWX,$SWY}\""

#-----------------------------------------------------
# Part 4: Calculate the coordinates of the two zones
#-----------------------------------------------------

WXH=`projpt $NWX $NWY  $ANG $WID_HALF | cut -d" " -f1`
WYH=`projpt $NWX $NWY  $ANG $WID_HALF | cut -d" " -f2`

EXH=`projpt $NEX $NEY  $ANG $WID_HALF | cut -d" " -f1`
EYH=`projpt $NEX $NEY  $ANG $WID_HALF | cut -d" " -f2`

echo "WH=\"x=$WXH,y=$WYH\""
echo "EH=\"x=$EXH,y=$EYH\""
echo "WHT=\"$WXH,$WYH\""
echo "EHT=\"$EXH,$EYH\""

echo "ZONE1=\"pts={$NWX,$NWY:$NEX,$NEY:$EXH,$EYH:$WXH,$WYH}\""
echo "ZONE2=\"pts={$WXH,$WYH:$EXH,$EYH:$SEX,$SEY:$SWX,$SWY}\""

#-----------------------------------------------------
# Part 5: Calculate the Center of the Field
#-----------------------------------------------------

CX=`projpt $WXH $WYH  $ANG_M90 $DEP_HALF | cut -d" " -f1`
CY=`projpt $WXH $WYH  $ANG_M90 $DEP_HALF | cut -d" " -f2`

echo "CENTER=\"$CX,$CY\""

#-----------------------------------------------------
# Part 6: Calculate the coordinates of the two flags
#-----------------------------------------------------

WXA=`projpt $NWX $NWY  $ANG $WPA | cut -d" " -f1`
WYA=`projpt $NWX $NWY  $ANG $WPA | cut -d" " -f2`

FXA=`projpt $WXA $WYA  $ANG_M90 $DEP_HALF | cut -d" " -f1`
FYA=`projpt $WXA $WYA  $ANG_M90 $DEP_HALF | cut -d" " -f2`

WXB=`projpt $SWX $SWY  $ANG_180 $WPA | cut -d" " -f1`
WYB=`projpt $SWX $SWY  $ANG_180 $WPA | cut -d" " -f2`
FXB=`projpt $WXB $WYB  $ANG_M90 $DEP_HALF | cut -d" " -f1`
FYB=`projpt $WXB $WYB  $ANG_M90 $DEP_HALF | cut -d" " -f2`

echo "BLUE_FLAG=\"x=$FXA,y=$FYA\""
echo "RED_FLAG=\"x=$FXB,y=$FYB\""

echo "BF=\"x=$FXA,y=$FYA\""
echo "RF=\"x=$FXB,y=$FYB\""
echo "BFT=\"$FXA,$FYA\""
echo "RFT=\"$FXB,$FYB\""

#-----------------------------------------------------
# Part 7: Calculate the Half Zone Centers
#-----------------------------------------------------
QXA=`projpt $NWX $NWY  $ANG $WID_QTR | cut -d" " -f1`
QYA=`projpt $NWX $NWY  $ANG $WID_QTR | cut -d" " -f2`

HXA=`projpt $QXA $QYA  $ANG_M90 $DEP_HALF | cut -d" " -f1`
HYA=`projpt $QXA $QYA  $ANG_M90 $DEP_HALF | cut -d" " -f2`

QXB=`projpt $SWX $SWY  $ANG_180 $WID_QTR | cut -d" " -f1`
QYB=`projpt $SWX $SWY  $ANG_180 $WID_QTR | cut -d" " -f2`

HXB=`projpt $QXB $QYB  $ANG_M90 $DEP_HALF | cut -d" " -f1`
HYB=`projpt $QXB $QYB  $ANG_M90 $DEP_HALF | cut -d" " -f2`

echo "BH=\"x=$HXA,y=$HYA\""
echo "RH=\"x=$HXB,y=$HYB\""

#-----------------------------------------------------
# Part 7: Calculate the Near Midfield Centers
#-----------------------------------------------------
TY=`projpt $WXH $WYH  $ANG_180 $WPA | cut -d" " -f1`
TY=`projpt $WXH $WYH  $ANG_180 $WPA | cut -d" " -f2`

IAX=`projpt $TX $TY   $ANG_M90 $DEP_HALF | cut -d" " -f1`
IAY=`projpt $TX $TY   $ANG_M90 $DEP_HALF | cut -d" " -f2`

TY=`projpt $WXH $WYH  $ANG $WPA | cut -d" " -f1`
TY=`projpt $WXH $WYH  $ANG $WPA | cut -d" " -f2`

IBX=`projpt $TX $TY   $ANG_M90 $DEP_HALF | cut -d" " -f1`
IBY=`projpt $TX $TY   $ANG_M90 $DEP_HALF | cut -d" " -f2`

echo "BH=\"x=$HXA,y=$HYA\""
echo "RH=\"x=$HXB,y=$HYB\""

#-----------------------------------------------------
# Part 10: Output the Field Width and Depth Angles
#-----------------------------------------------------
echo "WANG=$ANG"
echo "DANG=$ANG_M90"

WANGX=`nzero $ANG`
DANGX=`nzero $ANG_M90`

echo "WANGX=$WANGX"
echo "DANGX=$DANGX"


#                              NP                   
#     NW o--------------------o--------------------o NE
#        |                    |                    |
#        |          NWF       |NF        NEF       |
#    WWF o---------o----------o---------o----------o NEEF
#        |                    |                    |
#        |          NWF       |NH        NEH       |
#    WWH o---------o----------o---------o----------o NEEH
#        |                    |                    |
#        |          NWM       |NM        NEM       |
#   NWWM o---------o----------o---------o----------o NEEM
#        |                    |                    |
#        |          CPW       |(CP)      CPE       |
#     WC o=========o==========o=========o==========o EH
#        |                    |                    |
#        |          SWM       |SM        SEM       |
#   SWWM o---------o----------o---------o----------o SEEM
#        |                    |                    |
#        |          SWH       |SH        SEH       |
#   SWWH o---------o----------o---------o----------o SEEH
#        |                    |                    |
#        |          SWF       |SF        SEF       |
#   SWWF o---------o----------o---------o----------o SEEF
#        |                    |                    |
#        |                    |SP                  |
#     SW o--------------------o--------------------o SE

