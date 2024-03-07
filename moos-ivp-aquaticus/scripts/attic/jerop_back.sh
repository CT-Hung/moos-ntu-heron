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
NWX=0
NWY=150

WID1=$((WID/8))
WID2=$((WID/4))
WID3=$((WID*3/8))
WID4=$((WID/2))
WID5=$((WID*5/8))
WID6=$((WID*3/4))
WID7=$((WID*7/8))

DEP1=$((DEP/4))
DEP2=$((DEP/2))
DEP3=$((DEP*3/4))
DEP5=$((DEP*5/4))
DEP6=$((DEP*6/4))

ANG="149"
#ANG="90"
ANG_M90=$((ANG-90))
ANG_P90=$((ANG+90))

WANGX=`nzero $ANG`
DANGX=`nzero $ANG_M90`

NORTH="red"

echo "WANG=$ANG"
echo "DANG=$ANG_M90"
echo "WANGX=$WANGX"
echo "DANGX=$DANGX"



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
        echo "  --bn, -bn                                            "
        echo "    North is blue (Default red)                        "
        echo "                                                       "
        echo "Examples:                                              "
        echo " $ ./jerop.sh                                          "
        echo " $ ./jerop.sh --wid=150 --dep=90                       "
        echo " $ ./jerop.sh --nex=70 --ney=20 -bn                    "
	exit 0;
    elif [ "${ARGI:0:6}" = "--wid=" ]; then
        WID="${ARGI#--wid=*}/"
    elif [ "${ARGI:0:6}" = "--dep=" ]; then
        DEP="${ARGI#--dep=*}/"
    elif [ "${ARGI:0:6}" = "--nex=" ]; then
        NEX="${ARGI#--nex=*}/"
    elif [ "${ARGI:0:6}" = "--ney=" ]; then
        NEY="${ARGI#--ney=*}/"
    elif [ "${ARGI}" = "--bn" -o "${ARGI}" = "-bn" ]; then
	NORTH="blue"
    else
        echo "$ME Bad Arg:" $ARGI " Exit Code 1"
        exit 1
    fi
done

#-----------------------------------------------------
# Part 3: Calculate Row N                        (1/9)
#-----------------------------------------------------
NW="x=$NWX,y=$NWY"
NWT="$NWX,$NWY"

NWB=`projpt  $NWX $NWY  $ANG_M90 $DEP1 --ptf`
NWBT=`projpt $NWX $NWY  $ANG_M90 $DEP1 --pt`

NCB=`projpt  $NWX $NWY  $ANG_M90 $DEP2 --ptf`
NCBT=`projpt $NWX $NWY  $ANG_M90 $DEP2 --pt`

NEB=`projpt  $NWX $NWY  $ANG_M90 $DEP3 --ptf`
NEBT=`projpt $NWX $NWY  $ANG_M90 $DEP3 --pt`

NE=`projpt  $NWX $NWY  $ANG_M90 $DEP --ptf`
NET=`projpt $NWX $NWY  $ANG_M90 $DEP --pt`

XNW=`projpt  $NWX $NWY  $ANG_P90 $DEP1 --ptf`
XNWT=`projpt $NWX $NWY  $ANG_P90 $DEP1 --pt`

XXNW=`projpt  $NWX $NWY  $ANG_P90 $DEP2 --ptf`
XXNWT=`projpt $NWX $NWY  $ANG_P90 $DEP2 --pt`

XNE=`projpt  $NWX $NWY  $ANG_M90 $DEP5 --ptf`
XNET=`projpt $NWX $NWY  $ANG_M90 $DEP5 --pt`

XXNE=`projpt  $NWX $NWY  $ANG_M90 $DEP6 --ptf`
XXNET=`projpt $NWX $NWY  $ANG_M90 $DEP6 --pt`


echo "# -------ROW N (1/9) -------"
echo "NW=\"x=$NWX,y=$NWY\""
echo "NWT=\"$NWX,$NWY\""
echo "NWB=\"$NWB\""
echo "NWBT=\"$NWBT\""
echo "NCB=\"$NCB\""
echo "NCBT=\"$NCBT\""
echo "NEB=\"$NEB\""
echo "NEBT=\"$NEBT\""
echo "NE=\"$NE\""
echo "NET=\"$NET\""
#------- Off-field XNW, XXNW, XNE, XXNE
echo "XNW=\"$XNW\""
echo "XNWT=\"$XNWT\""
echo "XXNW=\"$XXNW\""
echo "XXNWT=\"$XXNWT\""
echo "XNE=\"$XNE\""
echo "XNET=\"$XNET\""
echo "XXNE=\"$XXNE\""
echo "XXNET=\"$XXNET\""


#-----------------------------------------------------
# Part 3: Calculate Row NF   (North FlagLine)    (2/9)
#-----------------------------------------------------
X=`projpt $NWX $NWY  $ANG $WID1 | cut -d" " -f1`
Y=`projpt $NWX $NWY  $ANG $WID1 | cut -d" " -f2`

NWWF="x=$X,y=$Y"
NWWFT="$X,$Y"

NWF=`projpt  $X $Y  $ANG_M90 $DEP1 --ptf`
NWFT=`projpt $X $Y  $ANG_M90 $DEP1 --pt`

NCF=`projpt   $X $Y  $ANG_M90 $DEP2 --ptf`
NCFT=`projpt  $X $Y  $ANG_M90 $DEP2 --pt`

NEF=`projpt  $X $Y  $ANG_M90 $DEP3 --ptf`
NEFT=`projpt $X $Y  $ANG_M90 $DEP3 --pt`

NEEF=`projpt  $X $Y  $ANG_M90 $DEP --ptf`
NEEFT=`projpt $X $Y  $ANG_M90 $DEP --pt`

echo "# -------ROW NF (2/9) -------"
echo "NWWF=\"$NWWF\""
echo "NWWFT=\"$NWWFT\""
echo "NWF=\"$NWF\""
echo "NWFT=\"$NWFT\""
echo "NCF=\"$NCF\""
echo "NCFT=\"$NCFT\""
echo "NEF=\"$NEF\""
echo "NEFT=\"$NEFT\""
echo "NEEF=\"$NEEF\""
echo "NEEFT=\"$NEEFT\""

#-----------------------------------------------------
# Part 3: Calculate Row NH   (North HalfPt)      (3/9)
#-----------------------------------------------------
X=`projpt $NWX $NWY  $ANG $WID2 | cut -d" " -f1`
Y=`projpt $NWX $NWY  $ANG $WID2 | cut -d" " -f2`

NWWH="x=$X,y=$Y"
NWWHT="$X,$Y"

NWH=`projpt  $X $Y  $ANG_M90 $DEP1 --ptf`
NWHT=`projpt $X $Y  $ANG_M90 $DEP1 --pt`

NCH=`projpt   $X $Y  $ANG_M90 $DEP2 --ptf`
NCHT=`projpt  $X $Y  $ANG_M90 $DEP2 --pt`

NEH=`projpt  $X $Y  $ANG_M90 $DEP3 --ptf`
NEHT=`projpt $X $Y  $ANG_M90 $DEP3 --pt`

NEEH=`projpt  $X $Y  $ANG_M90 $DEP --ptf`
NEEHT=`projpt $X $Y  $ANG_M90 $DEP --pt`

echo "# -------ROW NH (3/9) -------"
echo "NWWH=\"$NWWH\""
echo "NWWHT=\"$NWWHT\""
echo "NWH=\"$NWH\""
echo "NWHT=\"$NWHT\""
echo "NCH=\"$NCH\""
echo "NCHT=\"$NCHT\""
echo "NEH=\"$NEH\""
echo "NEHT=\"$NEHT\""
echo "NEEH=\"$NEEH\""
echo "NEEHT=\"$NEEHT\""


#-----------------------------------------------------
# Part 3: Calculate Row NM  (North Mid)          (4/9)
#-----------------------------------------------------
X=`projpt $NWX $NWY  $ANG $WID3 | cut -d" " -f1`
Y=`projpt $NWX $NWY  $ANG $WID3 | cut -d" " -f2`

NWWM="x=$X,y=$Y"
NWWMT="$X,$Y"

NWM=`projpt  $X $Y  $ANG_M90 $DEP1 --ptf`
NWMT=`projpt $X $Y  $ANG_M90 $DEP1 --pt`

NCM=`projpt   $X $Y  $ANG_M90 $DEP2 --ptf`
NCMT=`projpt  $X $Y  $ANG_M90 $DEP2 --pt`

NEM=`projpt  $X $Y  $ANG_M90 $DEP3 --ptf`
NEMT=`projpt $X $Y  $ANG_M90 $DEP3 --pt`

NEEM=`projpt  $X $Y  $ANG_M90 $DEP --ptf`
NEEMT=`projpt $X $Y  $ANG_M90 $DEP --pt`

echo "# -------ROW NM (4/9) -------"
echo "NWWM=\"$NWWM\""
echo "NWWMT=\"$NWWMT\""
echo "NWM=\"$NWM\""
echo "NWMT=\"$NWMT\""
echo "NCM=\"$NCM\""
echo "NCMT=\"$NCMT\""
echo "NEM=\"$NEM\""
echo "NEMT=\"$NEMT\""
echo "NEEM=\"$NEEM\""
echo "NEEMT=\"$NEEMT\""



#-----------------------------------------------------
# Part 3: Calculate Row C  (CENTER)              (5/9)
#-----------------------------------------------------
X=`projpt $NWX $NWY  $ANG $WID4 | cut -d" " -f1`
Y=`projpt $NWX $NWY  $ANG $WID4 | cut -d" " -f2`

WC="x=$X,y=$Y"
WCT="$X,$Y"

CPW=`projpt  $X $Y  $ANG_M90 $DEP1 --ptf`
CPWT=`projpt $X $Y  $ANG_M90 $DEP1 --pt`

CC=`projpt   $X $Y  $ANG_M90 $DEP2 --ptf`
CCT=`projpt  $X $Y  $ANG_M90 $DEP2 --pt`

CPE=`projpt  $X $Y  $ANG_M90 $DEP3 --ptf`
CPET=`projpt $X $Y  $ANG_M90 $DEP3 --pt`

EC=`projpt  $X $Y  $ANG_M90 $DEP --ptf`
ECT=`projpt $X $Y  $ANG_M90 $DEP --pt`

XW=`projpt  $X $Y  $ANG_P90 $DEP1 --ptf`
XWT=`projpt $X $Y  $ANG_P90 $DEP1 --pt`

XXW=`projpt  $X $Y  $ANG_P90 $DEP2 --ptf`
XXWT=`projpt $X $Y  $ANG_P90 $DEP2 --pt`

XE=`projpt  $X $Y  $ANG_M90 $DEP5 --ptf`
XET=`projpt $X $Y  $ANG_M90 $DEP5 --pt`

XXE=`projpt  $X $Y  $ANG_M90 $DEP6 --ptf`
XXET=`projpt $X $Y  $ANG_M90 $DEP6 --pt`


echo "# -------ROW C (5/9) -------"
echo "WC=\"$WC\""
echo "WCT=\"$WCT\""
echo "CPW=\"$CPW\""
echo "CPWT=\"$CPWT\""
echo "CC=\"$CC\""
echo "CCT=\"$CCT\""
echo "CPE=\"$CPE\""
echo "CPET=\"$CPET\""
echo "EC=\"$EC\""
echo "ECT=\"$ECT\""


#-----------------------------------------------------
# Part 3: Calculate Row SM  (South Mid)          (6/9)
#-----------------------------------------------------
X=`projpt $NWX $NWY  $ANG $WID5 | cut -d" " -f1`
Y=`projpt $NWX $NWY  $ANG $WID5 | cut -d" " -f2`

SWWM="x=$X,y=$Y"
SWWMT="$X,$Y"

echo "FOO="`projpt  $X $Y  $ANG_M90 $DEP1 --ptf`

SWM=`projpt  $X $Y  $ANG_M90 $DEP1 --ptf`
SWMT=`projpt $X $Y  $ANG_M90 $DEP1 --pt`

SCM=`projpt   $X $Y  $ANG_M90 $DEP2 --ptf`
SCMT=`projpt  $X $Y  $ANG_M90 $DEP2 --pt`

SEM=`projpt  $X $Y  $ANG_M90 $DEP3 --ptf`
SEMT=`projpt $X $Y  $ANG_M90 $DEP3 --pt`

SEEM=`projpt  $X $Y  $ANG_M90 $DEP --ptf`
SEEMT=`projpt $X $Y  $ANG_M90 $DEP --pt`

echo "# -------ROW NM (6/9) -------"
echo "SWWM=\"$SWWM\""
echo "SWWMT=\"$SWWMT\""
echo "SWM=\"$SWM\""
echo "SWMT=\"$SWMT\""
echo "SCM=\"$SCM\""
echo "SCMT=\"$SCMT\""
echo "SEM=\"$SEM\""
echo "SEMT=\"$SEMT\""
echo "SEEM=\"$SEEM\""
echo "SEEMT=\"$SEEMT\""
#------- Off-field XW, XXW, XE, XXE
echo "XW=\"$XW\""
echo "XWT=\"$XWT\""
echo "XXW=\"$XXW\""
echo "XXWT=\"$XXWT\""
echo "XE=\"$XE\""
echo "XET=\"$XET\""
echo "XXE=\"$XXE\""
echo "XXET=\"$XXET\""


#-----------------------------------------------------
# Part 3: Calculate Row SH   (South HalfPt)      (7/9)
#-----------------------------------------------------
X=`projpt $NWX $NWY  $ANG $WID6 | cut -d" " -f1`
Y=`projpt $NWX $NWY  $ANG $WID6 | cut -d" " -f2`

SWWH="x=$X,y=$Y"
SWWHT="$X,$Y"

SWH=`projpt  $X $Y  $ANG_M90 $DEP1 --ptf`
SWHT=`projpt $X $Y  $ANG_M90 $DEP1 --pt`

SCH=`projpt   $X $Y  $ANG_M90 $DEP2 --ptf`
SCHT=`projpt  $X $Y  $ANG_M90 $DEP2 --pt`

SEH=`projpt  $X $Y  $ANG_M90 $DEP3 --ptf`
SEHT=`projpt $X $Y  $ANG_M90 $DEP3 --pt`

SEEH=`projpt  $X $Y  $ANG_M90 $DEP --ptf`
SEEHT=`projpt $X $Y  $ANG_M90 $DEP --pt`

echo "# -------ROW SH (7/9) -------"
echo "SWWH=\"$SWWH\""
echo "SWWHT=\"$SWWHT\""
echo "SWH=\"$SWH\""
echo "SWHT=\"$SWHT\""
echo "SCH=\"$SCH\""
echo "SCHT=\"$SCHT\""
echo "SEH=\"$SEH\""
echo "SEHT=\"$SEHT\""
echo "SEEH=\"$SEEH\""
echo "SEEHT=\"$SEEHT\""


#-----------------------------------------------------
# Part 3: Calculate Row SF   (South FlagLine)    (8/9)
#-----------------------------------------------------
X=`projpt $NWX $NWY  $ANG $WID7 | cut -d" " -f1`
Y=`projpt $NWX $NWY  $ANG $WID7 | cut -d" " -f2`

SWWF="x=$X,y=$Y"
SWWFT="$X,$Y"

SWF=`projpt  $X $Y  $ANG_M90 $DEP1 --ptf`
SWFT=`projpt $X $Y  $ANG_M90 $DEP1 --pt`

SCF=`projpt   $X $Y  $ANG_M90 $DEP2 --ptf`
SCFT=`projpt  $X $Y  $ANG_M90 $DEP2 --pt`

SEF=`projpt  $X $Y  $ANG_M90 $DEP3 --ptf`
SEFT=`projpt $X $Y  $ANG_M90 $DEP3 --pt`

SEEF=`projpt  $X $Y  $ANG_M90 $DEP --ptf`
SEEFT=`projpt $X $Y  $ANG_M90 $DEP --pt`

echo "# -------ROW NF (8/9) -------"
echo "SWWF=\"$SWWF\""
echo "SWWFT=\"$SWWFT\""
echo "SWF=\"$SWF\""
echo "SWFT=\"$SWFT\""
echo "SCF=\"$SCF\""
echo "SCFT=\"$SCFT\""
echo "SEF=\"$SEF\""
echo "SEFT=\"$SEFT\""
echo "SEEF=\"$SEEF\""
echo "SEEFT=\"$SEEFT\""


#-----------------------------------------------------
# Part 3: Calculate Row N                        (9/9)
#-----------------------------------------------------
X=`projpt $NWX $NWY  $ANG $WID | cut -d" " -f1`
Y=`projpt $NWX $NWY  $ANG $WID | cut -d" " -f2`

SW="x=$X,y=$Y"
SWT="$X,$Y"

SWB=`projpt  $X $Y  $ANG_M90 $DEP1 --ptf`
SWBT=`projpt $X $Y  $ANG_M90 $DEP1 --pt`

SCB=`projpt  $X $Y  $ANG_M90 $DEP2 --ptf`
SCBT=`projpt $X $Y  $ANG_M90 $DEP2 --pt`

SEB=`projpt  $X $Y  $ANG_M90 $DEP3 --ptf`
SEBT=`projpt $X $Y  $ANG_M90 $DEP3 --pt`

SE=`projpt  $X $Y  $ANG_M90 $DEP --ptf`
SET=`projpt $X $Y  $ANG_M90 $DEP --pt`


XSW=`projpt  $X $Y  $ANG_P90 $DEP1 --ptf`
XSWT=`projpt $X $Y  $ANG_P90 $DEP1 --pt`

XXSW=`projpt  $X $Y  $ANG_P90 $DEP2 --ptf`
XXSWT=`projpt $X $Y  $ANG_P90 $DEP2 --pt`

XSE=`projpt  $X $Y  $ANG_M90 $DEP5 --ptf`
XSET=`projpt $X $Y  $ANG_M90 $DEP5 --pt`

XXSE=`projpt  $X $Y  $ANG_M90 $DEP6 --ptf`
XXSET=`projpt $X $Y  $ANG_M90 $DEP6 --pt`

echo "# -------ROW N (9/9) -------"
echo "SW=\"$SW\""
echo "SWT=\"$SWT\""
echo "SWB=\"$SWB\""
echo "SWBT=\"$SWBT\""
echo "SCB=\"$SCB\""
echo "SCBT=\"$SCBT\""
echo "SEB=\"$SEB\""
echo "SEBT=\"$SEBT\""
echo "SE=\"$SE\""
echo "SET=\"$SET\""



#-----------------------------------------------------
# Part 4: Calculate the coords of region & two zones
#-----------------------------------------------------
echo "# ------- ZONES -------"
ZONE1="pts={$NWT:$NET:$ECT:$WCT}"
ZONE2="pts={$WCT:$ECT:$SET:$SWT}"

echo "REGION=\"pts={$NWT:$NET:$SET:$SWT}\""
echo "ZONE1=\"$ZONE1\""
echo "ZONE2=\"$ZONE2\""
echo "CENTER=\"$CPT\""

#-----------------------------------------------------
# Part 6: Calculate the coordinates of the two flags
#-----------------------------------------------------

echo "# ------- FLAGS -------"

if [ "${NORTH}" = "red" ]; then
    BF=$SCF
    RF=$NCF
    BFT=$SCFT
    RFT=$NCFT
    RED_ZONE=$ZONE1
    BLUE_ZONE=$ZONE2
else
    BF=$NCF
    RF=$SCF
    BFT=$NCFT
    RFT=$SCFT
    RED_ZONE=$ZONE2
    BLUE_ZONE=$ZONE1
fi

echo "BLUE_FLAG=\"$BF\""
echo "RED_FLAG=\"$RF\""
echo "RF=\"$RF\""
echo "BF=\"$BF\""
echo "RFT=\"$RFT\""
echo "BFT=\"$BFT\""
echo "RED_ZONE=\"$RED_ZONE\""
echo "BLUE_ZONE=\"$BLUE_ZONE\""

#----------------------------------------------------------------
#                      ABSOLUTE NORTH
#
#                   NWB        NCB       NEB        
#     NW o---------o----------o---------o----------o NE    Row NB
#        |                    |                    |
#        |          NWF       |NCF       NEF       |
#   NWWF o---------o----------o---------o----------o NEEF  Row NF
#        |                    |                    |
#        |          NWH       |NCH       NEH       |
#   NWWH o---------o----------o---------o----------o NEEH  Row NH
#        |                    |                    |
#        |          NWM       |NCM       NEM       |
#   NWWM o---------o----------o---------o----------o NEEM  Row NM
#        |                    |                    |
#        |          CPW       |(CC)      CPE       |
#     WC o=========o==========o=========o==========o EC    Row C
#        |                    |                    |
#        |          SWM       |SCM       SEM       |
#   SWWM o---------o----------o---------o----------o SEEM  Row SM
#        |                    |                    |
#        |          SWH       |SCH       SEH       |
#   SWWH o---------o----------o---------o----------o SEEH  Row SH
#        |                    |                    |
#        |          SWF       |SCF       SEF       |
#   SWWF o---------o----------o---------o----------o SEEF  Row SF
#        |                    |                    |
#        |          SWB       |SCB       SEB       |
#     SW o---------o----------o---------o----------o SE    Row SB
#                     ABSOLUTE SOUTH           
#




#=================================================================
#
#                   PBX        CBX       SBX        
#   PPBX o---------o----------o---------o----------o SSBX  Row BX
#        |                    |                    |
#        |          PFX       |CFX       SFX       |
#   PPFX o---------o----------o---------o----------o SSFX  Row FX
#        |                    |                    |
#        |          PHX       |CHX       SHX       |
#   PPHX o---------o----------o---------o----------o SSHX  Row HX
#        |                    |                    |
#        |          PMX       |CMX       SMX       |
#   PPMX o---------o----------o---------o----------o SSMX  Row MX
#        |                    |                    |
#        |          PC        |CC        SC        | 
#    PPC o=========o==========o=========o==========o SSC   Row C
#        |                    |                    |
#        |          PM        |CM        SM        |
#    PPM o---------o----------o---------o----------o SSM   Row M
#        |                    |                    |
#        |          PH        |CH        SH        |
#    PPH o---------o----------o---------o----------o SSH   Row H
#        |                    |                    |
#        |          PF        |CF        SF        |
#    PPF o---------o----------o---------o----------o SSF   Row F
#        |              ^     |     ^              |
#        |          PB  |     |CB   |    SB        |
#    PPB o---------o----------o---------o----------o SSB   Row B
#                         HOME SIDE


#----------------------------------------------------------------
#                      ABSOLUTE OFF_FIELD
#
#                                           
#                               o XXN       
#                                           
#                               o XN        
#    XXNW    XNW                                XNE   XXNE
#       o     o      o----------o----------o     o    o 
#                    |          |          |
#                    o          o          o
#                    |          |          |
#                    o          o          o
#                    |          |          |
#                    o          o          o
#     XXW    XW      |          |          |    XE    XXE
#       o     o      o==========o==========o     o    o
#                    |          |          |
#                    o          o          o
#                    |          |          |
#                    o          o          o
#                    |          |          |
#                    o          o          o
#     XXSW   XSW     |          |          |    XSE   XXSE
#       o     o      o----------o----------o     o    o
#                                           
#                               o XS        
#                                           
#                               o XXS       






# Long string, when home team is in the north end of the field.
# For passing from launch scripts to nsplug for meta files.
HOME_IS_NORTH="\""
HOME_IS_NORTH+="PPB=\$NE   PB=\$NEB CB=\$NCB SB=\$NWB SSB=\$NW "
HOME_IS_NORTH+="PPF=\$NEEF PF=\$NEF CF=\$NCF SF=\$NWF SSF=\$NWWF "
HOME_IS_NORTH+="PPH=\$NEEH PH=\$NEH CH=\$NCH SH=\$NWH SSH=\$NWWH "
HOME_IS_NORTH+="PPM=\$NEEM PM=\$NEM CM=\$NCM SM=\$NWM SSM=\$NWWM "
HOME_IS_NORTH+="PPC=\$EC   PC=\$CPE CC=\$CC  SC=\$CPW SSC=\$WC "
HOME_IS_NORTH+="PPMX=\$SEEM PMX=\$SEM CMX=\$SCM SMX=\$SWM SSMX=\$SWWM "
HOME_IS_NORTH+="PPHX=\$SEEH PHX=\$SEH CHX=\$SCH SHX=\$SWH SSHX=\$SWWH "
HOME_IS_NORTH+="PPFX=\$SEEF PFX=\$SEF CFX=\$SCF SFX=\$SWF SSFX=\$SWWF "
HOME_IS_NORTH+="PPBX=\$SE   PBX=\$SEB CBX=\$SCB SBX=\$SWB SSBX=\$SW "

HOME_IS_NORTH+="PPBT=\$NET   PBT=\$NEBT CBT=\$NCBT SBT=\$NWBT SSBT=\$NWT "
HOME_IS_NORTH+="PPFT=\$NEEFT PFT=\$NEFT CFT=\$NCFT SFT=\$NWFT SSFT=\$NWWFT "
HOME_IS_NORTH+="PPHT=\$NEEHT PHT=\$NEHT CHT=\$NCHT SHT=\$NWHT SSHT=\$NWWHT "
HOME_IS_NORTH+="PPMT=\$NEEMT PMT=\$NEMT CMT=\$NCMT SMT=\$NWMT SSMT=\$NWWMT "
HOME_IS_NORTH+="PPCT=\$ECT   PCT=\$CPET CCT=\$CCT  SCT=\$CPWT SSCT=\$WCT "
HOME_IS_NORTH+="PPMXT=\$SEEMT PMXT=\$SEMT CMXT=\$SCMT SMXT=\$SWMT SSMXT=\$SWWMT "
HOME_IS_NORTH+="PPHXT=\$SEEHT PHXT=\$SEHT CHXT=\$SCHT SHXT=\$SWHT SSHXT=\$SWWHT "
HOME_IS_NORTH+="PPFXT=\$SEEFT PFXT=\$SEFT CFXT=\$SCFT SFXT=\$SWFT SSFXT=\$SWWFT "
HOME_IS_NORTH+="PPBXT=\$SET   PBXT=\$SEBT CBXT=\$SCBT SBXT=\$SWBT SSBXT=\$SWT "
HOME_IS_NORTH+="\""


# Long string, when home team is in the north end of the field.
# For passing from launch scripts to nsplug for meta files.
HOME_IS_SOUTH="\""
HOME_IS_SOUTH+="PPB=\$SW   PB=\$SWB CB=\$SCB SB=\$SEB SSB=\$SE "
HOME_IS_SOUTH+="PPF=\$SWWF PF=\$SWF CF=\$SCF SF=\$SEF SSF=\$SEEF "
HOME_IS_SOUTH+="PPH=\$SWWH PH=\$SWH CH=\$SCH SH=\$SEH SSH=\$SEEH "
HOME_IS_SOUTH+="PPM=\$SWWM PM=\$SWM CM=\$SCM SM=\$SEM SSM=\$SEEM "
HOME_IS_SOUTH+="PPC=\$WC   PC=\$CPW CC=\$CC  SC=\$CPE SSC=\$EC "
HOME_IS_SOUTH+="PPMX=\$NWWM PMX=\$NWM CMX=\$NCM SMX=\$NEM SSMX=\$NEEM "
HOME_IS_SOUTH+="PPHX=\$NWWH PHX=\$NWH CHX=\$NCH SHX=\$NEH SSHX=\$NEEH "
HOME_IS_SOUTH+="PPFX=\$NWWF PFX=\$NWF CFX=\$NCF SFX=\$NEF SSFX=\$NEEF "
HOME_IS_SOUTH+="PPBX=\$NW   PBX=\$NWB CBX=\$NCB SBX=\$NEB SSBX=\$NE "

HOME_IS_SOUTH+="PPBT=\$SWT   PBT=\$SWBT CBT=\$SCBT SBT=\$SEBT SSBT=\$SET "
HOME_IS_SOUTH+="PPFT=\$SWWFT PFT=\$SWFT CFT=\$SCFT SFT=\$SEFT SSFT=\$SEEFT "
HOME_IS_SOUTH+="PPHT=\$SWWHT PHT=\$SWHT CHT=\$SCHT SHT=\$SEHT SSHT=\$SEEHT "
HOME_IS_SOUTH+="PPMT=\$SWWMT PMT=\$SWMT CMT=\$SCMT SMT=\$SEMT SSMT=\$SEEMT "
HOME_IS_SOUTH+="PPCT=\$WCT   PCT=\$CPWT CCT=\$CCT  SCT=\$CPET SSCT=\$ECT "
HOME_IS_SOUTH+="PPMXT=\$NWWMT PMXT=\$NWMT CMXT=\$NCMT SMXT=\$NEMT SSMXT=\$NEEMT "
HOME_IS_SOUTH+="PPHXT=\$NWWHT PHXT=\$NWHT CHXT=\$NCHT SHXT=\$NEHT SSHXT=\$NEEHT "
HOME_IS_SOUTH+="PPFXT=\$NWWFT PFXT=\$NWFT CFXT=\$NCFT SFXT=\$NEFT SSFXT=\$NEEFT "
HOME_IS_SOUTH+="PPBXT=\$NWT   PBXT=\$NWBT CBXT=\$NCBT SBXT=\$NEBt SSBXT=\$NET "

HOME_IS_SOUTH+="\""

FLDS+="\""

FLDS+="NW=\$NW     NWB=\$NWB NCB=\$NCB NEB=\$NEB NE=\$NE " 
FLDS+="NWWF=\$NWWF NWF=\$NWF NCF=\$NCF NEF=\$NEF NEEF=\$NEEF " 
FLDS+="NWWH=\$NWWH NWH=\$NWH NCH=\$NCH NEH=\$NEH NEEH=\$NEEH " 
FLDS+="NWWM=\$NWWM NWM=\$NWM NCM=\$NCM NEM=\$NEM NEEM=\$NEEM " 
FLDS+="WC=\$WC     CPW=\$CPW CC=\$CC   CPE=\$CPE EC=\$EC " 
FLDS+="SWWM=\$SWWM SWM=\$SWM SCM=\$SCM SEM=\$SEM SEEM=\$SEEM " 
FLDS+="SWWH=\$SWWH SWH=\$SWH SCH=\$SCH SEH=\$SEH SEEH=\$SEEH " 
FLDS+="SWWF=\$SWWF SWF=\$SWF SCF=\$SCF SEF=\$SEF SEEF=\$SEEF " 
FLDS+="SW=\$SW     SWB=\$SWB SCB=\$SCB SEB=\$SEB SE=\$SE " 

FLDS+="RED_FLAG=\$RED_FLAG "
FLDS+="BLUE_FLAG=\$BLUE_FLAG "
FLDS+="BF=\$BF "
FLDS+="RF=\$RF "
FLDS+="BFT=\$BFT "
FLDS+="RFT=\$RFT "
FLDS+="BLUE_ZONE=\$BLUE_ZONE "
FLDS+="RED_ZONE=\$RED_ZONE "

FLDS+="REGION=\$REGION "
FLDS+="ZONE1=\$ZONE1 "
FLDS+="ZONE2=\$ZONE2 "
FLDS+="CENTER=\$CENTER "

FLDS+="WANG=\$ANG "
FLDS+="DANG=\$ANG_M90 "
FLDS+="WANGX=\$WANGX "
FLDS+="DANGX=\$DANGX "
FLDS+="\""


echo "#------------------------------------"
echo "HOME_IS_NORTH=$HOME_IS_NORTH"
echo "#------------------------------------"
echo "HOME_IS_SOUTH=$HOME_IS_SOUTH"
echo "#------------------------------------"
echo "FLDS=$FLDS"