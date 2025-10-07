function get_PLM_indices_WASM(out_PLM,SV,out_sleep,analysis_window,out_calc,savepath)
% GET_PLM_INDICES_WASM: This function, give in input the annotations for left and right LM,
% arousals and respiratory events, calculates the LM indices according to
% the WASM 2016 criteria (https://pubmed.ncbi.nlm.nih.gov/27890390/)
% INPUT: outPLM: the settings defined by the user to define the needed
% events for calculation of the LM indices; SV: the structure containing
% the EDF+ file; out_sleep: the UI figure where the user saved the
% annotations of lights off, lights on and sleep stages; analysis_window: a
% vector of 0s and 1s with sampling frequency of 1 Hz, with 1s
% corresponding to the area to be included in the analysis; out_calc: the
% UI figure with all the settings for calculation defined by the user;
% savepath: the path where a CSV file with the results is saved
% the SV structure, the outPLM, the out_sleep
% OUTPUT: The function, if it is run correctly, saves several CSV files:
% - _LM_indices_WASM.csv: a file containing several LM indices (refer to
% the manual of SOMAS for a detailed explanation of them)
% - _LM_indices_WASM.csv: a file containing several LM indices (refer to
% the manual of SOMAS for a detailed explanation of them)
% - _LM_raw.csv: a table containing information on the LM (refer to the
% manual of SOMAS for a detailed explanation)
% - IMI.csv: the information to plot a histogram of inter-movement
% intervals in seconds
% - IMI_LOG.csv: the information to plot a histogram of inter-movement
% intervals in seconds, transformed in log

%% Get the strings defined by the user for defining events
if out_PLM.leftCheck.Value
    TibL_str = out_PLM.leftDropDown.Value;
else 
    TibL_str = 'Annotation not available';
end
if out_PLM.rightCheck.Value
    TibR_str = out_PLM.rightDropDown.Value;
else
    TibR_str = 'Annotation not available';
end
if out_PLM.arousalCheck.Value
    arousal_str = out_PLM.arousalList.Value;
else
    arousal_str = 'Annotation not available';
end
if out_PLM.respCheck.Value
    resp_str = out_PLM.respList.Value;
else
    resp_str = 'Annotation not available';
end

%% Definition of a fictious sampling frequency
Fs = 1000;
% To make calculations easier, everything is converted into vectors with
% this sampling frequency

%% Figure 
fig = uifigure('Visible','off');
movegui(fig,'center');
fig.Visible='on';
uiprogressdlg(fig,'Title','Please Wait',...
    'Message','Calculating the LM indices according to WASM','Indeterminate','on');
drawnow

%% Make vectors at sampling frequency of Fs Hz for all the events

n = length(SV.hypno)*Fs; %Remember that the hypnogram has sampling frequency of 1 Hz
LM_left = zeros(n,1); 
LM_right = zeros(n,1);
arousal = zeros(n,1);
resp = zeros(n,1);

% LM left
warning_LM_left = false;
for g = 1:size(SV.annotations,1)
    thisAnnotation = SV.annotations{g,"Annotations"};
    if sum(ismember(thisAnnotation,TibL_str))>0
        thisStart = seconds(SV.annotations.Properties.RowTimes(g));
        thisDuration = seconds(SV.annotations.Duration(g));
        if isnan(thisDuration) | thisDuration==0
            warning_LM_left = true;
        else
            startSample = round(thisStart*Fs);
            endSample = round((thisStart+thisDuration)*Fs);
            LM_left(startSample:endSample) = 1;
        end
    end
end
if warning_LM_left
    warning('One or more annotations of left leg movement have lenght of 0 seconds and therefore not considered')
    warndlg('One or more annotations of left leg movement have lenght of 0 seconds and therefore not considered','Warning');
end

% LM right
warning_LM_right = false;
for g = 1:size(SV.annotations,1)
    thisAnnotation = SV.annotations{g,"Annotations"};
    if sum(ismember(thisAnnotation,TibR_str))>0
        thisStart = seconds(SV.annotations.Properties.RowTimes(g));
        thisDuration = seconds(SV.annotations.Duration(g));
        if isnan(thisDuration) | thisDuration==0
            warning_LM_right = true;
        else
            startSample = round(thisStart*Fs);
            endSample = round((thisStart+thisDuration)*Fs);
            LM_right(startSample:endSample) = 1;
        end
    end
end
if warning_LM_right
    warning('One or more annotations of right leg movement have lenght of 0 seconds and therefore not considered')
    warndlg('One or more annotations of right leg movement have lenght of 0 seconds and therefore not considered','Warning');
end

% Arousals
warning_arousal = false;
for g = 1:size(SV.annotations,1)
    thisAnnotation = SV.annotations{g,"Annotations"};
    if sum(ismember(thisAnnotation,arousal_str))>0
        thisStart = seconds(SV.annotations.Properties.RowTimes(g));
        thisDuration = seconds(SV.annotations.Duration(g));
        if isnan(thisDuration) | thisDuration==0
            warning_arousal = true;
        else
            startSample = round(thisStart*Fs);
            endSample = round((thisStart+thisDuration)*Fs);
            arousal(startSample:endSample) = 1;
        end
    end
end
if warning_arousal
    warning('One or more annotations of arousals have lenght of 0 seconds and therefore not considered')
    warndlg('One or more annotations of arousals have lenght of 0 seconds and therefore not considered','Warning');
end

% Respiratory events
warning_resp = false;
for g = 1:size(SV.annotations,1)
    thisAnnotation = SV.annotations{g,"Annotations"};
    if sum(ismember(thisAnnotation,resp_str))>0
        thisStart = seconds(SV.annotations.Properties.RowTimes(g));
        thisDuration = seconds(SV.annotations.Duration(g));
        if isnan(thisDuration) | thisDuration==0
            warning_resp = true;
        else
            startSample = round(thisStart*Fs);
            endSample = round((thisStart+thisDuration)*Fs);
            resp(startSample:endSample) = 1;
        end
    end
end
if warning_resp
    warning('One or more annotations of respiratory events have lenght of 0 seconds and therefore not considered')
    warndlg('One or more annotations of respiratory events have lenght of 0 seconds and therefore not considered','Warning');
end

% To avoid vectors of different lenghts cut all the vectors to have the
% same length
LM_left = LM_left(1:n);
LM_right = LM_right(1:n);
arousal = arousal(1:n);
resp = resp(1:n);

%% Remove the events which are not between lights off and lights on

% Create the ligths off lights on vector
ann_lightsOff = out_sleep.ListBox_loff.Value;
if strcmp(ann_lightsOff,'Annotation not available')
    ann_lightsOff = [];
end
ann_lightsOn = out_sleep.ListBox_lon.Value;
if strcmp(ann_lightsOn,'Annotation not available')
    ann_lightsOn = [];
end

lights = zeros(length(LM_left),1);
position_lights_off = [];
position_lights_on = [];

if ~isempty(ann_lightsOff)
    for j = 1:size(SV.annotations,1)
        thisAnnotation = SV.annotations{j,"Annotations"};
        if strcmp(thisAnnotation,ann_lightsOff)
            thisStart = round(seconds(SV.annotations.Properties.RowTimes(j))*Fs);
            position_lights_off = [position_lights_off; thisStart];            
        end
    end
end

if ~isempty(ann_lightsOn)
    for j = 1:size(SV.annotations,1)
        thisAnnotation = SV.annotations{j,"Annotations"};
        if strcmp(thisAnnotation,ann_lightsOn)
            thisStart = round(seconds(SV.annotations.Properties.RowTimes(j))*Fs);
            position_lights_on = [position_lights_on; thisStart];
        end
    end
end

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

%Remove what is outside lights off - lights on
LM_left(lights==0) = 0;
LM_right(lights==0) = 0;
arousal(lights==0) = 0;
resp(lights==0) = 0;

%% Remove the LM which are not in the analysis window

analysis_window_ext = repmat(analysis_window,1,Fs);
analysis_window_long = reshape(analysis_window_ext',size(analysis_window_ext,1)*size(analysis_window_ext,2),[]);
if length(LM_left)<=length(analysis_window_long) %If the signal is shorter than the LM vector 
    analysis_window_long(length(LM_left)+1:end) = [];
else
    analysis_window_long(end+1:length(LM_left)) = 0; %Remove
end

LM_left(analysis_window_long==0) = 0;
LM_right(analysis_window_long==0) = 0;
arousal(analysis_window_long==0) = 0;
resp(analysis_window_long==0) = 0;

%% Check if there are LM or not, in case stop the calculation and get back

if sum(LM_right)==0 & sum(LM_left)==0
    warning('There are no leg movements, LM indices according to WASM cannot be computed')
    warndlg('There are no leg movements, LM indices according to WASM cannot be computed','Warning');
    return;
end


%% Remove the LM which have lenght less than 0.5s
[start_LM_left, end_LM_left, dur_LM_left] = event_StartsEndsDurations(LM_left);
[start_LM_right, end_LM_right, dur_LM_right] = event_StartsEndsDurations(LM_right);

for i = 1:length(start_LM_left)
    if dur_LM_left(i)<0.5*Fs
        LM_left(start_LM_left(i):end_LM_left(i)) = 0;
    end
end

for i = 1:length(start_LM_right)
    if dur_LM_right(i)<0.5*Fs
        LM_right(start_LM_right(i):end_LM_right(i)) = 0;
    end
end

%% Define the vectors of CLM: only LM with duration less than 10s

[start_LM_left, end_LM_left, dur_LM_left] = event_StartsEndsDurations(LM_left);
[start_LM_right, end_LM_right, dur_LM_right] = event_StartsEndsDurations(LM_right);

CLM_left = LM_left;
for i = 1:length(dur_LM_left)
    if dur_LM_left(i)>10*Fs 
        CLM_left(start_LM_left(i):end_LM_left(i)) = 0;
    end
end

CLM_right = LM_right;
for i = 1:length(dur_LM_right)
    if dur_LM_right(i)>10*Fs 
        CLM_right(start_LM_right(i):end_LM_right(i)) = 0;
    end
end

%% Combine monolateral LM into bilateral LM
% Calculating again start and stop
[start_LM_left, end_LM_left, dur_LM_left] = event_StartsEndsDurations(LM_left);
[start_LM_right, end_LM_right, dur_LM_right] = event_StartsEndsDurations(LM_right);

bLM = zeros(length(LM_left),1);
% Implement the algorithm as described in appendix 1
for i = 1:length(start_LM_left)
    for j = 1:length(start_LM_right)
        if (start_LM_right(j)>=start_LM_left(i) && start_LM_right(j)<(end_LM_left(i)+0.5*Fs)) || ...
                (start_LM_left(i)>=start_LM_right(j) && start_LM_left(i)<(end_LM_right(j)+0.5*Fs))
            minStart = min([start_LM_left(i) start_LM_right(j)]);
            maxEnd = max([end_LM_left(i) end_LM_right(j)]);
            bLM(minStart:maxEnd) = 1;
        end
    end
end

%% Identify the bilateral CLM
% Apply the following rules as defined in the paper:
% A bilateral CLM is a bilateral LM that
% 1 Contains only CLM 
% 2 Contains <=4 CLM
% 3 has duration <=15s

bCLM = bLM;
[start_bLM, end_bLM, dur_bLM] = event_StartsEndsDurations(bLM);

%Rule 1: check on the lenght of the LM included, if one is more than 10s,
%then it is not a CLM --> exclude
for i = 1:length(start_bLM)
    this_LM_left = LM_left(start_bLM(i):end_bLM(i));
    this_LM_right = LM_right(start_bLM(i):end_bLM(i));
    [~,~,dur_this_LM_left] = event_StartsEndsDurations(this_LM_left);
    [~,~,dur_this_LM_right] = event_StartsEndsDurations(this_LM_right);
    dur = [dur_this_LM_left; dur_this_LM_right];
    if sum(dur>10*Fs)>=1 %If there is at least one
        bCLM(start_bLM(i):end_bLM(i)) = 0;
        CLM_left(start_bLM(i):end_bLM(i)) = 0;
        CLM_right(start_bLM(i):end_bLM(i)) = 0;
    end
end

%Rule 2
for i = 1:length(start_bLM)
    this_CLM_left = CLM_left(start_bLM(i):end_bLM(i));
    [start_this_CLM_left,~,~] = event_StartsEndsDurations(this_CLM_left);
    this_CLM_right = CLM_right(start_bLM(i):end_bLM(i));
    [start_this_CLM_right,~,~] = event_StartsEndsDurations(this_CLM_right);
    if (length(start_this_CLM_left)+length(start_this_CLM_right))>=5
        bCLM(start_bLM(i):end_bLM(i)) = 0;
        CLM_left(start_bLM(i):end_bLM(i)) = 0;
        CLM_right(start_bLM(i):end_bLM(i)) = 0;
    end
end

%Rule 3
for i = 1:length(start_bLM)
    if dur_bLM(i)>15*Fs
        bCLM(start_bLM(i):end_bLM(i)) = 0;
        CLM_left(start_bLM(i):end_bLM(i)) = 0;
        CLM_right(start_bLM(i):end_bLM(i)) = 0;
    end
end

%% Combine the monolateral and bilateral

CLM = double(CLM_left | CLM_right | bCLM);
LM = double(LM_left | LM_right | bLM);
LM_not_CLM = LM-CLM;

%% Make a table with the CLM and LM identified, as done by Hypnolab

[start_CLM,~,duration_CLM] = event_StartsEndsDurations(CLM);
[start_CLM_left,~,~] = event_StartsEndsDurations(CLM_left);
[start_CLM_right,~,~] = event_StartsEndsDurations(CLM_right);
[start_bCLM,~,~] = event_StartsEndsDurations(bCLM);

[start_LM,~,duration_LM] = event_StartsEndsDurations(LM);
[start_LM_left,~,~] = event_StartsEndsDurations(LM_left);
[start_LM_right,~,~] = event_StartsEndsDurations(LM_right);
[start_bLM,~,~] = event_StartsEndsDurations(bLM);

[start_LM_not_CLM,~,duration_LM_not_CLM] = event_StartsEndsDurations(LM_not_CLM);

%Get the information of the LM
epoch = ceil((start_LM/Fs)/30);
hypnogram_short = SV.hypno(1:30:end);
stage = hypnogram_short(epoch)';
%Type of movement:1=left;2=right;3=bilateral
movType = nan(length(epoch),1);
candidate = zeros(length(epoch),1);
%Check if it is a CLM
for i = 1:length(start_LM)
    thisStart = start_LM(i);
    if ismember(thisStart,start_bLM)
        movType(i) = 3;
        if ismember(thisStart,start_bCLM)
            candidate(i) = 1;
        end
    elseif ismember(thisStart,start_LM_left)
        movType(i) = 1;
        if ismember(thisStart,start_CLM_left)
            candidate(i) = 1;
        end
    elseif ismember(thisStart,start_LM_right)
        movType(i) = 2;
        if ismember(thisStart,start_CLM_right)
            candidate(i) = 1;
        end
    end
end

distance_start_LMs = diff(start_LM)/Fs;
distance_start_LMs = [0; distance_start_LMs];

%Get the short interval ones
short_interval = distance_start_LMs<10;

%Get now the PLM series
start_PLM = 1;
sequence = 1;
seq = nan(length(start_LM),1);
while start_PLM<length(start_LM)
    check = true;
    tmp = start_PLM;
    c = [];
    while check && tmp<length(distance_start_LMs)
        %Condition on the first one
        if tmp==1
            cond = 1;
        else
            cond = ~short_interval(tmp);
        end
        if (distance_start_LMs(tmp+1)>=10 && distance_start_LMs(tmp+1)<90) && candidate(tmp) && cond && candidate(tmp+1)
            c = [c; tmp];
            tmp = tmp+1;
        else
            c = [c; tmp];
            check = false;
        end
    end
    if length(c)>=4
        seq(c) = sequence;
        sequence = sequence+1;
    end
    start_PLM = tmp+1;
end

isolated_LM = isnan(seq) & ~short_interval;

LM_table = table(epoch,stage,start_LM/Fs,(start_LM+duration_LM)/Fs,duration_LM/Fs,movType,seq,distance_start_LMs,isolated_LM,short_interval,candidate,...
    'VariableNames',{'Epoch','Stage','Start','End','Duration','Mov type','Sequence','IMI','Isolated LM','Short interval','CLM'});

%% Calculate indices
% Calculate TST, TNREMT, TREMT, TWT 
%Upsample the hypnogram from 1 Hz to Fs
hypno_rep = repmat(SV.hypno, 1, Fs);
hypnogram_long = reshape(hypno_rep',[],1);

TST = sum(hypnogram_long<=0 & lights==1)/(Fs*3600); % Total sleep time
PLMS_index = sum(~isnan(LM_table.Sequence) & LM_table.Stage<=0)/TST;

TNREMT = sum(hypnogram_long<0 & lights==1)/(Fs*3600); % Time in NREM sleep 
PLM_NREM_index = sum(~isnan(LM_table.Sequence) & LM_table.Stage<0)/TNREMT;

TREMT = sum(hypnogram_long==0 & lights==1)/(Fs*3600); % Time in REM sleep 
PLM_REM_index = sum(~isnan(LM_table.Sequence) & LM_table.Stage==0)/TREMT;

TWT = sum(hypnogram_long==1 & lights==1)/(Fs*3600); % Time in wakefulness
PLMW_index = sum(~isnan(LM_table.Sequence) & LM_table.Stage==1)/TWT;

%% IMI hystogram
%IMIs are not computed if a non-CLM is between two
%CLM.
IMI = [];
for i = 1:length(start_LM)-1
    %Check that there are both CLM
    if candidate(i) && candidate(i+1)
        this_IMI = (start_LM(i+1)-start_LM(i))/Fs;
        if this_IMI<90
            IMI = [IMI; this_IMI];
        end
    end
end
%Histograms
thisF = figure('Visible','off');
movegui(thisF,'center')
subplot(121)
h1 = histogram(IMI,'NumBins',35,'BinEdges',0:2:90);
%title('Intermovement interval histogram')
xlabel('Intermovement interval [s]')
ylabel('Number of CLM')
subplot(122)
h2 = histogram(log(IMI),'NumBins',35,'BinEdges',0:0.1:4.5);
%title('Intermovement interval histogram (log)')
xlabel('Intermovement interval log [s]')
ylabel('Number of CLM')
sgtitle(['File ' SV.filename],'Interpreter','none')
if out_calc.VisualizeHist.Value==1
    thisF.Visible='on';
end

%% PLMS arousal index
% An arousal and a leg movement are associated with each other
%when they are overlapping or when there is less than 0.5 s between
%the end of one event and the onset of the other event, regardless
%of which is first.
[arousal_start, arousal_end, ~] = event_StartsEndsDurations(arousal);
associatedArousal = zeros(size(LM_table,1),1);
for i = 1:size(LM_table,1)
    this_LM_start = LM_table.Start(i);
    this_LM_end = LM_table.End(i);
    for j = 1:length(arousal_start)
        this_arousal_start = arousal_start(j)/Fs;
        this_arousal_end = arousal_end(j)/Fs;
        if (this_arousal_start>=(this_LM_start-0.5) & this_arousal_start<=(this_LM_end+0.5)) || ...
                 (this_arousal_end>=(this_LM_start-0.5) & this_arousal_end<=(this_LM_end+0.5)) || ...
                 (this_arousal_start<=(this_LM_start-0.5) & this_arousal_end>=(this_LM_end+0.5))
             associatedArousal(i) = 1;
        end
    end    

end

LM_table.AssociatedArousal = associatedArousal;
PLMS_arousal_index = sum(~isnan(LM_table.Sequence) & LM_table.Stage<=0 & LM_table.AssociatedArousal)/TST;

%% PLMSnr index 
% Candidate leg movements that are associated with respiratory
% events are called respiratory event associated leg movements (CLMr).
% CLMr are defined as CLM that:
% have some part overlapping within an interval of 2.0 s before
% to 10.25 s after the end of a respiratory event (recommended for
% obstructive sleep apnea syndromes)


LL = 2;
UL = 10.25;
% LL = 0.5;
% UL = 0.5;

% resp(hypnogram==2) = 0;
[resp_start, resp_end, ~] = event_StartsEndsDurations(resp);
associatedRespiration = zeros(size(LM_table,1),1);

for i = 1:size(LM_table,1)
    this_LM_start = LM_table.Start(i);
    this_LM_end = LM_table.End(i);
    for j = 1:length(resp_start)
        this_resp_start = resp_start(j)/Fs;
        this_resp_end = resp_end(j)/Fs;
        if (this_LM_start>=(this_resp_end-LL) & this_LM_start<=(this_resp_end+UL)) || ...
            (this_LM_end>=(this_resp_end-LL) & this_LM_end<=(this_resp_end+UL)) || ...
                (this_LM_start<=(this_resp_end-LL) & this_LM_end>=(this_resp_end+UL))
             associatedRespiration(i) = 1;
        end
    end          
end

LM_table.AssociatedRespiration = associatedRespiration;

%Reconsider the table excluding CLM that are not CLMr
LM_table_no_resp = LM_table;
CLMr = LM_table_no_resp.AssociatedRespiration==1;
LM_table_no_resp(CLMr,:) = [];

distance_start_LMs_noResp = diff(LM_table_no_resp.Start);
distance_start_LMs_noResp = [0; distance_start_LMs_noResp];
LM_table_no_resp.IMI = distance_start_LMs_noResp;
%Get the short interval ones
short_interval_noResp = distance_start_LMs_noResp<10;

%Get now the PLM series
start_PLM = 1;
sequence = 1;
seq = nan(length(LM_table_no_resp.Start),1);
while start_PLM<length(LM_table_no_resp.Start)
    check = true;
    tmp = start_PLM;
    c = [];
    while check && tmp<length(distance_start_LMs_noResp)
        %Condition on the first one
        if tmp==1
            cond = 1;
        else
            cond = ~short_interval_noResp(tmp);
        end
        if (distance_start_LMs_noResp(tmp+1)>=10 && distance_start_LMs_noResp(tmp+1)<90) && candidate(tmp) && cond && candidate(tmp+1)
            c = [c; tmp];
            tmp = tmp+1;
        else
            c = [c; tmp];
            check = false;
        end
    end
    if length(c)>=4
        seq(c) = sequence;
        sequence = sequence+1;
    end
    start_PLM = tmp+1;
end

LM_table_no_resp.Sequence = seq;
LM_table_no_resp.("Short interval") = short_interval_noResp;
LM_table_no_resp.("Isolated LM") = [];

%Get the indices
PLMSnr_index = sum(~isnan(LM_table_no_resp.Sequence) & LM_table_no_resp.Stage<=0)/TST;
PLMnr_NREM_index = sum(~isnan(LM_table_no_resp.Sequence) & LM_table_no_resp.Stage<0)/TNREMT;
PLMnr_REM_index = sum(~isnan(LM_table_no_resp.Sequence) & LM_table_no_resp.Stage==0)/TREMT;
PLMSnra_index = sum(~isnan(LM_table_no_resp.Sequence) & LM_table_no_resp.Stage<=0 & LM_table_no_resp.AssociatedArousal)/TST;

%% CLMr indices
CLMr_sleep = sum(LM_table.Stage<=0 & LM_table.CLM & LM_table.AssociatedRespiration)/TST;
CLMr_NREM = sum(LM_table.Stage<0 & LM_table.CLM & LM_table.AssociatedRespiration)/TNREMT;
CLMr_REM = sum(LM_table.Stage==0 & LM_table.CLM & LM_table.AssociatedRespiration)/TREMT;

%% Short IMI movement indices
shortIMI_sleep_index = sum(LM_table.("Short interval") & LM_table.Stage<=0)/TST;
shortIMI_wake_index = sum(LM_table.("Short interval") & LM_table.Stage==1)/TWT;
shortIMI_NREM_index = sum(LM_table.("Short interval") & LM_table.Stage<0)/TNREMT;
shortIMI_REM_index = sum(LM_table.("Short interval") & LM_table.Stage==0)/TREMT;

%% Isolated movement indices
isolated_CLM_sleep_index = sum(LM_table.("Isolated LM") & LM_table.Stage<=0)/TST;
isolated_CLM_wake_index = sum(LM_table.("Isolated LM") & LM_table.Stage==1)/TWT;
isolated_CLM_NREM_index = sum(LM_table.("Isolated LM") & LM_table.Stage<0)/TNREMT;
isolated_CLM_REM_index = sum(LM_table.("Isolated LM") & LM_table.Stage==0)/TREMT;

%% Average duration of PLMS and PLMW
avg_dur_PLM_sleep = nanmean(LM_table.Duration(~isnan(LM_table.Sequence) & LM_table.Stage<=0));
avg_dur_PLM_REM = nanmean(LM_table.Duration(~isnan(LM_table.Sequence) & LM_table.Stage==0));
avg_dur_PLM_NREM = nanmean(LM_table.Duration(~isnan(LM_table.Sequence) & LM_table.Stage<0));
avg_dur_PLM_wake = nanmean(LM_table.Duration(~isnan(LM_table.Sequence) & LM_table.Stage==1));

%% Average duration of CLM with IMI<10s
avg_dur_CLM_short_IMI_sleep = nanmean(LM_table.Duration(LM_table.("Short interval") & LM_table.Stage<=0));
avg_dur_CLM_short_IMI_wake = nanmean(LM_table.Duration(LM_table.("Short interval") & LM_table.Stage==1));
avg_dur_CLM_short_IMI_NREM = nanmean(LM_table.Duration(LM_table.("Short interval") & LM_table.Stage<0));
avg_dur_CLM_short_IMI_REM = nanmean(LM_table.Duration(LM_table.("Short interval") & LM_table.Stage==0));

%% Average duration of isolated LM
avg_dur_isolated_CLM_sleep = nanmean(LM_table.Duration(LM_table.("Isolated LM") & LM_table.Stage<=0));
avg_dur_isolated_CLM_wake = nanmean(LM_table.Duration(LM_table.("Isolated LM") & LM_table.Stage==1));
avg_dur_isolated_CLM_NREM = nanmean(LM_table.Duration(LM_table.("Isolated LM") & LM_table.Stage<0));
avg_dur_isolated_CLM_REM = nanmean(LM_table.Duration(LM_table.("Isolated LM") & LM_table.Stage==0));

%% Optional: Monolateral and bilateral indices (sleep and wake), withotu re-evaluating periodicity
PLMS_left_index = sum(~isnan(LM_table.Sequence) & LM_table.Stage<=0 & LM_table.("Mov type")==1)/TST;
PLMS_right_index = sum(~isnan(LM_table.Sequence) & LM_table.Stage<=0 & LM_table.("Mov type")==2)/TST;
PLMS_bil_index = sum(~isnan(LM_table.Sequence) & LM_table.Stage<=0 & LM_table.("Mov type")==3)/TST;

PLMW_left_index = sum(~isnan(LM_table.Sequence) & LM_table.Stage==1 & LM_table.("Mov type")==1)/TWT;
PLMW_right_index = sum(~isnan(LM_table.Sequence) & LM_table.Stage==1 & LM_table.("Mov type")==2)/TWT;
PLMW_bil_index = sum(~isnan(LM_table.Sequence) & LM_table.Stage==1 & LM_table.("Mov type")==3)/TWT;

%% Optional: periodicity indices
periodicity_index_sleep = sum(~isnan(LM_table.Sequence) & LM_table.Stage<=0)/sum(LM_table.CLM==1 & LM_table.Stage<=0);
periodicity_index_wake = sum(~isnan(LM_table.Sequence) & LM_table.Stage==1)/sum(LM_table.CLM==1 & LM_table.Stage==1);

%% Optional: Average and standard deviation of log of CLMS IMI for IMI ≥10 and < 90 s.
IMI_more10 = LM_table.IMI>=10;
IMI_less90 = LM_table.IMI<90;

avg_log_IMI = nanmean(log(LM_table.IMI(LM_table.CLM==1 & LM_table.Stage<=0 & IMI_more10 & IMI_less90)));
std_log_IMI = nanstd(log(LM_table.IMI(LM_table.CLM==1 & LM_table.Stage<=0 & IMI_more10 & IMI_less90)));

%% Optional: CLMS/h and CLMW/h
CLMS_index = sum(LM_table.CLM==1 & LM_table.Stage<=0)/TST;
CLMW_index = sum(LM_table.CLM==1 & LM_table.Stage==1)/TWT;
CLM_NREM_index = sum(LM_table.CLM==1 & LM_table.Stage<0)/TNREMT;
CLM_REM_index = sum(LM_table.CLM==1 & LM_table.Stage==0)/TREMT;

%% Final correction if the annotations of arousals and respiratory events were not given
if strcmp(arousal_str,'Annotation not available')
    PLMS_arousal_index = NaN;
    PLMSnra_index = NaN;
end

if strcmp(resp_str,'Annotation not available')
   PLMSnr_index = NaN;
   PLMnr_NREM_index = NaN;
   PLMnr_REM_index = NaN;
   PLMSnra_index = NaN;
   CLMr_sleep = NaN;
   CLMr_NREM = NaN;
   CLMr_REM = NaN;
end
%% Put the results in an array and save
close(fig)

results = [PLMS_index PLM_NREM_index PLM_REM_index PLMW_index ...
    PLMS_arousal_index ...
    PLMSnr_index PLMnr_NREM_index PLMnr_REM_index PLMSnra_index ...
    CLMr_sleep CLMr_NREM CLMr_REM ...
    shortIMI_sleep_index shortIMI_wake_index shortIMI_NREM_index shortIMI_REM_index ...
    isolated_CLM_sleep_index isolated_CLM_wake_index isolated_CLM_NREM_index isolated_CLM_REM_index ...
    avg_dur_PLM_sleep avg_dur_PLM_NREM avg_dur_PLM_REM avg_dur_PLM_wake ...
    avg_dur_CLM_short_IMI_sleep avg_dur_CLM_short_IMI_wake avg_dur_CLM_short_IMI_NREM avg_dur_CLM_short_IMI_REM ...
    avg_dur_isolated_CLM_sleep avg_dur_isolated_CLM_wake avg_dur_isolated_CLM_NREM avg_dur_isolated_CLM_REM ...
    PLMS_left_index PLMW_left_index ...
    PLMS_right_index PLMW_right_index ...
    PLMS_bil_index PLMW_bil_index ...
    periodicity_index_sleep periodicity_index_wake ...
    avg_log_IMI std_log_IMI ...
    CLMS_index CLMW_index CLM_NREM_index CLM_REM_index];
str = {'PLMS/hr','PLMS_NR/hr','PLMS_R/hr','PLMW/hr',...
    'PLMSa/hr',...
    'PLMSnr/hr','PLMnr_NR/hr','PLMnr_R/hr','PLMnr_a/hr',...
    'CLMSr/hr','CLMr_NR/hr','CLMr_R/hr',...
    'shortIMImovS/hr','shortIMImovW/hr','shortIMImov_NR/hr','shortIMImov_R/hr',...
    'isolatedLMS/hr','isolatedLMW/hr','isolatedLM_NR/hr','isolatedLM_R/hr',...
    'avgdur_PLMS [s]', 'avgdur_PLM_NR [s]', 'avgdur_PLM_R [s]', 'avgdur_PLMW [s]',...
    'avgdur_shortIMImovS [s]','avgdur_shortIMImovW [s]','avgdur_shortIMImov_NR [s]','avgdur_shortIMImov_R [s]',...
    'avgdur_isolatedLMS [s]','avgdur_isolatedLMW [s]','avgdur_isolatedLM_NR [s]','avgdur_isolatedLM_R [s]',...
    'PLMS/hr left','PLMW/hr left',...
    'PLMS/hr right','PLMW/hr right',...
    'PLMS/hr bilateral','PLMW/hr bilateral',...
    'Periodicity index sleep','Periodicity index wake',...
    'Average log IMI (10-90s)','Std log IMI (10-90s)',...
    'CLMS/hr','CLMW/hr','CLM_NR/hr','CLM_R/hr'};

t = array2table(results,'VariableNames',str);
%Save the results in a csv file
File = [savepath '\' SV.filename(1:end-4) '_LM_indices_WASM.csv'];
writetable(t, File);
%Save the IMI
File_h1 = [savepath '\' SV.filename(1:end-4) '-IMI.csv'];
a = [h1.BinEdges(1:end-1)'+h1.BinWidth/2 h1.Values'];
t1= array2table(a,'VariableNames',{'Bin center [s]','Number of CLM'});
writetable(t1,File_h1);
%Save the IMI LOG
File_h2 = [savepath '\' SV.filename(1:end-4) '-IMI_LOG.csv'];
b = [h2.BinEdges(1:end-1)'+h2.BinWidth/2 h2.Values'];
t2= array2table(b,'VariableNames',{'Bin center [s]','Number of CLM'});
writetable(t2,File_h2);
FileRaw = [savepath '\' SV.filename(1:end-4) '_LM_raw.csv'];

%Modify the LM_table to make it readable and save it 
LM_table_export = LM_table;
sleepstages = LM_table_export.Stage;
sleepstages_names = cell(length(sleepstages),1);
sleepstages_names(sleepstages==1)={'Wake'};
sleepstages_names(sleepstages==-1)={'N1'};
sleepstages_names(sleepstages==-2)={'N2'};
sleepstages_names(sleepstages==-3)={'N3'};
sleepstages_names(sleepstages==0)={'REM'};
LM_table_export.Stage = sleepstages_names;
movementtype = LM_table_export.("Mov type");
movementtype_names = cell(length(movementtype),1);
movementtype_names(movementtype==1) = {'Left'};
movementtype_names(movementtype==2) = {'Right'};
movementtype_names(movementtype==3) = {'Bilateral'};
LM_table_export.("Mov type") = movementtype_names;
if strcmp(arousal_str,'Annotation not available')
    LM_table_export.AssociatedArousal = nan(length(LM_table_export.AssociatedArousal),1);
end
if strcmp(resp_str,'Annotation not available')
    LM_table_export.AssociatedRespiration = nan(length(LM_table_export.AssociatedRespiration),1);
end
writetable(LM_table_export, FileRaw);


end
    