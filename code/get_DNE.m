function [out_DNE, out_DNE_log] = get_DNE(EMG,Fs,lights,artifacts,hypnogram,analysis_window)
% GET_DNE This function calculates the atonia index for all sleep
% stages in the analysis window, within lights off and excluding the
% artifacts selected by the user
% INPUT: EMG, the EMG signal; Fs: the sampling frequency of the EMG signal;
% lights: a vector of 0s and 1s of the same size of the EMG signal, with 1s
% indicating lights off time; artifacts: a vector of 0s and 1s of the same
% size of the EMG signal, with 1s indicating artifacts; hypnogram: a vector
% containing the hypnogram of the same size of the EMG signal, with 2 =
% unscored, 1 = W, 0 = REM, -1 = N1, -2 = N2, -3 = N3; window_analysis: a
% vector of 0s and 1s of the same size of the EMG signal, with 1s indicating 
% the window where the analysis should be done.
% OUTPUT: out_DNE: a vector of size (1,56), where the following values are reported:
% From 1 to 9: the 1st, 3rd, 5th, 25th, 50th, 75th, 95th, 97th, and 99th
% percentiles of distribution in REM sleep
% From 10 to 18: the 1st, 3rd, 5th, 25th, 50th, 75th, 95th, 97th, and 99th
% percentiles of distribution in N1 sleep
% From 19 to 27: the 1st, 3rd, 5th, 25th, 50th, 75th, 95th, 97th, and 99th
% percentiles of distribution in N2 sleep
% From 28 to 36: the 1st, 3rd, 5th, 25th, 50th, 75th, 95th, 97th, and 99th
% percentiles of distribution in N3 sleep
% From 37 to 45: the 1st, 3rd, 5th, 25th, 50th, 75th, 95th, 97th, and 99th
% percentiles of distribution in NREM sleep
% From 46 to 54: the 1st, 3rd, 5th, 25th, 50th, 75th, 95th, 97th, and 99th
% percentiles of distribution in W
% 55: bottom threshold
% 56: upper threshold 
% out_DNE_log: the same as for out_DNE, but with transformed with log10
% (excluded for bottom and upper threshold, which are not reported)

% Initialization
out_DNE = nan(1,56);

%1. Consider the signal only between lights off and on and exclude artifacts
EMG(artifacts==1) = NaN;
EMG(lights==0) = NaN;
EMG(analysis_window==0) = NaN;

%2. Rectify the signal
EMG_rect = abs(EMG);

%3. Now divide the whole signals into 0.5s mini-epochs
n_MiniEpochs = floor(length(EMG_rect)/(0.5*Fs));

%4. Calculate the average in each mini-epoch
averageEMGMiniEpochs = nan(n_MiniEpochs,1);
for j = 1:n_MiniEpochs
    theseSamples = (j-1)*(0.5*Fs)+1:j*(0.5*Fs);
    this_EMG = EMG_rect(theseSamples);
    averageEMGMiniEpochs(j) = nanmean(this_EMG);
end

%5. Trim the distribution by discarding (i.e. assigning NaN) to 
%its bottom 0.5% and its top 0.5% of values
bottom_threshold = prctile(averageEMGMiniEpochs,0.5);
up_threshold = prctile(averageEMGMiniEpochs,99.5);

%6. Normalize the signal
averageEMGMiniEpochs_norm = 100*(averageEMGMiniEpochs-bottom_threshold)/(up_threshold-bottom_threshold);
averageEMGMiniEpochs_norm(averageEMGMiniEpochs_norm<0 | averageEMGMiniEpochs_norm>100) = NaN;

%7.Calculate the indices in the different stages
%REM sleep
disp('Calculating in REM sleep')
REM_sleep = hypnogram==0;
toConsider = double(REM_sleep & ~artifacts & lights & analysis_window);
out_DNE(1:9) = calculate_DNE(n_MiniEpochs,Fs,toConsider,averageEMGMiniEpochs_norm);
%N1 sleep
disp('Calculating in N1 sleep')
N1_sleep = hypnogram==-1;
toConsider = double(N1_sleep & ~artifacts & lights & analysis_window);
out_DNE(10:18) = calculate_DNE(n_MiniEpochs,Fs,toConsider,averageEMGMiniEpochs_norm);
%N2 sleep
disp('Calculating in N2 sleep')
N2_sleep = hypnogram==-2;
toConsider = double(N2_sleep & ~artifacts & lights & analysis_window);
out_DNE(19:27) = calculate_DNE(n_MiniEpochs,Fs,toConsider,averageEMGMiniEpochs_norm);
%N3 sleep
disp('Calculating in N3 sleep')
N3_sleep = hypnogram==-3;
toConsider = double(N3_sleep & ~artifacts & lights & analysis_window);
out_DNE(28:36) = calculate_DNE(n_MiniEpochs,Fs,toConsider,averageEMGMiniEpochs_norm);
%NREM sleep
disp('Calculating in NREM sleep')
NREM_sleep = hypnogram<0;
toConsider = double(NREM_sleep & ~artifacts & lights & analysis_window);
out_DNE(37:45) = calculate_DNE(n_MiniEpochs,Fs,toConsider,averageEMGMiniEpochs_norm);
%W
disp('Calculating in W')
W = hypnogram==1;
toConsider = double(W & ~artifacts & lights & analysis_window);
out_DNE(46:54) = calculate_DNE(n_MiniEpochs,Fs,toConsider,averageEMGMiniEpochs_norm);

% Log
out_DNE_log = log10(out_DNE);

%Save the percentiles
out_DNE(55) = bottom_threshold;
out_DNE(56) = up_threshold;


end

