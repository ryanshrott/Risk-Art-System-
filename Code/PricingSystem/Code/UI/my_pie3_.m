function my_pie3(varargin)
% ------------------------------------------------------------------------
% Input arguments:
%
%     1: the data for the pie chart
%     2: explode vector
%     3: labels
%     4: labels' font size
% ------------------------------------------------------------------------

h = [];

switch nargin
    case 1
        h = pie3(varargin{1});
    case 2
        h = pie3(varargin{1}, varargin{2});
    case 3
        h = pie3(varargin{1}, zeros(length(varargin{1}), 1), varargin{3});
    case 4
        h = pie3(varargin{1}, zeros(length(varargin{1}), 1), varargin{3});
        
        % Find all graphics objects that have a 'FontSize' property and set it to
        % font_size
        hh = findobj(h, 'FontSize', 10)
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