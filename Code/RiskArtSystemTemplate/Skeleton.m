clc;
clear all;


%%INPUTS: 1. Historical time series for stocks, interest rates, fx rates, 
%         2. Implied vol surface (for option pricing)
%         3. Spread curves for each credit rating 
%         4. Transition matrices for credit quality  

%% Gathering Risk Factors 
equities = flipud(xlsread('data.xlsx','Stocks','B2:D649'));

underlying = xlsread('data.xlsx','Underlying','B3:D650');

impVol = xlsread('portfolio_data.xlsm','Options','K2:K4');

zeroUSD = xlsread('data.xlsx','USD','B2:P650')./100;
zeroCAD = xlsread('data.xlsx','CAD','B3:AD650')./100;
zeroCAD( :, all( isnan( zeroCAD ), 1 ) ) = []; 
zeroEUR = xlsread('data.xlsx','EUR','B2:AD650')./100;
zeroEUR( :, all( isnan( zeroEUR ), 1 ) ) = []; 

fxUSDCAD = xlsread('data.xlsx','FX','B3:B650');

fxEURCAD = xlsread('data.xlsx','FX','E3:E650');

spreads = xlsread('SpreadsbySector','Communications','L2:R16')./10^4;

% Input risk factors in seperate matrices 

riskFactors = [equities, underlying, fxUSDCAD, fxEURCAD, zeroUSD, zeroCAD, zeroEUR];

% Compute the portfolio value today using pricers

%% Principal component analysis

zeroRates = [zeroUSD, zeroCAD, zeroEUR];

% USD
S = cov(zeroUSD);

% Eigenvalue decomposition 
[QUSD, LambdaUSD] = pcacov(S);

Q1 = QUSD(:,1);
Lambda1 = LambdaUSD(1,1);
weights = zeros(size(zeroUSD,2),1);
for i=1:size(zeroUSD,2)
    weights(i) = LambdaUSD(i) ./ sum(LambdaUSD);
end
xUSD = (diag(LambdaUSD)^(-1/2) * QUSD' * zeroUSD')';

% CAD
S = cov(zeroCAD);

% Eigenvalue decomposition 
[QCAD, LambdaCAD] = pcacov(S);

Q1 = QCAD(:,1);
Lambda1 = LambdaCAD(1,1);
weights = zeros(size(zeroCAD,2),1);
for i=1:size(zeroCAD,2)
    weights(i) = LambdaCAD(i) ./ sum(LambdaCAD);
end
xCAD = (diag(LambdaCAD)^(-1/2) * QCAD' * zeroCAD')';

% EUR
S = cov(zeroEUR);

% Eigenvalue decomposition 
[QEUR, LambdaEUR] = pcacov(S);

Q1 = QEUR(:,1);
Lambda1 = LambdaEUR(1,1);
weights = zeros(size(zeroEUR,2),1);
for i=1:size(zeroEUR,2)
    weights(i) = LambdaEUR(i) ./ sum(LambdaEUR);
end
xEUR = (diag(LambdaEUR)^(-1/2) * QEUR' * zeroEUR')';

PCAriskFactors = [ xUSD(:,1), xCAD(:,1), xEUR(:,1)];

%% Computing returns 
riskFactors = [equities, underlying, fxUSDCAD, fxEURCAD, xUSD(:,1), xCAD(:,1), xEUR(:,1)];

riskFactorReturns = zeros(size(riskFactors)- [1 0]);
for i=1:size(riskFactorReturns,2);
    riskFactorReturns(:,i) = riskFactors(2:end,i)./riskFactors(1:end-1,i) - 1;
end

%% Compute correlation matrix of risk factors 

rho = corr(riskFactorReturns);

T = ...
[91.67 7.69 0.48 0.09 0.06 0.00 0.00 0.00;
0.62 90.49 8.10 0.60 0.05 0.11 0.02 0.01;
0.05 2.16 91.34 5.77 0.44 0.17 0.03 0.04;
0.02 0.22 4.07 89.71 4.68 0.80 0.20 0.29;
0.04 0.08 0.36 5.78 83.37 8.05 1.03 1.28;
0.00 0.07 0.22 0.32 5.84 82.52 4.78 6.24;
0.09 0.00 0.36 0.45 1.52 11.17 54.07 32.35;
zeros(1,7) 100] ./ 100; 

% Generate normalized correlated Gaussian random variables (can also be
% used for credit modelling) 
delta = 1/252;
T = 1; % Number of years to simulate in the future 
N = T/delta;
z = mvnrnd(zeros(1,size(riskFactors,2)), rho, N);
% Simulate all risk factors using correct models and correlations

zEquities = z(:,1:3);
zUnderlying = z(:,4:6);
zFXUSDCAD = z(:,7);
zFXEURCAD = z(:,8);
zZeroUSD = z(:,9);
zZeroCAD = z(:,10);
zZeroEUR = z(:,11);

equitiesSim = simGBM(equities(end,:)',mean(riskFactorReturns(:,1:3))'.*252,std(riskFactorReturns(:,1:3))'.*sqrt(252), zEquities, delta,T);
plot(1:252+648,[equities(:,3);equitiesSim(:,3)])

underylingSim = simGBM(underlying(end,:)',mean(riskFactorReturns(:,4:6))'.*252,std(riskFactorReturns(:,4:6))'.*sqrt(252), zUnderlying, delta,T);
plot(1:252+648,[underlying(:,3);underylingSim(:,3)])

[a1, m1, s1] = CalibrateCIR(fxUSDCAD,1/252);
[a2, m2, s2] = CalibrateCIR(fxEURCAD,1/252);

fxSim = simCIR([fxUSDCAD(end);fxEURCAD(end)],[a1;a2], [m1;m2], [s1;s2], [zFXUSDCAD,zFXEURCAD], T, delta);
plot(1:252+648,[fxUSDCAD(:);fxSim(:,1)])

[t, s, k] = CalibrateVasicek(xUSD(:,1),delta);
xSimUSD = simVas(xUSD, T, delta, zZeroUSD, t, s, k);
USDsim = (QUSD * diag(LambdaUSD)^(1/2) * xSimUSD')';

[t, s, k] = CalibrateVasicek(xCAD(:,1),delta);
xSimCAD = simVas(xCAD, T, delta, zZeroCAD, t, s, k);
CADsim = (QCAD * diag(LambdaCAD)^(1/2) * xSimCAD')';

[t, s, k] = CalibrateVasicek(xEUR(:,1),delta);
xSimEUR = simVas(xEUR, T, delta, zZeroEUR, t, s, k);
EURsim = (QEUR * diag(LambdaEUR)^(1/2) * xSimEUR')';

plot(1:252+648,[zeroCAD(:,2); CADsim(:,2)])

% Use Gaussian Copula model to model credit movements

% Compute the new price of the portfolio 

% Compute the change in price of the portfolio 