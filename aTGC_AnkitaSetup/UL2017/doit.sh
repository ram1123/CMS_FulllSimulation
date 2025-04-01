#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
scram p CMSSW CMSSW_10_6_30_patch1
cd CMSSW_10_6_30_patch1/src
eval `scram runtime -sh`

# Download fragment from McM
curl -s -k https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/EXO-RunIISummer20UL17wmLHEGEN-01081 --retry 3 --create-dirs -o Configuration/GenProduction/python/EXO-RunIISummer20UL17wmLHEGEN-01081-fragment.py
[ -s Configuration/GenProduction/python/EXO-RunIISummer20UL17wmLHEGEN-01081-fragment.py ]

scram b
cd ../..

cmsDriver.py Configuration/GenProduction/python/EXO-RunIISummer20UL17wmLHEGEN-01081-fragment.py --python_filename step1_semi_cfg.py --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN,LHE --fileout file:EXO-RunIISummer20UL17wmLHEGEN-01081.root --conditions 106X_mc2017_realistic_v6 --beamspot Realistic25ns13TeVEarly2017Collision --step LHE,GEN --geometry DB:Extended --era Run2_2017 --no_exec --mc -n 10


