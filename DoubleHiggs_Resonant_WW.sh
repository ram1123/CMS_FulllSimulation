#!/bin/bash
echo "Starting job on " `date`
echo "Running on: `uname -a`"
echo "System software: `cat /etc/redhat-release`"
source /cvmfs/cms.cern.ch/cmsset_default.sh
echo "###################################################"
echo "#    List of Input Arguments: "
echo "###################################################"
echo "Input Arguments (Cluster ID): $1"
echo "Input Arguments (Proc ID): $2"
echo "Input Arguments (Config file name): $3"
echo "Input Arguments (Dir name with date tag): $4"
echo "Input Arguments (gridpack name with path): $5"
echo "Input Arguments (Dir name): $6"
echo "###################################################"

OUTDIR=/eos/user/r/rasharma/post_doc_ihep/double-higgs/PvtProduction/Radion/DoubleHiggs_Resonant_WW/${4}/

echo "======="
ls -ltrh
echo "======"

echo $PWD
export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
echo "First step: wmLHE"
eval `scramv1 project CMSSW CMSSW_10_6_30_patch1`
cd CMSSW_10_6_30_patch1/src/
# set cmssw environment
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> List all files..."
ls -ltrh
echo "+=============================="
echo "==> Update the gridpack path:"
sed -i "s/args = cms.vstring.*/args = cms.vstring(\"${5}\"),/g" HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py 
echo "+=============================="
echo "Print lines having gridpack path"
sed -n 153,160p HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py  
echo "+=============================="
cmsRun HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py  
echo "==> List all files..."
ls -ltrh
echo "List all root files = "
ls -ltrh *.root
echo "+=============================="
date
echo "+=============================="

echo "Second step: genSIM"
eval `scramv1 project CMSSW CMSSW_10_6_17_patch1`
cd CMSSW_10_6_17_patch1/src
echo "pwd : ${PWD}"
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> List all files..."
echo "pwd : ${PWD}"
ls -ltrh
echo "+=============================="
echo "==> cmsRun HIG-RunIISummer20UL17SIM-03436_1_cfg.py" 
cmsRun HIG-RunIISummer20UL17SIM-03436_1_cfg.py  
echo "List all root files = "
ls -ltrh *.root
echo "+=============================="
echo "Third step: digi"
cmsRun HIG-RunIISummer20UL17DIGIPremix-03436_1_cfg.py
echo "List all root files = "
ls -ltrh *.root
echo "+=============================="
echo "Fourth step: HLT"
eval `scramv1 project CMSSW CMSSW_9_4_14_UL_patch1`
cd CMSSW_9_4_14_UL_patch1/src
echo "pwd : ${PWD}"
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> cmsRun HIG-RunIISummer20UL17HLT-03435_1_cfg.py"
cmsRun HIG-RunIISummer20UL17HLT-03435_1_cfg.py 
echo "List all root files = "
ls -ltrh *.root
echo "+=============================="
echo "Fifth step: RECO"
eval `scramv1 project CMSSW CMSSW_10_6_17_patch1`
cd CMSSW_10_6_17_patch1/src
echo "pwd : ${PWD}"
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> cmsRun HIG-RunIISummer20UL17RECO-03435_1_cfg.py"
cmsRun HIG-RunIISummer20UL17RECO-03435_1_cfg.py
echo "========================="
echo "==> List all files..."
echo "pwd : ${PWD}"
ls -ltrh
echo "+=============================="
echo "List all root files = "
ls -ltrh *.root
echo "+=============================="
echo "Sixth step: MiniAOD"
eval `scramv1 project CMSSW CMSSW_10_6_20`
cd CMSSW_10_6_20/src
echo "pwd : ${PWD}"
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> cmsRun HIG-RunIISummer20UL17MiniAODv2-03435_1_cfg.py"
cmsRun HIG-RunIISummer20UL17MiniAODv2-03435_1_cfg.py
echo "========================="
echo "==> List all files..."
echo "pwd : ${PWD}"
ls -ltrh
echo "+=============================="
echo "List all root files = "
ls -ltrh *.root
# copy output to eos
echo "xrdcp output for condor"
cp HIG-RunIISummer20UL17MiniAODv2-03435.root ${OUTDIR}/out_miniAOD_${6}_${1}_${2}.root
echo "+=============================="
echo "Seventh step: nanoAOD"
eval `scramv1 project CMSSW CMSSW_10_6_26`
cd CMSSW_10_6_26/src
echo "pwd : ${PWD}"
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> cmsRun   HIG-RunIISummer20UL16NanoAODAPVv9-01726_1_cfg.py"
cmsRun  HIG-RunIISummer20UL16NanoAODAPVv9-01726_1_cfg.py
echo "========================="
echo "==> List all files..."
echo "pwd : ${PWD}"
ls -ltrh
echo "+=============================="
echo "List all root files = "
ls -ltrh *.root
echo "+=============================="

# copy output to eos
echo "xrdcp output for condor"
cp HIG-RunIISummer20UL16NanoAODAPVv9-01726.root ${OUTDIR}/out_nanoAOD_${6}_${1}_${2}.root
echo "+=============================="
date

