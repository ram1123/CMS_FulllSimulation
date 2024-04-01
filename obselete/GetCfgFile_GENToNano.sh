#!/bin/bash
export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
scram p CMSSW CMSSW_10_6_30_patch1
cd CMSSW_10_6_30_patch1/src
eval `scram runtime -sh`

# Download fragment from McM
curl -s -k https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/EXO-RunIISummer20UL18wmLHEGEN-01092 --retry 3 --create-dirs -o Configuration/GenProduction/python/EXO-RunIISummer20UL18wmLHEGEN-01092-fragment.py
[ -s Configuration/GenProduction/python/EXO-RunIISummer20UL18wmLHEGEN-01092-fragment.py ]
scram b
cd ../..

cmsDriver.py Configuration/GenProduction/python/EXO-RunIISummer20UL18wmLHEGEN-01092-fragment.py --python_filename step_1_cfg.py  --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN,LHE --fileout file:EXO-RunIISummer20UL18wmLHEGEN-01092.root --conditions 106X_upgrade2018_realistic_v4 --beamspot Realistic25ns13TeVEarly2018Collision --step LHE,GEN --geometry DB:Extended --era Run2_2018 --no_exec --mc -n 10



scram p CMSSW CMSSW_10_6_17_patch1
cd CMSSW_10_6_17_patch1/src
eval `scram runtime -sh`

scram b
cd ../..

cmsDriver.py  --python_filename step_2_cfg.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:EXO-RunIISummer20UL18SIM-01290.root --conditions 106X_upgrade2018_realistic_v11_L1v1 --beamspot Realistic25ns13TeVEarly2018Collision --step SIM --geometry DB:Extended --filein file:EXO-RunIISummer20UL18wmLHEGEN-01092.root --era Run2_2018 --runUnscheduled --no_exec --mc -n -1


cmsDriver.py  --python_filename step_3_cfg.py --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI --fileout file:EXO-RunIISummer20UL18DIGIPremix-01390.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL18_106X_upgrade2018_realistic_v11_L1v1-v2/PREMIX" --conditions 106X_upgrade2018_realistic_v11_L1v1 --step DIGI,DATAMIX,L1,DIGI2RAW --procModifiers premix_stage2 --geometry DB:Extended --filein file:EXO-RunIISummer20UL18SIM-01290.root --datamix PreMix --era Run2_2018 --runUnscheduled --no_exec --mc -n -1

scram p CMSSW CMSSW_10_2_16_UL
cd CMSSW_10_2_16_UL/src
eval `scram runtime -sh`

scram b
cd ../..
cmsDriver.py  --python_filename step_4_cfg.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:EXO-RunIISummer20UL18HLT-01390.root --conditions 102X_upgrade2018_realistic_v15 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:2018v32 --geometry DB:Extended --filein file:EXO-RunIISummer20UL18DIGIPremix-01390.root --era Run2_2018 --no_exec --mc -n -1



export SCRAM_ARCH=slc7_amd64_gcc700
cd CMSSW_10_6_17_patch1/src
eval `scram runtime -sh`

scram b
cd ../..

cmsDriver.py  --python_filename step_5_cfg.py --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:EXO-RunIISummer20UL18RECO-01390.root --conditions 106X_upgrade2018_realistic_v11_L1v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --geometry DB:Extended --filein file:EXO-RunIISummer20UL18HLT-01390.root --era Run2_2018 --runUnscheduled --no_exec --mc -n -1



export SCRAM_ARCH=slc7_amd64_gcc700
scram p CMSSW CMSSW_10_6_25
cd CMSSW_10_6_25/src
eval `scram runtime -sh`

scram b
cd ../..

cmsDriver.py  --python_filename step_6_cfg.py --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:EXO-RunIISummer20UL18MiniAODv2-01346.root --conditions 106X_upgrade2018_realistic_v16_L1v1 --step PAT --procModifiers run2_miniAOD_UL --geometry DB:Extended --filein file:EXO-RunIISummer20UL18RECO-01390.root --era Run2_2018 --runUnscheduled --no_exec --mc -n -1


# NANO_AOD step
export SCRAM_ARCH=slc7_amd64_gcc700
scram p CMSSW CMSSW_10_6_26
cd CMSSW_10_6_26/src
eval `scram runtime -sh`
scram b
cd ../..

cmsDriver.py  --python_filename step_7_cfg.py --eventcontent NANOAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier NANOAODSIM --fileout file:EXO-RunIISummer20UL18NanoAODv9-01225.root --conditions 106X_upgrade2018_realistic_v16_L1v1 --step NANO --filein file:EXO-RunIISummer20UL18MiniAODv2-01346.root --era Run2_2018,run2_nanoAOD_106Xv2 --no_exec --mc -n -1
