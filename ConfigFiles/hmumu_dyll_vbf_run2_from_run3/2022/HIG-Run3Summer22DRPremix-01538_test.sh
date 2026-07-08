#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_6_17/src ] ; then
  echo release CMSSW_10_6_17 already exists
else
  scram p CMSSW CMSSW_10_6_17
fi
cd CMSSW_10_6_17/src
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
# Time per event (s): 36
# Target input events: 100
# Target output events: 100
# This validation will be computed based on the target output events!
EVENTS=100


# cmsDriver command
cmsDriver.py  --era Run2_2017 --customise Configuration/DataProcessing/Utils.addMonitoring --procModifiers premix_stage2 --datamix PreMix --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2e34v40 --geometry DB:Extended --conditions 106X_mc2017_realistic_v6 --datatier GEN-SIM-RAW --eventcontent PREMIXRAW --python_filename HIG-Run3Summer22DRPremix-01538_1_cfg.py --fileout file:HIG-Run3Summer22DRPremix-01538_0.root --filein file:HIG-Run3Summer22wmLHEGS-02640.root --number 100 --number_out 100 --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL17_106X_mc2017_realistic_v6-v3/PREMIX" --no_exec --mc || exit $? ;

# cmsDriver command
cmsDriver.py  --era Run2_2017 --customise Configuration/DataProcessing/Utils.addMonitoring --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --conditions 106X_mc2017_realistic_v6 --datatier AODSIM --eventcontent AODSIM --python_filename HIG-Run3Summer22DRPremix-01538_2_cfg.py --fileout file:HIG-Run3Summer22DRPremix-01538.root --filein file:HIG-Run3Summer22DRPremix-01538_0.root --number 100 --number_out 100 --no_exec --mc || exit $? ;

# End of HIG-Run3Summer22DRPremix-01538_test.sh file
