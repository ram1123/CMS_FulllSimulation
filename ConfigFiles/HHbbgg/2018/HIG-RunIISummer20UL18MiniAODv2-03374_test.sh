#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
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

# Maximum validation duration: 28800s
# Margin for validation duration: 30%
# Validation duration with margin: 28800 * (1 - 0.30) = 20160s
# Time per event for each sequence: 0.6000s
# Threads for each sequence: 4
# Time per event for single thread for each sequence: 4 * 0.6000s = 2.4000s
# Which adds up to 2.4000s per event
# Single core events that fit in validation duration: 20160s / 2.4000s = 8400
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, validation should run 10000 / 1.0000 = 10000 events to reach the limit of 10000
# Take the minimum of 8400 and 10000, but more than 0 -> 8400
# It is estimated that this validation will produce: 8400 * 1.0000 = 8400 events
EVENTS=8400


# cmsDriver command
cmsDriver.py  --python_filename HIG-RunIISummer20UL18MiniAODv2-03374_1_cfg.py --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:HIG-RunIISummer20UL18MiniAODv2-03374.root --conditions 106X_upgrade2018_realistic_v16_L1v1 --step PAT --procModifiers run2_miniAOD_UL --geometry DB:Extended --filein file:HIG-RunIISummer20UL18RECO-03374.root --era Run2_2018 --runUnscheduled --no_exec --mc -n $EVENTS || exit $? ;

# End of HIG-RunIISummer20UL18MiniAODv2-03374_test.sh file
