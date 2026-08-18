#!/bin/bash

export SCRAM_ARCH=el8_amd64_gcc12

source /cvmfs/cms.cern.ch/cmsset_default.sh
echo $HOSTNAME
if [ -r CMSSW_15_0_15_patch4/src ] ; then
  echo release CMSSW_15_0_15_patch4 already exists
else
  scram p CMSSW CMSSW_15_0_15_patch4
fi
cd CMSSW_15_0_15_patch4/src
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
# Time per event (s): 0.418
# Initial target input events: 100
# Initial target output events: 100
# Validation runtime will not run for long enough than expected, extending the time
# Target input events changed to: `minimum_runtime / time_per_event * number_of_threads`: `600 / 0.418 * 1` = 1.44e+03
# Target output events changed to: `target_input_events * event_efficiency`: `1.44e+03 * 1` = 1.44e+03
# Final target input events: 1435
# Final target output events: 1435
# This validation will be computed based on the target output events!
EVENTS=1435


# cmsDriver command
cmsDriver.py  --era Run2_2017,run2_nanoAOD_106Xv2 --customise Configuration/DataProcessing/Utils.addMonitoring --step NANO --conditions 150X_mc2017_realistic_v1 --datatier NANOAODSIM --eventcontent NANOAODSIM --python_filename SMP-RunIISummer20UL17NanoAODv15-00038_1_cfg.py --fileout file:SMP-RunIISummer20UL17NanoAODv15-00038.root --filein file:SMP-RunIISummer20UL17MiniAODv2-00096.root --number 1435 --number_out 1435 --no_exec --mc || exit $? ;

# End of SMP-RunIISummer20UL17NanoAODv15-00038_test.sh file
