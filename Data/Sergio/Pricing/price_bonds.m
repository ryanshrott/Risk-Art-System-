function [bonds_value, bond_prices, abs_bond_price_error, bond_durations] = price_bonds(file_path)

global h_line
fprintf([h_line 'Pricing the bonds...\n' h_line])

% Global variables
global raw_data
global column_labels
% Days in a year: days per annum
global dpa

% Plotting parameters
global line_width font_size

%% Import data
sheet = 'Bonds';
range = 'A1:X26';
% All the data will be in raw_data
[~, ~, raw_data] = xlsread(file_path, sheet, range);

% Read the headers of the excel file to know where is what
column_labels = raw_data(1, :);
% Remove the headers once for all to avoid offsetting all the time
raw_data(1, :) = [];
num_of_bonds = size(raw_data, 1);

%% Collect and process the data necessary for the calculations.
% Store values from raw_data into separate arrays for clarity and
% convenience. The names of the variables are self-explanatory.

% Positions
position = values_of('No. Securities');
% Face values
notionals = values_of('Face Value');
% Bond prices
bond_market_prices = values_of('Price');
% Coupon frequencies
coupon_frequencies = values_of('Coupon Frequency');
% Coupons
coupons = values_of('Coupon')./coupon_frequencies.*notionals;
% Yields
y = values_of('YTM')/100;
y(17) = 0.02669734;
% Time to maturity in years
T = (cellfun(@datenum, raw_data(:, find(strcmp(column_labels, 'Maturity'...
    )))) - repmat(today, num_of_bonds, 1))/dpa;
% Number of coupons to be paid
num_of_coupons = ceil(coupon_frequencies.*T);

%% Durations and prices
% Pre-allocate an array where the durations will be stored
bond_durations = zeros(size(bond_market_prices));
bond_prices = bond_durations;

for k = 17 %1:size(bond_durations, 1)
    % t(k) is the time from today to the k-th cashflow
    t = zeros(1, num_of_coupons(k));
    % c(k) is the k-th cashflow
    c = t;
    t(2:end) = -1/coupon_frequencies(k);
    t = fliplr(cumsum(t)) + T(k);
    c(:) = coupons(k);
    c(end) = c(end) + notionals(k);
    inflation = ((1.015).^t);
    bond_prices(k) = sum((inflation.*c).*exp(-y(k)*t));
    bond_durations(k) = sum(c.*t.*exp(-y(k)*t))/bond_prices(k);
    
end

% DEV MODE [[[
% plot(abs(bond_prices - bond_market_prices), 'LineWidth', line_width)
% title('Absolute difference between bond prices and bond market prices')
% ]]] DEV MODE

abs_bond_price_error = abs(bond_prices - bond_market_prices);

bonds_value = bond_prices;

clearvars raw_data column_labels

end % price_bonds function

% fprintf('\nBond Prices\t |Price - Mkt Price|\t Bond Durations')
% fprintf('\n%f\t%15.6f\t%20.6f', [bond_prices, abs_bond_price_error, bond_durations]')
% fprintf('\n')
% fprintf('\n')
% fprintf('max|Price - Mkt Price| = %f', max(abs_bond_price_error))
% fprintf('\n')
% 
% % Write bond-related information to Excel files
% % xlswrite('../Data/bond_prices.xlsx', bond_prices)
% % xlswrite('../Data/durations.xlsx', bond_durations)
