function stocks_value = price_stocks(file_path)

global h_line
fprintf([h_line 'Computing the value of the stocks...\n' h_line])

%% Initialisations
global raw_data
global column_labels
global dpa

%% Read equity data from the Excel file
sheet = 'Stocks';
[~, ~, raw_data] = xlsread(file_path, sheet);
% Read the headers of the columns to know where is what
column_labels = raw_data(1, :);
% Keep only the data related to the options
raw_data(1, :) = [];

stocks_value = sum(values_of('Market Value'));

clearvars raw_data column_labels

end







%