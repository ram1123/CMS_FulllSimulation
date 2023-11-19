# Auto generated configuration file
# using:
# Revision: 1.19
# Source: /local/reps/CMSSW/CMSSW/Configuration/Applications/python/ConfigBuilder.py,v
# with command line options: --python_filename HIG-RunIISummer20UL17NanoAODv9-03735_1_cfg.py --eventcontent NANOEDMAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier NANOAODSIM --fileout file:HIG-RunIISummer20UL17NanoAODv9-03735.root --conditions 106X_mc2017_realistic_v9 --step NANO --filein dbs:/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/RunIISummer20UL17MiniAODv2-106X_mc2017_realistic_v9-v3/MINIAODSIM --era Run2_2017,run2_nanoAOD_106Xv2 --no_exec --mc -n 10000
import FWCore.ParameterSet.Config as cms

from Configuration.Eras.Era_Run2_2017_cff import Run2_2017
from Configuration.Eras.Modifier_run2_nanoAOD_106Xv2_cff import run2_nanoAOD_106Xv2

process = cms.Process('NANO',Run2_2017,run2_nanoAOD_106Xv2)

# import of standard configurations
process.load('Configuration.StandardSequences.Services_cff')
process.load('SimGeneral.HepPDTESSource.pythiapdt_cfi')
process.load('FWCore.MessageService.MessageLogger_cfi')
process.load('Configuration.EventContent.EventContent_cff')
process.load('SimGeneral.MixingModule.mixNoPU_cfi')
process.load('Configuration.StandardSequences.GeometryRecoDB_cff')
process.load('Configuration.StandardSequences.MagneticField_cff')
process.load('PhysicsTools.NanoAOD.nano_cff')
process.load('Configuration.StandardSequences.EndOfProcess_cff')
process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_cff')
process.MessageLogger.cerr.FwkReport.reportEvery = cms.untracked.int32(500)

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(10000)
)

# Input source
process.source = cms.Source("PoolSource",
    fileNames = cms.untracked.vstring(
        '/store/mc/RunIISummer20UL17MiniAODv2/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/MINIAODSIM/106X_mc2017_realistic_v9-v3/30000/16BFAB78-DACE-204C-A607-639BDDB69107.root',
        '/store/mc/RunIISummer20UL17MiniAODv2/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/MINIAODSIM/106X_mc2017_realistic_v9-v3/30000/1A153B0F-7A5E-1B40-83F4-61A8177B094D.root',
        '/store/mc/RunIISummer20UL17MiniAODv2/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/MINIAODSIM/106X_mc2017_realistic_v9-v3/30000/25BB2617-1886-7B41-AF26-DCC3F1868925.root',
        '/store/mc/RunIISummer20UL17MiniAODv2/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/MINIAODSIM/106X_mc2017_realistic_v9-v3/30000/45F52F06-32CF-644F-884C-0564FF36FEED.root',
        '/store/mc/RunIISummer20UL17MiniAODv2/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/MINIAODSIM/106X_mc2017_realistic_v9-v3/30000/45FAC37D-A5FC-D645-8A80-A9814E86B463.root',
        '/store/mc/RunIISummer20UL17MiniAODv2/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/MINIAODSIM/106X_mc2017_realistic_v9-v3/30000/470C121C-B1ED-334B-AE84-56214DC93C24.root',
        '/store/mc/RunIISummer20UL17MiniAODv2/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/MINIAODSIM/106X_mc2017_realistic_v9-v3/30000/5A66B8CD-0789-B947-8BED-6BCA7944AE83.root',
        '/store/mc/RunIISummer20UL17MiniAODv2/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/MINIAODSIM/106X_mc2017_realistic_v9-v3/30000/6585DF03-4024-F54A-AAC5-C8F222AFDB3B.root',
        '/store/mc/RunIISummer20UL17MiniAODv2/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/MINIAODSIM/106X_mc2017_realistic_v9-v3/30000/778D6DD8-01A5-5E44-B7C7-FBB6E8535FA2.root',
        '/store/mc/RunIISummer20UL17MiniAODv2/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/MINIAODSIM/106X_mc2017_realistic_v9-v3/30000/84F35B47-1BC5-9A4A-A683-1DDFC4C283C5.root',
        '/store/mc/RunIISummer20UL17MiniAODv2/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/MINIAODSIM/106X_mc2017_realistic_v9-v3/30000/93E0CCA1-5027-FF4C-A5A0-E04E90AA4856.root',
        '/store/mc/RunIISummer20UL17MiniAODv2/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/MINIAODSIM/106X_mc2017_realistic_v9-v3/30000/9E59C968-F5C4-D149-82C9-5B7FDEB255D8.root',
        '/store/mc/RunIISummer20UL17MiniAODv2/GluGluToRadionToHHTo2B2G_M-1500_TuneCP5_PSWeights_narrow_13TeV-madgraph-pythia8/MINIAODSIM/106X_mc2017_realistic_v9-v3/30000/B8BBBAE1-D207-1244-87D8-B2A7EE1CAEA2.root'
    ),
    secondaryFileNames = cms.untracked.vstring()
)

process.options = cms.untracked.PSet(

)

# Production Info
process.configurationMetadata = cms.untracked.PSet(
    annotation = cms.untracked.string('--python_filename nevts:10000'),
    name = cms.untracked.string('Applications'),
    version = cms.untracked.string('$Revision: 1.19 $')
)

# Output definition

process.NANOEDMAODSIMoutput = cms.OutputModule("PoolOutputModule",
    compressionAlgorithm = cms.untracked.string('LZMA'),
    compressionLevel = cms.untracked.int32(9),
    dataset = cms.untracked.PSet(
        dataTier = cms.untracked.string('NANOAODSIM'),
        filterName = cms.untracked.string('')
    ),
    fileName = cms.untracked.string('file:HIG-RunIISummer20UL17NanoAODv9-03735.root'),
    outputCommands = process.NANOAODSIMEventContent.outputCommands
)

# Additional output definition

# Other statements
from Configuration.AlCa.GlobalTag import GlobalTag
process.GlobalTag = GlobalTag(process.GlobalTag, '106X_mc2017_realistic_v9', '')

# Path and EndPath definitions
process.nanoAOD_step = cms.Path(process.nanoSequenceMC)
process.endjob_step = cms.EndPath(process.endOfProcess)
process.NANOEDMAODSIMoutput_step = cms.EndPath(process.NANOEDMAODSIMoutput)

# Schedule definition
process.schedule = cms.Schedule(process.nanoAOD_step,process.endjob_step,process.NANOEDMAODSIMoutput_step)
from PhysicsTools.PatAlgos.tools.helpers import associatePatAlgosToolsTask
associatePatAlgosToolsTask(process)

# customisation of the process.

# Automatic addition of the customisation function from PhysicsTools.NanoAOD.nano_cff
from PhysicsTools.NanoAOD.nano_cff import nanoAOD_customizeMC

#call to customisation function nanoAOD_customizeMC imported from PhysicsTools.NanoAOD.nano_cff
process = nanoAOD_customizeMC(process)

# Automatic addition of the customisation function from Configuration.DataProcessing.Utils
from Configuration.DataProcessing.Utils import addMonitoring

#call to customisation function addMonitoring imported from Configuration.DataProcessing.Utils
process = addMonitoring(process)

# End of customisation functions

# Customisation from command line

# Add early deletion of temporary data products to reduce peak memory need
from Configuration.StandardSequences.earlyDeleteSettings_cff import customiseEarlyDelete
process = customiseEarlyDelete(process)
# End adding early deletion
