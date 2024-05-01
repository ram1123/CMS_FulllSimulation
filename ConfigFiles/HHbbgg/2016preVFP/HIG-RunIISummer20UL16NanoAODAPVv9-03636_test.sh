#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_6_26/src ] ; then
  echo release CMSSW_10_6_26 already exists
else
  scram p CMSSW CMSSW_10_6_26
fi
cd CMSSW_10_6_26/src
eval `scram runtime -sh`

cp -r ../../Configuration .
scram b
cd ../..

# Maximum validation duration: 28800s
# Margin for validation duration: 30%
# Validation duration with margin: 28800 * (1 - 0.30) = 20160s
# Time per event for each sequence: 0.4180s
# Threads for each sequence: 2
# Time per event for single thread for each sequence: 2 * 0.4180s = 0.8360s
# Which adds up to 0.8360s per event
# Single core events that fit in validation duration: 20160s / 0.8360s = 24114
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, validation should run 10000 / 1.0000 = 10000 events to reach the limit of 10000
# Take the minimum of 24114 and 10000, but more than 0 -> 10000
# It is estimated that this validation will produce: 10000 * 1.0000 = 10000 events
EVENTS=10000


# cmsDriver command
cmsDriver.py  --python_filename HIG-RunIISummer20UL16NanoAODAPVv9-03636_1_cfg.py --eventcontent NANOAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier NANOAODSIM --fileout file:HIG-RunIISummer20UL16NanoAODAPVv9-03636.root --conditions 106X_mcRun2_asymptotic_preVFP_v11 --step NANO --filein file:HIG-RunIISummer20UL16MiniAODAPVv2-02774.root --era Run2_2016_HIPM,run2_nanoAOD_106Xv2 --no_exec --mc -n $EVENTS || exit $? ;

# End of HIG-RunIISummer20UL16NanoAODAPVv9-03636_test.sh file
