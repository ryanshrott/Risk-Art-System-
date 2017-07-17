function my_pie3(varargin)
% ------------------------------------------------------------------------
% Input arguments:
%
%     1: the data for the pie chart
%     2: explode vector
%     3: labels
%     4: labels' font size
% ------------------------------------------------------------------------

% Partial check of input arguments
if nargin <2 % the data must be passed; no default data
    disp('At least one argument must be passed to my_pie3')
    return
elseif nargin > 4
    disp('Too many arguments passed to my_pie3')
    return
end

h = [];

switch nargin
    case 1 % only data is passed
        h = pie3(varargin{1});
    case 2 % data and explode vector
        h = pie3(varargin{1}, varargin{2});
    case 3 % data, explode vector, and labels
        nargin
        varargin{nargin}
        if isempty(varargin{2})
            default_explode = zeros(length(varargin{1}), 1);
            h = pie3(varargin{1}, default_explode, varargin{3});
        else
            h = pie3(varargin{1}, varargin{2}, varargin{3});
        end
    case 4 % data, explode vector, labels, and font size
        if isempty(varargin{2}) % no explode vector passed
            default_explode = zeros(length(varargin{1}), 1);
            if isempty(varargin{3}) % no labels passed
                h = pie3(varargin{1}, default_explode);
            else % labels passed
                h = pie3(varargin{1}, default_explode, varargin{3});
            end
        else % explode vector passed
            if isempty(varargin{3}) % no labels passed
                h = pie3(varargin{1}, varargin{2});
            else % labels passed
                h = pie3(varargin{1}, varargin{2}, varargin{3});
            end
        end
        
        % Find all graphics objects that have a 'FontSize' property and set it to
        % font_size
        hh = findobj(h, 'FontSize', 10);
        for k = 1:length(hh)
            hh(k).FontSize = varargin{4};
        end
        
end

% Find all graphics objects that have a 'LineStyle' property and set it to
% 'none'
hh = findobj(h, 'LineStyle', '-');
for k = 1:length(hh)
    hh(k).LineStyle = 'none';
end

end