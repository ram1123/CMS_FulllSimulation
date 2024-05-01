#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc630

source /cvmfs/cms.cern.ch/cmsset_default.sh
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

# Maximum validation duration: 28800s
# Margin for validation duration: 30%
# Validation duration with margin: 28800 * (1 - 0.30) = 20160s
# Time per event for each sequence: 2.0915s
# Threads for each sequence: 4
# Time per event for single thread for each sequence: 4 * 2.0915s = 8.3660s
# Which adds up to 8.3660s per event
# Single core events that fit in validation duration: 20160s / 8.3660s = 2409
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, validation should run 10000 / 1.0000 = 10000 events to reach the limit of 10000
# Take the minimum of 2409 and 10000, but more than 0 -> 2409
# It is estimated that this validation will produce: 2409 * 1.0000 = 2409 events
EVENTS=2409


# cmsDriver command
cmsDriver.py  --python_filename HIG-RunIISummer20UL17HLT-03331_1_cfg.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:HIG-RunIISummer20UL17HLT-03331.root --conditions 94X_mc2017_realistic_v15 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:2e34v40 --geometry DB:Extended --filein file:HIG-RunIISummer20UL17DIGIPremix-03331.root --era Run2_2017 --no_exec --mc -n $EVENTS || exit $? ;

# End of HIG-RunIISummer20UL17HLT-03331_test.sh file
