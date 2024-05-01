#!/usr/bin/env tcsh
#!/usr/bin/env tcsh
foreach file ( *.stdout )
	xrdcp -f $file /eos/uscms/store/user/rasharma/CMSSW_FullSimulation_April2017/New_21May2017/MiniAOD/WPlepWMhadJJ_EWK_LO_aQGC-FT-FS-FM_mjj100VJpT10_Pythia8CUEP8M1_13TeV_Madgraph_ext1/logs/
end
