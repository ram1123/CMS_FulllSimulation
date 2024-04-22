#!/bin/bash

#############################################################
#   This script is used by McM when it performs automatic   #
#  validation in HTCondor or submits requests to computing  #
#                                                           #
#      !!! THIS FILE IS NOT MEANT TO BE RUN BY YOU !!!      #
# If you want to run validation script yourself you need to #
#     get a "Get test" script which can be retrieved by     #
#  clicking a button next to one you just clicked. It will  #
# say "Get test command" when you hover your mouse over it  #
#      If you try to run this, you will have a bad time     #
#############################################################

#cd /afs/cern.ch/cms/PPD/PdmV/work/McM/submit/HIG-RunIISummer20UL16HLTAPV-03078/

# Make voms proxy
voms-proxy-init --voms cms --out $(pwd)/voms_proxy.txt --hours 4
export X509_USER_PROXY=$(pwd)/voms_proxy.txt


# Dump actual test code to a HIG-RunIISummer20UL16HLTAPV-03078_test.sh file that can be run in Singularity
cat <<'EndOfTestFile' > HIG-RunIISummer20UL16HLTAPV-03078_test.sh
#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc530

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_8_0_36_UL_patch1/src ] ; then
  echo release CMSSW_8_0_36_UL_patch1 already exists
else
  scram p CMSSW CMSSW_8_0_36_UL_patch1
fi
cd CMSSW_8_0_36_UL_patch1/src
eval `scram runtime -sh`

cp -r ../../Configuration .
scram b
cd ../..

# Maximum validation duration: 28800s
# Margin for validation duration: 30%
# Validation duration with margin: 28800 * (1 - 0.30) = 20160s
# Time per event for each sequence: 2.3639s
# Threads for each sequence: 4
# Time per event for single thread for each sequence: 4 * 2.3639s = 9.4556s
# Which adds up to 9.4556s per event
# Single core events that fit in validation duration: 20160s / 9.4556s = 2132
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, validation should run 10000 / 1.0000 = 10000 events to reach the limit of 10000
# Take the minimum of 2132 and 10000, but more than 0 -> 2132
# It is estimated that this validation will produce: 2132 * 1.0000 = 2132 events
EVENTS=2132


# cmsDriver command
cmsDriver.py  --python_filename HIG-RunIISummer20UL16HLTAPV-03078_1_cfg.py --eventcontent RAWSIM --outputCommand "keep *_mix_*_*,keep *_genPUProtons_*_*" --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --inputCommands "keep *","drop *_*_BMTF_*","drop *PixelFEDChannel*_*_*_*" --fileout file:HIG-RunIISummer20UL16HLTAPV-03078.root --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:25ns15e33_v4 --geometry DB:Extended --filein file:HIG-RunIISummer20UL16DIGIPremixAPV-03057.root --era Run2_2016 --no_exec --mc -n $EVENTS || exit $? ;

# End of HIG-RunIISummer20UL16HLTAPV-03078_test.sh file
EndOfTestFile

# Make file executable
chmod +x HIG-RunIISummer20UL16HLTAPV-03078_test.sh

if [ -e "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el7:amd64" ]; then
  CONTAINER_NAME="el7:amd64"
elif [ -e "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el7:x86_64" ]; then
  CONTAINER_NAME="el7:x86_64"
else
  echo "Could not find amd64 or x86_64 for el7"
  exit 1
fi
export SINGULARITY_CACHEDIR="/tmp/$(whoami)/singularity"
singularity run -B /afs -B /cvmfs -B /etc/grid-security -B /etc/pki/ca-trust --no-home /cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/$CONTAINER_NAME $(echo $(pwd)/HIG-RunIISummer20UL16HLTAPV-03078_test.sh)
