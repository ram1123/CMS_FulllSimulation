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

#cd /afs/cern.ch/cms/PPD/PdmV/work/McM/submit/HIG-Run3Summer22NanoAODv12-01310/

# Make voms proxy
voms-proxy-init --voms cms --out $(pwd)/voms_proxy.txt --hours 4
export X509_USER_PROXY=$(pwd)/voms_proxy.txt


# Dump actual test code to a HIG-Run3Summer22NanoAODv12-01310_test.sh file that can be run in Singularity
cat <<'EndOfTestFile' > HIG-Run3Summer22NanoAODv12-01310_test.sh
#!/bin/bash

export SCRAM_ARCH=el8_amd64_gcc11

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_13_0_24/src ] ; then
  echo release CMSSW_13_0_24 already exists
else
  scram p CMSSW CMSSW_13_0_24
fi
cd CMSSW_13_0_24/src
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
# Time per event (s): 0.34
# Initial target input events: 100
# Initial target output events: 100
# Validation runtime will not run for long enough than expected, extending the time
# Target input events changed to: `minimum_runtime / time_per_event * number_of_threads`: `600 / 0.34 * 1` = 1.76e+03
# Target output events changed to: `target_input_events * event_efficiency`: `1.76e+03 * 1` = 1.76e+03
# Final target input events: 1763
# Final target output events: 1763
# This validation will be computed based on the target output events!
EVENTS=1763


# cmsDriver command
cmsDriver.py  --scenario pp --era Run3 --customise Configuration/DataProcessing/Utils.addMonitoring --step NANO --conditions 130X_mcRun3_2022_realistic_v5 --datatier NANOAODSIM --eventcontent NANOAODSIM --python_filename HIG-Run3Summer22NanoAODv12-01310_1_cfg.py --fileout file:HIG-Run3Summer22NanoAODv12-01310.root --filein file:HIG-Run3Summer22MiniAODv4-01570.root --number 1763 --number_out 1763 --no_exec --mc || exit $? ;

# End of HIG-Run3Summer22NanoAODv12-01310_test.sh file
EndOfTestFile

# Make file executable
chmod +x HIG-Run3Summer22NanoAODv12-01310_test.sh

if [ -e "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el8:amd64" ]; then
  CONTAINER_NAME="el8:amd64"
elif [ -e "/cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/el8:x86_64" ]; then
  CONTAINER_NAME="el8:x86_64"
else
  echo "Could not find amd64 or x86_64 for el8"
  exit 1
fi
export SINGULARITY_CACHEDIR="/tmp/$(whoami)/singularity"
singularity run --no-home /cvmfs/unpacked.cern.ch/registry.hub.docker.com/cmssw/$CONTAINER_NAME $(echo $(pwd)/HIG-Run3Summer22NanoAODv12-01310_test.sh)
