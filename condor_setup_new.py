import os

sh_file_template = '''#!/bin/bash

echo "Starting job on " `date`
echo "Running on: `uname -a`"
echo "System software: `cat /etc/redhat-release`"
source /cvmfs/cms.cern.ch/cmsset_default.sh
echo "###################################################"
echo "#    List of Input Arguments: "
echo "###################################################"
echo "Input Arguments (Cluster ID): $1"
echo "Input Arguments (Proc ID): $2"
echo "Input Arguments (Root file name with path): $3"
echo "Input Arguments (Tag got from miniAOD file): $4"
#echo "Input Arguments (Config file name): $3"
echo "###################################################"

echo "======="
echo ${{PWD}}
ls -ltrh
echo "======"

export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc7_amd64_gcc700

cp {cmsswTarFileWithPath} .
tar -xf {NameOfTarFile}
cd {pathWhereCodePlaced}
scramv1 b ProjectRename
eval `scram runtime -sh` # alias of cmsevn command

echo "========================="
echo "pwd : ${{PWD}}"
ls -ltrh
echo "========================="
# Use below sed command if need to edit config file before run
#sed -i "s/MiniAODFileWithPath/${{3}}/g"  {ConfigFileToRun}

# cat for debug, as this will be printed out in stdout of condor log
#cat {ConfigFileToRun}
echo "========================="
echo "==> cmsRun   {ConfigFileToRun}"
cmsRun  {ConfigFileToRun}
echo "========================="
echo "==> List all files..."
ls -ltrh
echo "+=============================="
echo "List all root files = "
ls -ltrh *.root
echo "+=============================="

# copy output to eos
echo "xrdcp output for condor"
echo "+=============================="
cp {ExpectedOutputRootFile} {outputDirName}/out_nanoAOD_${{4}}_${{1}}_${{2}}.root
date
'''

jdl_file_template_part1of2 = '''Executable = {CondorExecutable}.sh
Universe = vanilla
Notification = ERROR
Should_Transfer_Files = YES
WhenToTransferOutput = ON_EXIT
Transfer_Input_Files = {CondorExecutable}.sh
x509userproxy = $ENV(X509_USER_PROXY)
getenv      = True
+JobFlavour = "{CondorQueue}"
'''

jdl_file_template_part2of2 = '''Output = {CondorLogPath}/log_$(Cluster)_$(Process).stdout
Error  = {CondorLogPath}/log_$(Cluster)_$(Process).stdout
Log  = {CondorLogPath}/log_$(Cluster)_$(Process).stdout
Arguments = $(Cluster) $(Process)   {InputRootFileToRun} {InputFileTag}
Queue 1
'''

# Step - 1: Get the tar file


# Step - 2: Copy the tar file to eos;
#                            if its cernbox then just cp command with full path will work
#                            else you need to use the xrdcp command and path will start from /store/xxx

# Step - 3: Get .sh and .jdl file; as produced below
CondorExecutable = "test"
with open(CondorExecutable + ".sh","w") as fout:
    fout.write(sh_file_template.format(
                                            cmsswTarFileWithPath = "/eos/xxx/cmsssw.tar",
                                            NameOfTarFile = "cmsssw.tar",
                                            pathWhereCodePlaced = "CMSSW_10_X_Y/src/test/macro/",
                                            ConfigFileToRun = "nano_17.py",
                                            ExpectedOutputRootFile = "nano.root",
                                            outputDirName = "/eos/cms/store/cmst3/group/dpsww/vvsemilep/2018/"
                                            ))
with open(CondorExecutable + ".jdl","w") as fout:
    fout.write(jdl_file_template_part1of2.format(
                                            CondorExecutable = CondorExecutable,
                                            ConfigFileToRun = "nano_17.py",
                                            CondorQueue = "espresso"))
    # To generalize add a for loop over all root files.
    fout.write(jdl_file_template_part2of2.format(
                                            CondorLogPath = "log",
                                            InputRootFileToRun = "\/store\/cmst3\/group\/dpsww\/WZToLNuQQ01j_5f_amcatnloFxFx_2016\/SMP-RunIISummer20UL16MiniAODv2-00057_4507799.root",
                                            InputFileTag = "4507799"
                                            ))

os.system("chmod 777 "+CondorExecutable+".sh");

print "===> Set Proxy Using:";
print "\tvoms-proxy-init --voms cms --valid 168:00";
print "===> copy proxy to home path"
print "cp /tmp/x509up_u48539 ~/"
print "===> export the proxy"
print "export X509_USER_PROXY=~/x509up_u48539"
print "\"condor_submit "+CondorExecutable+".jdl\" to submit";
