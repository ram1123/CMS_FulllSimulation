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

seed=$(($1 + ${2} + 1498))
#seed=123
basePath=${PWD}
step1=CMSSW_10_6_28_patch1
step2=CMSSW_10_6_17_patch1
step3=CMSSW_10_6_17_patch1
step4=CMSSW_8_0_33_UL
step5=CMSSW_10_6_17_patch1
step6=CMSSW_10_6_25
step7=CMSSW_10_6_26
outDir=${4}

[ ! -d "$outDir" ] && mkdir -p "$outDir"
cat step_1_prevfp_LO_cfg.py  > dummy.txt
#cat step_1_prevfp_cfg.py > dummy.txt
sed -e "s|GRIDPACK|${3}|g" dummy.txt > step_1_prevfp_cfg.py
step12356arch=slc7_amd64_gcc700
step4arch=slc7_amd64_gcc530


for i in {1..7}
do

    if [[ $i -eq 4 ]];then
	echo here	
	arch=${step4arch}
    else
	arch=${step12356arch}
    fi
    cmssw=step$i
    export SCRAM_ARCH=${arch}
    echo $i,${arch},${!cmssw}
    source /cvmfs/cms.cern.ch/cmsset_default.sh
    if [ -r ${!cmssw}/src ] ; then
	echo release ${!cmssw} already exists
    else
	scram p CMSSW ${!cmssw}
    fi
    cd ${!cmssw}/src
    if [ "${!cmssw}" = "CMSSW_10_6_26" ]; then
        echo "step - ${i}7"
	cp -r /afs/cern.ch/user/a/anmehta/public/osWW_vbs_fullsim/test_nanowts/UL2018/PhysicsTools .
	#cp -r /afs/cern.ch/user/a/anmehta/public/osWW_vbs_fullsim/test_nanowts/UL2018/initrwgt_aQGC16.header .
	cp -r /afs/cern.ch/user/a/anmehta/public/osWW_vbs_fullsim/test_nanowts/UL2018/${5}  initrwgt_aQGC16.header   #for smeft samples
    else
        echo "step - ${i} "
    fi
    export HOME=$PWD
    cmsenv
    #eval `scram runtime -sh`
    cp $basePath/step_${i}_prevfp_cfg.py .
    scram b    

    if [ $i -eq 1 ]
    then	
	cmsRun step_${i}_prevfp_cfg.py seedval=${seed}  > /dev/null
    else
	cmsrelnm1=step$((i-1))
	cp $basePath/${!cmsrelnm1}/src/*root .
	cmsRun step_${i}_prevfp_cfg.py
    fi
    cd $basePath/
done


cp ${step7}/src/nanoaod_prevfp.root ${outDir}/SMP-RunIISummer20UL16prevfpNanoAODv9_${seed}.root

