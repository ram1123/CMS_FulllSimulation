#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
echo $HOSTNAME
if [ -r CMSSW_10_6_28_patch1/src ] ; then
  echo release CMSSW_10_6_28_patch1 already exists
else
  scram p CMSSW CMSSW_10_6_28_patch1
fi
cd CMSSW_10_6_28_patch1/src
eval `scram runtime -sh`

cp -r ../../Configuration .
scram b
cd ../..

# Maximum validation runtime: 28800s
# Minimum validation runtime: 600s
# Output events to run for the validation job (from application's setting): 100
# Event efficiency: Computed using the request efficiency and its error.
# Event efficiency: `efficiency - (2 * efficiency_error)`: `0.102 - (2 * 0.0372)` = 0.0273
# Input events: `int(output_events / event_efficiency)`: `int(100 / 0.0273)` = 3668
# Time per event (s): Computed adding all the time_per_event values on every sequence
# Time per event (s): 4
# Target input events: 3668
# Target output events: 100
# This validation will be computed based on the target output events!
EVENTS=100


# cmsDriver command
cmsDriver.py Configuration/GenProduction/python/DY_VBF_Filter_mjj300GeV_fragment.py --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN,LHE --conditions 106X_mc2017_realistic_v6 --beamspot Realistic25ns13TeVEarly2017Collision --step LHE,GEN --geometry DB:Extended --era Run2_2017 --python_filename SMP-RunIISummer20UL17wmLHEGEN-00320_1_cfg.py --fileout file:SMP-RunIISummer20UL17wmLHEGEN-00320.root --number 3668 --number_out 100 --no_exec --mc || exit $? ;

# End of SMP-RunIISummer20UL17wmLHEGEN-00320_test.sh file
