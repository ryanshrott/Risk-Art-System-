% CDS Vetting 
clc;
clear all;

quantity = 4;
notional = 10000000;
spread = 0.0565;
frequency = 0.25;
daysToMat = 1278;
longShort = 1;
recoveryRate = 0.4;
accuracy = 30;


% USD Term Strucure 
zeroCurve = [0.38	0.3928	0.384	0.37	0.3703	0.3765	0.3812	0.3946	0.4011	0.4094	0.4332	0.4512	0.4925	0.528	0.597	0.683	0.76	1.123];
zeroTermTimes = [0.00	0.02	0.04	0.06	0.08	0.17	0.25	0.33	0.42	0.50	0.75	1.00	1.50	2.00	3.00	4.00	5.00	10.00];
lambda = [ 0 0.1725	0.315	0.6025	0.73	0.8875	1.1125	1.5575	2.055];
lambdaTimes = [0 0.5 1 2 3 4 5 7 10];
T = daysToMat/365; % Convert days to years
deltaDefault = T/accuracy; % default periods 
paymentTimes = fliplr(T:-1/frequency:0.001); 
defaultTimes = deltaDefault/2:deltaDefault:T-deltaDefault/2; % Assume default times are in the middle of default periods
pSurvivalToPeriodEnd = exp(-interp(paymentTimes, lambdaTimes, lambda)'.*paymentTimes); 

pDefaultDuringPeriod = exp(-interp(defaultTimes-deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes-deltaDefault/2)) - exp(-interp(defaultTimes+deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes+deltaDefault/2));

PVexpectedPayments = pSurvivalToPeriodEnd .* (notional*spread) * exp(-interp(paymentTimes, zeroTermTimes, zeroCurve) .* paymentTimes');

PVexpectedPayoff = pDefaultDuringPeriod .* (notional*(1-recoveryRate)) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

PVaccrualPayments = pDefaultDuringPeriod .* (notional*deltaDefault*spread) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

price = PVexpectedPayoff - PVexpectedPayments - PVaccrualPayments;

%cPrice = cdsPrice(quantity, notional, spread, frequency, daysToMat, lambdaTimes, lambda, longShort, recoveryRate, zeroTermTimes, zeroCurve, accuracy);

%%
quantity = 2;
notional = 10000000;
spread = 0.0447;
frequency = 0.25;
daysToMat = 1461;
longShort = 0;
recoveryRate = 0.4;
accuracy = 30;
zeroCurve = [0.38	0.3928	0.384	0.37	0.3703	0.3765	0.3812	0.3946	0.4011	0.4094	0.4332	0.4512	0.4925	0.528	0.597	0.683	0.76	1.123];
zeroTermTimes = [0.00	0.02	0.04	0.06	0.08	0.17	0.25	0.33	0.42	0.50	0.75	1.00	1.50	2.00	3.00	4.00	5.00	10.00];
lambda = [ 0 1.23	1.6875	3.1375	4.2125	5.125	6.5025	8.415	9.22];
lambdaTimes = [0 0.5 1 2 3 4 5 7 10];
T = daysToMat/365; % Convert days to years
deltaDefault = T/accuracy; % default periods 
paymentTimes = fliplr(T:-1/frequency:0.001); 
defaultTimes = deltaDefault/2:deltaDefault:T-deltaDefault/2; % Assume default times are in the middle of default periods
pSurvivalToPeriodEnd = exp(-interp(paymentTimes, lambdaTimes, lambda)'.*paymentTimes); 

pDefaultDuringPeriod = exp(-interp(defaultTimes-deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes-deltaDefault/2)) - exp(-interp(defaultTimes+deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes+deltaDefault/2));

PVexpectedPayments = pSurvivalToPeriodEnd .* (notional*spread) * exp(-interp(paymentTimes, zeroTermTimes, zeroCurve) .* paymentTimes');

PVexpectedPayoff = pDefaultDuringPeriod .* (notional*(1-recoveryRate)) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

PVaccrualPayments = pDefaultDuringPeriod .* (notional*deltaDefault*spread) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

price2 = PVexpectedPayoff - PVexpectedPayments - PVaccrualPayments;

%%
quantity = 3;
notional = 10000000;
spread = 0.05;
frequency = 0.25;
daysToMat = 183;
longShort = 1;
recoveryRate = 0.4;
accuracy = 30;
zeroCurve = [0.38	0.3928	0.384	0.37	0.3703	0.3765	0.3812	0.3946	0.4011	0.4094	0.4332	0.4512	0.4925	0.528	0.597	0.683	0.76	1.123];
zeroTermTimes = [0.00	0.02	0.04	0.06	0.08	0.17	0.25	0.33	0.42	0.50	0.75	1.00	1.50	2.00	3.00	4.00	5.00	10.00];
lambda = [ 0 0.5675	0.7075	1.2925	1.9575	2.625	3.375	4.7375	5.22];
lambdaTimes = [0 0.5 1 2 3 4 5 7 10];
T = daysToMat/365; % Convert days to years
deltaDefault = T/accuracy; % default periods 
paymentTimes = fliplr(T:-1/frequency:0.001); 
defaultTimes = deltaDefault/2:deltaDefault:T-deltaDefault/2; % Assume default times are in the middle of default periods
pSurvivalToPeriodEnd = exp(-interp(paymentTimes, lambdaTimes, lambda)'.*paymentTimes); 

pDefaultDuringPeriod = exp(-interp(defaultTimes-deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes-deltaDefault/2)) - exp(-interp(defaultTimes+deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes+deltaDefault/2));

PVexpectedPayments = pSurvivalToPeriodEnd .* (notional*spread) * exp(-interp(paymentTimes, zeroTermTimes, zeroCurve) .* paymentTimes');

PVexpectedPayoff = pDefaultDuringPeriod .* (notional*(1-recoveryRate)) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

PVaccrualPayments = pDefaultDuringPeriod .* (notional*deltaDefault*spread) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

price3 = PVexpectedPayoff - PVexpectedPayments - PVaccrualPayments;

%%
quantity = 2;
notional = 10000000;
spread = 0.0335;
frequency = 0.25;
daysToMat = 183;
longShort = 1;
recoveryRate = 0.4;
accuracy = 30;
zeroCurve = [0.38	0.3928	0.384	0.37	0.3703	0.3765	0.3812	0.3946	0.4011	0.4094	0.4332	0.4512	0.4925	0.528	0.597	0.683	0.76	1.123];
zeroTermTimes = [0.00	0.02	0.04	0.06	0.08	0.17	0.25	0.33	0.42	0.50	0.75	1.00	1.50	2.00	3.00	4.00	5.00	10.00];
lambda = [ 0 0.1275	0.14	0.22	0.365	0.54	0.7025	1.1525	1.37];
lambdaTimes = [0 0.5 1 2 3 4 5 7 10];
T = daysToMat/365; % Convert days to years
deltaDefault = T/accuracy; % default periods 
paymentTimes = fliplr(T:-1/frequency:0.001); 
defaultTimes = deltaDefault/2:deltaDefault:T-deltaDefault/2; % Assume default times are in the middle of default periods
pSurvivalToPeriodEnd = exp(-interp(paymentTimes, lambdaTimes, lambda)'.*paymentTimes); 

pDefaultDuringPeriod = exp(-interp(defaultTimes-deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes-deltaDefault/2)) - exp(-interp(defaultTimes+deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes+deltaDefault/2));

PVexpectedPayments = pSurvivalToPeriodEnd .* (notional*spread) * exp(-interp(paymentTimes, zeroTermTimes, zeroCurve) .* paymentTimes');

PVexpectedPayoff = pDefaultDuringPeriod .* (notional*(1-recoveryRate)) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

PVaccrualPayments = pDefaultDuringPeriod .* (notional*deltaDefault*spread) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

price4 = PVexpectedPayoff - PVexpectedPayments - PVaccrualPayments;

%%
quantity = 4;
notional = 10000000;
spread = 0.0135;
frequency = 0.25;
daysToMat = 183;
longShort = 1;
recoveryRate = 0.4;
accuracy = 30;
zeroCurve = [0.38	0.3928	0.384	0.37	0.3703	0.3765	0.3812	0.3946	0.4011	0.4094	0.4332	0.4512	0.4925	0.528	0.597	0.683	0.76	1.123];
zeroTermTimes = [0.00	0.02	0.04	0.06	0.08	0.17	0.25	0.33	0.42	0.50	0.75	1.00	1.50	2.00	3.00	4.00	5.00	10.00];
lambda = [ 0 0.13225	0.1435	0.3015	0.543125	0.760125	1.052775	1.646625	2.07475]; %Lambdas from FOX
lambdaTimes = [0 0.5 1 2 3 4 5 7 10];
T = daysToMat/365; % Convert days to years
deltaDefault = T/accuracy; % default periods 
paymentTimes = fliplr(T:-1/frequency:0.001); 
defaultTimes = deltaDefault/2:deltaDefault:T-deltaDefault/2; % Assume default times are in the middle of default periods
pSurvivalToPeriodEnd = exp(-interp(paymentTimes, lambdaTimes, lambda)'.*paymentTimes); 

pDefaultDuringPeriod = exp(-interp(defaultTimes-deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes-deltaDefault/2)) - exp(-interp(defaultTimes+deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes+deltaDefault/2));

PVexpectedPayments = pSurvivalToPeriodEnd .* (notional*spread) * exp(-interp(paymentTimes, zeroTermTimes, zeroCurve) .* paymentTimes');

PVexpectedPayoff = pDefaultDuringPeriod .* (notional*(1-recoveryRate)) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

PVaccrualPayments = pDefaultDuringPeriod .* (notional*deltaDefault*spread) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

price5 = PVexpectedPayoff - PVexpectedPayments - PVaccrualPayments;

%%
quantity = 4;
notional = 10000000;
spread = 0.0103;
frequency = 0.25;
daysToMat = 822;
longShort = 0;
recoveryRate = 0.4;
accuracy = 30;
zeroCurve = [0.38	0.3928	0.384	0.37	0.3703	0.3765	0.3812	0.3946	0.4011	0.4094	0.4332	0.4512	0.4925	0.528	0.597	0.683	0.76	1.123];
zeroTermTimes = [0.00	0.02	0.04	0.06	0.08	0.17	0.25	0.33	0.42	0.50	0.75	1.00	1.50	2.00	3.00	4.00	5.00	10.00];
lambda = [ 0 0.1275	0.14	0.22	0.365	0.54	0.7025	1.1525	1.37]; %Wrong Lambdas
lambdaTimes = [0 0.5 1 2 3 4 5 7 10];
T = daysToMat/365; % Convert days to years
deltaDefault = T/accuracy; % default periods 
paymentTimes = fliplr(T:-1/frequency:0.001); 
defaultTimes = deltaDefault/2:deltaDefault:T-deltaDefault/2; % Assume default times are in the middle of default periods
pSurvivalToPeriodEnd = exp(-interp(paymentTimes, lambdaTimes, lambda)'.*paymentTimes); 

pDefaultDuringPeriod = exp(-interp(defaultTimes-deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes-deltaDefault/2)) - exp(-interp(defaultTimes+deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes+deltaDefault/2));

PVexpectedPayments = pSurvivalToPeriodEnd .* (notional*spread) * exp(-interp(paymentTimes, zeroTermTimes, zeroCurve) .* paymentTimes');

PVexpectedPayoff = pDefaultDuringPeriod .* (notional*(1-recoveryRate)) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

PVaccrualPayments = pDefaultDuringPeriod .* (notional*deltaDefault*spread) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

price6 = PVexpectedPayoff - PVexpectedPayments - PVaccrualPayments;
%%
quantity = 3;
notional = 10000000;
spread = 0.0089;
frequency = 0.25;
daysToMat = 1278;
longShort = 0;
recoveryRate = 0.4;
accuracy = 30;
zeroCurve = [0.38	0.3928	0.384	0.37	0.3703	0.3765	0.3812	0.3946	0.4011	0.4094	0.4332	0.4512	0.4925	0.528	0.597	0.683	0.76	1.123];
zeroTermTimes = [0.00	0.02	0.04	0.06	0.08	0.17	0.25	0.33	0.42	0.50	0.75	1.00	1.50	2.00	3.00	4.00	5.00	10.00];
lambda = [ 0 0.23	0.35	0.65	1.025	1.55	2.125	2.95	3.3675]; 
lambdaTimes = [0 0.5 1 2 3 4 5 7 10];
T = daysToMat/365; % Convert days to years
deltaDefault = T/accuracy; % default periods 
paymentTimes = fliplr(T:-1/frequency:0.001); 
defaultTimes = deltaDefault/2:deltaDefault:T-deltaDefault/2; % Assume default times are in the middle of default periods
pSurvivalToPeriodEnd = exp(-interp(paymentTimes, lambdaTimes, lambda)'.*paymentTimes); 

pDefaultDuringPeriod = exp(-interp(defaultTimes-deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes-deltaDefault/2)) - exp(-interp(defaultTimes+deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes+deltaDefault/2));

PVexpectedPayments = pSurvivalToPeriodEnd .* (notional*spread) * exp(-interp(paymentTimes, zeroTermTimes, zeroCurve) .* paymentTimes');

PVexpectedPayoff = pDefaultDuringPeriod .* (notional*(1-recoveryRate)) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

PVaccrualPayments = pDefaultDuringPeriod .* (notional*deltaDefault*spread) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

price7 = PVexpectedPayoff - PVexpectedPayments - PVaccrualPayments;
%%
quantity = 1;
notional = 10000000;
spread = 0.0115;
frequency = 0.25;
daysToMat = 1826;
longShort = 1;
recoveryRate = 0.4;
accuracy = 30;
zeroCurve = [0.38	0.3928	0.384	0.37	0.3703	0.3765	0.3812	0.3946	0.4011	0.4094	0.4332	0.4512	0.4925	0.528	0.597	0.683	0.76	1.123];
zeroTermTimes = [0.00	0.02	0.04	0.06	0.08	0.17	0.25	0.33	0.42	0.50	0.75	1.00	1.50	2.00	3.00	4.00	5.00	10.00];
lambda = [ 0 0.4225	0.5025	0.7925	1.0375	1.27	1.59	1.9925	2.425]; 
lambdaTimes = [0 0.5 1 2 3 4 5 7 10];
T = daysToMat/365; % Convert days to years
deltaDefault = T/accuracy; % default periods 
paymentTimes = fliplr(T:-1/frequency:0.001); 
defaultTimes = deltaDefault/2:deltaDefault:T-deltaDefault/2; % Assume default times are in the middle of default periods
pSurvivalToPeriodEnd = exp(-interp(paymentTimes, lambdaTimes, lambda)'.*paymentTimes); 

pDefaultDuringPeriod = exp(-interp(defaultTimes-deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes-deltaDefault/2)) - exp(-interp(defaultTimes+deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes+deltaDefault/2));

PVexpectedPayments = pSurvivalToPeriodEnd .* (notional*spread) * exp(-interp(paymentTimes, zeroTermTimes, zeroCurve) .* paymentTimes');

PVexpectedPayoff = pDefaultDuringPeriod .* (notional*(1-recoveryRate)) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

PVaccrualPayments = pDefaultDuringPeriod .* (notional*deltaDefault*spread) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

price8 = PVexpectedPayoff - PVexpectedPayments - PVaccrualPayments;

%%
quantity = 1;
notional = 10000000;
spread = 0.05;
frequency = 0.25;
daysToMat = 365;
longShort = 1;
recoveryRate = 0.4;
accuracy = 30;
zeroCurve = [0.38	0.3928	0.384	0.37	0.3703	0.3765	0.3812	0.3946	0.4011	0.4094	0.4332	0.4512	0.4925	0.528	0.597	0.683	0.76	1.123];
zeroTermTimes = [0.00	0.02	0.04	0.06	0.08	0.17	0.25	0.33	0.42	0.50	0.75	1.00	1.50	2.00	3.00	4.00	5.00	10.00];
lambda = [ 0 0.13225	0.1435	0.3015	0.543125	0.760125	1.052775	1.646625	2.07475]; %Wrong Lambdas
lambdaTimes = [0 0.5 1 2 3 4 5 7 10];
T = daysToMat/365; % Convert days to years
deltaDefault = T/accuracy; % default periods 
paymentTimes = fliplr(T:-1/frequency:0.001); 
defaultTimes = deltaDefault/2:deltaDefault:T-deltaDefault/2; % Assume default times are in the middle of default periods
pSurvivalToPeriodEnd = exp(-interp(paymentTimes, lambdaTimes, lambda)'.*paymentTimes); 

pDefaultDuringPeriod = exp(-interp(defaultTimes-deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes-deltaDefault/2)) - exp(-interp(defaultTimes+deltaDefault/2, lambdaTimes, lambda)'.*(defaultTimes+deltaDefault/2));

PVexpectedPayments = pSurvivalToPeriodEnd .* (notional*spread) * exp(-interp(paymentTimes, zeroTermTimes, zeroCurve) .* paymentTimes');

PVexpectedPayoff = pDefaultDuringPeriod .* (notional*(1-recoveryRate)) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

PVaccrualPayments = pDefaultDuringPeriod .* (notional*deltaDefault*spread) * exp(-interp(defaultTimes, zeroTermTimes, zeroCurve) .* defaultTimes');

price9 = PVexpectedPayoff - PVexpectedPayments - PVaccrualPayments;