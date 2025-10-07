function out_calc = make_fig_main_calculations_v2(SV,settings_from_file)

%MAKE_FIG_MAIN_CALCULATIONS_V2: this function draws the UI figure where the
%user is asked to select the channels where the analyses should be perfomed
%(including the definitions of artifacts), the filters to be applied to the
%signals, and the annotations to calculate the LM indices according to the
%WASM 2016 criteria.
% INPUT: SV, the structure containing the EDF+ file; settings_from_file, if
% the user selected a file with the saved settings, these will be used to
% fill in the figure.
% OUTPUT: the figure with its fields

%Create main figure
out_calc.figcalc = uifigure('Visible', 'off','Position',[100 100 494 665],'Name',...
    ['Main calculation interface - file ' SV.filename]);
out_chin = [];
out_legL = [];
out_legR = [];
out_armL = [];
out_armR = [];
out_PLM = [];
out_calc.figcalc.UserData = struct('SV',SV,'out_chin',out_chin,...
    'out_legL',out_legL,'out_legR',out_legR,...
    'out_armL',out_armL,'out_armR',out_armR,...
    'out_PLM',out_PLM);

%------------- Atonia index and DNE ---------------------
%Title
out_calc.Title1 = uilabel(out_calc.figcalc,'HorizontalAlignment','center',...
    'FontSize',16,'FontWeight','bold','Position',[1 607 494 37],'Text',...
    {'For atonia index and DNE calculations:'; 'select EMG signals and specify their channels and artifacts'});
%Chin
out_calc.ChinCheckBox = uicheckbox(out_calc.figcalc,'Text','Chin',...
    'Position',[80 562 116 36]);
out_calc.ChinSpecs = uibutton(out_calc.figcalc, 'push','Position',[182 569 214 22],...
    'Text','Specify channel(s) and artifacts chin');
out_calc.ChinSpecs.ButtonPushedFcn=@makefig_chin;
%LegL
out_calc.LegLBox = uicheckbox(out_calc.figcalc,'Text','Left leg',...
    'Position',[80 507 116 36]);
out_calc.LegLSpecs = uibutton(out_calc.figcalc, 'push','Position',[177 514 224 22],...
    'Text','Specify channel(s) and artifacts left leg');
out_calc.LegLSpecs.ButtonPushedFcn=@makefig_legL;
%LegR
out_calc.LegRBox = uicheckbox(out_calc.figcalc,'Text','Right leg',...
    'Position',[80 445 116 36]);
out_calc.LegRSpecs = uibutton(out_calc.figcalc, 'push','Position',[174 452 231 22],...
    'Text','Specify channel(s) and artifacts right leg');
out_calc.LegRSpecs.ButtonPushedFcn=@makefig_legR;
%ArmL
out_calc.ArmLBox = uicheckbox(out_calc.figcalc,'Text','Left arm',...
    'Position',[80 385 116 36]);
out_calc.ArmLSpecs = uibutton(out_calc.figcalc, 'push','Position',[175 392 228 22],...
    'Text','Specify channel(s) and artifacts left arm');
out_calc.ArmLSpecs.ButtonPushedFcn=@makefig_armL;
%ArmR
out_calc.ArmRBox = uicheckbox(out_calc.figcalc,'Text','Right arm',...
    'Position',[80 322 116 36]);
out_calc.ArmRSpecs = uibutton(out_calc.figcalc, 'push','Position',[171 329 236 22],...
    'Text','Specify channel(s) and artifacts right arm');
out_calc.ArmRSpecs.ButtonPushedFcn=@makefig_armR;
%Notch filter
out_calc.NotchButtonGroup = uibuttongroup(out_calc.figcalc,'Title','Notch',...
    'Position',[74 203 100 106]);
out_calc.NoNotchButton = uiradiobutton(out_calc.NotchButtonGroup,'Text','No',...
    'Position',[11 60 58 22],'Value',true);
out_calc.Button50Notch = uiradiobutton(out_calc.NotchButtonGroup,'Text','50 Hz',...
    'Position',[11 38 65 22]);
out_calc.Button60Notch = uiradiobutton(out_calc.NotchButtonGroup,'Text','60 Hz',...
    'Position',[11 16 65 22]);
%Low cut
out_calc.LowcutCheckBox = uicheckbox(out_calc.figcalc,'Text','Low-cut','Position',...
    [195 273 64 22],'Value',1);
out_calc.SpinnerLow = uispinner(out_calc.figcalc,'Position',[284 273 100 22],'Value',10, ...
    'Limits',[0 Inf]);
%High cut
out_calc.HighcutCheckBox = uicheckbox(out_calc.figcalc,'Text','High-cut','Position',...
    [195 232 67 22],'Value',1);
out_calc.SpinnerHigh = uispinner(out_calc.figcalc,'Position',[284 232 100 22],'Value',100, ...
    'Limits',[0 Inf]);
%Visualize results
out_calc.Visualize = uicheckbox(out_calc.figcalc,'Position',[158 158 206 22],...
    'Text','Visualize results after calculation');

%---------- LM indices --------------
%Title
out_calc.Title2 = uilabel(out_calc.figcalc,'HorizontalAlignment','center',...
    'FontSize',16,'FontWeight','bold','Position',[2 113 494 37],'Text',...
    'For calculation of LM indices according to WASM');
%Checkbox and specify annotations
out_calc.LMCheckBox = uicheckbox(out_calc.figcalc,'Text','Calculate LM indices',...
    'Position',[75 78 133 36]);
out_calc.SpecifyAnnLM = uibutton(out_calc.figcalc,'push','Position',[240 85 166 22],...
    'Text','Specify relevant annotations');
out_calc.SpecifyAnnLM.ButtonPushedFcn=@makefig_PLM;
% Histograms IMI
out_calc.VisualizeHist = uicheckbox(out_calc.figcalc,'Position',[178 67 153 22],...
    'Text','Visualize histograms IMI');

%----Visualize choices button----
out_calc.VisualizeButton = uibutton(out_calc.figcalc,'push','Position',[128 10 100 46],...
    'Text',{'Visualize'; 'choices'});
out_calc.VisualizeButton.ButtonPushedFcn = @(~,~)display_choices(out_calc);


%----Calculate button-----
out_calc.CalculateButton = uibutton(out_calc.figcalc,'push','Position',[258 10 100 46],...
    'Text','Calculate');
out_calc.CalculateButton.ButtonPushedFcn=@(~,~)closeFig(out_calc.figcalc);

% If settings are available from previous file, include them
txt_warning = {};
if ~isempty(settings_from_file)
    [out_calc,txt_warning] = import_settings(out_calc,settings_from_file,SV);
end

%Make it visible
movegui(out_calc.figcalc,'center')
out_calc.figcalc.Visible = 'on';

%Show the warnings if the settings from a previous file could not be applied to
%this file
if ~isempty(txt_warning)
    warndlg(txt_warning)
end

end

%% Function to select the parameters for CHIN

function makefig_chin(src,event)
%MAKEFIG_CHIN: This function allows the user to select the EMG channels for
%the chin and to define the annotations to consider as artifacts

%Data from parent UI
fig = ancestor(src,"figure","toplevel");
data = fig.UserData;
out_chin = data.out_chin;
SV = data.SV;
%Define the figure
out_chin.figchin = uifigure('Visible', 'off','Position',[100 100 867 447],'Name',['Define chin and its artifacts - file ' SV.filename]); 
out_chin.chinPanel = uipanel(out_chin.figchin,'Position',[21 16 838 491]);
movegui(out_chin.figchin,'center')
%Title
out_chin.Title = uilabel(out_chin.chinPanel,'FontSize',16,'FontWeight','bold',...
    'Position',[271 397 320 26],'Text','Chin - specify channel(s) and artifacts');
%Type (no or derivation) and channels
out_chin.TypeButtonGroup = uibuttongroup(out_chin.chinPanel,'Title','Specify channel or derivation',...
    'Position',[31 284 722 104]);
%-single channel
out_chin.UnipolarButton = uiradiobutton(out_chin.TypeButtonGroup,'Text','Single channel',...
    'Position',[35 57 101 22],'Value',true);
out_chin.SingleChannelLabel = uilabel(out_chin.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[164 57 50 22],'Text','Channel');
out_chin.SingleChannelDropDown = uidropdown(out_chin.TypeButtonGroup,'Position',[229 57 188 22],...
    'Items',SV.NewSignalLabels);
%-derivation
out_chin.BipolarButton = uiradiobutton(out_chin.TypeButtonGroup,'Text','Derivation',...
    'Position',[34 14 76 22]);
out_chin.DerivChannel1Label = uilabel(out_chin.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[153 14 60 22],'Text','Channel 1');
out_chin.DerivChannel1DropDown = uidropdown(out_chin.TypeButtonGroup,'Position',[228 14 189 22],...
    'Items',SV.NewSignalLabels);
out_chin.DerivChannel2Label = uilabel(out_chin.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[435 14 60 22],'Text','Channel 2');
out_chin.DerivChannel2DropDown = uidropdown(out_chin.TypeButtonGroup,'Position',[510 14 199 22],...
    'Items',SV.NewSignalLabels);
%Artifacts
out_chin.ArtifactsCheckBox = uicheckbox(out_chin.chinPanel,'Text','Artifacts','Position',[35 251 66 22]);
out_chin.ListBox = uilistbox(out_chin.chinPanel,'Position',[121 10 562 263],'Items',SV.annotations_unique,'Multiselect','on');
%Confirm button
out_chin.ConfirmButton = uibutton(out_chin.chinPanel,'push','Position',[708 10 100 46],...
    'Text','Confirm');
out_chin.ConfirmButton.ButtonPushedFcn = @(~,~)confirmCloseChin(fig,out_chin);

%Make the figure visible
movegui(out_chin.figchin,'center')
out_chin.figchin.Visible = 'on';
end

function confirmCloseChin(fig,out_chin)
fig.UserData.out_chin = out_chin;
uiresume(out_chin.figchin)
out_chin.figchin.Visible='off';
end

%% Function to select the parameters for LEG LEFT

function makefig_legL(src,event)
%MAKEFIG_LEGL: This function allows the user to select the EMG channels for
%the legL and to define the annotations to consider as artifacts

%Data from parent UI
fig = ancestor(src,"figure","toplevel");
data = fig.UserData;
out_legL = data.out_legL;
SV = data.SV;
%Define the figure
out_legL.figlegL = uifigure('Visible', 'off','Position',[100 100 867 447],'Name',['Define leg left and its artifacts - file ' SV.filename]); 
out_legL.legLPanel = uipanel(out_legL.figlegL,'Position',[21 16 838 491]);
%Title
out_legL.Title = uilabel(out_legL.legLPanel,'FontSize',16,'FontWeight','bold',...
    'Position',[271 397 320 26],'Text','Left leg - specify channel(s) and artifacts');
%Type (no or derivation) and channels
out_legL.TypeButtonGroup = uibuttongroup(out_legL.legLPanel,'Title','Specify channel or derivation',...
    'Position',[31 284 722 104]);
%-single channel
out_legL.UnipolarButton = uiradiobutton(out_legL.TypeButtonGroup,'Text','Single channel',...
    'Position',[35 57 101 22],'Value',true);
out_legL.SingleChannelLabel = uilabel(out_legL.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[164 57 50 22],'Text','Channel');
out_legL.SingleChannelDropDown = uidropdown(out_legL.TypeButtonGroup,'Position',[229 57 188 22],...
    'Items',SV.NewSignalLabels);
%-derivation
out_legL.BipolarButton = uiradiobutton(out_legL.TypeButtonGroup,'Text','Derivation',...
    'Position',[34 14 76 22]);
out_legL.DerivChannel1Label = uilabel(out_legL.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[153 14 60 22],'Text','Channel 1');
out_legL.DerivChannel1DropDown = uidropdown(out_legL.TypeButtonGroup,'Position',[228 14 189 22],...
    'Items',SV.NewSignalLabels);
out_legL.DerivChannel2Label = uilabel(out_legL.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[435 14 60 22],'Text','Channel 2');
out_legL.DerivChannel2DropDown = uidropdown(out_legL.TypeButtonGroup,'Position',[510 14 199 22],...
    'Items',SV.NewSignalLabels);
%Artifacts
out_legL.ArtifactsCheckBox = uicheckbox(out_legL.legLPanel,'Text','Artifacts','Position',[35 251 66 22]);
out_legL.ListBox = uilistbox(out_legL.legLPanel,'Position',[121 10 562 263],'Items',SV.annotations_unique,'Multiselect','on');
%Confirm button
out_legL.ConfirmButton = uibutton(out_legL.legLPanel,'push','Position',[708 10 100 46],...
    'Text','Confirm');
out_legL.ConfirmButton.ButtonPushedFcn = @(~,~)confirmCloseLegL(fig,out_legL);
%Make it visible
movegui(out_legL.figlegL,'center')
out_legL.figlegL.Visible = 'on';
end

function confirmCloseLegL(fig,out_legL)
fig.UserData.out_legL = out_legL;
uiresume(out_legL.figlegL)
out_legL.figlegL.Visible='off';
end

%% Function to select the parameters for LEG RIGHT

function makefig_legR(src,event)
%MAKEFIG_LEGR: This function allows the user to select the EMG channels for
%the legR and to define the annotations to consider as artifacts

%Data from parent UI
fig = ancestor(src,"figure","toplevel");
data = fig.UserData;
out_legR = data.out_legR;
SV = data.SV;
%Define the figure
out_legR.figlegR = uifigure('Visible', 'off','Position',[100 100 867 447],'Name',['Define leg right and its artifacts - file ' SV.filename]); 
out_legR.legRPanel = uipanel(out_legR.figlegR,'Position',[21 16 838 491]);
%Title
out_legR.Title = uilabel(out_legR.legRPanel,'FontSize',16,'FontWeight','bold',...
    'Position',[271 397 320 26],'Text','Right leg - specify channel(s) and artifacts');
%Type (no or derivation) and channels
out_legR.TypeButtonGroup = uibuttongroup(out_legR.legRPanel,'Title','Specify channel or derivation',...
    'Position',[31 284 722 104]);
%-single channel
out_legR.UnipolarButton = uiradiobutton(out_legR.TypeButtonGroup,'Text','Single channel',...
    'Position',[35 57 101 22],'Value',true);
out_legR.SingleChannelLabel = uilabel(out_legR.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[164 57 50 22],'Text','Channel');
out_legR.SingleChannelDropDown = uidropdown(out_legR.TypeButtonGroup,'Position',[229 57 188 22],...
    'Items',SV.NewSignalLabels);
%-derivation
out_legR.BipolarButton = uiradiobutton(out_legR.TypeButtonGroup,'Text','Derivation',...
    'Position',[34 14 76 22]);
out_legR.DerivChannel1Label = uilabel(out_legR.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[153 14 60 22],'Text','Channel 1');
out_legR.DerivChannel1DropDown = uidropdown(out_legR.TypeButtonGroup,'Position',[228 14 189 22],...
    'Items',SV.NewSignalLabels);
out_legR.DerivChannel2Label = uilabel(out_legR.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[435 14 60 22],'Text','Channel 2');
out_legR.DerivChannel2DropDown = uidropdown(out_legR.TypeButtonGroup,'Position',[510 14 199 22],...
    'Items',SV.NewSignalLabels);
%Artifacts
out_legR.ArtifactsCheckBox = uicheckbox(out_legR.legRPanel,'Text','Artifacts','Position',[35 251 66 22]);
out_legR.ListBox = uilistbox(out_legR.legRPanel,'Position',[121 10 562 263],'Items',SV.annotations_unique,'Multiselect','on');
%Confirm button
out_legR.ConfirmButton = uibutton(out_legR.legRPanel,'push','Position',[708 10 100 46],...
    'Text','Confirm');
out_legR.ConfirmButton.ButtonPushedFcn = @(~,~)confirmCloseLegR(fig,out_legR);
%Make it visible
movegui(out_legR.figlegR,'center')
out_legR.figlegR.Visible = 'on';
end

function confirmCloseLegR(fig,out_legR)
fig.UserData.out_legR = out_legR;
uiresume(out_legR.figlegR)
out_legR.figlegR.Visible='off';
end

%% Function to select the parameters for ARM LEFT

function makefig_armL(src,event)
%MAKEFIG_ARML: This function allows the user to select the EMG channels for
%the armL and to define the annotations to consider as artifacts

%Data from parent UI
fig = ancestor(src,"figure","toplevel");
data = fig.UserData;
out_armL = data.out_armL;
SV = data.SV;
%Define the figure
out_armL.figarmL = uifigure('Visible', 'off','Position',[100 100 867 447],'Name',['Define arm left and its artifacts - file ' SV.filename]); 
out_armL.armLPanel = uipanel(out_armL.figarmL,'Position',[21 16 838 491]);
%Title
out_armL.Title = uilabel(out_armL.armLPanel,'FontSize',16,'FontWeight','bold',...
    'Position',[271 397 320 26],'Text','Left arm - specify channel(s) and artifacts');
%Type (no or derivation) and channels
out_armL.TypeButtonGroup = uibuttongroup(out_armL.armLPanel,'Title','Specify channel or derivation',...
    'Position',[31 284 722 104]);
%-single channel
out_armL.UnipolarButton = uiradiobutton(out_armL.TypeButtonGroup,'Text','Single channel',...
    'Position',[35 57 101 22],'Value',true);
out_armL.SingleChannelLabel = uilabel(out_armL.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[164 57 50 22],'Text','Channel');
out_armL.SingleChannelDropDown = uidropdown(out_armL.TypeButtonGroup,'Position',[229 57 188 22],...
    'Items',SV.NewSignalLabels);
%-derivation
out_armL.BipolarButton = uiradiobutton(out_armL.TypeButtonGroup,'Text','Derivation',...
    'Position',[34 14 76 22]);
out_armL.DerivChannel1Label = uilabel(out_armL.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[153 14 60 22],'Text','Channel 1');
out_armL.DerivChannel1DropDown = uidropdown(out_armL.TypeButtonGroup,'Position',[228 14 189 22],...
    'Items',SV.NewSignalLabels);
out_armL.DerivChannel2Label = uilabel(out_armL.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[435 14 60 22],'Text','Channel 2');
out_armL.DerivChannel2DropDown = uidropdown(out_armL.TypeButtonGroup,'Position',[510 14 199 22],...
    'Items',SV.NewSignalLabels);
%Artifacts
out_armL.ArtifactsCheckBox = uicheckbox(out_armL.armLPanel,'Text','Artifacts','Position',[35 251 66 22]);
out_armL.ListBox = uilistbox(out_armL.armLPanel,'Position',[121 10 562 263],'Items',SV.annotations_unique,'Multiselect','on');
%Confirm button
out_armL.ConfirmButton = uibutton(out_armL.armLPanel,'push','Position',[708 10 100 46],...
    'Text','Confirm');
out_armL.ConfirmButton.ButtonPushedFcn = @(~,~)confirmCloseArmL(fig,out_armL);
%Visualize
movegui(out_armL.figarmL,'center')
out_armL.figarmL.Visible ='on';
end

function confirmCloseArmL(fig,out_armL)
fig.UserData.out_armL = out_armL;
uiresume(out_armL.figarmL)
out_armL.figarmL.Visible='off';
end

%% Function to select the parameters for ARM RIGHT

function makefig_armR(src,event)
%MAKEFIG_ARMR: This function allows the user to select the EMG channels for
%the armR and to define the annotations to consider as artifacts

%Data from parent UI
fig = ancestor(src,"figure","toplevel");
data = fig.UserData;
out_armR = data.out_armR;
SV = data.SV;
%Define the figure
out_armR.figarmR = uifigure('Visible', 'off','Position',[100 100 867 447],'Name',['Define arm right and its artifacts - file ' SV.filename]); 
out_armR.armRPanel = uipanel(out_armR.figarmR,'Position',[21 16 838 491]);
%Title
out_armR.Title = uilabel(out_armR.armRPanel,'FontSize',16,'FontWeight','bold',...
    'Position',[271 397 320 26],'Text','Right arm - specify channel(s) and artifacts');
%Type (no or derivation) and channels
out_armR.TypeButtonGroup = uibuttongroup(out_armR.armRPanel,'Title','Specify channel or derivation',...
    'Position',[31 284 722 104]);
%-single channel
out_armR.UnipolarButton = uiradiobutton(out_armR.TypeButtonGroup,'Text','Single channel',...
    'Position',[35 57 101 22],'Value',true);
out_armR.SingleChannelLabel = uilabel(out_armR.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[164 57 50 22],'Text','Channel');
out_armR.SingleChannelDropDown = uidropdown(out_armR.TypeButtonGroup,'Position',[229 57 188 22],...
    'Items',SV.NewSignalLabels);
%-derivation
out_armR.BipolarButton = uiradiobutton(out_armR.TypeButtonGroup,'Text','Derivation',...
    'Position',[34 14 76 22]);
out_armR.DerivChannel1Label = uilabel(out_armR.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[153 14 60 22],'Text','Channel 1');
out_armR.DerivChannel1DropDown = uidropdown(out_armR.TypeButtonGroup,'Position',[228 14 189 22],...
    'Items',SV.NewSignalLabels);
out_armR.DerivChannel2Label = uilabel(out_armR.TypeButtonGroup,'HorizontalAlignment','right',...
    'Position',[435 14 60 22],'Text','Channel 2');
out_armR.DerivChannel2DropDown = uidropdown(out_armR.TypeButtonGroup,'Position',[510 14 199 22],...
    'Items',SV.NewSignalLabels);
%Artifacts
out_armR.ArtifactsCheckBox = uicheckbox(out_armR.armRPanel,'Text','Artifacts','Position',[35 251 66 22]);
out_armR.ListBox = uilistbox(out_armR.armRPanel,'Position',[121 10 562 263],'Items',SV.annotations_unique,'Multiselect','on');
%Confirm button
out_armR.ConfirmButton = uibutton(out_armR.armRPanel,'push','Position',[708 10 100 46],...
    'Text','Confirm');
out_armR.ConfirmButton.ButtonPushedFcn = @(~,~)confirmCloseArmR(fig,out_armR);
%Visualize
movegui(out_armR.figarmR,'center')
out_armR.figarmR.Visible = 'on';
end

function confirmCloseArmR(fig,out_armR)
fig.UserData.out_armR = out_armR;
uiresume(out_armR.figarmR)
out_armR.figarmR.Visible='off';
end

%% Function to select the PLM annotations

function makefig_PLM(src,event)
%MAKEFIG_PLM: This function allows the user to select the annotations
%necessary to calculate the LM indices

%Data from parent UI
fig = ancestor(src,"figure","toplevel");
data = fig.UserData;
out_PLM = data.out_PLM;
SV = data.SV;

out_PLM.figPLM = uifigure('Visible','off','Position',[100 100 572 633],...
    'Name',['Specify annotations for LM indices calculation - file ' SV.filename]);
out_PLM.title = uilabel(out_PLM.figPLM,'HorizontalAlignment','center',...
    'FontSize',16,'FontWeight','bold','Position',[1 586 572 30],...
    'Text','Specify annotations for LM indices calculation');
out_PLM.leftCheck = uicheckbox(out_PLM.figPLM,'Text','Limb movement - left',...
    'Position',[11 540 150 22]);
out_PLM.leftDropDown = uidropdown(out_PLM.figPLM,'Position',[171 539 369 24],...
    'Items',SV.annotations_unique);
out_PLM.rightCheck = uicheckbox(out_PLM.figPLM,'Text','Limb movement - right',...
    'Position',[12 482 150 22]);
out_PLM.rightDropDown = uidropdown(out_PLM.figPLM,'Position',[171 481 370 24],...
    'Items',SV.annotations_unique);
out_PLM.arousalCheck = uicheckbox(out_PLM.figPLM,'Text','Arousals','Position',...
    [12 407 150 22]);
out_PLM.arousalList = uilistbox(out_PLM.figPLM,'Position',[129 257 411 172],...
    'Items',SV.annotations_unique,'Multiselect','on');
out_PLM.respCheck = uicheckbox(out_PLM.figPLM,'Text','Resp. Events','Position',...
    [13 218 150 22]);
out_PLM.respList = uilistbox(out_PLM.figPLM,'Position',[129 68 412 172],...
    'Items',SV.annotations_unique,'Multiselect','on');
out_PLM.confirmButton = uibutton(out_PLM.figPLM,'push','Position',[207 7 170 38],...
    'Text','Confirm');
out_PLM.confirmButton.ButtonPushedFcn=@(~,~)confirmClosePLM(fig,out_PLM);
movegui(out_PLM.figPLM,'center')
out_PLM.figPLM.Visible = 'on';

end

function confirmClosePLM(fig,out_PLM)
fig.UserData.out_PLM = out_PLM;
uiresume(out_PLM.figPLM)
out_PLM.figPLM.Visible='off';
end


