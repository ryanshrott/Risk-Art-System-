function cds_values = price_cds(x, c)
% function price = price_cds(quantity, notional, spread, frequency, daysToMat, lambdaTimes, lambda, longShort, recoveryRate, zeroTermTimes, zeroCurve, accuracy)
%
% Description: This function outputs the price of a CDS with the following inputs:
%
% quantity = the absolute value of the position in the CDS
% notional = the principle notional on the payments
% spread = the percent of the principle notional payed to the seller
% frequency = the number of payments per year 
% daysToMat = the number of days until maturity
% lambda = the hazard rate term structure 
% lambdaTimes = the time structure of the lambda structure 
% longShort = long==1 and short==0
% recoveryRate = the recovery rate in case of default
% zeroTermTimes = the time structure of the zero rate points
% zeroCurve = a structure of zero rate points
% accuracy = Numerical integration accuracy coefficient: Choose greater
% than 30. 
%
% MODEL: This model is an extension of pricing in Hull. The
% extension is that the number of default periods can be arbitrary; so any
% level of accuracy can be calculated. 

% The number of CDS in the portfolio
num_of_cds = c.num_of_cds;

% Collect all the data necessary for the CDS pricing
daysToMat = datenum(c.CDS_maturity_dates) - repmat(...
    today + x.num_of_days_elapsed, c.num_of_cds, 1);
accuracy(num_of_cds) = c.CDS_accuracy;
accuracy(:) = accuracy(end);
frequency(num_of_cds) = c.CDS_frequency;
frequency(:) = frequency(end);
notional(num_of_cds) = c.CDS_notional;
notional(:) = notional(end);
recoveryRate(num_of_cds) = c.CDS_recovery_rate;
recoveryRate(:) = recoveryRate(end);
longShort = c.CDS_longShort;
quantity = c.CDS_positions;
spread = c.CDS_spreads;

lambdaTimes = repmat(c.CDS_lambda_times, num_of_cds, 1);

zeroTermTimes = repmat(c.CDS_time_structure, num_of_cds, 1);

lambda = c.CDS_lambda;

zeroCurve = repmat(c.CDS_zero_coupon, num_of_cds, 1);

%% CDS pricing
cds_prices = zeros(num_of_cds, 1);

for k = 1:num_of_cds
    
    T = daysToMat(k)/PortfolioConstants.dpa; % Convert days to years
    
    deltaDefault = T/accuracy(k); % default periods
    
    paymentTimes = fliplr(T:-1/frequency(k):0.001);
    
    defaultTimes = deltaDefault/2:deltaDefault:T-deltaDefault/2; % Assume default times are in the middle of default periods
    
    pSurvivalToPeriodEnd = exp(-interp(paymentTimes, lambdaTimes(k, :), lambda(k, :))'.*paymentTimes);
    
    pDefaultDuringPeriod = exp(-interp(defaultTimes-deltaDefault/2, lambdaTimes(k, :), lambda(k, :))'.*(defaultTimes-deltaDefault/2)) - exp(-interp(defaultTimes+deltaDefault/2, lambdaTimes(k, :), lambda(k, :))'.*(defaultTimes+deltaDefault/2));
    
    PVexpectedPayments = pSurvivalToPeriodEnd .* (notional(k)*spread(k)) * exp(-interp(paymentTimes, zeroTermTimes(k, :), zeroCurve(k, :)) .* paymentTimes');
    
    PVexpectedPayoff = pDefaultDuringPeriod .* (notional(k)*(1-recoveryRate(k))) * exp(-interp(defaultTimes, zeroTermTimes(k, :), zeroCurve(k, :)) .* defaultTimes');
    
    PVaccrualPayments = pDefaultDuringPeriod .* (notional(k)*deltaDefault*spread(k)) * exp(-interp(defaultTimes, zeroTermTimes(k, :), zeroCurve(k, :)) .* defaultTimes');
    
    cds_prices(k) = PVexpectedPayoff - PVexpectedPayments - PVaccrualPayments;
    
end

cds_values = x.USDCAD*longShort.*quantity.*cds_prices;

end

