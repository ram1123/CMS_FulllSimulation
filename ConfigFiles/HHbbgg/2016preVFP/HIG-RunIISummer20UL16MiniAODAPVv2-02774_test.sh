#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_6_25/src ] ; then
  echo release CMSSW_10_6_25 already exists
else
  scram p CMSSW CMSSW_10_6_25
fi
cd CMSSW_10_6_25/src
eval `scram runtime -sh`

cp -r ../../Configuration .
scram b
cd ../..

# Maximum validation duration: 28800s
# Margin for validation duration: 30%
# Validation duration with margin: 28800 * (1 - 0.30) = 20160s
# Time per event for each sequence: 0.8135s
# Threads for each sequence: 4
# Time per event for single thread for each sequence: 4 * 0.8135s = 3.2538s
# Which adds up to 3.2538s per event
# Single core events that fit in validation duration: 20160s / 3.2538s = 6195
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, validation should run 10000 / 1.0000 = 10000 events to reach the limit of 10000
# Take the minimum of 6195 and 10000, but more than 0 -> 6195
# It is estimated that this validation will produce: 6195 * 1.0000 = 6195 events
EVENTS=6195


# cmsDriver command
cmsDriver.py  --python_filename HIG-RunIISummer20UL16MiniAODAPVv2-02774_1_cfg.py --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:HIG-RunIISummer20UL16MiniAODAPVv2-02774.root --conditions 106X_mcRun2_asymptotic_preVFP_v11 --step PAT --procModifiers run2_miniAOD_UL --geometry DB:Extended --filein file:HIG-RunIISummer20UL16RECOAPV-03078.root --era Run2_2016_HIPM --runUnscheduled --no_exec --mc -n $EVENTS || exit $? ;

# End of HIG-RunIISummer20UL16MiniAODAPVv2-02774_test.sh file
