function get_sleep_parameters(filename,hypno,annotations,out_sleep,savepath,analysis_window,start_date,start_time)
%This function calculates the sleep macrostructure parameters. If more
%pairs of lights-off/lights-on are available, the software calculates the
%parameters for each of them.
% INPUT: filename, the name of the file as a string; hypno: the hypnogram
% reported in the frequency of 1 Hz, annotations: the unique annotations
% that are included in the EDF+ file; out_sleep: the UI figure where the
% annotations of lights off, lights on and sleep stages are defined;
% savepath: the path where the file with the sleep macrostructure
% parameters should be saved; analysis_window: the window that the user
% selected for the analysis (sampled at 1 Hz); start_date: the staring date
% of the EDF+ file; start_time: the starting time of the EDF+ file
% OUTPUT: the function saves the sleep macrostructure parameter in a csv
% file.

%% Get lights off vector
%Based on the annotations of lights off and lights on provided by the user,
%a vector of the same siye of the hypnogram (i.e., with sampling frequency
%of 1 Hz) is obtained. The vector has values of 0s and 1s, with 1s
%corresponding to the times where lights are off

%Definition of the vector
lights = zeros(length(hypno),1);
%Get annotations of lights off and on
ann_lightsOff = out_sleep.ListBox_loff.Value;
if strcmp(ann_lightsOff,'Annotation not available')
    ann_lightsOff = [];
end
ann_lightsOn = out_sleep.ListBox_lon.Value;
if strcmp(ann_lightsOn,'Annotation not available')
    ann_lightsOn = [];
end

%Obtain, from the annotations, at which second lights off and lights on are defined 
position_lights_off = [];
position_lights_on = [];
if ~isempty(ann_lightsOff)
    for j = 1:size(annotations,1)
        thisAnnotation = annotations{j,"Annotations"};
        if strcmp(thisAnnotation,ann_lightsOff)
            thisStart = round(seconds(annotations.Properties.RowTimes(j)));
            position_lights_off = [position_lights_off; thisStart];
        end
    end
end
if ~isempty(ann_lightsOn)
    for j = 1:size(annotations,1)
        thisAnnotation = annotations{j,"Annotations"};
        if strcmp(thisAnnotation,ann_lightsOn)
            thisStart = round(seconds(annotations.Properties.RowTimes(j)));
            position_lights_on = [position_lights_on; thisStart];
        end
    end
end

%In the lights vector, set to 1 the times where lights are off. A check is
%performed if the number of annotations of lights off and on is not matching
if (length(position_lights_off) == length(position_lights_on)) & ~isempty(position_lights_off) & ~isempty(position_lights_on)
    for i = 1:length(position_lights_off)
        if position_lights_on(i)<=length(lights)
            lights(position_lights_off(i):position_lights_on(i))=1;
        else
            lights(position_lights_off(i):end)=1;
        end
    end
elseif isempty(position_lights_off) & isempty(position_lights_on) % Both not specified, then lights are the whole signal lenght
    lights(1:end) = 1;
elseif length(position_lights_off)==1 & isempty(position_lights_on) % Only lights off specified and appearing once
    lights(position_lights_off:end) = 1;
elseif length(position_lights_on)==1 & isempty(position_lights_off)
    lights(1:position_lights_on) = 1;
else
    errordlg('Number of annotations of lights off and on do not match')
    error('Number of annotations of lights off and on do not match');
end


%% Correct analysis window
% A small correction on the vector analysis window is performed if this
% does not match the lights vector
if length(lights)<=length(analysis_window) %If the signal is shorter than the hypnogram 
    analysis_window(length(lights)+1:end) = [];
else
    analysis_window(end+1:length(lights)) = 0; %Remove
end

%% Identify the intersection between lights off and analysis window
% Define the start and end of analyses period as the intersection between
% lights off and analysis window
[lights_off_analysis,lights_on_analysis,~] = event_StartsEndsDurations((analysis_window+lights)==2);

%% Now for each pair of lights off/lights, calculate the following sleep macrostructure parameters

TRT = nan(length(lights_off_analysis),1); % total recording time
TST = nan(length(lights_off_analysis),1); % total sleep time
SPT = nan(length(lights_off_analysis),1); % sleep period time
SO = nan(length(lights_off_analysis),1); % sleep onset
SE = nan(length(lights_off_analysis),1); % sleep efficiency
WASO = nan(length(lights_off_analysis),1); % wake after sleep onset
W_time = nan(length(lights_off_analysis),1); % wake time
W_percSPT = nan(length(lights_off_analysis),1); % wake as percentage of sleep period time
N1_time = nan(length(lights_off_analysis),1); % N1 time
N1_percTST = nan(length(lights_off_analysis),1); % N1 as percentage of total sleep time
N1_percSPT = nan(length(lights_off_analysis),1); % N1 as percentage of sleep period time
N1_onset = nan(length(lights_off_analysis),1); % Onset of N1 sleep
N2_time = nan(length(lights_off_analysis),1); % N2 time
N2_percTST = nan(length(lights_off_analysis),1); % N2 as percentage of total sleep time
N2_percSPT = nan(length(lights_off_analysis),1); % N2 as percentage of sleep period time
N2_onset = nan(length(lights_off_analysis),1); % Onset of N2 sleep
N3_time = nan(length(lights_off_analysis),1); % N3 time
N3_percTST = nan(length(lights_off_analysis),1); % N3 as percentage of total sleep time
N3_percSPT = nan(length(lights_off_analysis),1); % N3 as percentage of sleep period time
N3_onset = nan(length(lights_off_analysis),1); % Onset of N3 sleep
REM_time = nan(length(lights_off_analysis),1); % REM time
REM_percTST = nan(length(lights_off_analysis),1); % REM as percentage of total sleep time
REM_percSPT = nan(length(lights_off_analysis),1); % REM as percentage of sleep period time
REM_onset = nan(length(lights_off_analysis),1); % Onset of REM sleep
REM_latency = nan(length(lights_off_analysis),1); % REM sleep latency
LOFF = cell(length(lights_off_analysis),1); % Time of lights off
LON = cell(length(lights_off_analysis),1); % Time of lights on

start_recording = datetime([convertStringsToChars(start_date) ' ' convertStringsToChars(start_time)],'InputFormat','dd.MM.yy HH.mm.ss');

for i = 1:length(lights_off_analysis)
    %Restrict the hypnogram to the current pair of lights off-lights on
    thisWindow = zeros(length(hypno),1);
    thisWindow(lights_off_analysis(i):lights_on_analysis(i))=1;
    thisHypno = hypno;
    thisHypno(thisWindow==0)=2;
    
    %1. Total recording time
    TRT(i) = round(sum(thisWindow)/60,1); %In minutes
    %2. Total sleep time
    TST(i) = round(sum(thisHypno<=0)/60,1);
    %3. Sleep period time
    AWA = max(find(thisHypno <= 0)); %Last sleep
    hypno_s = hypno(min(find(thisHypno <= 0)):AWA); %From first to last sleep
    SPT(i) = round(length(hypno_s)/60,1);
    %4. Sleep efficiency
    SE(i) = round(100*TST(i)/TRT(i),1);
    %5. N1 time and percentages
    N1_time(i) = round(sum(thisHypno==-1)/60,1);
    N1_percTST(i) = round(100*N1_time(i)/TST(i),1);
    N1_percSPT(i) = round(100*N1_time(i)/SPT(i),1);
    %5. N2 time and percentages
    N2_time(i) = round(sum(thisHypno==-2)/60,1);
    N2_percTST(i) = round(100*N2_time(i)/TST(i),1);
    N2_percSPT(i) = round(100*N2_time(i)/SPT(i),1);
    %6. N3 time and percentages
    N3_time(i) = round(sum(thisHypno==-3)/60,1);
    N3_percTST(i) = round(100*N3_time(i)/TST(i),1);
    N3_percSPT(i) = round(100*N3_time(i)/SPT(i),1);
    %6. REM time and percentages
    REM_time(i) = round(sum(thisHypno==0)/60,1);
    REM_percTST(i) = round(100*REM_time(i)/TST(i),1);
    REM_percSPT(i) = round(100*REM_time(i)/SPT(i),1);
    %6. W time and pecentage (in SPT)
    W_time(i) = round(sum(hypno_s==1)/60,1);
    W_percSPT(i) = round(100*W_time(i)/SPT(i),1);
    %7. Sleep onset
    sleep = find(thisHypno<=0);
    %In the selected lights and analysis period, get the first lights off
 	thisLightsOff = lights_off_analysis(i);
    SO(i) = round((sleep(1)-thisLightsOff)/60,1);
    %8. WASO
    WASO(i) = TRT(i)-TST(i)-SO(i);
    % 9. Onset of different sleep stages from sleep onset
    N1 = find(thisHypno == -1);
    if ~isempty(N1)
        N1_onset(i) = round((N1(1)-thisLightsOff)/60,1);
    end
    N2 = find(thisHypno == -2);
    if ~isempty(N2)
        N2_onset(i) = round((N2(1)-thisLightsOff)/60,1);
    end
    N3 = find(thisHypno == -3);
    if ~isempty(N3)
        N3_onset(i) = round((N3(1)-thisLightsOff)/60,1);
    end
    REM = find(thisHypno == 0);
    if ~isempty(REM)
        REM_onset(i) = round((REM(1)-thisLightsOff)/60,1);
    end
    % REM latency
    if ~isempty(REM)
        REM_latency(i) = round((REM(1)-sleep(1))/60,1);
    end
    
    %Lights off and on
    LOFF{i} = datestr(start_recording+seconds(lights_off_analysis(i)),'yyyy-mm-dd HH:MM:SS');
    LON{i} = datestr(start_recording+seconds(lights_on_analysis(i)),'yyyy-mm-dd HH:MM:SS');
end
    
    
    
%% Save the results
t = table(LOFF,LON,TRT,TST,SPT,SO,SE,WASO,W_time,W_percSPT,...
    N1_time,N1_percTST,N1_percSPT,N1_onset,...
    N2_time,N2_percTST,N2_percSPT,N2_onset,...
    N3_time,N3_percTST,N3_percSPT,N3_onset,...
    REM_time,REM_percTST,REM_percSPT,REM_onset,REM_latency,...
    'VariableNames',...
    {'Lights off','Lights on','Total recording time [min]','Total sleep time (TST) [min]','Sleep period time (SPT) [min]','Sleep onset [min]',...
    'Sleep efficiency [%]','WASO [min]','Wake time in SPT [min]','Wake [%SPT]',...
    'N1 time [min]','N1 [%TST]','N1 [%SPT]','N1 onset [min]',...
    'N2 time [min]','N2 [%TST]','N2 [%SPT]','N2 onset [min]',...
    'N3 time [min]','N3 [%TST]','N3 [%SPT]','N3 onset [min]',...
    'REM time [min]','REM [%TST]','REM [%SPT]','REM onset [min]','REM latency [min]'});


%% Write the parameters in file
f = [savepath '\' filename(1:end-4) '_sleep_macrostructure.csv'];
writetable(t,f);


end

