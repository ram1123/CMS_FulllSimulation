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

# Maximum validation runtime: 57600s
# Minimum validation runtime: 600s
# Output events to run for the validation job (from application's setting): 100
# Event efficiency: Computed using the request efficiency and its error.
# Event efficiency: `efficiency - (2 * efficiency_error)`: `0.04 - (2 * 0)` = 0.04
# Input events: `int(output_events / event_efficiency)`: `int(100 / 0.04)` = 2499
# Time per event (s): Computed adding all the time_per_event values on every sequence
# Time per event (s): 1.75
# Target input events: 2499
# Target output events: 100
# This validation will be computed based on the target output events!
EVENTS=100

# Random seed between 1 and 100 for externalLHEProducer
SEED=$(($(date +%s) % 100 + 1))


# cmsDriver command
cmsDriver.py Configuration/GenProduction/python/HIG-Run3Summer22wmLHEGS-02640-fragment.py --era Run2_2017 --customise Configuration/DataProcessing/Utils.addMonitoring --beamspot Realistic25ns13TeVEarly2017Collision --step LHE,GEN,SIM --geometry DB:Extended --conditions 106X_mc2017_realistic_v6 --customise_commands process.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${SEED})" --datatier GEN-SIM,LHE --eventcontent RAWSIM,LHE --python_filename HIG-Run3Summer22wmLHEGS-02640_1_cfg.py --fileout file:HIG-Run3Summer22wmLHEGS-02640.root --number 2499 --number_out 100 --no_exec --mc || exit $? ;

# End of HIG-Run3Summer22wmLHEGS-02640_test.sh file
