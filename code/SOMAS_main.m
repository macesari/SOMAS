function SOMAS_main

% SOMAS_main
% Version 1.0 (August 2025)
% Description:
%   SOMAS (Sleep Open-source Muscle Activity Analysis System) is a
%   user-friendly software that allows calculation of the following: 
%   1. Atonia index (AI) in all sleep stages (see:
%   https://pubmed.ncbi.nlm.nih.gov/20817596/) 
%   2. Distributions of normalized EMG values (DNE) in all sleep stages
%   (see: https://pubmed.ncbi.nlm.nih.gov/28329117/)
%   3. Leg movement indices according to the WASM 2016 criteria (see:
%   https://pubmed.ncbi.nlm.nih.gov/27890390/) 
% SOMAS needs in input an EDF+ data
% Code written by Matteo Cesari, Department of Neurology, Medical
% University of Innsbruck, Austria. For questions on the code, please
% contact matteo.cesari@i-med.ac.at

clearvars
close all

try % To catch any exception
    
    %% Selection of the EDF+ file
    SV = []; %Structure that keeps all the file
    [SV.filename, SV.path ] = uigetfile({'*.edf'}, 'Select the EDF+ file');
    fprintf('\n=================================================================\n');
    disp(['Start analysis: ' datestr(datetime)])
    fprintf('EDF+ File\t\t:\t %s\n', SV.filename)

    %% Read the EDF+ file
    fig_read_edf = uifigure('Visible','off');
    movegui(fig_read_edf,'center')
    fig_read_edf.Visible = 'on';
    uiprogressdlg(fig_read_edf,'Title','Please Wait',...
            'Message','Loading EDF+ file','Indeterminate','on');
    drawnow
    try 
        [SV.data, SV.annotations] = edfread([SV.path, SV.filename]);
        SV.header = edfinfo([SV.path, SV.filename]);
        disp('The EDF+ file has been succesfully imported')
    catch 
        [SV.data, SV.annotations]   = my_edfread([SV.path, SV.filename]);
        SV.header = my_edfinfo([SV.path, SV.filename]);
        disp('The EDF+ file has been succesfully imported with the modified function')
    end
    close(fig_read_edf)

    % Make a check if it is an EDF+ or not
    s = SV.header.Reserved;
    if strcmp(s,'') %It is an EDF, not an EDF+
        errordlg('The selected file is an EDF and not an EDF+ file')
        disp('The selected file is not an EDF and not an EDF+ file')
        clearvars
        pause(20)
        quit force % Interrupt after 20 seconds
    end

    % Add the channel numbers and creade new signal labels, this is needed
    % as sometimes different channels have the same name 
    for i = 1:length(SV.header.SignalLabels)
        this_label = SV.header.SignalLabels{i};
        new_label = ['ch_' num2str(i) '_' this_label];
        SV.NewSignalLabels{i,1} = new_label;
    end


    %% Ask the user to define the start and end of the analysis window
    out_select_times = makefig_select_times(SV);
    uiwait(out_select_times.figanalysis);

    %Check that the times are within the start and end of recording, otherwise throw an error
    start_recording = datetime(out_select_times.StartrecordingTextArea.Value,'Format',...
        'yyyy-MM-dd HH:mm:ss');
    start_analysis = datetime(out_select_times.StartanalysisTextArea.Value,'Format',...
        'yyyy-MM-dd HH:mm:ss');
    end_recording = datetime(out_select_times.EndrecordingTextArea.Value,'Format',...
        'yyyy-MM-dd HH:mm:ss');
    end_analysis = datetime(out_select_times.EndanalysisTextArea.Value,'Format',...
        'yyyy-MM-dd HH:mm:ss');

    if start_analysis<start_recording || end_analysis>end_recording
        e = errordlg('Error: either the start analysis is set prior to the start of the recording or the end of the analysis after the end of the recording');
        movegui(e,'center')
        error('Error: either the start analysis is set prior to the start of the recording or the end of the analysis after the end of the recording')
    end

    %Based on the start and end of the recording and analysis, define the
    %window where the analysis should be performed. A vector with sampling
    %frequency of 1 Hz is created for this purpose
    dur_recording = seconds(end_recording-start_recording);
    analysis_window = ones(dur_recording,1);
    removed_beginning = seconds(start_analysis-start_recording);
    removed_end = seconds(end_recording-end_analysis);
    if removed_beginning>0
        analysis_window(1:removed_beginning) = 0;
    end
    if removed_end>0
        analysis_window(end-removed_end:end) = 0;
    end
    SV.analysis_window = analysis_window; %Save in SV

    %Print these values in the log file
    disp(['Start recording: ' datestr(start_recording)])
    disp(['End recording: ' datestr(end_recording)])
    disp(['Start analysis: ' datestr(start_analysis)])
    disp(['End analysis: ' datestr(end_analysis)])

    %% Get annotations from EDF+ file
    % The annotations are repeated in the file, therefore get only the unique
    % annotations (i.e. not repeated)
    annotations_unique = cellstr(unique(SV.annotations{:,"Annotations"}));

    %If the text of an annotation contains a new line, remove it and replace it
    %with a white space
    for i = 1:length(annotations_unique)
        thisString = annotations_unique{i};
        thisString(thisString == newline) = '';
        annotations_unique{i} = thisString;
    end

    %Save the name of the annotations
    SV.annotations_unique = [{'Annotation not available'}; annotations_unique];
    
    %% Ask if there is a file where the selections have been made and, if so, select it
    % In case the user already saved the settings (i.e., annotations and
    % channels), these are now loaded here

    answer_loadSettings = questdlg('Would you like to load the settings from a previous file?', ...
	'Load Settings','Yes','No','Yes');
    switch answer_loadSettings
        case 'Yes'
            [filename_settings, path_settings] = uigetfile({'*.mat'}, 'Select the settings file');
            settings_from_file = load([path_settings filename_settings]);
        case 'No'
            settings_from_file = [];
    end
    
    %% Select annotations ligths off, lights on and sleep stages and create hypnogram
    %The user is asked to provide the name of the annotations defining
    %lights off, lights on and the sleep stages.
    
    out_sleep = make_fig_sleep_annotations_v2(SV,settings_from_file);
    uiwait(out_sleep.figsleep);

    figwaithypno = uifigure('Visible','off');
    movegui(figwaithypno,'center');
    figwaithypno.Visible='on';
    uiprogressdlg(figwaithypno,'Title','Please Wait',...
        'Message','Preparing the hypnogram','Indeterminate','on');
    drawnow

    % With these annotations create the hypnogram (frequency of 1 Hz)
    
    % Get the annotations from the figure
    ann_W = out_sleep.ListBox_W.Value;
    if strcmp(ann_W,'Annotation not available')
        ann_W = [];
    end
    ann_N1 = out_sleep.ListBox_N1.Value;
    if strcmp(ann_N1,'Annotation not available')
        ann_N1 = [];
    end
    ann_N2 = out_sleep.ListBox_N2.Value;
    if strcmp(ann_N2,'Annotation not available')
        ann_N2 = [];
    end
    ann_N3 = out_sleep.ListBox_N3.Value;
    if strcmp(ann_N3,'Annotation not available')
        ann_N3 = [];
    end
    ann_REM = out_sleep.ListBox_REM.Value;
    if strcmp(ann_REM,'Annotation not available')
        ann_REM = [];
    end

    %Add an error if no sleep/wake annotation is provided
    if isempty(ann_W) && isempty(ann_N1) && isempty(ann_N2) && isempty(ann_N3) && isempty(ann_REM)
        errordlg('No wake/sleep annotation has been selected')
        disp('No wake/sleep annotation has been selected')
        clearvars
        pause(20)
        quit force
    end


    % Initialize the hypnogram as a vector with sampling frequency of 1 Hz 
    % with duration between start and end of the recording. Note that the
    % following code is used:
    % W = 1, N1 = -1, N2 = -2, N3 = -3, REM = 0, unscored = 2

    hypnogram = nan(1,dur_recording);
    for i = 1:size(SV.annotations,1)
        thisAnnotation = SV.annotations{i,"Annotations"};
        thisStart = round(seconds(SV.annotations.Properties.RowTimes(i)));
        thisDuration = round(seconds(SV.annotations.Duration(i)));    
        if strcmp(thisAnnotation,ann_W)
            stage = 1;
            hypnogram(thisStart+1:thisStart+thisDuration) = stage;
        elseif strcmp(thisAnnotation,ann_N1)
            stage = -1;
            hypnogram(thisStart+1:thisStart+thisDuration) = stage;
        elseif strcmp(thisAnnotation,ann_N2)
            stage = -2; 
            hypnogram(thisStart+1:thisStart+thisDuration) = stage;
        elseif strcmp(thisAnnotation,ann_N3)
            stage = -3;
            hypnogram(thisStart+1:thisStart+thisDuration) = stage;
        elseif strcmp(thisAnnotation,ann_REM)
            stage = -5; % Temporary value for REM
            hypnogram(thisStart+1:thisStart+thisDuration) = stage;
        end    
    end
    %First, change the ones set by Matlab from 0 to 2 (i.e., the unscored
    %ones) and then finally assign 0 to the REM epochs
    hypnogram(hypnogram==0) = 2;
    hypnogram(hypnogram==-5) = 0;
    SV.hypno = hypnogram; % The hypnogram is now saved

    %Print the annotations that have been selected on the log file
    disp('The hypnogram has been created with the following annotations:')
    disp(['Lights off: ' out_sleep.ListBox_loff.Value])
    disp(['Lights on: ' out_sleep.ListBox_lon.Value])
    disp(['Wakefulness: ' ann_W])
    disp(['N1 sleep: ' ann_N1])
    disp(['N2 sleep: ' ann_N2])
    disp(['N3 sleep: ' ann_N3])
    disp(['REM sleep: ' ann_REM])

    close(figwaithypno);

    %% Selection of channels and analyses to be performed
    % Here the function main_fig_calculations_v2 is called. This allows the
    % user to specify the channels and the analyses to be performed.

    out_calc = make_fig_main_calculations_v2(SV,settings_from_file);
    uiwait(out_calc.figcalc);

    %Print the selections in the log file, to allow the user to check what
    %has been selected
    printChoices(out_calc);

    %% Ask the user if they want to save the settings for another file
    answer_saveSettings = questdlg('Would you like to save the settings for a future analysis?', ...
	'Save Settings','Yes','No','Yes');
    %Remember only the choices..otherwise too big file!!
    switch answer_saveSettings
        case 'Yes'
            s = getSettings(out_sleep,out_calc);
            uisave('s',[SV.filename(1:end-4) '_settings'])
    end

    %% Ask the user the directory where the results should be saved
    savepath = uigetdir(SV.path,'Select directory where results should be saved'); 
    disp(['Save folder specified: ' savepath])

    %% Prepare the EMG signals
    % If an EMG signal is selected, the program prepares it by performing a
    % series of steps, as described in the function get_signal
    %Chin
    if out_calc.ChinCheckBox.Value==1
        disp('Preparing chin channel')
        figwaitchin = uifigure('Visible','off');
        movegui(figwaitchin,'center');
        figwaitchin.Visible='on';
        uiprogressdlg(figwaitchin,'Title','Please Wait',...
            'Message','Preparing the chin channel','Indeterminate','on');
        drawnow
        [chin,Fs_chin,lights_chin,hypnogram_chin,artifacts_chin,analysis_window_chin] ...
            = get_signal(SV,out_calc,out_calc.figcalc.UserData.out_chin,out_sleep,analysis_window,'chin');
        close(figwaitchin);
    end

    %Leg left
    if out_calc.LegLBox.Value==1
        disp('Preparing left leg channel')
        figwaitlegL = uifigure('Visible','off');
        movegui(figwaitlegL,'center');
        figwaitlegL.Visible='on';
        uiprogressdlg(figwaitlegL,'Title','Please Wait',...
            'Message','Preparing the left leg channel','Indeterminate','on');
        drawnow
        [legL,Fs_legL,lights_legL,hypnogram_legL,artifacts_legL,analysis_window_legL] ...
            = get_signal(SV,out_calc,out_calc.figcalc.UserData.out_legL,out_sleep,analysis_window,'leg left');
        close(figwaitlegL);
    end

    %Leg right
    if out_calc.LegRBox.Value==1
        disp('Preparing right leg channel')
        figwaitlegR = uifigure('Visible','off');
        movegui(figwaitlegR,'center');
        figwaitlegR.Visible='on';
        uiprogressdlg(figwaitlegR,'Title','Please Wait',...
            'Message','Preparing the right leg channel','Indeterminate','on');
        drawnow
        [legR,Fs_legR,lights_legR,hypnogram_legR,artifacts_legR,analysis_window_legR] ...
            = get_signal(SV,out_calc,out_calc.figcalc.UserData.out_legR,out_sleep,analysis_window,'leg right');
        close(figwaitlegR);
    end

    %Arm left
    if out_calc.ArmLBox.Value==1
        disp('Preparing left arm channel')
        figwaitarmL = uifigure('Visible','off');
        movegui(figwaitarmL,'center');
        figwaitarmL.Visible='on';
        uiprogressdlg(figwaitarmL,'Title','Please Wait',...
            'Message','Preparing the left arm channel','Indeterminate','on');
        drawnow
        [armL,Fs_armL,lights_armL,hypnogram_armL,artifacts_armL,analysis_window_armL] ...
            = get_signal(SV,out_calc,out_calc.figcalc.UserData.out_armL,out_sleep,analysis_window,'arm left');
        close(figwaitarmL);
    end

    %Arm right
    if out_calc.ArmRBox.Value==1
        disp('Preparing right arm channel')
        figwaitarmR = uifigure('Visible','off');
        movegui(figwaitarmR,'center');
        figwaitarmR.Visible='on';
        uiprogressdlg(figwaitarmR,'Title','Please Wait',...
            'Message','Preparing the right arm channel','Indeterminate','on');
        drawnow
        [armR,Fs_armR,lights_armR,hypnogram_armR,artifacts_armR,analysis_window_armR] ...
            = get_signal(SV,out_calc,out_calc.figcalc.UserData.out_armR,out_sleep,analysis_window,'arm right');
        close(figwaitarmR);
    end

    %% Calculation sleep macrostructure parameters
    % By default, SOMAS calculates parameters of sleep macrostructure. This
    % can be useful for the user to double check that there are no errors
    % in the sleep structure
    figwaitsleepparam = uifigure('Visible','off');
    movegui(figwaitsleepparam,'center')
    figwaitsleepparam.Visible = 'on';
    uiprogressdlg(figwaitsleepparam,'Title','Please Wait',...
        'Message','Calculating sleep parameters','Indeterminate','on');
    drawnow
    get_sleep_parameters(SV.filename,SV.hypno,SV.annotations,out_sleep,savepath,analysis_window,SV.header.StartDate,SV.header.StartTime)
    close(figwaitsleepparam);

    %% Calculation of atonia index and DNE
    %Check if at least one of the channels is selected
    if out_calc.ChinCheckBox.Value==1 || out_calc.LegLBox.Value==1 || ...
            out_calc.LegRBox.Value==1 || out_calc.ArmLBox.Value==1 || ...
            out_calc.ArmRBox.Value == 1   

        %---------------------Atonia index calculation-------------------------
        figwaitatoniaindex = uifigure('Visible','off');
        movegui(figwaitatoniaindex,'center')
        figwaitatoniaindex.Visible = 'on';
        uiprogressdlg(figwaitatoniaindex,'Title','Please Wait',...
            'Message','Calculating atonia index','Indeterminate','on');
        drawnow

        %Prepare the cell with the results
        results_atonia_index =  cell(7,13);
        results_atonia_index{1,1} = 'Chin';
        results_atonia_index{2,1} = 'Left leg';
        results_atonia_index{3,1} = 'Right leg';
        results_atonia_index{4,1} = 'Left arm';
        results_atonia_index{5,1} = 'Right arm';
        results_atonia_index{6,1} = 'Average legs';
        results_atonia_index{7,1} = 'Average arms';
        %Columns
        v_ai = cell(1,13);
        v_ai{1} = 'EMG channel';
        v_ai{2} = 'REM atonia index';
        v_ai{3} = 'N1 atonia index';
        v_ai{4} = 'N2 atonia index';
        v_ai{5} = 'N3 atonia index';
        v_ai{6} = 'NREM atonia index';
        v_ai{7} = 'W atonia index';
        v_ai{8} = 'REM [min]';
        v_ai{9} = 'N1 [min]';
        v_ai{10} = 'N2 [min]';
        v_ai{11} = 'N3 [min]';
        v_ai{12} = 'NREM [min]';
        v_ai{13} = 'W [min]';
        %Set the values to NaN
        for i = 1:7
            for j = 2:13
                results_atonia_index{i,j} = NaN;
           end        
        end
        %Preallocate
        out_atonia_index_chin = nan(1,12);
        out_atonia_index_legL = nan(1,12);
        out_atonia_index_legR = nan(1,12);
        out_atonia_index_armL = nan(1,12);
        out_atonia_index_armR = nan(1,12);
        %Chin
        if out_calc.ChinCheckBox.Value==1
            disp('Get atonia index for chin')
            [out_atonia_index_chin,~,~,~,~,~,~] = get_atonia_index(chin,Fs_chin,lights_chin,artifacts_chin,hypnogram_chin,analysis_window_chin);
            for j = 1:length(out_atonia_index_chin)
                results_atonia_index{1,j+1} = out_atonia_index_chin(j);
            end
        end

        %Leg left
        if out_calc.LegLBox.Value==1
            disp('Get atonia index for left leg')
            [out_atonia_index_legL,REM_legL,N1_legL,N2_legL,N3_legL,NREM_legL,W_legL] = get_atonia_index(legL,Fs_legL,lights_legL,artifacts_legL,hypnogram_legL,analysis_window_legL);
            for j = 1:length(out_atonia_index_legL)
                results_atonia_index{2,j+1} = out_atonia_index_legL(j);
            end
        end

        %Leg right
        if out_calc.LegRBox.Value==1
            disp('Get atonia index for right leg')
            [out_atonia_index_legR,REM_legR,N1_legR,N2_legR,N3_legR,NREM_legR,W_legR] = get_atonia_index(legR,Fs_legR,lights_legR,artifacts_legR,hypnogram_legR,analysis_window_legR);
            for j = 1:length(out_atonia_index_legR)
                results_atonia_index{3,j+1} = out_atonia_index_legR(j);
            end
        end

        %Arm left
        if out_calc.ArmLBox.Value==1
            disp('Get atonia index for left arm')
            [out_atonia_index_armL,REM_armL,N1_armL,N2_armL,N3_armL,NREM_armL,W_armL] = get_atonia_index(armL,Fs_armL,lights_armL,artifacts_armL,hypnogram_armL,analysis_window_armL);
            for j = 1:length(out_atonia_index_armL)
                results_atonia_index{4,j+1} = out_atonia_index_armL(j);
            end
        end

        %Arm right
        if out_calc.ArmRBox.Value==1
            disp('Get atonia index for right arm')
            [out_atonia_index_armR,REM_armR,N1_armR,N2_armR,N3_armR,NREM_armR,W_armR] = get_atonia_index(armR,Fs_armR,lights_armR,artifacts_armR,hypnogram_armR,analysis_window_armR);
            for j = 1:length(out_atonia_index_armR)
                results_atonia_index{5,j+1} = out_atonia_index_armR(j);
            end
        end

        %Average legs
        % For the values of atonia index, the simple average
        % is calculated. Instead, for the time of artifact-free signal, 
        % the union of parts considered for calculation is obtained
        if out_calc.LegLBox.Value==1 || out_calc.LegRBox.Value==1
            out_atonia_index_avg_legs = nanmean([out_atonia_index_legL; out_atonia_index_legR]);
            for j = 1:6
                results_atonia_index{6,j+1} = out_atonia_index_avg_legs(j);
            end
            if out_calc.LegLBox.Value==1 && out_calc.LegRBox.Value==1
                results_atonia_index{6,8} = round((sum(REM_legL | REM_legR)/Fs_legL)/60,2);
                results_atonia_index{6,9} = round((sum(N1_legL | N1_legR)/Fs_legL)/60,2);
                results_atonia_index{6,10} = round((sum(N2_legL | N2_legR)/Fs_legL)/60,2);
                results_atonia_index{6,11} = round((sum(N3_legL | N3_legR)/Fs_legL)/60,2);
                results_atonia_index{6,12} = round((sum(NREM_legL | NREM_legR)/Fs_legL)/60,2);
                results_atonia_index{6,13} = round((sum(W_legL | W_legR)/Fs_legL)/60,2);
            elseif out_calc.LegLBox.Value==1 && out_calc.LegRBox.Value==0
                for j = 8:13
                    results_atonia_index{6,j} = results_atonia_index{2,j};
                end
            elseif out_calc.LegLBox.Value==0 && out_calc.LegRBox.Value==1
                for j = 8:13
                    results_atonia_index{6,j} = results_atonia_index{3,j};
                end
            end

        end

        %Average arms
        % For the values of atonia index, the simple average
        % is calculated. Instead, for the time of artifact-free signal, 
        % the union of parts considered for calculation is obtained
        if out_calc.ArmLBox.Value==1 || out_calc.ArmRBox.Value==1
            out_atonia_index_avg_arms = nanmean([out_atonia_index_armL; out_atonia_index_armR]);
            for j = 1:6
                results_atonia_index{7,j+1} = out_atonia_index_avg_arms(j);
            end
            if out_calc.ArmLBox.Value==1 && out_calc.ArmRBox.Value==1
                results_atonia_index{7,8} = round((sum(REM_armL | REM_armR)/Fs_armL)/60,2);
                results_atonia_index{7,9} = round((sum(N1_armL | N1_armR)/Fs_armL)/60,2);
                results_atonia_index{7,10} = round((sum(N2_armL | N2_armR)/Fs_armL)/60,2);
                results_atonia_index{7,11} = round((sum(N3_armL | N3_armR)/Fs_armL)/60,2);
                results_atonia_index{7,12} = round((sum(NREM_armL | NREM_armR)/Fs_armL)/60,2);
                results_atonia_index{7,13} = round((sum(W_armL | W_armR)/Fs_armL)/60,2);
            elseif out_calc.ArmLBox.Value==1 && out_calc.ArmRBox.Value==0
                for j = 8:13
                    results_atonia_index{7,j} = results_atonia_index{4,j};
                end
            elseif out_calc.ArmLBox.Value==0 && out_calc.ArmRBox.Value==1
                for j = 8:13
                    results_atonia_index{7,j} = results_atonia_index{5,j};
                end
            end

        end    
        close(figwaitatoniaindex);

        %Save the atonia index and write it in file
        t_atonia_index = cell2table(results_atonia_index,'VariableNames',v_ai);
        f = [savepath '\' SV.filename(1:end-4) '_atonia_index.csv'];
        writetable(t_atonia_index,f);

        %-------------------------DNE calculation------------------------------
        figwaitDNE = uifigure('Visible','off');
        movegui(figwaitDNE,'center')
        figwaitDNE.Visible = 'on';
        uiprogressdlg(figwaitDNE,'Title','Please Wait',...
            'Message','Calculating DNE','Indeterminate','on');
        drawnow

        %Prepare the cell with the results
        results_DNE =  cell(7,55);
        results_DNE{1,1} = 'Chin';
        results_DNE{2,1} = 'Left leg';
        results_DNE{3,1} = 'Right leg';
        results_DNE{4,1} = 'Left arm';
        results_DNE{5,1} = 'Right arm';
        results_DNE{6,1} = 'Average legs';
        results_DNE{7,1} = 'Average arms';
        %Columns
        v_dne = cell(1,size(results_DNE,2));
        v_dne{1} = 'EMG channel'; 
        v_dne{2} = 'REM perc 1'; v_dne{3} = 'REM perc 3'; v_dne{4} = 'REM perc 5';  
        v_dne{5} = 'REM perc 25'; v_dne{6} = 'REM perc 50'; v_dne{7} = 'REM perc 75'; 
        v_dne{8} = 'REM perc 95'; v_dne{9} = 'REM perc 97'; v_dne{10} = 'REM perc 99';
        v_dne{11} = 'N1 perc 1'; v_dne{12} = 'N1 perc 3'; v_dne{13} = 'N1 perc 5';
        v_dne{14} = 'N1 perc 25'; v_dne{15} = 'N1 perc 50'; v_dne{16} = 'N1 perc 75';
        v_dne{17} = 'N1 perc 95'; v_dne{18} = 'N1 perc 97'; v_dne{19} = 'N1 perc 99';
        v_dne{20} = 'N2 perc 1'; v_dne{21} = 'N2 perc 3'; v_dne{22} = 'N2 perc 5';
        v_dne{23} = 'N2 perc 25'; v_dne{24} = 'N2 perc 50'; v_dne{25} = 'N2 perc 75';
        v_dne{26} = 'N2 perc 95'; v_dne{27} = 'N2 perc 97'; v_dne{28} = 'N2 perc 99';
        v_dne{29} = 'N3 perc 1'; v_dne{30} = 'N3 perc 3'; v_dne{31} = 'N3 perc 5';
        v_dne{32} = 'N3 perc 25'; v_dne{33} = 'N3 perc 50'; v_dne{34} = 'N3 perc 75';
        v_dne{35} = 'N3 perc 95'; v_dne{36} = 'N3 perc 97'; v_dne{37} = 'N3 perc 99';
        v_dne{38} = 'NREM perc 1'; v_dne{39} = 'NREM perc 3'; v_dne{40} = 'NREM perc 5';
        v_dne{41} = 'NREM perc 25'; v_dne{42} = 'NREM perc 50'; v_dne{43} = 'NREM perc 75';
        v_dne{44} = 'NREM perc 95'; v_dne{45} = 'NREM perc 97'; v_dne{46} = 'NREM perc 99';
        v_dne{47} = 'W perc 1'; v_dne{48} = 'W perc 3'; v_dne{49} = 'W perc 5';
        v_dne{50} = 'W perc 25'; v_dne{51} = 'W perc 50'; v_dne{52} = 'W perc 75';
        v_dne{53} = 'W perc 95'; v_dne{54} = 'W perc 97'; v_dne{55} = 'W perc 99';
        v_dne{56} = '0.5th percentile'; v_dne{57} = '99.5th percentile';

        %Set the values to NaN
        for i = 1:7
            for j = 2:57
                results_DNE{i,j} = NaN;
           end        
        end

        %Preallocate
        out_DNE_chin = nan(1,56);
        out_DNE_legL = nan(1,56);
        out_DNE_legR = nan(1,56);
        out_DNE_armL = nan(1,56);
        out_DNE_armR = nan(1,56);

        %Chin
        if out_calc.ChinCheckBox.Value==1
            disp('Get DNE for chin')
            [out_DNE_chin, ~] = get_DNE(chin,Fs_chin,lights_chin,artifacts_chin,hypnogram_chin,analysis_window_chin);
            for j = 1:length(out_DNE_chin)
                results_DNE{1,j+1} = out_DNE_chin(j);
            end
        end

        %Leg left
        if out_calc.LegLBox.Value==1
            disp('Get DNE for left leg')
            [out_DNE_legL, ~] = get_DNE(legL,Fs_legL,lights_legL,artifacts_legL,hypnogram_legL,analysis_window_legL);
            for j = 1:length(out_DNE_legL)
                results_DNE{2,j+1} = out_DNE_legL(j);
            end
        end

        %Leg right
        if out_calc.LegRBox.Value==1
            disp('Get DNE for right leg')
            [out_DNE_legR, ~] = get_DNE(legR,Fs_legR,lights_legR,artifacts_legR,hypnogram_legR,analysis_window_legR);
            for j = 1:length(out_DNE_legR)
                results_DNE{3,j+1} = out_DNE_legR(j);
            end
        end

        %Arm left
        if out_calc.ArmLBox.Value==1
            disp('Get DNE for left arm')
            [out_DNE_armL, ~] = get_DNE(armL,Fs_armL,lights_armL,artifacts_armL,hypnogram_armL,analysis_window_armL);
            for j = 1:length(out_DNE_armL)
                results_DNE{4,j+1} = out_DNE_armL(j);
            end
        end

        %Arm right
        if out_calc.ArmRBox.Value==1
            disp('Get DNE for right arm')
            [out_DNE_armR, ~] = get_DNE(armR,Fs_armR,lights_armR,artifacts_armR,hypnogram_armR,analysis_window_armR);
            for j = 1:length(out_DNE_armR)
                results_DNE{5,j+1} = out_DNE_armR(j);
            end
        end

        %Average legs
        if out_calc.LegLBox.Value==1 || out_calc.LegRBox.Value==1
            out_DNE_avg_legs = nanmean([out_DNE_legL; out_DNE_legR]);
            for j = 1:length(out_DNE_avg_legs)
                results_DNE{6,j+1} = out_DNE_avg_legs(j);
            end
        end

        %Average arms
        if out_calc.ArmLBox.Value==1 || out_calc.ArmRBox.Value==1
            out_DNE_avg_arms = nanmean([out_DNE_armL; out_DNE_armR]);
            for j = 1:length(out_DNE_avg_arms)
                results_DNE{7,j+1} = out_DNE_avg_arms(j);
            end
        end
        close(figwaitDNE);

        %Save the DNE
        t_DNE = cell2table(results_DNE,'VariableNames',v_dne);
        f = [savepath '\' SV.filename(1:end-4) '_DNE.csv'];
        writetable(t_DNE,f);

        %------------------If selected, visualize the results------------------
        if out_calc.Visualize.Value==1
            %Chin
            if out_calc.ChinCheckBox.Value==1
                visualize_results(out_atonia_index_chin,out_DNE_chin,['Chin, ' SV.filename]);        
            end
            %Leg left
            if out_calc.LegLBox.Value==1
                visualize_results(out_atonia_index_legL,out_DNE_legL,['Left leg, ' SV.filename]);
            end
            %Leg right
            if out_calc.LegRBox.Value==1
                visualize_results(out_atonia_index_legR,out_DNE_legR,['Right leg, ' SV.filename]);
            end
            %Arm left
            if out_calc.ArmLBox.Value==1
                visualize_results(out_atonia_index_armL,out_DNE_armL,['Left arm, ' SV.filename]);
            end
            %Arm right
            if out_calc.ArmRBox.Value==1
                visualize_results(out_atonia_index_armR,out_DNE_armR,['Right arm, ' SV.filename]);
            end
            %Average legs
            if out_calc.LegLBox.Value==1 || out_calc.LegRBox.Value==1
                visualize_results(out_atonia_index_avg_legs,out_DNE_avg_legs,['Average legs, ' SV.filename]);
            end
            %Average arms
            if out_calc.ArmLBox.Value==1 || out_calc.ArmRBox.Value==1
                visualize_results(out_atonia_index_avg_arms,out_DNE_avg_arms,['Average arms, ' SV.filename]);
            end
        end    
    end


    %% Calculation of the LM indices according to WASM criteria
    if out_calc.LMCheckBox.Value==1
        disp('Calculation of LM indices according to WASM')
        get_PLM_indices_WASM(out_calc.figcalc.UserData.out_PLM,SV,out_sleep,analysis_window,out_calc,savepath);
    end

    %% Finalyse
    msgbox('All calculations completed','Success');
    disp(['End analysis file: ' SV.filename ' at ' datestr(datetime)])
    fprintf('\n=================================================================\n');
    clearvars
    close_hidden

catch exception
    errordlg(['Identifier: ' exception.identifier '\n Message: ' ...
        exception.message])
    disp(['Identifier: ' exception.identifier '\n Message: ' ...
        exception.message])
    disp(getReport(exception))
    clearvars
    pause(20)
    quit force % Quit force after 20 seconds
end
    

end