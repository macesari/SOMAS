function out_select_times = makefig_select_times(SV)
%MAKEFIG_SELECT_TIMES: this function makes the figure to make the user specify
%the analysis window. This is needed if the user would like to select only
%a part of the recording where the analyses should be performed.
%INPUT: SV, the structure containing the EDF+ file
%OUTPUT: out_select_times, a structure that memorizes the figure and the
%data there saved.

%Get the start and end of the recording
start_date = SV.header.StartDate;
start_time = SV.header.StartTime;
start_recording = datetime([convertStringsToChars(start_date) ' ' convertStringsToChars(start_time)],'InputFormat','dd.MM.yy HH.mm.ss');
duration_recording = SV.data.("Record Time")(end)+SV.header.DataRecordDuration;
end_recording = start_recording+duration_recording;
grayColor = [.7 .7 .7];
%Create figure
out_select_times.figanalysis = uifigure('Visible','off','Position',[100 100 453 371],'Name',['Specify analysis window - file ' SV.filename]);
%Title
out_select_times.SelectanalysisperiodLabel = uilabel(out_select_times.figanalysis,'HorizontalAlignment','center',...
    'FontSize',16,'FontWeight','bold','Position',[1 324 426 31],'Text','Select analysis window');
%Start recording
out_select_times.StartrecordingTextAreaLabel = uilabel(out_select_times.figanalysis,'HorizontalAlignment','right','Position',[18 273 84 22],...
    'Text','Start Recording');
out_select_times.StartrecordingTextArea = uitextarea(out_select_times.figanalysis,'Position',[117 266 297 36],...
    'Value',datestr(start_recording,'yyyy-mm-dd HH:MM:SS'),'Editable','off','FontColor',grayColor);
%End recording
out_select_times.EndrecordingTextAreaLabel = uilabel(out_select_times.figanalysis,'HorizontalAlignment','right','Position',[21 225 80 22],...
    'Text','End Recording');
out_select_times.EndrecordingTextArea = uitextarea(out_select_times.figanalysis,'Position',[117 218 298 36],...
    'Value',datestr(end_recording,'yyyy-mm-dd HH:MM:SS'),'Editable','off','FontColor',grayColor);
%Start analysis
out_select_times.StartanalysisTextAreaLabel = uilabel(out_select_times.figanalysis,'HorizontalAlignment','right','Position',[21 157 78 22],...
    'Text','Start Analysis');
out_select_times.StartanalysisTextArea = uitextarea(out_select_times.figanalysis,'Position',[114 150 301 36],...
    'Value',datestr(start_recording,'yyyy-mm-dd HH:MM:SS'),'Editable','on');
%End analysis         
out_select_times.EndanalysisTextAreaLabel = uilabel(out_select_times.figanalysis,'HorizontalAlignment','right','Position',[21 105 74 22],...
    'Text','End Analysis');
out_select_times.EndanalysisTextArea = uitextarea(out_select_times.figanalysis,'Position',[111 98 304 36],...
    'Value',datestr(end_recording,'yyyy-mm-dd HH:MM:SS'),'Editable','on');
%Note
t = 'Note: use the format "yyyy-mm-dd HH:MM:SS" to specify the dates and times';
out_select_times.Note = uilabel(out_select_times.figanalysis,'Position',[20 58 423 28],...
    'Text',t);
%Next button
out_select_times.NextButton_analysis = uibutton(out_select_times.figanalysis,'push','Position',[167 18 146 30],...
    'Text','Next');
out_select_times.NextButton_analysis.ButtonPushedFcn=@(~,~)closeFig(out_select_times.figanalysis);
%Make it visible
movegui(out_select_times.figanalysis,'center')
out_select_times.figanalysis.Visible = 'on';

end

