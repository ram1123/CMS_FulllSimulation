#!/bin/bash

echo "Job started..."
echo "Starting job on " $(date)
echo "Running on: $(uname -a)"
echo "System software: $(cat /etc/redhat-release)"
source /cvmfs/cms.cern.ch/cmsset_default.sh
echo "###################################################"
echo "#    List of Input Arguments: "
echo "###################################################"
echo "Input Arguments (Cluster ID): $1"
echo "Input Arguments (Proc ID): $2"
echo "Input Arguments (Output Dir): $3"
echo "Input Arguments (Gridpack with path): $4"
echo "Input Arguments (maxEvents): $5"
echo ""

export SCRAM_ARCH=slc7_amd64_gcc700

# Setting up CMSSW versions and configuration files
step1=CMSSW_10_6_30_patch1
step1_cfg=HIG-RunIISummer20UL17wmLHEGEN-03707_1_cfg.py
step2=CMSSW_10_6_17_patch1
step2_cfg=HIG-RunIISummer20UL17SIM-03331_1_cfg.py
step3=CMSSW_10_6_17_patch1
step3_cfg=HIG-RunIISummer20UL17DIGIPremix-03331_1_cfg.py
step4=CMSSW_9_4_14_UL_patch1
step4_cfg=HIG-RunIISummer20UL17HLT-03331_1_cfg.py
step5=CMSSW_10_6_17_patch1
step5_cfg=HIG-RunIISummer20UL17RECO-03331_1_cfg.py
step6=CMSSW_10_6_20
step6_cfg=HIG-RunIISummer20UL17MiniAODv2-03331_1_cfg.py
step7=CMSSW_10_6_26
step7_cfg=HIG-RunIISummer20UL17NanoAODv9-03735_1_cfg.py

seed=$(($1 + $2))

echo "###################################################"
echo "Running step1..."
if [ -r ${step1}/src ] ; then
    echo release ${step1} already exists
else
    scram p CMSSW ${step1}
fi
cd ${step1}/src
eval `scram runtime -sh`
scram b
cd -
cmsRun ${step1_cfg} seedval=${seed} maxEvents=${5} gridpack=${4}
echo "###################################################"
echo "Running step2..."
if [ -r ${step2}/src ] ; then
    echo release ${step2} already exists
else
    scram p CMSSW ${step2}
fi
cd ${step2}/src
eval `scram runtime -sh`
scram b
cd -
cmsRun ${step2_cfg}
echo "###################################################"
echo "Running step3..."
if [ -r ${step3}/src ] ; then
    echo release ${step3} already exists
else
    scram p CMSSW ${step3}
fi
cd ${step3}/src
eval `scram runtime -sh`
scram b
cd -
cmsRun ${step3_cfg}
echo "###################################################"
echo "Running step4..."
if [ -r ${step4}/src ] ; then
    echo release ${step4} already exists
else
    scram p CMSSW ${step4}
fi
cd ${step4}/src
eval `scram runtime -sh`
scram b
cd -
cmsRun ${step4_cfg}
echo "###################################################"
echo "Running step5..."
if [ -r ${step5}/src ] ; then
    echo release ${step5} already exists
else
    scram p CMSSW ${step5}
fi
cd ${step5}/src
eval `scram runtime -sh`
scram b
cd -
cmsRun ${step5_cfg}
echo "###################################################"
echo "Running step6..."
if [ -r ${step6}/src ] ; then
    echo release ${step6} already exists
else
    scram p CMSSW ${step6}
fi
cd ${step6}/src
eval `scram runtime -sh`
scram b
cd -
cmsRun ${step6_cfg}
echo "###################################################"
echo "Running step7..."
if [ -r ${step7}/src ] ; then
    echo release ${step7} already exists
else
    scram p CMSSW ${step7}
fi
cd ${step7}/src
eval `scram runtime -sh`
scram b
cd -
cmsRun ${step7_cfg}

echo "Job finished"
