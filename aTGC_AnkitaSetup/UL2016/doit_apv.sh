#!/bin/bash

cd CMSSW_10_6_27/src
eval `scram runtime -sh`

# Download fragment from McM
curl -s -k https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/SMP-RunIISummer20UL16wmLHEGENAPV-00303 --retry 3 --create-dirs -o Configuration/GenProduction/python/SMP-RunIISummer20UL16wmLHEGENAPV-00303-fragment.py
[ -s Configuration/GenProduction/python/SMP-RunIISummer20UL16wmLHEGENAPV-00303-fragment.py ] 
scram b
cd ../..
cmsDriver.py Configuration/GenProduction/python/SMP-RunIISummer20UL16wmLHEGENAPV-00303-fragment.py --python_filename step_1_apv_cfg.py --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN,LHE --fileout file:SMP-RunIISummer20UL16wmLHEGENAPV-00303.root --conditions 106X_mcRun2_asymptotic_preVFP_v8 --beamspot Realistic25ns13TeV2016Collision --step LHE,GEN --geometry DB:Extended --era Run2_2016_HIPM --no_exec --mc -n 100

#####step2

cd CMSSW_10_6_17_patch1/src
eval `scram runtime -sh`

scram b
cd ../..

cmsDriver.py  --python_filename step_2_apv_cfg.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:SMP-RunIISummer20UL16SIMAPV-00100.root --conditions 106X_mcRun2_asymptotic_preVFP_v8 --beamspot Realistic25ns13TeV2016Collision --step SIM --geometry DB:Extended --filein file:SMP-RunIISummer20UL16wmLHEGENAPV-00303.root --era Run2_2016_HIPM --runUnscheduled --no_exec --mc -n -1

cmsDriver.py  --python_filename step_3_apv_cfg.py --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI --fileout file:SMP-RunIISummer20UL16DIGIPremixAPV-00093.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL16_106X_mcRun2_asymptotic_v13-v1/PREMIX" --conditions 106X_mcRun2_asymptotic_preVFP_v8 --step DIGI,DATAMIX,L1,DIGI2RAW --procModifiers premix_stage2 --geometry DB:Extended --filein file:SMP-RunIISummer20UL16SIMAPV-00100.root --datamix PreMix --era Run2_2016_HIPM --runUnscheduled --no_exec --mc -n -1





cd CMSSW_8_0_33_UL/src
eval `scram runtime -sh`

scram b
cd ../..

cmsDriver.py  --python_filename step_4_apv_cfg.py --eventcontent RAWSIM --outputCommand "keep *_mix_*_*,keep *_genPUProtons_*_*" --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --inputCommands "keep *","drop *_*_BMTF_*","drop *PixelFEDChannel*_*_*_*" --fileout file:SMP-RunIISummer20UL16HLTAPV-00100.root --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:25ns15e33_v4 --geometry DB:Extended --filein file:SMP-RunIISummer20UL16DIGIPremixAPV-00093.root --era Run2_2016 --no_exec --mc -n -1



cd CMSSW_10_6_17_patch1/src
eval `scram runtime -sh`

scram b
cd ../..
cmsDriver.py  --python_filename step_5_apv_cfg.py --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:SMP-RunIISummer20UL16RECOAPV-00100.root --conditions 106X_mcRun2_asymptotic_preVFP_v8 --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --filein file:SMP-RunIISummer20UL16HLTAPV-00100.root --era Run2_2016_HIPM --runUnscheduled --no_exec --mc -n -1


cd CMSSW_10_6_25/src
eval `scram runtime -sh`

scram b
cd ../..

cmsDriver.py  --python_filename step_6_apv_cfg.py --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:SMP-RunIISummer20UL16MiniAODAPVv2-00073.root --conditions 106X_mcRun2_asymptotic_preVFP_v11 --step PAT --procModifiers run2_miniAOD_UL --geometry DB:Extended --filein file:SMP-RunIISummer20UL16RECOAPV-00100.root --era Run2_2016_HIPM --runUnscheduled --no_exec --mc -n -1


