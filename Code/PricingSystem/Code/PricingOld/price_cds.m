function cds_value = price_cds(file_path)
%
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

global h_line
fprintf([h_line 'Pricing the CDS...\n' h_line])

% Initialisations
global raw_data
global column_labels

%% Read CDS data from the Excel file
sheet = 'CDS';
range = 'A1:N10';
[~, ~, raw_data] = xlsread(file_path, sheet, range);
% Read the headers of the columns to know where is what
column_labels = raw_data(1, :);
% Keep only the data related to the options
raw_data(1, :) = [];
num_of_cds = size(raw_data, 1);

% Collect all the data necessary for the CDS pricing
daysToMat = values_of('Days to Maturity');
accuracy = values_of('Accuracy');
frequency = values_of('Frequency');
notional = values_of('Notional');
spread = values_of('Spread');
recoveryRate = values_of('Recovery');
longShort = values_of('Long/Short');
longShort(longShort == 0) = -1;
quantity = values_of('Position');

lambda_times = values_of('Lambda Time Structure');
lambdaTimes = [];
for k = 1:size(lambda_times, 1)
    lambdaTimes = [lambdaTimes; str2num(lambda_times(k, :))];
end
clearvars lambda_times

zero_times = values_of('Time Structure');
zeroTermTimes = [];
for k = 1:size(zero_times, 1)
    zeroTermTimes = [zeroTermTimes; str2num(zero_times(k, :))];
end
clearvars zero_times

lambda = raw_data(:, find(strcmp(column_labels, 'Lambdas')));
tmp = [];
for k = 1:size(lambda, 1)
    tmp = [tmp; str2num(lambda{k, :})];
end
lambda = tmp;
clearvars tmp

zero_curve = values_of('Zero Coupon');
zeroCurve = [];
for k = 1:size(zero_curve, 1)
    zeroCurve = [zeroCurve; str2num(zero_curve(k, :))];
end

%% CDS pricing
cds_prices = zeros(num_of_cds, 1);

for k = 1:num_of_cds
    
    T = daysToMat(k)/Constants.dpa; % Convert days to years
    
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

cds_value = SpotFXrates.USDCAD*sum(longShort.*quantity.*cds_prices);

end

