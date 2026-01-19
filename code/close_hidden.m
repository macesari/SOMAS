% function close_hidden()
%
% Close all hidden figures such as waitbar()
% Written by Kenneth H. Cate, 2008-01-17
%
% Modified:
%   2008-09-22  K.H.C.  Replaced k with hidden_figures
%                       Added loop to find hidden among all_figures
%   2008-09-17  K.H.C.  Removed test for 'waitbar();'
%                       Changed CloseRequestFcn to 'closereq' (was '')
%   2008-04-17  K.H.C.  Added test for isempty(visible_figures)
function close_hidden( fig )
    all_figures = allchild(0);      % All the figures, hidden and visible
    if ~isempty(all_figures)
        if nargin >= 1
            if find(all_figures == fig)
                all_figures = fig;
            else
                all_figures = [];
            end
        end
        visible_figures = get(0, 'Children');   % Visible figures
        hidden_figures  = all_figures;
        if ~isempty(visible_figures)            % Are any visible?
            for i=length(hidden_figures):-1:1   % Remove visible figures from list
                if find(hidden_figures(i) == visible_figures)
                    hidden_figures(i) = [];
                end
            end
        end
        for i=1:length(hidden_figures)
            h = hidden_figures(i);
            if strcmp(h.Name,'SOMAS')
                continue
            end
          % fctn = get(h, 'CloseRequestFcn');   % This line is used for debugging only
            set(h, 'CloseRequestFcn', 'closereq');  % Re-set the close function
            close(h);
        end
    end   
return
