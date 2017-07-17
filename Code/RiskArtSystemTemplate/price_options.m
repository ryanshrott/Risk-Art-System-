function [options_value, option_prices] = price_options(x, c)

%% Parameters necessary for pricing the European options
% Spot prices
S0 = x.spot_prices;
% Strikes
K = c.K;
% Risk-free rates
r = [x.risk_free_rate; x.risk_free_rate; x.risk_free_rate];
% Time to maturity in years
T = (datenum(c.options_maturity_dates) -...
    repmat(today + x.num_of_days_elapsed, c.num_of_options, 1))/c.dpa;
% Implied volatilities
vols = x.implied_vol;
% Dividend yields
y = c.yields;

%% Pricing of the options
option_prices = zeros(c.num_of_options, 1);

if sum(T > 0) == c.num_of_options
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
    option_prices = x.USDCAD*option_prices;
    % mkt_option_prices = values_of('Last Price');
else
    % Assuming we won't simulate for more than a year, only the first
    % option may expire.
    if find(T <= 0) ~= 1
        fprintf('\nSomething went wrong. Probably, your VaR horizon is too long\n')
        return
    end
    % Treat the first European put separately
    eur = 2;
    amer = 3;
    [~, option_prices(eur)] = blsprice(S0(eur), K(eur), r(eur), T(eur),...
        vols(eur), y(eur));
    [~, tmp] = binprice(S0(amer), K(amer), r(amer), T(amer), 0.1,...
        vols(amer), 1, y(amer));
    option_prices(amer) = tmp(1);
    % Time in years for which the payoff of the put has been invested
    t = (today + x.num_of_days_elapsed - datenum(c.options_maturity_dates{1}))/c.dpa;
    % Risk-free rate at which the payoff of the put has been invested
    if t < min(x.rate_time_structure)
        rfr = x.zero_curve_USD(1);
    elseif t > max(x.rate_time_structure)
        rfr = x.zero_curve_USD(end);
    else
        rfr = interp1(x.rate_time_structure, x.zero_curve_USD, t);
    end
    
    option_prices(1) = max([0, K(1) - x.spot_at_expiration])*exp(t*rfr);
    % All our options are USD
    option_prices = x.USDCAD*option_prices;
end

options_value = option_prices.*c.options_positions;

end







%