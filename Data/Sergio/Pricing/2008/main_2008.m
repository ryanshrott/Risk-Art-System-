function [portfolio_value, bonds_value, options_value, stocks_value, cds_value] = main_2008
% ------------------------------------------------------------------------
% Inputs:
%
% portfolio_value = total value of the portfolio
%     bonds_value = the value of the bonds
%   options_value = the value of the options
%    stocks_value = the value of the stocks
%       cds_value = the value of the cds
% ------------------------------------------------------------------------

%% MMF1926 -- Risk Management Project
% clear
% clc

format short g

%% Location of Excel file with the portfolio info
file_path = 'C:\Users\sergio.ortizorendain\Documents\MATLAB\Pricing\Data\portfolio_data.xlsm';

%% A few global variables
% Days in a year: days per annum
global dpa
dpa = 365; % 252 % 360
% Plotting parameters
global line_width
line_width = 2;
global font_size
font_size = 14;
% Command-line formatting
global h_line
h_line = [repmat('-', 1, 66) '\n'];
global star_line
star_line = [repmat('*', 1, 66) '\n'];

% Flags used to select actions
bonds = 1;
options = 1;
cds = 1;
stocks = 1;
% command_line_output = 1;

%% Bond pricing, durations, and other quantities related to the bonds
% fprintf('\n')

if bonds == 1
    
    % bonds_value = price_bonds(file_path);
    bonds_value = price_bonds_with_r_and_s(file_path);
    fprintf('The value of the bond portfolio is %g\n', bonds_value)
    
    fprintf('\nWARNING: FIX THE DURATION OF THE ONTARIO BOND\n')
    
end

%% Option pricing
if options == 1

    options_value = price_options(file_path);
    fprintf('The value of the options portfolio is %g\n', options_value)

end

%% Add the value of the stocks
if stocks == 1
    
    stocks_value = price_stocks(file_path);
    fprintf('The value of the stocks is %g\n', stocks_value)
    
end

%% CDS prices
if cds == 1
    
    cds_value = price_cds(file_path);
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

