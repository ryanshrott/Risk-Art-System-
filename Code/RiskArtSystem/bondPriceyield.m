function price = bondPriceyield(quantity, notional, couponRate, frequency, daysToMat, yield, longShort)
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
%rates = interpRates(t,termTimes,zeroCurve);

%This formula works for the valuation of the continuous rate
%pricey = (notional * (couponRate/frequency)) * sum(exp(-t .* (yield))) + notional * exp(-t(end) * yield);
%This formula works for the valuation of the compunding rate
price = sum((notional * (couponRate/frequency)) ./((1 + (yield)).^t)) + notional / (1 + (yield))^t(end);

% Adjust the price based on quantity and long/short status 
if(longShort ~= 0) 
    price = quantity * price; % Long position
else 
    price = -quantity * price; % Short position
end

end