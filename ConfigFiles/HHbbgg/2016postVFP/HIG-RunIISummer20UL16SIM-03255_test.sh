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
# Time per event for each sequence: 13.3371s
# Threads for each sequence: 4
# Time per event for single thread for each sequence: 4 * 13.3371s = 53.3484s
# Which adds up to 53.3484s per event
# Single core events that fit in validation duration: 20160s / 53.3484s = 377
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, validation should run 10000 / 1.0000 = 10000 events to reach the limit of 10000
# Take the minimum of 377 and 10000, but more than 0 -> 377
# It is estimated that this validation will produce: 377 * 1.0000 = 377 events
EVENTS=377


# cmsDriver command
cmsDriver.py  --python_filename HIG-RunIISummer20UL16SIM-03255_1_cfg.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:HIG-RunIISummer20UL16SIM-03255.root --conditions 106X_mcRun2_asymptotic_v13 --beamspot Realistic25ns13TeV2016Collision --step SIM --geometry DB:Extended --filein file:HIG-RunIISummer20UL16wmLHEGEN-03756.root --era Run2_2016 --runUnscheduled --no_exec --mc -n $EVENTS || exit $? ;

# End of HIG-RunIISummer20UL16SIM-03255_test.sh file
