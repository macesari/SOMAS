function [out_calc,txt_warning] = import_settings(out_calc,settings_from_file,SV)
%IMPORT_SETTINGS: This function, based on the settings saved for a previous
%file, applies them to the current file. The function has many checks to
%carefully note that only appropriate settings are chosen.
% INPUT: out_calc: the settings passed from the main file; SV, 
% the structure containing the EDF+ file; settings_from_file, if
% the user selected a file with the saved settings, these will be used to
% fill in the figure.
% OUTPUT: out_calc, the settings modified based on the settings saved;
% txt_warning: the warnings in case some settings could not be applied to
% the current file

txt_warning = {};

%Import the settings related to the main UI figure 
out_calc.ChinCheckBox.Value = settings_from_file.s.chin.selected;
out_calc.LegLBox.Value = settings_from_file.s.legL.selected;
out_calc.LegRBox.Value = settings_from_file.s.legR.selected;
out_calc.ArmLBox.Value = settings_from_file.s.armL.selected;
out_calc.ArmRBox.Value = settings_from_file.s.armR.selected;
out_calc.NoNotchButton.Value = settings_from_file.s.notch.no;
out_calc.Button50Notch.Value = settings_from_file.s.notch.fifty;
out_calc.Button60Notch.Value = settings_from_file.s.notch.sixty;
out_calc.LowcutCheckBox.Value = settings_from_file.s.lowcut.selected;
out_calc.SpinnerLow.Value = settings_from_file.s.lowcut.value;
out_calc.HighcutCheckBox.Value = settings_from_file.s.highcut.selected;
out_calc.SpinnerHigh.Value = settings_from_file.s.highcut.value;
out_calc.Visualize.Value = settings_from_file.s.visualizeRWA;
out_calc.LMCheckBox.Value = settings_from_file.s.LM.calculate_indices;
if out_calc.LMCheckBox.Value == 1
    out_calc.VisualizeHist.Value = settings_from_file.s.LM.visualizeHist;
end

%Import the settings related to the definition of chin and of its artifacts
if settings_from_file.s.chin.selected
    out_calc.figcalc.UserData.out_chin.UnipolarButton.Value = settings_from_file.s.chin.unipolar;
    if settings_from_file.s.chin.unipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.chin.signal_unipolar))==1
        out_calc.figcalc.UserData.out_chin.SingleChannelDropDown.Value = settings_from_file.s.chin.signal_unipolar;
    elseif settings_from_file.s.chin.unipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.chin.signal_unipolar))==0 
        out_calc.figcalc.UserData.out_chin.SingleChannelDropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Unipolar chin signal not found, select another signal'];
        warning('Unipolar chin signal not found, select another signal')
    end
    out_calc.figcalc.UserData.out_chin.BipolarButton.Value = settings_from_file.s.chin.bipolar;
    if settings_from_file.s.chin.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.chin.signal_bopolar_1))==1
        out_calc.figcalc.UserData.out_chin.DerivChannel1DropDown.Value = settings_from_file.s.chin.signal_bopolar_1;
    elseif settings_from_file.s.chin.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.chin.signal_bopolar_1))==0
        out_calc.figcalc.UserData.out_chin.DerivChannel1DropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Bipolar chin signal not found, select another signal'];
        warning('Bipolar chin signal not found, select another signal')
    end
    if settings_from_file.s.chin.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.chin.signal_bopolar_2))==1
        out_calc.figcalc.UserData.out_chin.DerivChannel2DropDown.Value = settings_from_file.s.chin.signal_bopolar_2;
    elseif settings_from_file.s.chin.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.chin.signal_bopolar_2))==0
        out_calc.figcalc.UserData.out_chin.DerivChannel2DropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Bipolar chin signal not found, select another signal'];
        warning('Bipolar chin signal not found, select another signal')
    end
    out_calc.figcalc.UserData.out_chin.ArtifactsCheckBox.Value = settings_from_file.s.chin.artifact_selected;
    if settings_from_file.s.chin.artifact_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.chin.artifacts))>=1
        pos = find(ismember(SV.annotations_unique,settings_from_file.s.chin.artifacts));
        out_calc.figcalc.UserData.out_chin.ListBox.Value = SV.annotations_unique(pos)';
    elseif settings_from_file.s.chin.artifact_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.chin.artifacts))==0 % This means that the artifacts were not found
        txt_warning = [txt_warning; 'None of the artifacts specified for chin was found in the annotations'];
        warning('None of the artifacts specified for chin was found in the annotations')
        out_calc.figcalc.UserData.out_chin.ArtifactsCheckBox.Value = false;
    end
end

%Import the settings related to the definition of the left leg and of its artifacts
if settings_from_file.s.legL.selected
    out_calc.figcalc.UserData.out_legL.UnipolarButton.Value = settings_from_file.s.legL.unipolar;
    if settings_from_file.s.legL.unipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.legL.signal_unipolar))==1
        out_calc.figcalc.UserData.out_legL.SingleChannelDropDown.Value = settings_from_file.s.legL.signal_unipolar;
    elseif settings_from_file.s.legL.unipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.legL.signal_unipolar))==0
        out_calc.figcalc.UserData.out_legL.SingleChannelDropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Unipolar leg left signal not found, select another signal'];
        warning('Unipolar leg left signal not found, select another signal')
    end
    out_calc.figcalc.UserData.out_legL.BipolarButton.Value = settings_from_file.s.legL.bipolar;
    if settings_from_file.s.legL.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.legL.signal_bopolar_1))==1
        out_calc.figcalc.UserData.out_legL.DerivChannel1DropDown.Value = settings_from_file.s.legL.signal_bopolar_1;
    elseif settings_from_file.s.legL.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.legL.signal_bopolar_1))==0
        out_calc.figcalc.UserData.out_legL.DerivChannel1DropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Bipolar leg left signal not found, select another signal'];
        warning('Bipolar leg left signal not found, select another signal')
    end
    if settings_from_file.s.legL.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.legL.signal_bopolar_2))==1
        out_calc.figcalc.UserData.out_legL.DerivChannel2DropDown.Value = settings_from_file.s.legL.signal_bopolar_2;
    elseif settings_from_file.s.legL.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.legL.signal_bopolar_2))==0
        out_calc.figcalc.UserData.out_legL.DerivChannel2DropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Bipolar leg left signal not found, select another signal'];
        warning('Bipolar leg left signal not found, select another signal')
    end
    out_calc.figcalc.UserData.out_legL.ArtifactsCheckBox.Value = settings_from_file.s.legL.artifact_selected;
    if settings_from_file.s.legL.artifact_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.legL.artifacts))>=1
        pos = find(ismember(SV.annotations_unique,settings_from_file.s.legL.artifacts));
        out_calc.figcalc.UserData.out_legL.ListBox.Value = SV.annotations_unique(pos)';
    elseif settings_from_file.s.legL.artifact_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.legL.artifacts))==0 % This means that the artifacts were not found
        txt_warning = [txt_warning; 'None of the artifacts specified for leg left was found in the annotations'];
        warning('None of the artifacts specified for leg left was found in the annotations')
        out_calc.figcalc.UserData.out_legL.ArtifactsCheckBox.Value = false;
    end
end

%Import the settings related to the definition of the right leg and of its artifacts
if settings_from_file.s.legR.selected
    out_calc.figcalc.UserData.out_legR.UnipolarButton.Value = settings_from_file.s.legR.unipolar;
    if settings_from_file.s.legR.unipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.legR.signal_unipolar))==1
        out_calc.figcalc.UserData.out_legR.SingleChannelDropDown.Value = settings_from_file.s.legR.signal_unipolar;
    elseif settings_from_file.s.legR.unipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.legR.signal_unipolar))==0
        out_calc.figcalc.UserData.out_legR.SingleChannelDropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Unipolar leg right signal not found, select another signal'];
        warning('Unipolar leg right signal not found, select another signal')
    end
    out_calc.figcalc.UserData.out_legR.BipolarButton.Value = settings_from_file.s.legR.bipolar;
    if settings_from_file.s.legR.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.legR.signal_bopolar_1))==1
        out_calc.figcalc.UserData.out_legR.DerivChannel1DropDown.Value = settings_from_file.s.legR.signal_bopolar_1;
    elseif settings_from_file.s.legR.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.legR.signal_bopolar_1))==0
        out_calc.figcalc.UserData.out_legR.DerivChannel1DropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Bipolar leg right signal not found, select another signal'];
        warning('Bipolar leg right signal not found, select another signal')
    end
    if settings_from_file.s.legR.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.legR.signal_bopolar_2))==1
        out_calc.figcalc.UserData.out_legR.DerivChannel2DropDown.Value = settings_from_file.s.legR.signal_bopolar_2;
    elseif settings_from_file.s.legR.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.legR.signal_bopolar_2))==0
        out_calc.figcalc.UserData.out_legR.DerivChannel2DropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Bipolar leg right signal not found, select another signal'];
        warning('Bipolar leg right signal not found, select another signal')
    end
    out_calc.figcalc.UserData.out_legR.ArtifactsCheckBox.Value = settings_from_file.s.legR.artifact_selected;
    if settings_from_file.s.legR.artifact_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.legR.artifacts))>=1
        pos = find(ismember(SV.annotations_unique,settings_from_file.s.legR.artifacts));
        out_calc.figcalc.UserData.out_legR.ListBox.Value = SV.annotations_unique(pos)';
    elseif settings_from_file.s.legR.artifact_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.legR.artifacts))==0 % This means that the artifacts were not found
        txt_warning = [txt_warning; 'None of the artifacts specified for leg right was found in the annotations'];
        out_calc.figcalc.UserData.out_legR.ArtifactsCheckBox.Value = false;
        warning('None of the artifacts specified for leg right was found in the annotations')
    end
end

%Import the settings related to the definition of the left arm and of its artifacts
if settings_from_file.s.armL.selected
    out_calc.figcalc.UserData.out_armL.UnipolarButton.Value = settings_from_file.s.armL.unipolar;
    if settings_from_file.s.armL.unipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.armL.signal_unipolar))==1
        out_calc.figcalc.UserData.out_armL.SingleChannelDropDown.Value = settings_from_file.s.armL.signal_unipolar;
    elseif settings_from_file.s.armL.unipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.armL.signal_unipolar))==0
        out_calc.figcalc.UserData.out_armL.SingleChannelDropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Unipolar arm left signal not found, select another signal'];
        warning('Unipolar arm left signal not found, select another signal')
    end
    out_calc.figcalc.UserData.out_armL.BipolarButton.Value = settings_from_file.s.armL.bipolar;
    if settings_from_file.s.armL.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.armL.signal_bopolar_1))==1
        out_calc.figcalc.UserData.out_armL.DerivChannel1DropDown.Value = settings_from_file.s.armL.signal_bopolar_1;
    elseif settings_from_file.s.armL.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.armL.signal_bopolar_1))==0
        out_calc.figcalc.UserData.out_armL.DerivChannel1DropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Bipolar arm left signal not found, select another signal'];
        warning('Bipolar arm left signal not found, select another signal')
    end
    if settings_from_file.s.armL.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.armL.signal_bopolar_2))==1
        out_calc.figcalc.UserData.out_armL.DerivChannel2DropDown.Value = settings_from_file.s.armL.signal_bopolar_2;
    elseif settings_from_file.s.armL.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.armL.signal_bopolar_2))==0
        out_calc.figcalc.UserData.out_armL.DerivChannel2DropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Bipolar arm left signal not found, select another signal'];
        warning('Bipolar arm left signal not found, select another signal')
    end
    out_calc.figcalc.UserData.out_armL.ArtifactsCheckBox.Value = settings_from_file.s.armL.artifact_selected;
    if settings_from_file.s.armL.artifact_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.armL.artifacts))>=1
        pos = find(ismember(SV.annotations_unique,settings_from_file.s.armL.artifacts));
        out_calc.figcalc.UserData.out_armL.ListBox.Value = SV.annotations_unique(pos)';
    elseif settings_from_file.s.armL.artifact_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.armL.artifacts))==0% This means that the artifacts were not found
        warning('None of the artifacts specified for arm left was found in the annotations')
        txt_warning = [txt_warning; 'None of the artifacts specified for arm left was found in the annotations'];
        out_calc.figcalc.UserData.out_armL.ArtifactsCheckBox.Value = false;
    end
end

%Import the settings related to the definition of the right arm and of its artifacts
if settings_from_file.s.armR.selected
    out_calc.figcalc.UserData.out_armR.UnipolarButton.Value = settings_from_file.s.armR.unipolar;
    if settings_from_file.s.armR.unipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.armR.signal_unipolar))==1
        out_calc.figcalc.UserData.out_armR.SingleChannelDropDown.Value = settings_from_file.s.armR.signal_unipolar;
    elseif settings_from_file.s.armR.unipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.armR.signal_unipolar))==0
        out_calc.figcalc.UserData.out_armR.SingleChannelDropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Unipolar arm right signal not found, select another signal'];
        warning('Unipolar arm right signal not found, select another signal')
    end
    out_calc.figcalc.UserData.out_armR.BipolarButton.Value = settings_from_file.s.armR.bipolar;
    if settings_from_file.s.armR.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.armR.signal_bopolar_1))==1
        out_calc.figcalc.UserData.out_armR.DerivChannel1DropDown.Value = settings_from_file.s.armR.signal_bopolar_1;
    elseif settings_from_file.s.armR.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.armR.signal_bopolar_1))==0
        out_calc.figcalc.UserData.out_armR.DerivChannel1DropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Bipolar arm right signal not found, select another signal'];
        warning('Bipolar arm right signal not found, select another signal')
    end
    if settings_from_file.s.armR.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.armR.signal_bopolar_2))==1
        out_calc.figcalc.UserData.out_armR.DerivChannel2DropDown.Value = settings_from_file.s.armR.signal_bopolar_2;
    elseif settings_from_file.s.armR.bipolar & sum(ismember(SV.NewSignalLabels,settings_from_file.s.armR.signal_bopolar_2))==0
        out_calc.figcalc.UserData.out_armR.DerivChannel2DropDown.Value = 'ERROR: SIGNAL NOT FOUND';
        txt_warning = [txt_warning; 'Bipolar arm right signal not found, select another signal'];
        warning('Bipolar arm right signal not found, select another signal')
    end
    out_calc.figcalc.UserData.out_armR.ArtifactsCheckBox.Value = settings_from_file.s.armR.artifact_selected;
    if settings_from_file.s.armR.artifact_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.armR.artifacts))>=1
        pos = find(ismember(SV.annotations_unique,settings_from_file.s.armR.artifacts));
        out_calc.figcalc.UserData.out_armR.ListBox.Value = SV.annotations_unique(pos)';
    elseif settings_from_file.s.armR.artifact_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.armR.artifacts))==0 % This means that the artifacts were not found
        warning('None of the artifacts specified for arm right was found in the annotations')
        txt_warning = [txt_warning; 'None of the artifacts specified for arm right was found  in the annotations'];
        out_calc.figcalc.UserData.out_armR.ArtifactsCheckBox.Value = false;
    end
end

%Import the settings related to the definition of the parameters for the
%calculation of the LM indices
if settings_from_file.s.LM.calculate_indices
    out_calc.figcalc.UserData.out_PLM.leftCheck.Value = settings_from_file.s.LM.ann_left_selected;
    if settings_from_file.s.LM.ann_left_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.LM.ann_left_value))==1
        out_calc.figcalc.UserData.out_PLM.leftDropDown.Value = settings_from_file.s.LM.ann_left_value;
    elseif settings_from_file.s.LM.ann_left_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.LM.ann_left_value))==0
        out_calc.figcalc.UserData.out_PLM.leftCheck.Value = 0;
        txt_warning = [txt_warning; 'Annotation of left leg movement not found'];
        warning('Annotation of left leg movement not found')
    end
    out_calc.figcalc.UserData.out_PLM.rightCheck.Value = settings_from_file.s.LM.ann_right_selected;
    if settings_from_file.s.LM.ann_right_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.LM.ann_right_value))==1
        out_calc.figcalc.UserData.out_PLM.rightDropDown.Value = settings_from_file.s.LM.ann_right_value;
    elseif settings_from_file.s.LM.ann_right_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.LM.ann_right_value))==0
        out_calc.figcalc.UserData.out_PLM.rightCheck.Value = 0;
        txt_warning = [txt_warning; 'Annotation of right leg movement not found'];
        warning('Annotation of left leg movement not found')
    end
    out_calc.figcalc.UserData.out_PLM.arousalCheck.Value = settings_from_file.s.LM.arousal_selected;
    if settings_from_file.s.LM.arousal_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.LM.arousal_value))>=1
        pos =  find(ismember(SV.annotations_unique,settings_from_file.s.LM.arousal_value));
        out_calc.figcalc.UserData.out_PLM.arousalList.Value = SV.annotations_unique(pos)';
    elseif settings_from_file.s.LM.arousal_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.LM.arousal_value))==0% This means that the annotations of arousals were not found
        warning('No match of arousal annotations')
        txt_warning = [txt_warning; 'No match of arousal annotations'];
        out_calc.figcalc.UserData.out_PLM.arousalCheck.Value = false;
    end
    out_calc.figcalc.UserData.out_PLM.respCheck.Value = settings_from_file.s.LM.resp_selected;
    if settings_from_file.s.LM.resp_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.LM.resp_value))>=1
        pos =  find(ismember(SV.annotations_unique,settings_from_file.s.LM.resp_value));
        out_calc.figcalc.UserData.out_PLM.respList.Value = SV.annotations_unique(pos)';
    elseif settings_from_file.s.LM.resp_selected & sum(ismember(SV.annotations_unique,settings_from_file.s.LM.resp_value))==0 % This means that the annotations of respiratory events were not found
        warning('No match of respiratory events annotations')
        txt_warning = [txt_warning; 'No match of respiratory events annotations'];
        out_calc.figcalc.UserData.out_PLM.arousalCheck.Value = false;
    end
end
end