import subprocess
import os
import sys

sys.path.append("Utils/python_utils/.")
import gridpack_lists as sampleLists

from color_style import style

"""Fields changed by user"""
StringToChange = 'DoubleHiggs_Resonant_WW'
# StringToChange = 'DoubleHiggs_NonResonant_ZZ'
condor_file_name = StringToChange
storeAreaPath = '/eos/user/r/rasharma/post_doc_ihep/double-higgs/PvtProduction/Radion'
storeAreaPathWithEOSString = '/eos/user/r/rasharma/post_doc_ihep/double-higgs/PvtProduction/Radion'

"""Check if we are working on sl6 machine"""
# SystemOSCheck = 'cat /etc/redhat-release'
# sysReleaseCheck = os.popen(SystemOSCheck).read()
# if sysReleaseCheck.find('release 6') == -1:
#   print(style.RED+'\n\nERROR: You are not on the SL6 machine. Please swich on sl6 machine then run this script.\n\n'+style.RESET)
#   exit()

"""Create log files"""
import infoCreaterGit
# SumamryOfCurrentSubmission = raw_input("\n\nWrite summary for current job submission: ")
SumamryOfCurrentSubmission = "\n\nWrite summary for current job submission: "
infoLogFiles = infoCreaterGit.BasicInfoCreater('summary.dat',SumamryOfCurrentSubmission)
infoLogFiles.GenerateGitPatchAndLog()

"""Create directories for storing log files and output files at EOS."""
import fileshelper
dirsToCreate = fileshelper.FileHelper('condor_logs/'+StringToChange, storeAreaPathWithEOSString)
output_log_path = dirsToCreate.CreateLogDirWithDate()
dirTag = dirsToCreate.dirName
"""Create directories for different models at EOS"""
for key in sampleLists.models:
  if key == 'radion_UL':
    for gridpcaks in sampleLists.models[key]:
        print gridpcaks
        DirName = gridpcaks.split('/')[-1].split('_')
        DirName = DirName[0]+'_'+DirName[1]+'_'+DirName[2]+'_'+DirName[3]
        storeDir = dirsToCreate.createStoreDirWithDate(StringToChange,DirName)
        print storeDir
        infoLogFiles.SendGitLogAndPatchToEos(storeDir)

import condorJobHelper
listOfFilesToTransfer = 'HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py, HIG-RunIISummer20UL17SIM-03436_1_cfg.py, HIG-RunIISummer20UL17DIGIPremix-03436_1_cfg.py, HIG-RunIISummer20UL17HLT-03435_1_cfg.py, HIG-RunIISummer20UL17RECO-03435_1_cfg.py, HIG-RunIISummer20UL17MiniAODv2-03435_1_cfg.py, HIG-RunIISummer20UL16NanoAODAPVv9-01726_1_cfg.py'

condorJobHelper = condorJobHelper.condorJobHelper(condor_file_name,
                                                  listOfFilesToTransfer,
                                                  12000,    # request_memory 12000
                                                  8,    # request_cpus 8
                                                  output_log_path,
                                                  'test',   # logFileName
                                                  "",   # Arguments
                                                  1 # Queue
                                                  )
jdlFile = condorJobHelper.jdlFileHeaderCreater()
print '==> jdlfile name: ',jdlFile


for key in sampleLists.models:
  print(key)
  if key == 'radion_UL':
    for gridpcaks in sampleLists.models[key]:
        DirName = gridpcaks.split('/')[-1].split('_')
        DirName = DirName[0]+'_'+DirName[1]+'_'+DirName[2]+'_'+DirName[3]
        condorJobHelper.logFileName = DirName
        condorJobHelper.Arguments = 'HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py  '+DirName+os.sep+dirTag+ '  '+gridpcaks.replace('/','\/') + '  ' + DirName
        jdlFile = condorJobHelper.jdlFileAppendLogInfo()


outScript = open(condor_file_name+".sh","w");

outScript.write('#!/bin/bash')
outScript.write('\n'+'echo "Starting job on " `date`')
outScript.write('\n'+'echo "Running on: `uname -a`"')
outScript.write('\n'+'echo "System software: `cat /etc/redhat-release`"')
outScript.write('\n'+'source /cvmfs/cms.cern.ch/cmsset_default.sh')
outScript.write('\n'+'echo "'+'#'*51+'"')
outScript.write('\n'+'echo "#    List of Input Arguments: "')
outScript.write('\n'+'echo "'+'#'*51+'"')
outScript.write('\n'+'echo "Input Arguments (Cluster ID): $1"')
outScript.write('\n'+'echo "Input Arguments (Proc ID): $2"')
outScript.write('\n'+'echo "Input Arguments (Config file name): $3"')
outScript.write('\n'+'echo "Input Arguments (Dir name with date tag): $4"')
outScript.write('\n'+'echo "Input Arguments (gridpack name with path): $5"')
outScript.write('\n'+'echo "Input Arguments (Dir name): $6"')
outScript.write('\n'+'echo "'+'#'*51+'"')
outScript.write('\n'+'')
outScript.write('\n'+'OUTDIR='+storeAreaPath+os.sep+StringToChange+'/${4}/')
outScript.write('\n'+'')
outScript.write('\n'+'echo "======="')
outScript.write('\n'+'ls')
outScript.write('\n'+'echo "======"')
outScript.write('\n'+'')
outScript.write('\n'+'echo $PWD')
outScript.write('\n'+'export SCRAM_ARCH=slc7_amd64_gcc700')
outScript.write('\n'+'source /cvmfs/cms.cern.ch/cmsset_default.sh')

# Step -1: wmLHE
outScript.write('\n'+'eval `scramv1 project CMSSW CMSSW_10_6_30_patch1`')
outScript.write('\n'+'cd CMSSW_10_6_30_patch1/src/')
outScript.write('\n'+'# set cmssw environment')
outScript.write('\n'+'eval `scram runtime -sh`')
outScript.write('\n'+'cd -')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> List all files..."')
outScript.write('\n'+'ls ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "==> Running wmLHE step (1001 events will be generated)"')
outScript.write("\n"+'sed -i "s/args = cms.vstring.*/args = cms.vstring(\\"${5}\\"),/g" HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "Print lines having gridpack path"')
outScript.write('\n'+'# cat HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py  ')
outScript.write('\n'+' sed -n 153,160p HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py  ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'cmsRun HIG-RunIISummer20UL17wmLHEGEN-03846_1_cfg.py  ')
# outScript.write('\n'+'cmsRun ${3} ')
outScript.write('\n'+'echo "List all root files = "')
outScript.write('\n'+'ls *.root')
outScript.write('\n'+'echo "List all files"')
outScript.write('\n'+'ls ')
outScript.write('\n'+'echo "==> List all files..."')
outScript.write('\n'+'ls *.root ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'date')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'')
outScript.write('\n'+'echo "Loading CMSSW env DR1, DR2 and MiniAOD"')
outScript.write('\n'+'')

# Step -2: GEN-SIM
outScript.write('\n'+'# as LHE and DR/MINIAOD are in different CMSSW reelase so change CMSSW environment')
outScript.write('\n'+'eval `scramv1 project CMSSW CMSSW_10_6_17_patch1`')
outScript.write('\n'+'cd CMSSW_10_6_17_patch1/src')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'eval `scram runtime -sh`')
outScript.write('\n'+'cd -')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> List all files..."')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'ls ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "==> cmsRun HIG-RunIISummer20UL17SIM-03436_1_cfg.py" ')
outScript.write('\n'+'cmsRun HIG-RunIISummer20UL17SIM-03436_1_cfg.py  ')

# Step -3: Digi
outScript.write('\n'+'cmsRun HIG-RunIISummer20UL17DIGIPremix-03436_1_cfg.py')



# Step -4: HLT
outScript.write('\n'+'# as LHE and DR/MINIAOD are in different CMSSW reelase so change CMSSW environment')
outScript.write('\n'+'eval `scramv1 project CMSSW CMSSW_9_4_14_UL_patch1`')
outScript.write('\n'+'cd CMSSW_9_4_14_UL_patch1/src')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'eval `scram runtime -sh`')
outScript.write('\n'+'cd -')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> cmsRun HIG-RunIISummer20UL17HLT-03435_1_cfg.py"')
outScript.write('\n'+'cmsRun HIG-RunIISummer20UL17HLT-03435_1_cfg.py ')

# Step -5: reco
outScript.write('\n'+'# as LHE and DR/MINIAOD are in different CMSSW reelase so change CMSSW environment')
outScript.write('\n'+'eval `scramv1 project CMSSW CMSSW_10_6_17_patch1`')
outScript.write('\n'+'cd CMSSW_10_6_17_patch1/src')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'eval `scram runtime -sh`')
outScript.write('\n'+'cd -')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> cmsRun HIG-RunIISummer20UL17RECO-03435_1_cfg.py"')
outScript.write('\n'+'cmsRun HIG-RunIISummer20UL17RECO-03435_1_cfg.py')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> List all files..."')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'ls ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "List all root files = "')
outScript.write('\n'+'ls *.root')
outScript.write('\n'+'echo "List all files"')
outScript.write('\n'+'ls ')
outScript.write('\n'+'echo "+=============================="')

# Step -6 : MiniAOD
outScript.write('\n'+'# as LHE and DR/MINIAOD are in different CMSSW reelase so change CMSSW environment')
outScript.write('\n'+'eval `scramv1 project CMSSW CMSSW_10_6_20`')
outScript.write('\n'+'cd CMSSW_10_6_20/src')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'eval `scram runtime -sh`')
outScript.write('\n'+'cd -')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> cmsRunHIG-RunIISummer20UL17MiniAODv2-03435_1_cfg.py"')
outScript.write('\n'+'cmsRunHIG-RunIISummer20UL17MiniAODv2-03435_1_cfg.py')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> List all files..."')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'ls ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "List all root files = "')
outScript.write('\n'+'ls *.root')
outScript.write('\n'+'echo "List all files"')
outScript.write('\n'+'ls ')
outScript.write('\n'+'echo "+=============================="')

# Step -7 : nanoAOD
outScript.write('\n'+'# as LHE and DR/MINIAOD are in different CMSSW reelase so change CMSSW environment')
outScript.write('\n'+'eval `scramv1 project CMSSW CMSSW_10_6_26`')
outScript.write('\n'+'cd CMSSW_10_6_26/src')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'eval `scram runtime -sh`')
outScript.write('\n'+'cd -')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> cmsRun   HIG-RunIISummer20UL16NanoAODAPVv9-01726_1_cfg.py"')
outScript.write('\n'+'cmsRun  HIG-RunIISummer20UL16NanoAODAPVv9-01726_1_cfg.py')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> List all files..."')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'ls ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "List all root files = "')
outScript.write('\n'+'ls *.root')
outScript.write('\n'+'echo "List all files"')
outScript.write('\n'+'ls ')
outScript.write('\n'+'echo "+=============================="')


outScript.write('\n'+'')
outScript.write('\n'+'# copy output to eos')
outScript.write('\n'+'echo "xrdcp output for condor"')
# outScript.write('\n'+'cp HIG-RunIISummer20UL16NanoAODAPVv9-01726.root out_nanoAOD_${1}_${2}.root')
# outScript.write('\n'+'cp HIG-RunIISummer20UL16NanoAODAPVv9-01726.root ${OUTDIR}/out_nanoAOD_${6}_${1}_${2}.root')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> List all files..."')
outScript.write('\n'+'ls *.root ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "xrdcp output for condor"')
outScript.write('\n'+'cp HIG-RunIISummer20UL16NanoAODAPVv9-01726.root ${OUTDIR}/out_nanoAOD_${6}_${1}_${2}.root')
# outScript.write('\n'+'cp out_nanoAOD_${1}_${2}.root ${OUTDIR}/out_nanoAOD_${1}_${2}.root')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> List all files..."')
outScript.write('\n'+'ls *.root ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'date')
outScript.write('\n'+'')
outScript.write('\n'+'')

outScript.close();

os.system("chmod 777 "+condor_file_name+".sh");

print "===> Set Proxy Using:";
print "\tvoms-proxy-init --voms cms --valid 168:00";
print "===> copy proxy to home path"
print "cp /tmp/x509up_u48539 ~/"
print "===> export the proxy"
print "export X509_USER_PROXY=~/x509up_u48539"
print "\"condor_submit "+condor_file_name+".jdl\" to submit";
