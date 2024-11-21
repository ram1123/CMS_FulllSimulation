#!/bin/bash
echo "Job started..."
echo "Starting job on " `date`
echo "Running on: `uname -a`"
echo "System software: `cat /etc/redhat-release`"
source /cvmfs/cms.cern.ch/cmsset_default.sh
echo "###################################################"
echo "#    List of Input Arguments: "
echo "###################################################"
echo "Input Arguments (Cluster ID): $1"
echo "Input Arguments (Proc ID): $2"
echo "Input Arguments (Gridpack with path): $3"
echo "Input Arguments (Output Dir): $4"

echo "i am here ${PWD}"



seed=$(($1 + ${2} + ${2} + 2089))

basePath=${PWD}
step1=CMSSW_10_6_30_patch1
step2=CMSSW_10_6_17_patch1
step3=CMSSW_10_6_17_patch1
step4=CMSSW_9_4_14_UL_patch1
step5=CMSSW_10_6_17_patch1
step6=CMSSW_10_6_20
step7=CMSSW_10_6_26
outDir=${4}


cat step1_cfg.py > dummy.txt
#sed -i "s/GRIDPACK/${3}/g" dummy.txt
sed -e "s|GRIDPACK|${3}|g" dummy.txt > dummy.py



