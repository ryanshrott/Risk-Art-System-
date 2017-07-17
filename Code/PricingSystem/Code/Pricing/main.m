function main
% ------------------------------------------------------------------------
% Function description goes here.
% ------------------------------------------------------------------------

%% Preamble
% Get access to class definitions
addpath('../Classes')

% Location of Excel file with the portfolio info
filename = 'portfolio_data.xlsm';
file_path = ['../../Data/' filename];

% A few global variables to avoid functions with excessive number of inputs
% Command-line formatting
global h_line
h_line = [repmat('-', 1, 66) '\n'];
global star_line
star_line = [repmat('*', 1, 66) '\n'];

% Portfolio parameters that change during simulation
x = PricingInput;
x.num_of_days_elapsed = 0;

% Portfolio constants
c = PortfolioConstants;

% Flags used to select actions
bonds = x.BONDS;
options = x.OPTIONS;
cds = x.CDS;
stocks = 0; %x.STOCKS;

%% Bond pricing, durations, and other quantities related to the bonds
% fprintf('\n')

if bonds == 1
    
    %% Import data
    sheet = 'Bonds';
    range = 'A1:Y26';
    % All the data will be in raw_data
    [~, ~, raw_data] = xlsread(file_path, sheet, range);
    % Read the headers of the excel file to know where is what
    column_labels = raw_data(1, :);
    % Remove the headers once for all to avoid offsetting all the time
    raw_data(1, :) = [];
    c.num_of_bonds = size(raw_data, 1);

    % Collect the data necessary to price the bonds
    c.bond_positions = values_of('No. Securities', column_labels, raw_data);
    c.bond_notionals = values_of('Face Value', column_labels, raw_data);
    c.bond_coupon_frequencies = values_of('Coupon Frequency', column_labels, raw_data);
    c.bond_coupons = values_of('Coupon', column_labels, raw_data);
    c.bonds_maturity_dates = labels_of('Maturity', column_labels, raw_data);
    c.bond_sectors = labels_of('Sector', column_labels, raw_data);
    x.rate_time_structure = [0.25 0.5 1:10 15 20 30];
    tmp = xlsread(file_path, 'CAD');
    x.zero_curve_CAD = tmp(end, 2:end);
    tmp = xlsread(file_path, 'EUR');
    x.zero_curve_EUR = tmp(end, 2:end);
    tmp = xlsread(file_path, 'USD');
    x.zero_curve_USD = tmp(end, 2:end);
    x.EURCAD = 1.4458;
    x.USDCAD = 1.3004;
    x.bond_ratings = labels_of('S&P', column_labels, raw_data);
    
    % Call the pricing function for bonds
    bonds_value = price_bonds_with_r_and_s(x, c)
    fprintf('\nWARNING: PRICE THE ILB CORRECTLY\n')
    
end

%% Option pricing
if options == 1
    
    % Import data
    sheet = 'Options';
    [~, ~, raw_data] = xlsread(file_path, sheet);
    % Read the headers of the columns to know where is what
    column_labels = raw_data(1, :);
    % Keep only the data related to the options
    raw_data(1, :) = [];
    x.spot_prices = values_of('Price Underlying', column_labels, raw_data);
    c.K = values_of('Strike', column_labels, raw_data);
    x.risk_free_rate = x.zero_curve_USD(1);
    x.implied_vol = values_of('Implied Volatility', column_labels, raw_data);
    c.yields = values_of('Dividend Yield', column_labels, raw_data);
    c.num_of_options = size(raw_data, 1);
    
    % Call the pricing function for options
    options_value = price_options(x, c)
    fprintf('The value of the options portfolio is %g\n', options_value)

end

%% Add the value of the stocks
if stocks == 1
    
    stocks_value = price_stocks(x, c);
    fprintf('The value of the stocks is %g\n', stocks_value)
    
end

%% CDS prices
if cds == 1
    
    cds_value = price_cds(x, c);
    fprintf('The value of the CDS portfolio is %g\n', cds_value)
    
end

%% The end
if bonds&&options&&cds&&stocks
    portfolio_value = sum([bonds_value, options_value, stocks_value, cds_value]);
else % flags were used to skip pricing parts of the portfolio
    fprintf([star_line 'Parts of the portfolio were not priced\n' star_line])
    portfolio_value = [];
end

fprintf('\n')
end

