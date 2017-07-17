function stocks_value = price_stocks(file_path)

global h_line
fprintf([h_line 'Computing the value of the stocks...\n' h_line])

%% Initialisations
global raw_data
global column_labels
global dpa

%% Import FX
file_path = 'C:\Users\sergio.ortizorendain\Documents\MATLAB\Pricing\Data\portfolio_data.xlsm';
sheet = 'FX';
range = 'A1:B657';
% All the data will be in raw_data
[~, ~, raw_data] = xlsread(file_path, sheet, range);

% Read the headers of the excel file to know where is what
column_labels = raw_data(1, :);
% Remove the headers once for all to avoid offsetting all the time
raw_data(1, :) = [];
usdcad = cell2mat(raw_data(end,2));

sheet = 'FX';
range = 'd1:e657';
% All the data will be in raw_data
[~, ~, raw_data2] = xlsread(file_path, sheet, range);

% Read the headers of the excel file to know where is what
column_labels2 = raw_data2(1, :);
% Remove the headers once for all to avoid offsetting all the time
raw_data2(1, :) = [];
eurcad = cell2mat(raw_data2(end,2));
% clear raw_data
% clear raw_data2
% clear column_labels2
% clear column_labels1
% clear range sheet column_labels
%% Read equity data from the Excel file
sheet = 'Stocks';
[~, ~, raw_data] = xlsread(file_path, sheet);
% Read the headers of the columns to know where is what
column_labels = raw_data(1, :);
% Keep only the data related to the options
raw_data(1, :) = [];

stocks_value = sum(values_of('Market Value'))*(1-0.1821)*usdcad*(1.02338);

clearvars raw_data column_labels

end







%