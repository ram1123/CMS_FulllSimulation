#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
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

# Maximum validation duration: 28800s
# Margin for validation duration: 30%
# Validation duration with margin: 28800 * (1 - 0.30) = 20160s
# Time per event for each sequence: 2.2574s
# Threads for each sequence: 4
# Time per event for single thread for each sequence: 4 * 2.2574s = 9.0296s
# Which adds up to 9.0296s per event
# Single core events that fit in validation duration: 20160s / 9.0296s = 2232
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, validation should run 10000 / 1.0000 = 10000 events to reach the limit of 10000
# Take the minimum of 2232 and 10000, but more than 0 -> 2232
# It is estimated that this validation will produce: 2232 * 1.0000 = 2232 events
EVENTS=2232


# cmsDriver command
cmsDriver.py  --python_filename HIG-RunIISummer20UL16RECOAPV-03078_1_cfg.py --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:HIG-RunIISummer20UL16RECOAPV-03078.root --conditions 106X_mcRun2_asymptotic_preVFP_v8 --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --filein file:HIG-RunIISummer20UL16HLTAPV-03078.root --era Run2_2016_HIPM --runUnscheduled --no_exec --mc -n $EVENTS || exit $? ;

# End of HIG-RunIISummer20UL16RECOAPV-03078_test.sh file
