function [signal,Fs_signal,lights_signal,hypnogram_signal,artifacts_signal,analysis_window_signal] = ...
    get_signal(SV,out_calc,out_signal,out_sleep,analysis_window,s)

%GET_SIGNAL: Based on the the settings specified by the user, this function
%prepares an EMG signal by performing the following: 
% - step 1: vectorize the EMG signal and make derivation if needed
% - step 2: apply notch filter
% - step 3: apply low-cut filter
% - step 4: apply high-cut filte
% - step 5: create a hypnogram matching 1:1 to the lenght of the EMG signal
% - step 6: create an artifact signal matching 1:1 to the lenght of the EMG signal
% - step 7: create a lights-off signal matching 1:1 to the lenght of the EMG signal
% - step 8: create an analysis-window matching 1:1 to the lenght of the EMG signal
% INPUT: SV, the structure of containing the EDF+ file; out_calc, the UI
% figure containing the settings for the calculations; out_signal: the
% settings specific for the signal of interest; out_sleep: the UI figure
% with the annotations of lights off, lights on and sleep stages;
% analysis_window: the analysis window defined by the user; s: a string
% defining which signal is currently prepared.
% OUTPUT: signal, the finalized EMG signal; Fs_signal: the sampling
% frequency of the signal; lights_signal: a vector of 0s and 1s of the same
% size of signal, with 1 indicating lights off; hypnogram_signal: a vector
% with the same size of signal where 2 = unscored, 1 = W, 0 = REM, -1 = N1,
% -2 = N2, -3 = N3; artifacts_signal: a vector of 0s and 1s of the same
% size of signal, with 1 indicating artifact; analysis_window_signal: a
% vector of 0s and 1s of the same size of signal, with 1 indicating the
% area to be analysed.

signal = [];

%---------------Step 1: single channel or derivation-----------------------
if out_signal.UnipolarButton.Value==1 % Case of single channel
    pos_signal = find(strcmp(out_signal.SingleChannelDropDown.Value,SV.NewSignalLabels));
    seconds_in_chunck = seconds(SV.header.DataRecordDuration); % Added to correct bug
    Fs_signal = SV.header.NumSamples(pos_signal)/seconds_in_chunck; %Added to correct bug
    %Vectorize signal
    tmp = SV.data(:,pos_signal);
    tmp_table = timetable2table(tmp);
    start_sample_tmp = round(seconds(tmp_table{:,1})*Fs_signal+1); %Added +1 in case the start is exactly at 0
    for j = 1:length(start_sample_tmp)
        this_start = start_sample_tmp(j);
        this_end = this_start+length(cell2mat(tmp_table{j,2}))-1;
        signal(this_start:this_end) = cell2mat(tmp_table{j,2});
    end
elseif out_signal.BipolarButton.Value==1 % Case of derivation   
    pos_signal_1 = find(strcmp(out_signal.DerivChannel1DropDown.Value,SV.NewSignalLabels));
    pos_signal_2 = find(strcmp(out_signal.DerivChannel2DropDown.Value,SV.NewSignalLabels));
    seconds_in_chunck = seconds(SV.header.DataRecordDuration); % Added to correct bug
    Fs_signal_1 = SV.header.NumSamples(pos_signal_1)/seconds_in_chunck; % Added to correct bug
    Fs_signal_2 = SV.header.NumSamples(pos_signal_2)/seconds_in_chunck; % Added to correct bug
    if Fs_signal_1 ~= Fs_signal_2
        error(['Error in derivation for ' s ...
            ': the two selected channels have different sampling frequencies']);
    else
        Fs_signal = Fs_signal_1;
        %Vectorize signal_1
        signal_1 = SV.data(:,pos_signal_1);
        signal_1_table = timetable2table(signal_1);
        start_sample_signal_1 = round(seconds(signal_1_table{:,1})*Fs_signal+1);  %Added +1 in case the start is exactly at 0
        signal_1_vector = [];
        for j = 1:length(start_sample_signal_1)
            this_start = start_sample_signal_1(j);
            this_end = this_start+length(cell2mat(signal_1_table{j,2}))-1;
            signal_1_vector(this_start:this_end) = cell2mat(signal_1_table{j,2});
        end
        %Vectorize signal_2
        signal_2 = SV.data(:,pos_signal_2);
        signal_2_table = timetable2table(signal_2);
        start_sample_signal_2 = round(seconds(signal_2_table{:,1})*Fs_signal+1);  %Added +1 in case the start is exactly at 0
        signal_2_vector = [];
        for j = 1:length(start_sample_signal_2)
            this_start = start_sample_signal_2(j);
            this_end = this_start+length(cell2mat(signal_2_table{j,2}))-1;
            signal_2_vector(this_start:this_end) = cell2mat(signal_2_table{j,2});
        end
        %Get the signal
        signal = signal_1_vector-signal_2_vector;
    end
end

%-----------------Step 2: Notch--------------------------------------------
if out_calc.Button50Notch.Value==1
    w0 = 50/(Fs_signal/2);
    b0 = w0/30;
    [b_notch,a_notch] = iirnotch(w0,b0);
    signal = filtfilt(b_notch,a_notch,signal);
elseif out_calc.Button60Notch.Value==1
    w0 = 60/(Fs_signal/2);
    b0 = w0/30;
    [b_notch,a_notch] = iirnotch(w0,b0);
    signal = filtfilt(b_notch,a_notch,signal);
end

% -------------------Step 3: Low cut --------------------------------------
if out_calc.LowcutCheckBox.Value == 1
    f = out_calc.SpinnerLow.Value;
    if f>=Fs_signal/2 
        errordlg([s ' - low cut frequency is not valid'])
        error([s ' - low cut frequency is not valid'])
    else
        [b_low,a_low] = butter(6,f/(Fs_signal/2),'high');
        signal = filtfilt(b_low,a_low,signal);
    end
end

% -------------------Step 4: High cut --------------------------------------
if out_calc.HighcutCheckBox.Value == 1
    f = out_calc.SpinnerHigh.Value;
    if f>=Fs_signal/2
        errordlg([s ' - high cut frequency is not valid'])
        error([s ' - high cut frequency is not valid'])
    else
        [b_high,a_high] = butter(6,f/(Fs_signal/2),'low');
        signal = filtfilt(b_high,a_high,signal);
    end
end

% -------------- Step 5: Hypnogram matching lenght of signal --------------
hypnogram_ext = repmat(SV.hypno',1,Fs_signal);
hypnogram_signal = reshape(hypnogram_ext',size(hypnogram_ext,1)*size(hypnogram_ext,2),[]);
if length(signal)<=length(hypnogram_signal) %If the signal is shorter than the hypnogram 
    hypnogram_signal(length(signal)+1:end) = [];
else
    hypnogram_signal(end+1:length(signal)) = 2; %Add invalid
end

% -------------- Step 6: Artifact vector matching lenght of signal --------
artifacts_signal = zeros(length(signal),1);
warning_artifacts = false;
if out_signal.ArtifactsCheckBox.Value==1 %In case artifacts have been selected
    for j = 1:size(SV.annotations,1)
        thisAnnotation = SV.annotations{j,"Annotations"};
        if ismember(thisAnnotation,out_signal.ListBox.Value)
            thisStart = round(seconds(SV.annotations.Properties.RowTimes(j))*Fs_signal);
            thisDuration = round(seconds(SV.annotations.Duration(j))*Fs_signal);
            if isnan(thisDuration) | thisDuration==0
                warning_artifacts = true;
            else
                thisEnd = thisStart+thisDuration-1;
                if thisStart<=length(signal)
                    if thisEnd<=length(signal)
                        artifacts_signal(thisStart:thisEnd) = 1;
                    else
                        artifacts_signal(thisStart:length(signal)) = 1;
                    end
                end
            end
        end
    end
end

if warning_artifacts
    warning('One or more annotations of artifacts have lenght of 0 seconds and therefore not considered')
    warndlg('One or more annotations of artifacts have lenght of 0 seconds and therefore not considered','Warning');
end



% --------- Step 7: Lights vector matching lenght of signal ---------------
ann_lightsOff = out_sleep.ListBox_loff.Value;
if strcmp(ann_lightsOff,'Annotation not available')
    ann_lightsOff = [];
end
ann_lightsOn = out_sleep.ListBox_lon.Value;
if strcmp(ann_lightsOn,'Annotation not available')
    ann_lightsOn = [];
end

lights_signal = zeros(length(signal),1);

position_lights_off = [];
position_lights_on = [];

if ~isempty(ann_lightsOff)
    for j = 1:size(SV.annotations,1)
        thisAnnotation = SV.annotations{j,"Annotations"};
        if strcmp(thisAnnotation,ann_lightsOff)
            thisStart = round(seconds(SV.annotations.Properties.RowTimes(j))*Fs_signal);
            position_lights_off = [position_lights_off; thisStart];
        end
    end
end

if ~isempty(ann_lightsOn)
    for j = 1:size(SV.annotations,1)
        thisAnnotation = SV.annotations{j,"Annotations"};
        if strcmp(thisAnnotation,ann_lightsOn)
            thisStart = round(seconds(SV.annotations.Properties.RowTimes(j))*Fs_signal);
            position_lights_on = [position_lights_on; thisStart];
        end
    end
end

if (length(position_lights_off) == length(position_lights_on)) & ~isempty(position_lights_off) & ~isempty(position_lights_on)
    for i = 1:length(position_lights_off)
        if position_lights_on(i)<=length(lights_signal)
            lights_signal(position_lights_off(i):position_lights_on(i))=1;
        else
            lights_signal(position_lights_off(i):end)=1;
        end
    end
elseif isempty(position_lights_off) & isempty(position_lights_on) % Both not specified, then lights are the whole signal lenght
    lights_signal(1:end) = 1;
elseif length(position_lights_off)==1 & isempty(position_lights_on) % Only lights off specified and appearing once
    lights_signal(position_lights_off:end) = 1;
elseif length(position_lights_on)==1 & isempty(position_lights_off)
    lights_signal(1:position_lights_on) = 1;
else
    errordlg('Number of annotations of lights off and on do not match')
    error('Number of annotations of lights off and on do not match');
end
   

% -------------- Step 8: Analysis window matching lenght of signal --------------
analysis_window_ext = repmat(analysis_window,1,Fs_signal);
analysis_window_signal = reshape(analysis_window_ext',size(analysis_window_ext,1)*size(analysis_window_ext,2),[]);
if length(signal)<=length(analysis_window_signal) %If the signal is shorter than the hypnogram 
    analysis_window_signal(length(signal)+1:end) = [];
else
    analysis_window_signal(end+1:length(signal)) = 0; %Remove
end

end

