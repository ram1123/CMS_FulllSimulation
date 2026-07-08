#!/bin/bash

export SCRAM_ARCH=el8_amd64_gcc11

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_13_0_24/src ] ; then
  echo release CMSSW_13_0_24 already exists
else
  scram p CMSSW CMSSW_13_0_24
fi
cd CMSSW_13_0_24/src
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
# Time per event (s): 1
# Initial target input events: 100
# Initial target output events: 100
# Validation runtime will not run for long enough than expected, extending the time
# Target input events changed to: `minimum_runtime / time_per_event * number_of_threads`: `600 / 1 * 1` = 600
# Target output events changed to: `target_input_events * event_efficiency`: `600 * 1` = 600
# Final target input events: 600
# Final target output events: 600
# This validation will be computed based on the target output events!
EVENTS=600


# cmsDriver command
cmsDriver.py  --era Run2_2017 --customise Configuration/DataProcessing/Utils.addMonitoring --step PAT --geometry DB:Extended --conditions 106X_mc2017_realistic_v9 --datatier MINIAODSIM --eventcontent MINIAODSIM --python_filename HIG-Run3Summer22MiniAODv4-01570_1_cfg.py --fileout file:HIG-Run3Summer22MiniAODv4-01570.root --filein file:HIG-Run3Summer22DRPremix-01538.root --number 600 --number_out 600 --runUnscheduled --no_exec --mc || exit $? ;

# End of HIG-Run3Summer22MiniAODv4-01570_test.sh file
