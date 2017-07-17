function pie_charts(varargin)

if nargin ~= 4
    warning('Less than 4 asset classes present in the pie charts')
end

explode = zeros(1, nargin);
explode(1) = 1;
pie3(cell2mat(varargin), explode)

figure
h = pie3(cell2mat(varargin(2:end)));

end