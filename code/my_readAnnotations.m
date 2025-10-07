function [recordTimes,onset,annotations,...
    annotationDuration] = my_readAnnotations(RawAnnotations)
%readAnnotations function is used to make Annotations of EDF/EDF+ files more readable
%
%   This function is for internal use only. It may change or be removed.

%   Copyright 2020 The MathWorks, Inc.

nr = numel(RawAnnotations);
x = zeros(nr,1);

for ii = 1:nr
    if ~ischar(RawAnnotations{ii})
        RawAnnotations{ii} = char(RawAnnotations{ii});
    end
    RawAnnotations{ii} = purifyAnnotation(RawAnnotations{ii});
    x(ii) = count(RawAnnotations{ii}, char(0));
end

idx = 0;
r_idx = zeros(nr,1);
tOnset = cell(sum(x),1);
tDuration = cell(sum(x),1);
annotations = strings(sum(x),1);

for ii = 1:nr
    n_idx = [0 find(RawAnnotations{ii} == char(0))];
    r_idx(ii) = 1+idx;
    
    for jj = 1:x(ii)
        idx = idx+1;
        temp = RawAnnotations{ii}(1+n_idx(jj):n_idx(jj+1)-1);
        o_idx = find(temp == char(20));
        d_idx = find(temp(1:o_idx(1)) == char(21));
        
        if (any(d_idx))
            tDuration{idx} = temp(1+d_idx(1):o_idx(1)-1);
            tOnset{idx} = temp(1:d_idx(1)-1);
        else
            tOnset{idx} = temp(1:o_idx(1)-1);
        end
        annotations(idx) = temp(1+o_idx(1):o_idx(end)-1);
    end
end

r_idx = find(strcmp(annotations,'')); %Defined by Matteo
onset = seconds(str2double(tOnset));
annotationDuration = seconds(str2double(tDuration));
recordTimes = onset(r_idx);

n_idx = annotations == "";
onset(n_idx) = [];
annotationDuration(n_idx) = [];
annotations(n_idx) = [];

if isempty(onset)
    onset = onset(:);
    annotations = annotations(:);
    annotationDuration = annotationDuration(:);
end
end

function res = purifyAnnotation(input)
for ii = numel(input):-1:1
    if (input(ii) == char(0))
        input(ii) = ' ';
    else
        input(ii+1) = char(0);
        break;
    end
end

res = strtrim(input);
end
