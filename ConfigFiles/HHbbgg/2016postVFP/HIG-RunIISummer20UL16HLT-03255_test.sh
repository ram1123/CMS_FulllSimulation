#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc530

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_8_0_36_UL_patch1/src ] ; then
  echo release CMSSW_8_0_36_UL_patch1 already exists
else
  scram p CMSSW CMSSW_8_0_36_UL_patch1
fi
cd CMSSW_8_0_36_UL_patch1/src
eval `scram runtime -sh`

cp -r ../../Configuration .
scram b
cd ../..

# Maximum validation duration: 28800s
# Margin for validation duration: 30%
# Validation duration with margin: 28800 * (1 - 0.30) = 20160s
# Time per event for each sequence: 4.3639s
# Threads for each sequence: 4
# Time per event for single thread for each sequence: 4 * 4.3639s = 17.4556s
# Which adds up to 17.4556s per event
# Single core events that fit in validation duration: 20160s / 17.4556s = 1154
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, validation should run 10000 / 1.0000 = 10000 events to reach the limit of 10000
# Take the minimum of 1154 and 10000, but more than 0 -> 1154
# It is estimated that this validation will produce: 1154 * 1.0000 = 1154 events
EVENTS=1154


# cmsDriver command
cmsDriver.py  --python_filename HIG-RunIISummer20UL16HLT-03255_1_cfg.py --eventcontent RAWSIM --outputCommand "keep *_mix_*_*,keep *_genPUProtons_*_*" --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --inputCommands "keep *","drop *_*_BMTF_*","drop *PixelFEDChannel*_*_*_*" --fileout file:HIG-RunIISummer20UL16HLT-03255.root --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:25ns15e33_v4 --geometry DB:Extended --filein file:HIG-RunIISummer20UL16DIGIPremix-03250.root --era Run2_2016 --no_exec --mc -n $EVENTS || exit $? ;

# End of HIG-RunIISummer20UL16HLT-03255_test.sh file
