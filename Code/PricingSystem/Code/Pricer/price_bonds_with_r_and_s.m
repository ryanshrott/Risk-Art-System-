function bonds_value = price_bonds_with_r_and_s(x, c)
% This function prices the bonds in the portfolio.

%% Collect and process the data necessary for the calculations.
% Store values from raw_data into separate arrays for clarity and
% convenience. The names of the variables are self-explanatory.

% Positions
position = c.bond_positions;
% Face values
notionals = c.bond_notionals;
% Coupon frequencies
coupon_frequencies = c.bond_coupon_frequencies;
% Coupons in $
coupons = (c.bond_coupons)./coupon_frequencies.*notionals;
% Time to maturity in years
T = (datenum(c.bonds_maturity_dates) - repmat(...
    today + x.num_of_days_elapsed, c.num_of_bonds, 1))/c.dpa;
% Number of coupons to be paid
num_of_coupons = ceil(coupon_frequencies.*T);
% The sectors represented in the portfolio
sectors = c.bond_sectors;
% The spreads for each sector
unique_sectors = unique(sectors);
spreads = load('spreads.mat');
spreads = spreads.spreads;
% The currency each bond is in
currency = c.bond_currencies;
% The ratings of the bonds
ratings = x.bond_ratings;
% Tenor in years for the corporate spreads
tenor = [0.25; 0.5; 1; 2; 3; 4; 5; 7; 8; 9; 10; 15; 20; 25; 30]';

% Read the zero rates
% zero_time_structure = [0.25 0.5 1:10 15 20 30];
zero_time_structure = x.rate_time_structure;
% CAD rates
CAD_rates = x.zero_curve_CAD;
% EURO rates
EUR_rates = x.zero_curve_EUR;
% USD rates
USD_rates = x.zero_curve_USD;

%% Array pre-allocation
bond_prices_r_s = zeros(c.num_of_bonds, 1);

exchange_rate = [];
for k = 1:size(c.num_of_bonds, 1)
    
    % The spreads
    the_spreads = sector2spreads(sectors{k}, unique_sectors, spreads);
    the_spreads(:, 1) = [];
    the_spreads = cell2mat(the_spreads(2:end, ratings(k)))'*1e-4;
    % The rates, depending on currency
    switch currency{k}
        case 'CAD'
            zero_rates = CAD_rates;
            exchange_rate = 1.0;
        case 'EUR'
            zero_rates = EUR_rates;
            exchange_rate = x.EURCAD;
        case 'USD'
            zero_rates = USD_rates;
            exchange_rate = x.USDCAD;
    end
    
    % t(k) is the time from today to the k-th cashflow
    t = zeros(1, num_of_coupons(k));
    % c(k) is the k-th cashflow
    c = t;
    t(2:end) = -1/coupon_frequencies(k);
    t = fliplr(cumsum(t)) + T(k);
    c(:) = coupons(k);
    c(end) = c(end) + notionals(k);
    
    s = interp1([0 tenor], [the_spreads(1) the_spreads], t);
    r = interp1([0 zero_time_structure], [zero_rates(1) zero_rates], t)/100;
    
    bond_prices_r_s(k) = exchange_rate*sum(c.*exp(-(s + r).*t));
    
end

bonds_value = position'*bond_prices_r_s;

end % price_bonds function
