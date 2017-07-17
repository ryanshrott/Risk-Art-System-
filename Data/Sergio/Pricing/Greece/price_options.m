function [options_value, option_prices] = price_options(file_path)

global h_line
fprintf([h_line 'Pricing the options...\n' h_line])

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
sheet = 'Options';
[~, ~, raw_data] = xlsread(file_path, sheet);
% Read the headers of the columns to know where is what
column_labels = raw_data(1, :);
% Keep only the data related to the options
raw_data(1, :) = [];

%% Parameters necessary for pricing the European options
% Strikes
K = values_of('Strike');
% Implied volatilities
vols = values_of('Implied Volatility');
% Risk-free rates
r = values_of('Risk Free Rate');
% Spot prices
S0 = values_of('Price Underlying');
% Dividend yields
y = values_of('Dividend Yield');
% Time to maturity in years
T = cell2mat(...
    raw_data(:, find(strcmp(column_labels, 'Days to Maturity')))...
    )/dpa;

%% Pricing of the options
option_prices = zeros(size(raw_data, 1), 1);
% Index directly into the arrays to select the parameters for the European
% options
eur = 1:1:2;
amer = 3;
[~, option_prices(eur)] = blsprice(S0(eur)*(1-0.1238), K(eur), r(eur)*(1-0.1358), T(eur),...
    vols(eur)*1.693, y(eur));
[~, tmp] = binprice(S0(amer)*(1-0.1238), K(amer), r(amer)*(1-0.1358), T(amer), 0.1,...
    vols(amer)*1.693, 1, y(amer));
option_prices(amer) = tmp(1);
% mkt_option_prices = values_of('Last Price');

options_value = option_prices'*values_of('Position')*usdcad*(1.0465);

clearvars raw_data column_labels

end
%