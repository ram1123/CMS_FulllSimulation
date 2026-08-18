#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc630

source /cvmfs/cms.cern.ch/cmsset_default.sh
echo $HOSTNAME
if [ -r CMSSW_9_4_14_UL_patch1/src ] ; then
  echo release CMSSW_9_4_14_UL_patch1 already exists
else
  scram p CMSSW CMSSW_9_4_14_UL_patch1
fi
cd CMSSW_9_4_14_UL_patch1/src
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
# Time per event (s): 2.09
# Initial target input events: 100
# Initial target output events: 100
# Validation runtime will not run for long enough than expected, extending the time
# Target input events changed to: `minimum_runtime / time_per_event * number_of_threads`: `600 / 2.09 * 1` = 287
# Target output events changed to: `target_input_events * event_efficiency`: `287 * 1` = 287
# Final target input events: 286
# Final target output events: 286
# This validation will be computed based on the target output events!
EVENTS=286


# cmsDriver command
cmsDriver.py  --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --conditions 94X_mc2017_realistic_v15 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:2e34v40 --geometry DB:Extended --era Run2_2017 --python_filename SMP-RunIISummer20UL17HLT-00109_1_cfg.py --fileout file:SMP-RunIISummer20UL17HLT-00109.root --filein file:SMP-RunIISummer20UL17DIGIPremix-00109.root --number 286 --number_out 286 --no_exec --mc || exit $? ;

# End of SMP-RunIISummer20UL17HLT-00109_test.sh file
