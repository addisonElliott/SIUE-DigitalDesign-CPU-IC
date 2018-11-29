#
# This is the encounter script we will use for AMS 0.35 micron
# standard cell (core) designs.
#
# Author:   Created by George L.Engel using modfied version of AMS scripts
# Date:     25 July 2018 
#
print $log "Starting enc_hitikit.tcl\n" {color_green}

set  topcell       $BASENAME
set  dbdir         "$PNR_DIR/db"

# Only one item in our constraint list

set  consList      {pnr}

set  checkedLogTilLine  0

#
# Add the AMS HitKit Menu

addAMSHKMenu

# Free the previous design

print $log "Executing Encounter freeDesign command ..." {color_blue}
freeDesign

# Load the .conf file

print  $log  "Executing amsDbSetup (loading configuration data)"  {color_blue}
amsDbSetup

# Set up the grid for floorplanning 

print  $log  "Executing amsUserGrid (setting up grid for floorplanning)" {color_blue}
amsUserGrid

# Hook up power and ground

print  $log  "Executing amsGlobalConnect (connecting up to vdd! and gnd!)" {color_blue}
amsGlobalConnect core

#  Set up stuff for timing analysis

print  $log  "Executing amsSetMMMC (creating timing constraints)" {color_blue}
amsSetMMMC    

print  $log  "Executing amsSetAnalysisView minmax pnr" {color_blue}
amsSetAnalysisView minmax pnr

# Create a floorplan and suspend

print    $log  "Executing amsFloorplan (floorplanning)" {color_blue}

amsFloorplan core  $UTILIZATION  $CORE_TO_BOUND   $ASPECT

# Place our pins

print    $log  "Executing SIUE Tcl package placePins procedure (pin location specified in env.tcl file)" {color_blue}

placePins

print    $log  "---> Type resume to continue after reviewing the FLOORPLAN!!!!" {color_red}

win
suspend
fit

# Add the end cap cells

print  $log  "Executing amsAddEndCaps (adding bypass capacitors)" {color_blue}
amsAddEndCaps

# Do a power route

print   $log  "Executing  amsPowerRoute (routing power i.e. gnd! and vdd! and io pins)" {color_blue}
amsPowerRoute {gnd!  vdd!}

# Perform a placement

print $log  "Executing amsPlace $PLACEMENT_MODE" {color_blue}
amsPlace  $PLACEMENT_MODE

# Perform Clock Tree Synthesis

print  $log  "Executing amsCts (performing clock tree synthesis using sdc file)" {color_blue}
amsCts

# Perform a Timing Analysis

print    $log  "Executing amsTA (postCTS timing analysis)" {color_blue}
amsTa  postCTS

# Optimize the design

print $log "Executing Encounter optDesign -postCTS command" {color_blue}
optDesign -postCTS

# Add filler

print  $log  "Executing amsFillperi (adding filler cells to pad area)" {color_blue}
amsFillperi

# Route rest (other than clock) of the signals

print  $log  "Executing amsRoute (routing signals using $ROUTER_TO_USE)" {color_blue}
amsRoute $ROUTER_TO_USE

# Add more filler

print  $log  "### --- Executing amsFillcore (adding filler cells to core)" {color_blue}
amsFillcore

# Perform another timing analysis

print $log  "Executing amsTA (postRoute timing analysis)" {color_blue}
amsTa postRoute

# Verifying geometry and connectivity

print $log  "Executing Encounter verifyGeometry command" {color_blue}
verifyGeometry

print $log  "Executing Encounter verifyConnectivity -type all command" {color_blue}
verifyConnectivity -type all

print    $log  "---> Type resume to continue after making sure there are no DRC or LVS errors!" {color_red}
print    $log  "If errors are present, try typing \"route wroute\" or \"route nano\" to attempt to fix them" {color_blue}
win

# Process to route again and automatically call verify geometry and connectivity afterwards
proc route {type} {
    global log

    amsRoute $type

    print $log  "Executing Encounter verifyGeometry command" {color_blue}
    verifyGeometry

    print $log  "Executing Encounter verifyConnectivity -type all command" {color_blue}
    verifyConnectivity -type all
}

suspend
fit

# Adding pins to vdd! and gnd! nets
# This is done so as to satisfy Virtuoso DRC/LVS

print $log  "Executing SIUE Tcl package createPowerPins command" {color_blue}

createPowerPins

# Write out the final design
# pnr is the postfix name

print $log  "Executing amsWrite pnr (so _pnr will be appended to name)" {color_blue}
amsWrite pnr

# Write out a SDF file for the minimum and maximum views

print $log  "Executing amsWriteSDF4View {pnr_min pnr_max}" {color_blue}
amsWriteSDF4View {pnr_min  pnr_max}

#
print $log "---> Copying sdf file to the sim_dir/sdf directory" {color_red}

file delete -force ${SDF_DIR}/${BASENAME}_pnr.sdf
file copy -force ${PNR_DIR}/sdf/${BASENAME}_pnr_min.sdf ${SDF_DIR}/${BASENAME}_pnr.sdf

print $log "\nFinshing enc_hitikit.tcl" {color_green}