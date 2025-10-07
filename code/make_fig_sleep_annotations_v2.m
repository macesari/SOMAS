function outsleep = make_fig_sleep_annotations_v2(SV,settings_from_file)
%MAKE_FIG_SLEEP_ANNOTATIONS_V2: this function draws the figure where the
%annotations of lights off, lights on and sleep stages are selected.
% INPUT: SV, the structure containing the EDF+ file; settings_from_file, if
% the user selected a file with the saved settings, these will be used to
% fill in the figure.
% OUTPUT: the figure with its fields

%Setting up the figure
outsleep.figsleep = uifigure('Visible','off','Position',[300 300 640 592],'Name',['Specify hypnogram annotations - file ' SV.filename]);
outsleep.SpecifyannotationsPanel = uipanel(outsleep.figsleep,'Title','Specify annotations for the generation of the hypnogram','Position',[20 35 604 542]);
outsleep.LightsoffLabel = uilabel(outsleep.SpecifyannotationsPanel,'Position',[31 479 101 22],'Text','Lights off');
outsleep.LightsonLabel = uilabel(outsleep.SpecifyannotationsPanel,'Position',[33 422 101 22],'Text','Lights on');
outsleep.ListBox_loff = uidropdown(outsleep.SpecifyannotationsPanel,'Position',[136 479 438 22],'Items',SV.annotations_unique);
outsleep.ListBox_lon = uidropdown(outsleep.SpecifyannotationsPanel,'Position',[137 422 438 22],'Items',SV.annotations_unique);
outsleep.WLabel = uilabel(outsleep.SpecifyannotationsPanel,'Position',[32 359 101 22],'Text','Wakefulness');
outsleep.ListBox_W = uidropdown(outsleep.SpecifyannotationsPanel,'Position',[138 359 438 22],'Items',SV.annotations_unique);
outsleep.N1Label = uilabel(outsleep.SpecifyannotationsPanel,'Position',[32 292 101 22],'Text','N1 sleep');
outsleep.ListBox_N1 = uidropdown(outsleep.SpecifyannotationsPanel,'Position',[139 292 438 22],'Items',SV.annotations_unique);
outsleep.N2Label = uilabel(outsleep.SpecifyannotationsPanel,'Position',[32 225 101 22],'Text','N2 sleep');
outsleep.ListBox_N2 = uidropdown(outsleep.SpecifyannotationsPanel,'Position',[140 225 438 22],'Items',SV.annotations_unique);
outsleep.N3Label = uilabel(outsleep.SpecifyannotationsPanel,'Position',[32 152 101 22],'Text','N3 sleep');
outsleep.ListBox_N3 = uidropdown(outsleep.SpecifyannotationsPanel,'Position',[141 152 438 22],'Items',SV.annotations_unique);
outsleep.REMLabel = uilabel(outsleep.SpecifyannotationsPanel,'Position',[32 85 101 22],'Text','REM sleep');
outsleep.ListBox_REM = uidropdown(outsleep.SpecifyannotationsPanel,'Position',[142 85 438 22],'Items',SV.annotations_unique');
outsleep.NextButton_sleep = uibutton(outsleep.SpecifyannotationsPanel, 'push','Position',[217 16 177 36],'Text','Next');
outsleep.NextButton_sleep.ButtonPushedFcn=@(~,~)closeFig(outsleep.figsleep);

%If the settings were saved, use them 
if ~isempty(settings_from_file)
    %Lights off
    if sum(ismember(SV.annotations_unique,settings_from_file.s.ann_hypno.ann_loff))==1
        outsleep.ListBox_loff.Value = settings_from_file.s.ann_hypno.ann_loff;
    end
    %Lights on
    if sum(ismember(SV.annotations_unique,settings_from_file.s.ann_hypno.ann_lon))==1
        outsleep.ListBox_lon.Value = settings_from_file.s.ann_hypno.ann_lon;
    end
    %Wakefulness
    if sum(ismember(SV.annotations_unique,settings_from_file.s.ann_hypno.ann_W))==1
        outsleep.ListBox_W.Value = settings_from_file.s.ann_hypno.ann_W;
    end
    %N1 sleep
    if sum(ismember(SV.annotations_unique,settings_from_file.s.ann_hypno.ann_N1))==1
        outsleep.ListBox_N1.Value = settings_from_file.s.ann_hypno.ann_N1;
    end
    %N2 sleep
    if sum(ismember(SV.annotations_unique,settings_from_file.s.ann_hypno.ann_N2))==1
        outsleep.ListBox_N2.Value = settings_from_file.s.ann_hypno.ann_N2;
    end
    %N3 sleep
    if sum(ismember(SV.annotations_unique,settings_from_file.s.ann_hypno.ann_N3))==1
        outsleep.ListBox_N3.Value = settings_from_file.s.ann_hypno.ann_N3;
    end
    %REM sleep
    if sum(ismember(SV.annotations_unique,settings_from_file.s.ann_hypno.ann_REM))==1
        outsleep.ListBox_REM.Value = settings_from_file.s.ann_hypno.ann_REM;
    end
end

movegui(outsleep.figsleep,'center')
outsleep.figsleep.Visible='on';
end

