#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
echo $HOSTNAME
if [ -r CMSSW_10_6_20/src ] ; then
  echo release CMSSW_10_6_20 already exists
else
  scram p CMSSW CMSSW_10_6_20
fi
cd CMSSW_10_6_20/src
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
# Time per event (s): 0.339
# Initial target input events: 100
# Initial target output events: 100
# Validation runtime will not run for long enough than expected, extending the time
# Target input events changed to: `minimum_runtime / time_per_event * number_of_threads`: `600 / 0.339 * 1` = 1.77e+03
# Target output events changed to: `target_input_events * event_efficiency`: `1.77e+03 * 1` = 1.77e+03
# Final target input events: 1769
# Final target output events: 1769
# This validation will be computed based on the target output events!
EVENTS=1769


# cmsDriver command
cmsDriver.py  --era Run2_2017 --customise Configuration/DataProcessing/Utils.addMonitoring --procModifiers run2_miniAOD_UL --step PAT --geometry DB:Extended --conditions 106X_mc2017_realistic_v9 --datatier MINIAODSIM --eventcontent MINIAODSIM --python_filename SMP-RunIISummer20UL17MiniAODv2-00096_1_cfg.py --fileout file:SMP-RunIISummer20UL17MiniAODv2-00096.root --filein file:SMP-RunIISummer20UL17RECO-00109.root --number 1769 --number_out 1769 --runUnscheduled --no_exec --mc || exit $? ;

# End of SMP-RunIISummer20UL17MiniAODv2-00096_test.sh file
