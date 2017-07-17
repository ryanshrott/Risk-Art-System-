clc;
clear all;


%INPUTS: 1. Historical time series for stocks, interest rates, fx rates, 
%         2. Implied vol surface (for option pricing)
%         3. Spread curves for each credit rating 
%         4. Transition matrices for credit quality  

% Gathering Risk Factors 
 currentRatings = [3 4 4 5 4 2 4 3 6 4 2 4 3 3 2 3 3 3 4 1 3 4 4 3 1]; % These are the current ratings of each firm 

equities = xlsread('data.xlsx','Stocks','B6:D649');

underlying = xlsread('data.xlsx','Underlying','B7:D650');

impVol = xlsread('portfolio_data.xlsm','Options','K2:K4');

zeroUSD = xlsread('data.xlsx','USD','B6:P649')./100;
zeroCurveTimes = [3/12, 6/12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 30];

zeroCAD = xlsread('data.xlsx','CAD','B7:AD650')./100;
zeroCAD( :, all( isnan( zeroCAD ), 1 ) ) = []; 

zeroEUR = xlsread('data.xlsx','EUR','B7:AD650')./100;
zeroEUR( :, all( isnan( zeroEUR ), 1 ) ) = []; 

fxUSDCAD = xlsread('data.xlsx','FX','B7:B650');

fxEURCAD = xlsread('data.xlsx','FX','E7:E650');

spreads = xlsread('SpreadsbySector','Communications','L2:R16')./10^4;

bondSpreads = xlsread('Implied_Yield','Yield','B2:Z645');


% Inputing spread time series for each CDS

cdsGE = cleanData((xlsread('CDS HIstoric.xlsx', 'SPREAD', 'C7:J650')))./100./100;
cdsCNQCN = cleanData((xlsread('CDS HIstoric.xlsx','SPREAD', 'K7:R650')))./100./100;
cdsSABR = cleanData((xlsread('CDS HIstoric.xlsx','SPREAD', 'S7:Z650')))./100./100;
cdsHOT = cleanData((xlsread('CDS HIstoric.xlsx','SPREAD', 'AA7:AH650')))./100./100;
cdsFOXA = cleanData((xlsread('CDS HIstoric.xlsx','SPREAD', 'AI7:AP650')))./100./100;
cdsFRANCE = cleanData((xlsread('CDS HIstoric.xlsx','SPREAD', 'AQ7:AX650')))./100./100;
cdsCAT = cleanData((xlsread('CDS HIstoric.xlsx','SPREAD', 'AY7:BF650')))./100./100;
cdsWFC = cleanData((xlsread('CDS HIstoric.xlsx','SPREAD', 'BG7:BN650')))./100./100;
cdsHUNT = cleanData((xlsread('CDS HIstoric.xlsx','SPREAD', 'BO7:BV650')))./100./100;


% Convert to hazard rates
lambdaGE = cdsGE ./ (1-0.4);
lambdaCNQCN = cdsCNQCN ./ (1-0.4);
lambdaSABR = cdsSABR ./ (1-0.4);
lambdaHOT = cdsHOT ./ (1-0.4);
lambdaFOXA = cdsFOXA ./ (1-0.4);
lambdaFRANCE = cdsFRANCE ./ (1-0.4);
lambdaCAT = cdsCAT ./ (1-0.4);
lambdaCAT(1,6) = lambdaCAT(2,6)+0.0001;
lambdaWFC = cdsWFC ./ (1-0.4);
lambdaHUNT = cdsHUNT ./ (1-0.4);

lambda = [lambdaGE(end,:); lambdaCNQCN(end,:); lambdaSABR(end,:); lambdaHOT(end,:); lambdaFOXA(end,:); lambdaFRANCE(end,:);...
          lambdaCAT(end,:); lambdaWFC(end,:); lambdaHUNT(end,:)];
      
bondSpreads = xlsread('Implied_Yield','Yield','B2:Z645');

%Input risk factors in seperate matrices 

riskFactors = [equities, underlying, fxUSDCAD, fxEURCAD, zeroUSD, zeroCAD, zeroEUR, lambdaGE, lambdaCNQCN, lambdaSABR, lambdaHOT...
               lambdaFOXA, lambdaFRANCE, lambdaCAT, lambdaWFC,lambdaHUNT, bondSpreads];


% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]); 
z.BONDS = 1;
z.CDS = 1;
z.OPTIONS = 1;
z.STOCKS = 1;
z.historical_implied_spreads = bondSpreads(end,:);

[p0, bonds_valueZERO, options_valueZERO, stocks_valueZERO, cds_valuesZERO] = price(z);

%% Principal component analysis

zeroRates = [zeroUSD, zeroCAD, zeroEUR];

% USD
S = cov(zeroUSD);

% Eigenvalue decomposition 
[QUSD, LambdaUSD] = pcacov(S);

Q1 = QUSD(:,1);
Lambda1 = LambdaUSD(1,1);
weights = zeros(size(zeroUSD,2),1);
for y=1:size(zeroUSD,2)
    weights(y) = LambdaUSD(y) ./ sum(LambdaUSD);
end
xUSD = (diag(LambdaUSD)^(-1/2) * QUSD' * zeroUSD')';

% CAD
S = cov(zeroCAD);

% Eigenvalue decomposition 
[QCAD, LambdaCAD] = pcacov(S);

Q1 = QCAD(:,1);
Lambda1 = LambdaCAD(1,1);
weights = zeros(size(zeroCAD,2),1);
for y=1:size(zeroCAD,2)
    weights(y) = LambdaCAD(y) ./ sum(LambdaCAD);
end
xCAD = (diag(LambdaCAD)^(-1/2) * QCAD' * zeroCAD')';

% EUR
S = cov(zeroEUR);

% Eigenvalue decomposition 
[QEUR, LambdaEUR] = pcacov(S);

Q1 = QEUR(:,1);
Lambda1 = LambdaEUR(1,1);
weights = zeros(size(zeroEUR,2),1);
for y=1:size(zeroEUR,2)
    weights(y) = LambdaEUR(y) ./ sum(LambdaEUR);
end
xEUR = (diag(LambdaEUR)^(-1/2) * QEUR' * zeroEUR')';

PCAriskFactors = [ xUSD(:,1), xCAD(:,1), xEUR(:,1)];

%% Computing returns 

riskFactors = [equities, underlying, fxUSDCAD, fxEURCAD, xUSD(:,1), xCAD(:,1), xEUR(:,1), lambdaGE, lambdaCNQCN, lambdaSABR, lambdaHOT...
               lambdaFOXA, lambdaFRANCE, lambdaCAT, lambdaWFC,lambdaHUNT, bondSpreads];

riskFactorReturns = zeros(size(riskFactors)- [1 0]);
for y=1:83;
    riskFactorReturns(:,y) = riskFactors(2:end,y)./riskFactors(1:end-1,y) - 1;
end
for y=84:108;
    riskFactorReturns(:,y) = riskFactors(2:end,y)./riskFactors(1:end-1,y) - 1;
end
%% Compute correlation matrix of risk factors 

rho = corr(riskFactorReturns);

% Generate normalized correlated Gaussian random variables (can also be
% used for credit modelling) 
delta = 1/252;
T = 1; % Number of years to simulate in the future 
N = T/delta;
nSims = 200;

prices = zeros(nSims,1);

counterPartyRatings =[2 4 4 4 4 4 3 3 6];
impLambda = c.CDS_lambda;
lambdaTimes = c.CDS_lambda_times;


for i=1:nSims

zz = mvnrnd(zeros(1,size(riskFactorReturns,2)), rho, N);
% Simulate all risk factors using correct models and correlations

zEquities = zz(:,1:3);
zUnderlying = zz(:,4:6);
zFXUSDCAD = zz(:,7);
zFXEURCAD = zz(:,8);
zZeroUSD = zz(:,9);
zZeroCAD = zz(:,10);
zZeroEUR = zz(:,11);
zLambda = zz(:,12:83);
zBondSpreads = zz(:,84:end);

x = 12:83;
lambdaSim = simGBM(riskFactors(end,x)',mean(riskFactorReturns(:,x))'.*252, std(riskFactorReturns(:,x))'.*sqrt(252), zLambda, delta,T);
plot(1:252+644,[riskFactors(:, x);lambdaSim(:,1:length(x))])

bondSpreadSim = simGBM(riskFactors(end,84:end)',mean(riskFactorReturns(:,84:end))'.*252, std(riskFactorReturns(:,84:end))'.*sqrt(252), zBondSpreads, delta,T);

plot(1:252+644,[riskFactors(:, 84:108);bondSpreadSim(:,1:length(84:108))])

equitiesSim = simGBM(equities(end,:)',mean(riskFactorReturns(:,1:3))'.*252,std(riskFactorReturns(:,1:3))'.*sqrt(252), zEquities, delta,T);

underylingSim = simGBM(underlying(end,:)',mean(riskFactorReturns(:,4:6))'.*252,std(riskFactorReturns(:,4:6))'.*sqrt(252), zUnderlying, delta,T);

[a1, m1, s1] = CalibrateCIR(fxUSDCAD,1/252);
[a2, m2, s2] = CalibrateCIR(fxEURCAD,1/252);

fxSim = simCIR([fxUSDCAD(end);fxEURCAD(end)],[a1;a2], [m1;m2], [s1;s2], [zFXUSDCAD,zFXEURCAD], T, delta);

[t, s, k] = CalibrateVasicek(xUSD(:,1),delta);
xSimUSD = simVas(xUSD, T, delta, zZeroUSD, t, s, k);
USDsim = (QUSD * diag(LambdaUSD)^(1/2) * xSimUSD')';

[t, s, k] = CalibrateVasicek(xCAD(:,1),delta);
xSimCAD = simVas(xCAD, T, delta, zZeroCAD, t, s, k);
CADsim = (QCAD * diag(LambdaCAD)^(1/2) * xSimCAD')';

[t, s, k] = CalibrateVasicek(xEUR(:,1),delta);
xSimEUR = simVas(xEUR, T, delta, zZeroEUR, t, s, k);
EURsim = (QEUR * diag(LambdaEUR)^(1/2) * xSimEUR')';


daysToExp = wrkdydif('7/11/2016', '10/24/2016', 1);
spot_at_expiration = equitiesSim(daysToExp/252/delta,1);

x = PricingInput(1, equitiesSim(end,:)', USDsim(end,1), underylingSim(end,:)', spot_at_expiration, impVol, USDsim(end,:), CADsim(end,:), EURsim(end,:), zeroCurveTimes,...
                fxSim(end,1), fxSim(end,2), currentRatings, [zeros(9,1), reshape(lambdaSim(end,:),8,9)']);

x.historical_implied_spreads = bondSpreadSim(end,:);
[prices(i), ~, ~, ~, cds] = price(x);

end


deltaP = prices - p0;

hist(deltaP);

VaR99 = prctile(deltaP, 1);
VaR95 = prctile(deltaP, 5);
CVaR99 = mean(deltaP(deltaP < VaR99));
CVaR95 = mean(deltaP(deltaP < VaR95));


%% Credit Modelling of Sectors
% Here we assume perfect correlation between companies in a given sector 
% Order is Communications, Financial, G
currentRatings = [3 4 4 5 4 2 4 3 6 4 2 4 3 3 2 3 3 3 4 1 3 4 4 3 1]; % These are the current ratings of each firm 

%rho = xlsread('portfolio_data (CR).xlsm', 'CreditRisk', 'AD78:BB102');

nFirms = length(currentRatings);
nSectors = 5;
Trans = ...
[100.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00;
0.30	95.21	4.49	0.00	0.00	0.00	0.00	0.00;
0.00	1.48	92.87	5.65	0.00	0.00	0.00	0.00;
0.00	0.06	3.33	91.37	5.24	0.00	0.00	0.00;
0.00	0.00	0.00	3.99	88.00	7.56	0.26	0.18;
0.00	0.00	0.00	0.17	4.13	87.67	5.27	2.76;
0.00	0.00	0.00	0.00	0.00	7.20	61.15	31.65;
zeros(1,7) 100] ./ 100; 

n = 1000;
x = zeros(n,2);
% Use Gaussian Copula model to model credit movements
w = zeros(n,1);
for i=1:n
    w(i) = 1;
y = i/n;
x(i,1) = y;
rho = [1	y	0.368	0.124	0.368	-0.314	0.124	y	0.368	0.368	0.124	0.368	0.124	0.124	0.124	0.124	0.124	0.124	y	0.124	0.124	0.368	0.368	0.01	0.124;
y	1	0.368	0.124	0.368	-0.314	0.124	y	0.368	0.368	0.124	0.368	0.124	0.124	0.124	0.124	0.124	0.124	y	0.124	0.124	0.368	0.368	0.01	0.124;
0.368	0.368	1	-0.672	y	-0.964	-0.672	0.368	y	y	-0.672	y	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	y	y	0.844	-0.672;
0.124	0.124	-0.672	1	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.368	0.368	y	-0.672	1	-0.964	-0.672	0.368	y	y	-0.672	y	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	y	y	0.844	-0.672;
-0.314	-0.314	-0.964	0.561	-0.964	1	0.561	-0.314	-0.964	-0.964	0.561	-0.964	0.561	0.561	0.561	0.561	0.561	0.561	-0.314	0.561	0.561	-0.964	-0.964	-0.874	0.561;
0.124	0.124	-0.672	y	-0.672	0.561	1	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
y	y	0.368	0.124	0.368	-0.314	0.124	1	0.368	0.368	0.124	0.368	0.124	0.124	0.124	0.124	0.124	0.124	y	0.124	0.124	0.368	0.368	0.01	0.124;
0.368	0.368	y	-0.672	y	-0.964	-0.672	0.368	1	y	-0.672	y	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	y	y	0.844	-0.672;
0.368	0.368	y	-0.672	y	-0.964	-0.672	0.368	y	1	-0.672	y	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	y	y	0.844	-0.672;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	1	-0.672	y	y	y	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.368	0.368	y	-0.672	y	-0.964	-0.672	0.368	y	y	-0.672	1	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	y	y	0.844	-0.672;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	1	y	y	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	1	y	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	1	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	1	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	1	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	y	1	0.124	y	y	-0.672	-0.672	-0.67	y;
y	y	0.368	0.124	0.368	-0.314	0.124	y	0.368	0.368	0.124	0.368	0.124	0.124	0.124	0.124	0.124	0.124	1	0.124	0.124	0.368	0.368	0.01	0.124;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	y	y	0.124	1	y	-0.672	-0.672	-0.67	y;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	y	y	0.124	y	1	-0.672	-0.672	-0.67	y;
0.368	0.368	y	-0.672	y	-0.964	-0.672	0.368	y	y	-0.672	y	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	1	y	0.844	-0.672;
0.368	0.368	y	-0.672	y	-0.964	-0.672	0.368	y	y	-0.672	y	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	y	1	0.844	-0.672;
0.01	0.01	0.844	-0.67	0.844	-0.874	-0.67	0.01	0.844	0.844	-0.67	0.844	-0.67	-0.67	-0.67	-0.67	-0.67	-0.67	0.01	-0.67	-0.67	0.844	0.844	1	-0.67;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	1;];


if(sum(eig(rho) < 0) > 0)
    x(i,2) = 0;
else
    x(i,2) = 1;
end

end

y = 0.9734;
rho = [1	y	0.368	0.124	0.368	-0.314	0.124	y	0.368	0.368	0.124	0.368	0.124	0.124	0.124	0.124	0.124	0.124	y	0.124	0.124	0.368	0.368	0.01	0.124;
y	1	0.368	0.124	0.368	-0.314	0.124	y	0.368	0.368	0.124	0.368	0.124	0.124	0.124	0.124	0.124	0.124	y	0.124	0.124	0.368	0.368	0.01	0.124;
0.368	0.368	1	-0.672	y	-0.964	-0.672	0.368	y	y	-0.672	y	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	y	y	0.844	-0.672;
0.124	0.124	-0.672	1	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.368	0.368	y	-0.672	1	-0.964	-0.672	0.368	y	y	-0.672	y	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	y	y	0.844	-0.672;
-0.314	-0.314	-0.964	0.561	-0.964	1	0.561	-0.314	-0.964	-0.964	0.561	-0.964	0.561	0.561	0.561	0.561	0.561	0.561	-0.314	0.561	0.561	-0.964	-0.964	-0.874	0.561;
0.124	0.124	-0.672	y	-0.672	0.561	1	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
y	y	0.368	0.124	0.368	-0.314	0.124	1	0.368	0.368	0.124	0.368	0.124	0.124	0.124	0.124	0.124	0.124	y	0.124	0.124	0.368	0.368	0.01	0.124;
0.368	0.368	y	-0.672	y	-0.964	-0.672	0.368	1	y	-0.672	y	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	y	y	0.844	-0.672;
0.368	0.368	y	-0.672	y	-0.964	-0.672	0.368	y	1	-0.672	y	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	y	y	0.844	-0.672;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	1	-0.672	y	y	y	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.368	0.368	y	-0.672	y	-0.964	-0.672	0.368	y	y	-0.672	1	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	y	y	0.844	-0.672;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	1	y	y	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	1	y	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	1	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	1	y	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	1	y	0.124	y	y	-0.672	-0.672	-0.67	y;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	y	1	0.124	y	y	-0.672	-0.672	-0.67	y;
y	y	0.368	0.124	0.368	-0.314	0.124	y	0.368	0.368	0.124	0.368	0.124	0.124	0.124	0.124	0.124	0.124	1	0.124	0.124	0.368	0.368	0.01	0.124;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	y	y	0.124	1	y	-0.672	-0.672	-0.67	y;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	y	y	0.124	y	1	-0.672	-0.672	-0.67	y;
0.368	0.368	y	-0.672	y	-0.964	-0.672	0.368	y	y	-0.672	y	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	1	y	0.844	-0.672;
0.368	0.368	y	-0.672	y	-0.964	-0.672	0.368	y	y	-0.672	y	-0.672	-0.672	-0.672	-0.672	-0.672	-0.672	0.368	-0.672	-0.672	y	1	0.844	-0.672;
0.01	0.01	0.844	-0.67	0.844	-0.874	-0.67	0.01	0.844	0.844	-0.67	0.844	-0.67	-0.67	-0.67	-0.67	-0.67	-0.67	0.01	-0.67	-0.67	0.844	0.844	1	-0.67;
0.124	0.124	-0.672	y	-0.672	0.561	y	0.124	-0.672	-0.672	y	-0.672	y	y	y	y	y	y	0.124	y	y	-0.672	-0.672	-0.67	1;];

eig(rho)

cumT = cumsum(Trans,2);

cumT(:,end) = ones(8,1);

transitionValues = norminv(cumT);

transitionValues(isnan( transitionValues )) = inf;

% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = equities(end,1);

x = PricingInput(1,equities(end,:)',zeroUSD(end,1), underlying(end,:)', spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]);
x.historical_implied_spreads = bondSpreads(end,:);
  
p0 = price(x);

nSims = 500;
sims = mvnrnd(zeros(nFirms,1),rho, nSims);
futureRatings = zeros(nSims,nFirms);

prices = zeros(nSims,1);

x.num_of_days_elapsed = 1;
for i=1:nSims
    futureRatings(i,:) = simRating(sims(i,:), currentRatings, transitionValues);
    x.bond_ratings = futureRatings(i,:);
    prices(i) = price(x);
end
hist(prices - p0,64);

CreditVaR99 = prctile(prices - p0, 1);
CreditVaR95 = prctile(prices - p0, 5);
CreditVar999 = prctile(prices - p0, 0.1);

% Compute the new price of the portfolio 

% Compute the change in price of the portfolio 