#!/bin/bash
set -e

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
echo "Input Arguments (output file): $6"
echo ""

# Setting up CMSSW versions and configuration files
step1=CMSSW_10_6_17
step1_cfg=HIG-Run3Summer22wmLHEGS-02640_1_cfg.py
step2=CMSSW_10_6_17
step2_cfg=B2G-RunIISummer20UL17DIGIPremix-05659_1_cfg.py
step3=CMSSW_9_4_14_UL
step3_cfg=B2G-RunIISummer20UL17HLT-05659_1_cfg.py
step4=CMSSW_10_6_17
step4_cfg=B2G-RunIISummer20UL17RECO-05659_1_cfg.py
step5=CMSSW_10_6_20
step5_cfg=B2G-RunIISummer20UL17MiniAODv2-05659_1_cfg.py
step6=CMSSW_10_6_32
step6_cfg=B2G-RunIISummer20UL17NanoAODv9-05660_1_cfg.py

seed=$(($1 + $2))

echo "###################################################"
echo "Running step1..."
export SCRAM_ARCH=slc7_amd64_gcc700
if [ ! -r ${step1}/src ] ; then
    scram p CMSSW ${step1}
fi
echo "--------"
cd ${step1}/src
eval `scram runtime -sh`
scram b
cd -
cmsRun ${step1_cfg} seedval=${seed} maxEvents=${5} gridpack=${4}
echo "list all files"
ls -ltrh
echo "###################################################"
echo "Running step2..."
export SCRAM_ARCH=slc7_amd64_gcc700
if [ ! -r ${step2}/src ] ; then
    scram p CMSSW ${step2}
fi
echo "--------"
cd ${step2}/src
eval `scram runtime -sh`
scram b
cd -
cmsRun ${step2_cfg}
echo "list all files"
ls -ltrh
echo "###################################################"
echo "Running step3..."
export SCRAM_ARCH=slc7_amd64_gcc630
if [ ! -r ${step3}/src ] ; then
    scram p CMSSW ${step3}
fi
echo "--------"
cd ${step3}/src
eval `scram runtime -sh`
scram b
cd -
cmsRun ${step3_cfg}
echo "list all files"
ls -ltrh
echo "###################################################"
echo "Running step4..."
export SCRAM_ARCH=slc7_amd64_gcc700
if [ ! -r ${step4}/src ] ; then
    scram p CMSSW ${step4}
fi
echo "--------"
cd ${step4}/src
eval `scram runtime -sh`
scram b
cd -
cmsRun ${step4_cfg}
echo "list all files"
ls -ltrh
echo "###################################################"
echo "Running step5..."
export SCRAM_ARCH=slc7_amd64_gcc700
if [ ! -r ${step5}/src ] ; then
    scram p CMSSW ${step5}
fi
echo "--------"
cd ${step5}/src
eval `scram runtime -sh`
scram b
cd -
cmsRun ${step5_cfg}
echo "list all files"
ls -ltrh
echo "###################################################"
echo "Running step6..."
export SCRAM_ARCH=slc7_amd64_gcc700
if [ ! -r ${step6}/src ] ; then
    scram p CMSSW ${step6}
fi
echo "--------"
cd ${step6}/src
eval `scram runtime -sh`
scram b
cd -
cmsRun ${step6_cfg}
echo "list all files"
ls -ltrh

# Copy output nanoAOD file to output directory
echo "Copying output nanoAOD file to output directory"
ls -ltrh
echo "cp -r $6 $3/nanoAOD_$1_$2.root"
cp -r $6 $3/nanoAOD_$1_$2.root
echo "Job finished on " $(date)
