function saveSettings(out_calc,out_sleep,fName)
uisave({'out_calc','out_sleep'},[fName(1:end-4) '_settings.mat'])
end