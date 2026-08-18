#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
echo $HOSTNAME
if [ -r CMSSW_10_6_17_patch1/src ] ; then
  echo release CMSSW_10_6_17_patch1 already exists
else
  scram p CMSSW CMSSW_10_6_17_patch1
fi
cd CMSSW_10_6_17_patch1/src
eval `scram runtime -sh`

cp -r ../../Configuration .
scram b
cd ../..

# Maximum validation runtime: 28800s
# Minimum validation runtime: 600s
# Output events to run for the validation job (from application's setting): 100
# Event efficiency: Computed using the request efficiency and its error.
# Event efficiency: `efficiency - (2 * efficiency_error)`: `1 - (2 * 0)` = 1
# Input events: `int(output_events / event_efficiency)`: `int(100 / 1)` = 100
# Time per event (s): Computed adding all the time_per_event values on every sequence
# Time per event (s): 3.9
# Initial target input events: 100
# Initial target output events: 100
# Validation runtime will not run for long enough than expected, extending the time
# Target input events changed to: `minimum_runtime / time_per_event * number_of_threads`: `600 / 3.9 * 1` = 154
# Target output events changed to: `target_input_events * event_efficiency`: `154 * 1` = 154
# Final target input events: 153
# Final target output events: 153
# This validation will be computed based on the target output events!
EVENTS=153


# cmsDriver command
cmsDriver.py  --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --conditions 106X_mc2017_realistic_v6 --beamspot Realistic25ns13TeVEarly2017Collision --step SIM --geometry DB:Extended --era Run2_2017 --python_filename SMP-RunIISummer20UL17SIM-00109_1_cfg.py --fileout file:SMP-RunIISummer20UL17SIM-00109.root --filein file:SMP-RunIISummer20UL17wmLHEGEN-00320.root --number 153 --number_out 153 --runUnscheduled --no_exec --mc || exit $? ;

# End of SMP-RunIISummer20UL17SIM-00109_test.sh file
