#!/bin/bash

# Step -1: wmLHE
export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
eval `scramv1 project CMSSW CMSSW_10_6_30_patch1` # cmsrel CMSSW_10_6_30_patch1
cd CMSSW_10_6_30_patch1/src
eval `scram runtime -sh` # cmsenv
cd -
cmsRun HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py

# Step -2: GEN-SIM
eval `scramv1 project CMSSW CMSSW_10_6_17_patch1` # cmsrel CMSSW_10_6_17_patch1
cd CMSSW_10_6_17_patch1/src
eval `scram runtime -sh` # cmsenv
cd -
cmsRun HIG-RunIISummer20UL17SIM-03436_1_cfg.py

# Step -3: Digi
cmsRun HIG-RunIISummer20UL17DIGIPremix-03436_1_cfg.py

# Step -4: HLT
eval `scramv1 project CMSSW CMSSW_9_4_14_UL_patch1` # cmsrel CMSSW_9_4_14_UL_patch1
cd CMSSW_9_4_14_UL_patch1/src
eval `scram runtime -sh` # cmsenv
cd -
cmsRun HIG-RunIISummer20UL17HLT-03435_1_cfg.py

# Step -5: reco
# eval `scramv1 project CMSSW CMSSW_10_6_17_patch1` # cmsrel CMSSW_10_6_17_patch1
cd CMSSW_10_6_17_patch1/src
eval `scram runtime -sh` # cmsenv
cd -
cmsRun HIG-RunIISummer20UL17RECO-03435_1_cfg.py

# Step -6 : MiniAOD
eval `scramv1 project CMSSW CMSSW_10_6_20` # cmsrel CMSSW_10_6_20
cd CMSSW_10_6_20/src
eval `scram runtime -sh` # cmsenv
cd -
cmsRun  HIG-RunIISummer20UL17MiniAODv2-03435_1_cfg.py

# Step -7 : nanoAOD
eval `scramv1 project CMSSW CMSSW_10_6_26` # cmsrel CMSSW_10_6_26
cd CMSSW_10_6_26/src
eval `scram runtime -sh` # cmsenv
cd -
cmsRun  HIG-RunIISummer20UL16NanoAODAPVv9-01726_1_cfg.py
