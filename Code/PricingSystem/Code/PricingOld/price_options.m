function [options_value, option_prices] = price_options(file_path)

global h_line
fprintf([h_line 'Pricing the options...\n' h_line])

%% Initialisations
global raw_data
global column_labels
global dpa

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
    )/Constants.dpa;

%% Pricing of the options
option_prices = zeros(size(raw_data, 1), 1);
% Index directly into the arrays to select the parameters for the European
% options
eur = 1:1:2;
amer = 3;
[~, option_prices(eur)] = blsprice(S0(eur), K(eur), r(eur), T(eur),...
    vols(eur), y(eur));
[~, tmp] = binprice(S0(amer), K(amer), r(amer), T(amer), 0.1,...
    vols(amer), 1, y(amer));
option_prices(amer) = tmp(1);
% All our options are USD
option_prices = SpotFXrates.USDCAD*option_prices;
% mkt_option_prices = values_of('Last Price');

options_value = option_prices'*values_of('Position');

clearvars raw_data column_labels

end







%