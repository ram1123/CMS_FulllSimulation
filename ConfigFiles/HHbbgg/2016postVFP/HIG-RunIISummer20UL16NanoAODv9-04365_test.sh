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
# Time per event for each sequence: 0.3402s
# Threads for each sequence: 2
# Time per event for single thread for each sequence: 2 * 0.3402s = 0.6804s
# Which adds up to 0.6804s per event
# Single core events that fit in validation duration: 20160s / 0.6804s = 29629
# Produced events limit in McM is 10000
# According to 1.0000 efficiency, validation should run 10000 / 1.0000 = 10000 events to reach the limit of 10000
# Take the minimum of 29629 and 10000, but more than 0 -> 10000
# It is estimated that this validation will produce: 10000 * 1.0000 = 10000 events
EVENTS=10000


# cmsDriver command
cmsDriver.py  --python_filename HIG-RunIISummer20UL16NanoAODv9-04365_1_cfg.py --eventcontent NANOAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier NANOAODSIM --fileout file:HIG-RunIISummer20UL16NanoAODv9-04365.root --conditions 106X_mcRun2_asymptotic_v17 --step NANO --filein file:HIG-RunIISummer20UL16MiniAODv2-03246.root --era Run2_2016,run2_nanoAOD_106Xv2 --no_exec --mc -n $EVENTS || exit $? ;

# End of HIG-RunIISummer20UL16NanoAODv9-04365_test.sh file
