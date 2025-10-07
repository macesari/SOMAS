function printChoices(out_calc)
%PRINTCHOICES This function
disp('Calculation of atonia index and DNE')

%Chin
valueChin = out_calc.ChinCheckBox.Value;
if valueChin==0
    disp('*Chin not selected')
elseif valueChin==1
    disp('*Chin selected with the following settings:')
    if out_calc.figcalc.UserData.out_chin.UnipolarButton.Value==1
        t = out_calc.figcalc.UserData.out_chin.SingleChannelDropDown.Value;
        disp([' - Single channel: ' t])
    elseif out_calc.figcalc.UserData.out_chin.BipolarButton.Value==1
        t1 = out_calc.figcalc.UserData.out_chin.DerivChannel1DropDown.Value;
        t2 = out_calc.figcalc.UserData.out_chin.DerivChannel2DropDown.Value;
        disp([' - Derivation: ' t1 ' - ' t2])
    end
    if out_calc.figcalc.UserData.out_chin.ArtifactsCheckBox.Value==0
        disp(' - No artifacts selected')
    elseif out_calc.figcalc.UserData.out_chin.ArtifactsCheckBox.Value==1
        t = out_calc.figcalc.UserData.out_chin.ListBox.Value;
        disp([' - Artifacts: ']);
        disp(t)
    end
end

%Leg left
valuelegL = out_calc.LegLBox.Value;
if valuelegL==0
    disp('*Leg left not selected')
elseif valuelegL==1
    disp('*Leg left selected with the following settings:')
    if out_calc.figcalc.UserData.out_legL.UnipolarButton.Value==1
        t = out_calc.figcalc.UserData.out_legL.SingleChannelDropDown.Value;
        disp([' - Single channel: ' t])
    elseif out_calc.figcalc.UserData.out_legL.BipolarButton.Value==1
        t1 = out_calc.figcalc.UserData.out_legL.DerivChannel1DropDown.Value;
        t2 = out_calc.figcalc.UserData.out_legL.DerivChannel2DropDown.Value;
        disp([' - Derivation: ' t1 ' - ' t2])
    end
    if out_calc.figcalc.UserData.out_legL.ArtifactsCheckBox.Value==0
        disp(' - No artifacts selected')
    elseif out_calc.figcalc.UserData.out_legL.ArtifactsCheckBox.Value==1
        t = out_calc.figcalc.UserData.out_legL.ListBox.Value;
        disp([' - Artifacts: ']);
        disp(t)
    end
end

%Leg right
valuelegR = out_calc.LegRBox.Value;
if valuelegR==0
    disp('*Leg right not selected')
elseif valuelegR==1
    disp('*Leg right selected with the following settings:')
    if out_calc.figcalc.UserData.out_legR.UnipolarButton.Value==1
        t = out_calc.figcalc.UserData.out_legR.SingleChannelDropDown.Value;
        disp([' - Single channel: ' t])
    elseif out_calc.figcalc.UserData.out_legR.BipolarButton.Value==1
        t1 = out_calc.figcalc.UserData.out_legR.DerivChannel1DropDown.Value;
        t2 = out_calc.figcalc.UserData.out_legR.DerivChannel2DropDown.Value;
        disp([' - Derivation: ' t1 ' - ' t2])
    end
    if out_calc.figcalc.UserData.out_legR.ArtifactsCheckBox.Value==0
        disp(' - No artifacts selected')
    elseif out_calc.figcalc.UserData.out_legR.ArtifactsCheckBox.Value==1
        t = out_calc.figcalc.UserData.out_legR.ListBox.Value;
        disp([' - Artifacts: ']);
        disp(t)
    end
end

%Arm left
valuearmL = out_calc.ArmLBox.Value;
if valuearmL==0
    disp('*Arm left not selected')
elseif valuearmL==1
    disp('*Arm left selected with the following settings:')
    if out_calc.figcalc.UserData.out_armL.UnipolarButton.Value==1
        t = out_calc.figcalc.UserData.out_armL.SingleChannelDropDown.Value;
        disp([' - Single channel: ' t])
    elseif out_calc.figcalc.UserData.out_armL.BipolarButton.Value==1
        t1 = out_calc.figcalc.UserData.out_armL.DerivChannel1DropDown.Value;
        t2 = out_calc.figcalc.UserData.out_armL.DerivChannel2DropDown.Value;
        disp([' - Derivation: ' t1 ' - ' t2])
    end
    if out_calc.figcalc.UserData.out_armL.ArtifactsCheckBox.Value==0
        disp(' - No artifacts selected')
    elseif out_calc.figcalc.UserData.out_armL.ArtifactsCheckBox.Value==1
        t = out_calc.figcalc.UserData.out_armL.ListBox.Value;
        disp([' - Artifacts: ']);
        disp(t)
    end
end

%Arm right
valuearmR = out_calc.ArmRBox.Value;
if valuearmR==0
    disp('*Arm right not selected')
elseif valuearmR==1
    disp('*Arm right selected with the following settings:')
    if out_calc.figcalc.UserData.out_armR.UnipolarButton.Value==1
        t = out_calc.figcalc.UserData.out_armR.SingleChannelDropDown.Value;
        disp([' - Single channel: ' t])
    elseif out_calc.figcalc.UserData.out_armR.BipolarButton.Value==1
        t1 = out_calc.figcalc.UserData.out_armR.DerivChannel1DropDown.Value;
        t2 = out_calc.figcalc.UserData.out_armR.DerivChannel2DropDown.Value;
        disp([' - Derivation: ' t1 ' - ' t2])
    end
    if out_calc.figcalc.UserData.out_armR.ArtifactsCheckBox.Value==0
        disp(' - No artifacts selected')
    elseif out_calc.figcalc.UserData.out_armR.ArtifactsCheckBox.Value==1
        t = out_calc.figcalc.UserData.out_armR.ListBox.Value;
        disp([' - Artifacts: ']);
        disp(t)
    end
end

%Notch
notch_no = out_calc.NoNotchButton.Value;
notch_50 = out_calc.Button50Notch.Value;
notch_60 = out_calc.Button60Notch.Value;
if notch_no==1
    disp('*Notch: no')
elseif notch_50==1
    disp('*Notch: 50 Hz')
elseif notch_60==1
    disp('*Notch: 60 Hz')
end

%Low-cut
if out_calc.LowcutCheckBox.Value==0
    disp('*No low-cut selected')
elseif out_calc.LowcutCheckBox.Value==1
    disp(['*Low-cut set at ' num2str(out_calc.SpinnerLow.Value) ' Hz'])
end

%High-cut
if out_calc.HighcutCheckBox.Value==0
    disp('*No high-cut selected')
elseif out_calc.HighcutCheckBox.Value==1
    disp(['*High-cut set at ' num2str(out_calc.SpinnerHigh.Value) ' Hz'])
end

%Show graphs
if out_calc.Visualize.Value==0
    disp('*Visualization of results atonia index and DNE: false')
elseif out_calc.Visualize.Value==1
    disp('*Visualization of results atonia index and DNE: true')
end

%PLM
if out_calc.LMCheckBox.Value==0
    disp('No calculation of LM indices')
elseif out_calc.LMCheckBox.Value==1
    disp('Calculation of LM indices with the following parameters:')
    %Left limb movement
    if out_calc.figcalc.UserData.out_PLM.leftCheck.Value==0
        disp(' - No left limb movement specified')
    elseif out_calc.figcalc.UserData.out_PLM.leftCheck.Value==1
        t = out_calc.figcalc.UserData.out_PLM.leftDropDown.Value;
        disp([' - Left limb movement annotation: ' t])
    end
    %Right limb movement
    if out_calc.figcalc.UserData.out_PLM.rightCheck.Value==0
        disp(' - No right limb movement specified')
    elseif out_calc.figcalc.UserData.out_PLM.rightCheck.Value==1
        t = out_calc.figcalc.UserData.out_PLM.rightDropDown.Value;
        disp([' - Right limb movement annotation: ' t])
    end
    %Arousal
    if out_calc.figcalc.UserData.out_PLM.arousalCheck.Value==0
        disp(' - No arousal specified')
    elseif out_calc.figcalc.UserData.out_PLM.arousalCheck.Value==1
        t = out_calc.figcalc.UserData.out_PLM.arousalList.Value;
        disp(' - Arousals annotations : ')
        disp(t)
    end
    %Respiratory events
    if out_calc.figcalc.UserData.out_PLM.respCheck.Value==0
        disp(' - No respiratory events specified')
    elseif out_calc.figcalc.UserData.out_PLM.respCheck.Value==1
        t = out_calc.figcalc.UserData.out_PLM.respList.Value;
        disp(' - Respiratory events annotations : ')
        disp(t)
    end
    if out_calc.VisualizeHist.Value==0
        disp('*Visualization histograms IMI: false');
    elseif out_calc.VisualizeHist.Value==1
        disp('*Visualization histograms IMI: true');
    end
end  

end

