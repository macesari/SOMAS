function display_choices(out_calc)

%DISPLAY_CHOICES This function shows to the user the choices that have been
%made
txt = {};
txt = [txt; 'Calculation of atonia index and DNE'];
txt = [txt; ' '];

%Chin
valueChin = out_calc.ChinCheckBox.Value;
if valueChin==0
    txt = [txt; '*Chin not selected'];
elseif valueChin==1
    txt = [txt; '*Chin selected with the following settings:'];
    if out_calc.figcalc.UserData.out_chin.UnipolarButton.Value==1
        t = out_calc.figcalc.UserData.out_chin.SingleChannelDropDown.Value;
        tt = [' - Single channel: ' t];
        txt = [txt; tt];
    elseif out_calc.figcalc.UserData.out_chin.BipolarButton.Value==1
        t1 = out_calc.figcalc.UserData.out_chin.DerivChannel1DropDown.Value;
        t2 = out_calc.figcalc.UserData.out_chin.DerivChannel2DropDown.Value;
        tt = [' - Derivation: ' t1 ' - ' t2];
        txt = [txt; tt];
    end
    if out_calc.figcalc.UserData.out_chin.ArtifactsCheckBox.Value==0
        txt = [txt; ' - No artifacts selected'];
    elseif out_calc.figcalc.UserData.out_chin.ArtifactsCheckBox.Value==1
        t = out_calc.figcalc.UserData.out_chin.ListBox.Value;
        txt = [txt; ' - Artifacts: '];
        txt = [txt; t'];
    end
end
txt = [txt; ' '];
%Leg left
valuelegL = out_calc.LegLBox.Value;
if valuelegL==0
    txt = [txt; '*Leg left not selected'];
elseif valuelegL==1
    txt = [txt; '*Leg left selected with the following settings:'];
    if out_calc.figcalc.UserData.out_legL.UnipolarButton.Value==1
        t = out_calc.figcalc.UserData.out_legL.SingleChannelDropDown.Value;
        tt = [' - Single channel: ' t];
        txt = [txt; tt];
    elseif out_calc.figcalc.UserData.out_legL.BipolarButton.Value==1
        t1 = out_calc.figcalc.UserData.out_legL.DerivChannel1DropDown.Value;
        t2 = out_calc.figcalc.UserData.out_legL.DerivChannel2DropDown.Value;
        tt = [' - Derivation: ' t1 ' - ' t2];
        txt = [txt; tt];
    end
    if out_calc.figcalc.UserData.out_legL.ArtifactsCheckBox.Value==0
        txt = [txt; ' - No artifacts selected'];
    elseif out_calc.figcalc.UserData.out_legL.ArtifactsCheckBox.Value==1
        t = out_calc.figcalc.UserData.out_legL.ListBox.Value;
        txt = [txt; ' - Artifacts: '];
        txt = [txt; t'];
    end
end
txt = [txt; ' '];
%Leg right
valuelegR = out_calc.LegRBox.Value;
if valuelegR==0
    txt = [txt; '*Leg right not selected'];
elseif valuelegR==1
    txt = [txt; '*Leg right selected with the following settings:'];
    if out_calc.figcalc.UserData.out_legR.UnipolarButton.Value==1
        t = out_calc.figcalc.UserData.out_legR.SingleChannelDropDown.Value;
        tt = [' - Single channel: ' t];
        txt = [txt; tt];
    elseif out_calc.figcalc.UserData.out_legR.BipolarButton.Value==1
        t1 = out_calc.figcalc.UserData.out_legR.DerivChannel1DropDown.Value;
        t2 = out_calc.figcalc.UserData.out_legR.DerivChannel2DropDown.Value;
        tt = [' - Derivation: ' t1 ' - ' t2];
        txt = [txt; tt];
    end
    if out_calc.figcalc.UserData.out_legR.ArtifactsCheckBox.Value==0
        txt = [txt; ' - No artifacts selected'];
    elseif out_calc.figcalc.UserData.out_legR.ArtifactsCheckBox.Value==1
        t = out_calc.figcalc.UserData.out_legR.ListBox.Value;
        txt = [txt; ' - Artifacts: '];
        txt = [txt; t'];
    end
end
txt = [txt; ' '];
%Arm left
valuearmL = out_calc.ArmLBox.Value;
if valuearmL==0
    txt = [txt; '*Arm left not selected'];
elseif valuearmL==1
    txt = [txt; '*Arm left selected with the following settings:'];
    if out_calc.figcalc.UserData.out_armL.UnipolarButton.Value==1
        t = out_calc.figcalc.UserData.out_armL.SingleChannelDropDown.Value;
        tt = [' - Single channel: ' t];
        txt = [txt; tt];
    elseif out_calc.figcalc.UserData.out_armL.BipolarButton.Value==1
        t1 = out_calc.figcalc.UserData.out_armL.DerivChannel1DropDown.Value;
        t2 = out_calc.figcalc.UserData.out_armL.DerivChannel2DropDown.Value;
        tt = [' - Derivation: ' t1 ' - ' t2];
        txt = [txt; tt];
    end
    if out_calc.figcalc.UserData.out_armL.ArtifactsCheckBox.Value==0
        txt = [txt; ' - No artifacts selected'];
    elseif out_calc.figcalc.UserData.out_armL.ArtifactsCheckBox.Value==1
        t = out_calc.figcalc.UserData.out_armL.ListBox.Value;
        txt = [txt; ' - Artifacts: '];
        txt = [txt; t'];
    end
end
txt = [txt; ' '];
%Arm right
valuearmR = out_calc.ArmRBox.Value;
if valuearmR==0
    txt = [txt; '*Arm right not selected'];
elseif valuearmR==1
    txt = [txt; '*Arm right selected with the following settings:'];
    if out_calc.figcalc.UserData.out_armR.UnipolarButton.Value==1
        t = out_calc.figcalc.UserData.out_armR.SingleChannelDropDown.Value;
        tt = [' - Single channel: ' t];
        txt = [txt; tt];
    elseif out_calc.figcalc.UserData.out_armR.BipolarButton.Value==1
        t1 = out_calc.figcalc.UserData.out_armR.DerivChannel1DropDown.Value;
        t2 = out_calc.figcalc.UserData.out_armR.DerivChannel2DropDown.Value;
        tt = [' - Derivation: ' t1 ' - ' t2];
        txt = [txt; tt];
    end
    if out_calc.figcalc.UserData.out_armR.ArtifactsCheckBox.Value==0
        txt = [txt; ' - No artifacts selected'];
    elseif out_calc.figcalc.UserData.out_armR.ArtifactsCheckBox.Value==1
        t = out_calc.figcalc.UserData.out_armR.ListBox.Value;
        txt = [txt; ' - Artifacts: '];
        txt = [txt; t'];
    end
end
txt = [txt; ' '];
%Notch
notch_no = out_calc.NoNotchButton.Value;
notch_50 = out_calc.Button50Notch.Value;
notch_60 = out_calc.Button60Notch.Value;
if notch_no==1
    txt = [txt; '*Notch: no'];
elseif notch_50==1
    txt = [txt; '*Notch: 50 Hz'];
elseif notch_60==1
    txt = [txt; '*Notch: 60 Hz'];
end

%Low-cut
if out_calc.LowcutCheckBox.Value==0
    txt = [txt; '*No low-cut selected'];
elseif out_calc.LowcutCheckBox.Value==1
    tt = ['*Low-cut set at ' num2str(out_calc.SpinnerLow.Value) ' Hz'];
    txt = [txt; tt];
end

%High-cut
if out_calc.HighcutCheckBox.Value==0
    txt = [txt; '*No high-cut selected'];
elseif out_calc.HighcutCheckBox.Value==1
    tt = ['*High-cut set at ' num2str(out_calc.SpinnerHigh.Value) ' Hz'];
    txt = [txt; tt];
end
txt = [txt; ' '];
%Show graphs
if out_calc.Visualize.Value==0
    txt = [txt; '*Visualization of results atonia index and DNE: false'];
elseif out_calc.Visualize.Value==1
    txt = [txt; '*Visualization of results atonia index and DNE: true'];
end
txt = [txt; ' '];

%PLM
if out_calc.LMCheckBox.Value==0
    txt = [txt; 'No calculation of LM indices'];
elseif out_calc.LMCheckBox.Value==1
    txt = [txt; 'Calculation of LM indices with the following parameters:'];
    %Left limb movement
    if out_calc.figcalc.UserData.out_PLM.leftCheck.Value==0
        txt = [txt; ' - No left limb movement specified'];
    elseif out_calc.figcalc.UserData.out_PLM.leftCheck.Value==1
        t = out_calc.figcalc.UserData.out_PLM.leftDropDown.Value;
        tt = [' - Left limb movement annotation: ' t];
        txt = [txt; tt];
    end
    %Right limb movement
    if out_calc.figcalc.UserData.out_PLM.rightCheck.Value==0
        txt = [txt; ' - No right limb movement specified'];
    elseif out_calc.figcalc.UserData.out_PLM.rightCheck.Value==1
        t = out_calc.figcalc.UserData.out_PLM.rightDropDown.Value;
        tt = [' - Right limb movement annotation: ' t];
        txt = [txt; tt];
    end
    %Arousal
    if out_calc.figcalc.UserData.out_PLM.arousalCheck.Value==0
        txt = [txt; ' - No arousal specified'];
    elseif out_calc.figcalc.UserData.out_PLM.arousalCheck.Value==1
        t = out_calc.figcalc.UserData.out_PLM.arousalList.Value;
        txt = [txt; ' - Arousals annotations : '];
        txt = [txt; t'];
    end
    %Respiratory events
    if out_calc.figcalc.UserData.out_PLM.respCheck.Value==0
        txt = [txt; ' - No respiratory events specified'];
    elseif out_calc.figcalc.UserData.out_PLM.respCheck.Value==1
        t = out_calc.figcalc.UserData.out_PLM.respList.Value;
        txt = [txt; ' - Respiratory events annotations : '];
        txt = [txt; t'];
    end
    if out_calc.VisualizeHist.Value==0
        txt = [txt; '*Visualization histograms IMI: false'];
    elseif out_calc.VisualizeHist.Value==1
        txt = [txt; '*Visualization histograms IMI: true'];
    end
end



f = uifigure('Visible','off','Name','Choice of parameters','Position',[895,119,771,876]);
uitextarea(f,'Value',txt,'Position',[27,9,729,850],...
    'HorizontalAlignment','left','FontSize',12);
% uicontrol(f,'Style','text','String',txt,'Position',[27,9,729,850],...
%     'HorizontalAlignment','left','FontSize',10);
movegui(f,'center')
f.Visible = 'on';