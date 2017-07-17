%% Asia Currency Crisis
% Historical dates: Jul-2-1997:Jan-12-1998. Thai Bhat 
%collapse when Tha govt started to float ccy. Spread across asia to impact ccy and equities mkts.
clear;clc
file_path = 'C:\Users\sergio.ortizorendain\Documents\MATLAB\Pricing\Data\portfolio_data.xlsm';
%% Bonds
% CAD rates
[CAD_rates, ~, ~] = xlsread(file_path, 'CAD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
CAD_rates = CAD_rates(end, 1:end);
% EURO rates
[EUR_rates, ~, ~] = xlsread(file_path, 'EUR');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
EUR_rates = EUR_rates(end, 1:end);
% USD rates
[USD_rates, ~, ~] = xlsread(file_path, 'USD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
USD_rates = USD_rates(end, 1:end);
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
% The sectors represented in the portfolio
sectors = labels_of('Sector');
% The spreads for each sector
unique_sectors = unique(sectors);
spreads = cell(size(unique_sectors));

for k = 1:length(unique_sectors)
    [~, ~, spreads{k}] = xlsread(file_path, unique_sectors{k}, 'A1:H16');
end

for k = 1:25
the_spreads = sector2spreads(sectors{k}, unique_sectors, spreads);
the_spreads(:, 1) = [];
corporate_spreads(k,:) = cell2mat(the_spreads(2:end, rating2bin(ratings{k})))'*1e-4;
end

