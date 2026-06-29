#!/bin/bash

# Binds for singularity containers
# Mount /afs, /eos, /cvmfs, /etc/grid-security for xrootd
export APPTAINER_BINDPATH='/afs,/cvmfs,/cvmfs/grid.cern.ch/etc/grid-security:/etc/grid-security,/eos,/etc/pki/ca-trust,/run/user,/var/run/user'

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

#cd /afs/cern.ch/cms/PPD/PdmV/work/McM/submit/HIG-Run3Summer22DRPremix-01538/

# Make voms proxy
voms-proxy-init --voms cms --out $(pwd)/voms_proxy.txt --hours 4
export X509_USER_PROXY=$(pwd)/voms_proxy.txt


# Dump actual test code to a HIG-Run3Summer22DRPremix-01538_test.sh file that can be run in Singularity
cat <<'EndOfTestFile' > HIG-Run3Summer22DRPremix-01538_test.sh
#!/bin/bash

export SCRAM_ARCH=el8_amd64_gcc10

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_12_4_25/src ] ; then
  echo release CMSSW_12_4_25 already exists
else
  scram p CMSSW CMSSW_12_4_25
fi
cd CMSSW_12_4_25/src
eval `scram runtime -sh`

cp -r ../../Configuration .
scram b
cd ../..

# Maximum validation runtime: 28800s
# Minimum validation runtime: 600s
# Output events to run for the validation job (from application's setting): 100
# Event efficiency: Computed using the request efficiency and its error.
# Event efficiency: `efficiency - (2 * efficiency_error)`: `1 - (2 * 0)` = 1
# Input events: `int(output_events / event_efficiency)`: `int(100 / 1)` = 100
# Time per event (s): Computed adding all the time_per_event values on every sequence
# Time per event (s): 36
# Target input events: 100
# Target output events: 100
# This validation will be computed based on the target output events!
EVENTS=100


# cmsDriver command
cmsDriver.py  --era Run3 --customise Configuration/DataProcessing/Utils.addMonitoring --procModifiers premix_stage2,siPixelQualityRawToDigi --datamix PreMix --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2022v12 --geometry DB:Extended --conditions 124X_mcRun3_2022_realistic_v12 --datatier GEN-SIM-RAW --eventcontent PREMIXRAW --python_filename HIG-Run3Summer22DRPremix-01538_1_cfg.py --fileout file:HIG-Run3Summer22DRPremix-01538_0.root --filein file:HIG-Run3Summer22wmLHEGS-02640.root --number 100 --number_out 100 --pileup_input "dbs:/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer22_124X_mcRun3_2022_realistic_v11-v2/PREMIX" --no_exec --mc || exit $? ;

# cmsDriver command
cmsDriver.py  --era Run3 --customise Configuration/DataProcessing/Utils.addMonitoring --procModifiers siPixelQualityRawToDigi --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --conditions 124X_mcRun3_2022_realistic_v12 --datatier AODSIM --eventcontent AODSIM --python_filename HIG-Run3Summer22DRPremix-01538_2_cfg.py --fileout file:HIG-Run3Summer22DRPremix-01538.root --filein file:HIG-Run3Summer22DRPremix-01538_0.root --number 100 --number_out 100 --no_exec --mc || exit $? ;

# End of HIG-Run3Summer22DRPremix-01538_test.sh file
EndOfTestFile

# Make file executable
chmod +x HIG-Run3Summer22DRPremix-01538_test.sh

if [ -e "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el8:amd64" ]; then
  CONTAINER_NAME="el8:amd64"
elif [ -e "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el8:x86_64" ]; then
  CONTAINER_NAME="el8:x86_64"
else
  echo "Could not find amd64 or x86_64 for el8"
  exit 1
fi
export SINGULARITY_CACHEDIR="/tmp/$(whoami)/singularity"
singularity run --no-home /cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/$CONTAINER_NAME $(echo $(pwd)/HIG-Run3Summer22DRPremix-01538_test.sh)
