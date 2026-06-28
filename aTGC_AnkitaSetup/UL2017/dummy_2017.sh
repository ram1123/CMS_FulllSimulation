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



seed=$(($1 + ${2} + 1289))
#seed=123
basePath=${PWD}
step1=CMSSW_10_6_30_patch1
step2=CMSSW_10_6_17_patch1
step3=CMSSW_10_6_17_patch1
step4=CMSSW_9_4_14_UL_patch1
step5=CMSSW_10_6_17_patch1
step6=CMSSW_10_6_20
step7=CMSSW_10_6_26
outDir=${4}
[ ! -d "$outDir" ] && mkdir -p "$outDir"

#cat step1_cfg.py > dummy.txt
cat step_1_LO_cfg.py > dummy.txt
sed -e "s|GRIDPACK|${3}|g" dummy.txt > step1_cfg.py  
#since / are there in the path name else use sed -e "s/GRIDPACK/${3}/g" dummy.txt > dummy.py

step12356arch=slc7_amd64_gcc700
step4arch=slc7_amd64_gcc630

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
	#cp -r /afs/cern.ch/user/a/anmehta/public/osWW_vbs_fullsim/test_nanowts/UL2018/initrwgt_aQGC16.header .  # for aTGC samples
	cp -r /afs/cern.ch/user/a/anmehta/public/osWW_vbs_fullsim/test_nanowts/UL2018/${5}  initrwgt_aQGC16.header   #for smeft samples
    else
        echo "step - ${i} "
    fi
    export HOME=$PWD
    cmsenv
    #eval `scram runtime -sh`
    cp $basePath/step${i}_cfg.py .
    scram b    
    
    if [ $i -eq 1 ]
    then	
	cmsRun step${i}_cfg.py seedval=${seed}  > /dev/null
	echo "================================================= list of files"
	ls *.root
    else
	echo "runnning step${i}_cfg.py"
	cmsrelnm1=step$((i-1))
	cp $basePath/${!cmsrelnm1}/src/*root .
	cmsRun step${i}_cfg.py
    fi
    cd $basePath/
done

echo "cp ${step7}/src/SMP-RunIISummer20UL17NanoAODv9-00017.root ${outDir}/SMP-RunIISummer20UL17NanoAODv9_${seed}.root"
cp ${step7}/src/SMP-RunIISummer20UL17NanoAODv9-00017.root ${outDir}/SMP-RunIISummer20UL17NanoAODv9_${seed}.root


##amfname=RunIISummer20UL17MiniAODv2_${seed}.root
##ammv ${step6}/src/SMP-RunIISummer20UL17MiniAODv2-00089.root ${step6}/src/${fname}
##amcd ${step6}/src/
##ameval `scram unsetenv -sh`; gfal-copy -n 1 "file:////`pwd`/${fname}" "srm://dcache-se-cms.desy.de:8443/${outDir}/${fname}"



##amcp ${step6}/src/*RunIISummer20UL17MiniAODv2*.root ${outDir}/RunIISummer20UL17MiniAODv2_${seed}.root



##amcp ${basePath}/step1_cfg.py .
##amcmsRun step1_cfg.py seedval=${seed} > /dev/null
##am#cp SMP-RunIISummer20UL17wmLHEGEN-00306.root ${basePath}/
##am
##amcd ${basePath}/
##amscram p CMSSW CMSSW_10_6_17_patch1
##amcd CMSSW_10_6_17_patch1/src
##ameval `scram runtime -sh`
##amscram b
##am#cp ${basePath}/SMP-RunIISummer20UL17wmLHEGEN-00306.root .
##amln -sf ${basePath}/CMSSW_10_6_27/src/SMP-RunIISummer20UL17wmLHEGEN-00306.root SMP-RunIISummer20UL17wmLHEGEN-00306.root
##amcp ${basePath}/step* .
##amcmsRun step2_cfg.py
##amcmsRun step3_cfg.py
##am
##am#cp SMP-RunIISummer20UL17DIGIPremix-00091.root ${basePath}/
##amcd ${basePath}
##amexport SCRAM_ARCH=slc7_amd64_gcc630
##amscram p CMSSW CMSSW_9_4_14_UL_patch1
##amcd CMSSW_9_4_14_UL_patch1/src
##ameval `scram runtime -sh`
##amln -sf ${basePath}/CMSSW_10_6_17_patch1/src/SMP-RunIISummer20UL17DIGIPremix-00091.root SMP-RunIISummer20UL17DIGIPremix-00091.root
##am#cp ${basePath}/CMSSW_10_6_17_patch1/src/SMP-RunIISummer20UL17DIGIPremix-00091.root .
##amscram b
##amcp ${basePath}/step4* .
##amcmsRun step4_cfg.py
##am
##amcd ${basePath}/CMSSW_10_6_17_patch1/src
##ameval `scram runtime -sh`
##amln -sf  ${basePath}/CMSSW_9_4_14_UL_patch1/src/SMP-RunIISummer20UL17HLT-00091.root SMP-RunIISummer20UL17HLT-00091.root
##amcmsRun step5_cfg.py
##amcd ${basePath}/
##am
##amexport SCRAM_ARCH=slc7_amd64_gcc700
##amscram p CMSSW CMSSW_10_6_20
##amcd CMSSW_10_6_20/src
##ameval `scram runtime -sh`
##amcp ${basePath}/step6* .
##amscram b
##amln -sf ${basePath}/CMSSW_10_6_17_patch1/src/SMP-RunIISummer20UL17RECO-00091.root SMP-RunIISummer20UL17RECO-00091.root
##amcmsRun step6_cfg.py
##am
##amcp SMP-RunIISummer20UL17MiniAODv2-00089.root ${outDir}/miniaod_${seed}.root
