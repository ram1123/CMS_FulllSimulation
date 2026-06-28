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
echo "Input Arguments (Output Dir): $4"
echo "Input Arguments Gridpack name: $3"

echo "i am here ${PWD}"

seed=$((${1} + ${2} + 1734))
#seed=123
basePath=${PWD}
step1=CMSSW_10_6_30_patch1
step2=CMSSW_10_6_17_patch1
step3=CMSSW_10_6_17_patch1
step4=CMSSW_10_2_16_UL
step5=CMSSW_10_6_17_patch1
step6=CMSSW_10_6_25
step7=CMSSW_10_6_26
outDir=${4}
[ ! -d "${outDir}" ] && mkdir -p "${outDir}"

#cat step_1_cfg.py > dummy.txt
cat step_1_LO_cfg.py  > dummy.txt
sed -e "s|GRIDPACK|${3}|g" dummy.txt > step_1_cfg.py

for i in {1..7}
do
    cmssw=step$i
    export SCRAM_ARCH=slc7_amd64_gcc700
    echo $i,${!cmssw}
    source /cvmfs/cms.cern.ch/cmsset_default.sh
    if [ -r ${!cmssw}/src ] ; then
        echo release ${!cmssw} already exists
    else
        scram p CMSSW ${!cmssw}
    fi
    cd ${!cmssw}/src
    export HOME=$PWD
    eval `scram runtime -sh`
    cp $basePath/step_${i}_cfg.py .
    scram b
    if [ "${!cmssw}" = "CMSSW_10_6_26" ]; then
        echo "step - ${i}7"
	cp -r /afs/cern.ch/user/a/anmehta/public/osWW_vbs_fullsim/test_nanowts/UL2018/PhysicsTools .
	#cp -r /afs/cern.ch/user/a/anmehta/public/osWW_vbs_fullsim/test_nanowts/UL2018/initrwgt_aQGC16.header . # for aTGC samples
	#cp -r /afs/cern.ch/user/a/anmehta/public/osWW_vbs_fullsim/test_nanowts/UL2018/initrwgt_aQGC16_smeft.header  initrwgt_aQGC16.header   #for smeft samples
	cp -r /afs/cern.ch/user/a/anmehta/public/osWW_vbs_fullsim/test_nanowts/UL2018/${5}  initrwgt_aQGC16.header   #for smeft samples
    else
        echo "step - ${i} "
    fi
    export HOME=$PWD
    eval `scram runtime -sh`
    echo `pwd`
    scramv1 b -j2
    ls
    if [ $i -eq 1 ]
    then
	echo "runnning step_${i}_cfg.py"
	ls
        cmsRun step_${i}_cfg.py seedval=${seed} > /dev/null
        echo "================================================= list of files"
        ls *.root
        echo "================================================="
    else
        echo "runnning step_${i}_cfg.py"
        cmsrelnm1=step$((i-1))
	cp $basePath/${!cmsrelnm1}/src/*root .
        cmsRun step_${i}_cfg.py > /dev/null
	echo "i am done copying "
        echo "================================================= list of files"
        ls -ltrh *.root
        echo "================================================="
    fi
    cd ${basePath}/
done


echo "cp ${step7}/src/EXO-RunIISummer20UL18NanoAODv9-01225.root ${outDir}/EXO-RunIISummer20UL18NanoAODv9_${seed}.root"
cp ${step7}/src/EXO-RunIISummer20UL18NanoAODv9-01225.root ${outDir}/EXO-RunIISummer20UL18NanoAODv9_${seed}.root

echo "Ending job on " `date`
