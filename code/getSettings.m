function s = getSettings(out_sleep,out_calc)
%GETSETTINGS If the user wants to save the settings for the analysis of a
%future file, this function is called. 
%   INPUT: out_sleep, the UI figure containing the annotations of lights
%   off, lights on and sleep stages; out_calc: the UI figure containing the
%   specifications related to the analyses to be done, the channels and
%   annotations needed for them
%   OUTPUT: s, a structure where the necessary information is saved for the
%   future file

s = struct;

% Lights off, lights on and annotations of sleep stages
s.ann_hypno.ann_loff = out_sleep.ListBox_loff.Value;
s.ann_hypno.ann_lon = out_sleep.ListBox_lon.Value;
s.ann_hypno.ann_W = out_sleep.ListBox_W.Value;
s.ann_hypno.ann_N1 = out_sleep.ListBox_N1.Value;
s.ann_hypno.ann_N2 = out_sleep.ListBox_N2.Value;
s.ann_hypno.ann_N3 = out_sleep.ListBox_N3.Value;
s.ann_hypno.ann_REM = out_sleep.ListBox_REM.Value;

%Chin
s.chin.selected = out_calc.ChinCheckBox.Value;
if s.chin.selected
    s.chin.unipolar = out_calc.figcalc.UserData.out_chin.UnipolarButton.Value;
    s.chin.bipolar = out_calc.figcalc.UserData.out_chin.BipolarButton.Value; 
    s.chin.signal_unipolar = out_calc.figcalc.UserData.out_chin.SingleChannelDropDown.Value;
    s.chin.signal_bopolar_1 = out_calc.figcalc.UserData.out_chin.DerivChannel1DropDown.Value;
    s.chin.signal_bopolar_2 = out_calc.figcalc.UserData.out_chin.DerivChannel2DropDown.Value;
    s.chin.artifact_selected = out_calc.figcalc.UserData.out_chin.ArtifactsCheckBox.Value;
    s.chin.artifacts = out_calc.figcalc.UserData.out_chin.ListBox.Value;
end

%Left leg
s.legL.selected = out_calc.LegLBox.Value;
if s.legL.selected
    s.legL.unipolar = out_calc.figcalc.UserData.out_legL.UnipolarButton.Value;
    s.legL.bipolar = out_calc.figcalc.UserData.out_legL.BipolarButton.Value; 
    s.legL.signal_unipolar = out_calc.figcalc.UserData.out_legL.SingleChannelDropDown.Value;
    s.legL.signal_bopolar_1 = out_calc.figcalc.UserData.out_legL.DerivChannel1DropDown.Value;
    s.legL.signal_bopolar_2 = out_calc.figcalc.UserData.out_legL.DerivChannel2DropDown.Value;
    s.legL.artifact_selected = out_calc.figcalc.UserData.out_legL.ArtifactsCheckBox.Value;
    s.legL.artifacts = out_calc.figcalc.UserData.out_legL.ListBox.Value;
end

%Right leg
s.legR.selected = out_calc.LegRBox.Value;
if s.legR.selected
    s.legR.unipolar = out_calc.figcalc.UserData.out_legR.UnipolarButton.Value;
    s.legR.bipolar = out_calc.figcalc.UserData.out_legR.BipolarButton.Value; 
    s.legR.signal_unipolar = out_calc.figcalc.UserData.out_legR.SingleChannelDropDown.Value;
    s.legR.signal_bopolar_1 = out_calc.figcalc.UserData.out_legR.DerivChannel1DropDown.Value;
    s.legR.signal_bopolar_2 = out_calc.figcalc.UserData.out_legR.DerivChannel2DropDown.Value;
    s.legR.artifact_selected = out_calc.figcalc.UserData.out_legR.ArtifactsCheckBox.Value;
    s.legR.artifacts = out_calc.figcalc.UserData.out_legR.ListBox.Value;
end

%Left arm
s.armL.selected = out_calc.ArmLBox.Value;
if s.armL.selected
    s.armL.unipolar = out_calc.figcalc.UserData.out_armL.UnipolarButton.Value;
    s.armL.bipolar = out_calc.figcalc.UserData.out_armL.BipolarButton.Value; 
    s.armL.signal_unipolar = out_calc.figcalc.UserData.out_armL.SingleChannelDropDown.Value;
    s.armL.signal_bopolar_1 = out_calc.figcalc.UserData.out_armL.DerivChannel1DropDown.Value;
    s.armL.signal_bopolar_2 = out_calc.figcalc.UserData.out_armL.DerivChannel2DropDown.Value;
    s.armL.artifact_selected = out_calc.figcalc.UserData.out_armL.ArtifactsCheckBox.Value;
    s.armL.artifacts = out_calc.figcalc.UserData.out_armL.ListBox.Value;
end

%Rigth arm
s.armR.selected = out_calc.ArmRBox.Value;
if s.armR.selected
    s.armR.unipolar = out_calc.figcalc.UserData.out_armR.UnipolarButton.Value;
    s.armR.bipolar = out_calc.figcalc.UserData.out_armR.BipolarButton.Value; 
    s.armR.signal_unipolar = out_calc.figcalc.UserData.out_armR.SingleChannelDropDown.Value;
    s.armR.signal_bopolar_1 = out_calc.figcalc.UserData.out_armR.DerivChannel1DropDown.Value;
    s.armR.signal_bopolar_2 = out_calc.figcalc.UserData.out_armR.DerivChannel2DropDown.Value;
    s.armR.artifact_selected = out_calc.figcalc.UserData.out_armR.ArtifactsCheckBox.Value;
    s.armR.artifacts = out_calc.figcalc.UserData.out_armR.ListBox.Value;
end

%Filters
s.notch.no = out_calc.NoNotchButton.Value;
s.notch.fifty = out_calc.Button50Notch.Value;
s.notch.sixty = out_calc.Button60Notch.Value;
s.lowcut.selected = out_calc.LowcutCheckBox.Value;
s.lowcut.value = out_calc.SpinnerLow.Value;
s.highcut.selected = out_calc.HighcutCheckBox.Value;
s.highcut.value = out_calc.SpinnerHigh.Value;

%Visualize RWA indices
s.visualizeRWA = out_calc.Visualize.Value;

%Annotations to calculate LM indices
s.LM.calculate_indices = out_calc.LMCheckBox.Value;
if s.LM.calculate_indices
    s.LM.ann_left_selected = out_calc.figcalc.UserData.out_PLM.leftCheck.Value;
    s.LM.ann_left_value = out_calc.figcalc.UserData.out_PLM.leftDropDown.Value;
    s.LM.ann_right_selected = out_calc.figcalc.UserData.out_PLM.rightCheck.Value;
    s.LM.ann_right_value = out_calc.figcalc.UserData.out_PLM.rightDropDown.Value;
    s.LM.arousal_selected = out_calc.figcalc.UserData.out_PLM.arousalCheck.Value;
    s.LM.arousal_value = out_calc.figcalc.UserData.out_PLM.arousalList.Value;
    s.LM.resp_selected = out_calc.figcalc.UserData.out_PLM.respCheck.Value;
    s.LM.resp_value = out_calc.figcalc.UserData.out_PLM.respList.Value;
    s.LM.visualizeHist= out_calc.VisualizeHist.Value;
end

end