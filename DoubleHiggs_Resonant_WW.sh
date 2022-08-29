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
ls
echo "======"

echo $PWD
export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
eval `scramv1 project CMSSW CMSSW_10_6_30_patch1`
cd CMSSW_10_6_30_patch1/src/
# set cmssw environment
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> List all files..."
ls 
echo "+=============================="
echo "==> Running wmLHE step (1001 events will be generated)"
sed -i "s/args = cms.vstring.*/args = cms.vstring(\"${5}\"),/g" HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py 
echo "+=============================="
echo "Print lines having gridpack path"
# cat HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py  
 sed -n 153,160p HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py  
echo "+=============================="
cmsRun HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py  
echo "List all root files = "
ls *.root
echo "List all files"
ls 
echo "==> List all files..."
ls *.root 
echo "+=============================="
date
echo "+=============================="

echo "Loading CMSSW env DR1, DR2 and MiniAOD"

# as LHE and DR/MINIAOD are in different CMSSW reelase so change CMSSW environment
eval `scramv1 project CMSSW CMSSW_10_6_17_patch1`
cd CMSSW_10_6_17_patch1/src
echo "pwd : ${PWD}"
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> List all files..."
echo "pwd : ${PWD}"
ls 
echo "+=============================="
echo "==> cmsRun HIG-RunIISummer20UL17SIM-03436_1_cfg.py" 
cmsRun HIG-RunIISummer20UL17SIM-03436_1_cfg.py  
cmsRun HIG-RunIISummer20UL17DIGIPremix-03436_1_cfg.py
# as LHE and DR/MINIAOD are in different CMSSW reelase so change CMSSW environment
eval `scramv1 project CMSSW CMSSW_9_4_14_UL_patch1`
cd CMSSW_9_4_14_UL_patch1/src
echo "pwd : ${PWD}"
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> cmsRun HIG-RunIISummer20UL17HLT-03435_1_cfg.py"
cmsRun HIG-RunIISummer20UL17HLT-03435_1_cfg.py 
# as LHE and DR/MINIAOD are in different CMSSW reelase so change CMSSW environment
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
ls 
echo "+=============================="
echo "List all root files = "
ls *.root
echo "List all files"
ls 
echo "+=============================="
# as LHE and DR/MINIAOD are in different CMSSW reelase so change CMSSW environment
eval `scramv1 project CMSSW CMSSW_10_6_20`
cd CMSSW_10_6_20/src
echo "pwd : ${PWD}"
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> cmsRunHIG-RunIISummer20UL17MiniAODv2-03435_1_cfg.py"
cmsRunHIG-RunIISummer20UL17MiniAODv2-03435_1_cfg.py
echo "========================="
echo "==> List all files..."
echo "pwd : ${PWD}"
ls 
echo "+=============================="
echo "List all root files = "
ls *.root
echo "List all files"
ls 
echo "+=============================="
# as LHE and DR/MINIAOD are in different CMSSW reelase so change CMSSW environment
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
ls 
echo "+=============================="
echo "List all root files = "
ls *.root
echo "List all files"
ls 
echo "+=============================="

# copy output to eos
echo "xrdcp output for condor"
echo "========================="
echo "==> List all files..."
ls *.root 
echo "+=============================="
echo "xrdcp output for condor"
cp HIG-RunIISummer20UL16NanoAODAPVv9-01726.root ${OUTDIR}/out_nanoAOD_${6}_${1}_${2}.root
echo "========================="
echo "==> List all files..."
ls *.root 
echo "+=============================="
date

