import os
from gridpack_lists import models

CondorExecutable = "test"
outputDirName = "/eos/user/r/rasharma/post_doc_ihep/aTGC/nanoAODnTuples/aTGC_SignalSamples/"
CondorQueue = "testmatch" # espresso, testmatch
queue = 1000 # Number of jobs

sh_file_template = '''#!/bin/bash

echo "{test}"
echo "Starting job on " `date`
echo "Running on: `uname -a`"
echo "System software: `cat /etc/redhat-release`"
source /cvmfs/cms.cern.ch/cmsset_default.sh
echo "###################################################"
echo "#    List of Input Arguments: "
echo "###################################################"
echo "Input Arguments (Cluster ID): $1"
echo "Input Arguments (Proc ID): $2"
echo "Input Arguments (Output Dir): $3"
echo "Input Arguments (Gridpack with path): $4"

echo "i am here ${{PWD}}"

seed=$((${{1}} + ${{2}} + 189))
#seed=123
basePath=${{PWD}}
step1=CMSSW_10_6_30_patch1
step2=CMSSW_10_6_17_patch1
step3=CMSSW_10_6_17_patch1
step4=CMSSW_10_2_16_UL
step5=CMSSW_10_6_17_patch1
step6=CMSSW_10_6_25
step7=CMSSW_10_6_26
outDir={{3}}
[ ! -d "${{outDir}}" ] && mkdir -p "${{outDir}}"

arch=slc7_amd64_gcc700


sed -i "s|args = cms.vstring.*|args = cms.vstring('$4'),|g" step_1_cfg.py
echo "+=============================="
echo "Print lines having gridpack path"
sed -n 176,183p step_1_cfg.py  # Print line number 153 to 160; it is expected that gridpack path and nEvents patch exists between 153 and 160
echo "+=============================="



for i in {{1..7}}
do
    cmssw=step$i
    export SCRAM_ARCH=slc7_amd64_gcc700
    echo "==> PWD:  ${{PWD}}"
    echo $i,${{arch}},${{!cmssw}}
    source /cvmfs/cms.cern.ch/cmsset_default.sh
    if [ -r ${{!cmssw}}/src ] ; then
        echo release ${{!cmssw}} already exists
    else
        scram p CMSSW ${{!cmssw}}
    fi
    cd ${{!cmssw}}/src
    if [ "${{!cmssw}}" = "CMSSW_10_6_26" ]; then
        echo "step - ${{i}}7"
        eval `scram runtime -sh`
        git cms-init
        git cms-merge-topic ram1123:aTGC_VV_reweight_CMSSW100626
        wget https://raw.githubusercontent.com/ram1123/cmssw/6295127490fb426e7ccbe39b68195677bfdf60f0/initrwgt_aQGC16.header
    else
        echo "step - ${{i}} "
    fi
    echo `pwd`
    echo ${{!cmssw}}
    echo "================================================="
    export HOME=${{PWD}}
    eval `scram runtime -sh`
    scram b
    cd -
    echo "runnning step_${{i}}_cfg.py"
    if [ $i -eq 1 ]
    then
        cmsRun step_${{i}}_cfg.py seedval=${{seed}}
        echo "================================================="
        echo "List the root files"
        ls *.root
        echo "================================================="
    else
        echo "runnning step_${{i}}_cfg.py"
        cmsrelnm1=step$((i-1))
        cmsRun step_${{i}}_cfg.py
        echo "================================================="
        echo "List the root files"
        ls *.root
        echo "================================================="
    fi
    cd ${{basePath}}/
done


cp EXO-RunIISummer20UL18NanoAODv9-01225.root ${{outDir}}/EXO-RunIISummer20UL18NanoAODv9_${{seed}}.root

echo "Ending job on " `date`
'''


jdl_file_template_part1of2 = '''Executable = {CondorExecutable}.sh
Universe = vanilla
Notification = ERROR
Should_Transfer_Files = YES
WhenToTransferOutput = ON_EXIT
Transfer_Input_Files = {CondorExecutable}.sh, UL2018_ConfigFiles/step_1_cfg.py, UL2018_ConfigFiles/step_2_cfg.py, UL2018_ConfigFiles/step_3_cfg.py, UL2018_ConfigFiles/step_4_cfg.py, UL2018_ConfigFiles/step_5_cfg.py, UL2018_ConfigFiles/step_6_cfg.py, UL2018_ConfigFiles/step_7_cfg.py
x509userproxy = $ENV(X509_USER_PROXY)
getenv      = True
+JobFlavour = "{CondorQueue}"
request_memory = 12000
request_cpus = 8
'''


jdl_file_template_part2of2 = '''Output = {CondorLogPath}/log_$(Cluster)_$(Process).stdout
Error  = {CondorLogPath}/log_$(Cluster)_$(Process).stdout
Log  = {CondorLogPath}/log_$(Cluster)_$(Process).stdout
Arguments = $(Cluster) $(Process)   {OutPutDir} {GridpackWithPath}
Queue {queue}
'''


with open(CondorExecutable + ".sh","w") as fout:
    fout.write(sh_file_template.format(test="Job started..."))

with open(CondorExecutable + ".jdl","w") as fout:
    fout.write(jdl_file_template_part1of2.format(
                                            CondorExecutable = CondorExecutable,
                                            CondorQueue = CondorQueue))

    # To generalize add a for loop over all root files.
    for gridpackWithPath in models['aTGC']:
        short_name = gridpackWithPath.split('/')[-1].replace('_4f_NLO_FXFX_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz','')

        output_rootfile_path =  'outputDirName'+'/'+short_name
        # os.makedirs(output_rootfile_path)

        output_logfile_path = 'log'+'/' + short_name
        # os.makedirs(output_logfile_path)
        fout.write(jdl_file_template_part2of2.format(
                                            CondorLogPath = output_logfile_path,
                                            OutPutDir = short_name,
                                            # GridpackWithPath = gridpackWithPath.replace('/','\/'),
                                            GridpackWithPath = gridpackWithPath,
                                            queue = queue
                                            ))

os.system("chmod 777 "+CondorExecutable+".sh");

print "===> Set Proxy Using:";
print "\tvoms-proxy-init --voms cms --valid 168:00";
print "===> copy proxy to home path"
print "cp /tmp/x509up_u48539 ~/"
print "===> export the proxy"
print "export X509_USER_PROXY=~/x509up_u48539"
print "\"condor_submit "+CondorExecutable+".jdl\" to submit";
