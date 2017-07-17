function price = bondPrice(quantity, notional, couponRate, frequency, daysToMat, termTimes, zeroCurve, longShort)
% Description: This function outputs the price of a bond with the following inputs:

% quantity = the absolute value of the position in the CDS
% notional = the principle notional on the payments from the bond issuer 
% coupon = the percent of the principle notional payed on payment dates
% frequency = the number of payments per year 
% daysToMat = the number of days until maturity
% zeroCurve 
% longShort = long==1 and short==0

T = daysToMat/365; % Convert days to years

t = fliplr(T:-1/frequency:0.001); 
% Interpolate a term stucture 
rates = interp(t,termTimes,zeroCurve);

price = (notional * (couponRate/frequency)) * sum(exp(-t .* (rates')./100 )) + notional * exp(-t(end) * rates(end)./100);

% Adjust the price based on quantity and long/short status 
if(longShort ~= 0) 
    price = quantity * price; % Long position
else 
    price = -quantity * price; % Short position
end

end