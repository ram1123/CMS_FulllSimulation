#!/bin/bash
echo "Starting job on " `date`
echo "Running on: `uname -a`"

echo "i am here ${PWD}"

seed=$((${1} + ${2} + 189))
#seed=123
basePath=${PWD}
step1=CMSSW_10_6_30_patch1
step2=CMSSW_10_6_17_patch1
step3=CMSSW_10_6_17_patch1
step4=CMSSW_10_2_16_UL
step5=CMSSW_10_6_17_patch1
step6=CMSSW_10_6_25
step7=CMSSW_10_6_26
outDir=/eos/user/r/rasharma/post_doc_ihep/aTGC/nanoAODnTuples/UL202018_12Jan2023
[ ! -d "${outDir}" ] && mkdir -p "${outDir}"


arch=slc7_amd64_gcc700


for i in {1..7}
do
    cmssw=step$i
    export SCRAM_ARCH=slc7_amd64_gcc700
    echo "i am here ${PWD}"
    echo $i,${arch},${!cmssw}
    source /cvmfs/cms.cern.ch/cmsset_default.sh
    if [ -r ${!cmssw}/src ] ; then
        echo release ${!cmssw} already exists
    else
        scram p CMSSW ${!cmssw}
    fi
    cd ${!cmssw}/src
    export HOME=$PWD
    eval `scram runtime -sh`
    scram b
    cd -
    echo "runnning step_${i}_cfg.py"
    if [ $i -eq 1 ]
    then
        cmsRun step_${i}_cfg.py seedval=${seed}
        echo "================================================="
        echo "List the root files"
        ls *.root
        echo "================================================="
    else
        echo "runnning step_${i}_cfg.py"
        cmsrelnm1=step$((i-1))
        cmsRun step_${i}_cfg.py
        echo "================================================="
        echo "List the root files"
        ls *.root
        echo "================================================="
    fi
    cd ${basePath}/
done


cp EXO-RunIISummer20UL18NanoAODv9-01225.root ${outDir}/EXO-RunIISummer20UL18NanoAODv9_${seed}.root

echo "Ending job on " `date`
