#!/bin/bash
##amexport SCRAM_ARCH=slc7_amd64_gcc700
##amsource /cvmfs/cms.cern.ch/cmsset_default.sh
##amscram p CMSSW CMSSW_10_6_19_patch3
##amcd CMSSW_10_6_19_patch3/src
##ameval `scram runtime -sh`
##am
##am# Download fragment from McM
##amcurl -s -k https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/SMP-RunIISummer20UL16wmLHEGEN-00060 --retry 3 --create-dirs -o Configuration/GenProduction/python/SMP-RunIISummer20UL16wmLHEGEN-00060-fragment.py
##am[ -s Configuration/GenProduction/python/SMP-RunIISummer20UL16wmLHEGEN-00060-fragment.py ]
##amscram b
##amcd ../..
##amcmsDriver.py Configuration/GenProduction/python/SMP-RunIISummer20UL16wmLHEGEN-00060-fragment.py --python_filename SMP-RunIISummer20UL16wmLHEGEN-00060_1_cfg.py --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN,LHE --fileout file:SMP-RunIISummer20UL16wmLHEGEN-00060.root --conditions 106X_mcRun2_asymptotic_v13 --beamspot Realistic25ns13TeV2016Collision --step LHE,GEN --geometry DB:Extended --era Run2_2016 --no_exec --mc -n 100
##amscram p CMSSW CMSSW_10_6_17_patch1
##amcd CMSSW_10_6_17_patch1/src
##ameval `scram runtime -sh`
##am
##amscram b
##amcd ../..
##amcmsDriver.py  --python_filename SMP-RunIISummer20UL16SIM-00047_1_cfg.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:SMP-RunIISummer20UL16SIM-00047.root --conditions 106X_mcRun2_asymptotic_v13 --beamspot Realistic25ns13TeV2016Collision --step SIM --geometry DB:Extended --filein file:SMP-RunIISummer20UL16wmLHEGEN-00060.root --era Run2_2016 --runUnscheduled --no_exec --mc -n -1

cmsDriver.py  --python_filename step_3_cfg.py --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI --fileout file:SMP-RunIISummer20UL16DIGIPremix-00044.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL16_106X_mcRun2_asymptotic_v13-v1/PREMIX" --conditions 106X_mcRun2_asymptotic_v13 --step DIGI,DATAMIX,L1,DIGI2RAW --procModifiers premix_stage2 --geometry DB:Extended --filein file:SMP-RunIISummer20UL16SIM-00047.root --datamix PreMix --era Run2_2016 --runUnscheduled --no_exec --mc -n -1

export SCRAM_ARCH=slc7_amd64_gcc530
scram p CMSSW CMSSW_8_0_33_UL
cd CMSSW_8_0_33_UL/src
eval `scram runtime -sh`

scram b
cd ../..

cmsDriver.py  --python_filename step_4_cfg.py  --eventcontent RAWSIM --outputCommand "keep *_mix_*_*,keep *_genPUProtons_*_*" --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --inputCommands "keep *","drop *_*_BMTF_*","drop *PixelFEDChannel*_*_*_*" --fileout file:SMP-RunIISummer20UL16HLT-00047.root --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:25ns15e33_v4 --geometry DB:Extended --filein file:SMP-RunIISummer20UL16DIGIPremix-00044.root --era Run2_2016 --no_exec --mc -n -1

export SCRAM_ARCH=slc7_amd64_gcc700
cd CMSSW_10_6_17_patch1/src
eval `scram runtime -sh`

scram b
cd ../..
cmsDriver.py  --python_filename step_5_cfg.py --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:SMP-RunIISummer20UL16RECO-00047.root --conditions 106X_mcRun2_asymptotic_v13 --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --filein file:SMP-RunIISummer20UL16HLT-00047.root --era Run2_2016 --runUnscheduled --no_exec --mc -n -1


export SCRAM_ARCH=slc7_amd64_gcc700
scram p CMSSW CMSSW_10_6_25
cd CMSSW_10_6_25/src
eval `scram runtime -sh`

scram b
cd ../..
cmsDriver.py  --python_filename step_6_cfg.py --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:SMP-RunIISummer20UL16MiniAODv2-00057.root --conditions 106X_mcRun2_asymptotic_v17 --step PAT --procModifiers run2_miniAOD_UL --geometry DB:Extended --filein file:SMP-RunIISummer20UL16RECO-00047.root --era Run2_2016 --runUnscheduled --no_exec --mc -n -1
