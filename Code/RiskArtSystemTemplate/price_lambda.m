function [portfolio_value, bonds_value, options_value, stocks_value, cds_values] = price_lambda(x)
% ------------------------------------------------------------------------
% Inputs: See the definition of the class 'PricingInput'.
%
% The typeof(x) = PricingInput
% ------------------------------------------------------------------------

% Create an object of type PortfolioConstants that contains as memebers all
% the portfolio constants necessary for pricing.
c = PortfolioConstants;

% Flags used to select what to price
bonds = x.BONDS;
options = x.OPTIONS;
cds = x.CDS;
stocks = x.STOCKS;

portfolio_value = 0;

%% Bond pricing
if bonds == 1
    
    % bonds_value = price_bonds(file_path);
    bonds_value = price_bonds_with_r_and_s(x, c);
    
else
    
    bonds_value = 0;
    
end

%% Option pricing
if options == 1
    
    options_value = price_options(x, c);
    
else
    
    options_value = 0;
    
end

%% The value of the stocks
if stocks == 1
    
    stocks_value = x.USDCAD*sum(x.stock_prices.*c.stock_positions);
    
else
    
    stocks_value = 0;
    
end


%% CDS prices
if cds == 1
    
    cds_values = price_cds_cva(x, c);
    
else
    
    cds_values = 0;
    
end

%% Nothing priced, if all flags == 0
if sum([bonds cds options stocks]) == 0
   fprintf('\nThe way you set the flags, nothing is being priced.\n')
   return
end

%% Return
portfolio_value = bonds_value + options_value + stocks_value + sum(cds_values);

end

