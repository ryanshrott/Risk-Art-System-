clc;
clear all;


%INPUTS: 1. Historical time series for stocks, interest rates, fx rates, 
%         2. Implied vol surface (for option pricing)
%         3. Spread curves for each credit rating 
%         4. Transition matrices for credit quality  

% Gathering Risk Factors 
currentRatings = [4	 4	6	4	4	4	4	3	4	4	3	5	1	1	4	2	3	3	3	2	3]; % These are the current ratings of each firm 

equities = flipud(xlsread('data.xlsx','Stocks','B2:D649'));

underlying = xlsread('data.xlsx','Underlying','B3:D650');

impVol = xlsread('portfolio_data.xlsm','Options','K2:K4');

zeroUSD = xlsread('data.xlsx','USD','B2:P650')./100;
zeroCurveTimes = [3/12, 6/12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 30];

zeroCAD = xlsread('data.xlsx','CAD','B3:AD650')./100;
zeroCAD( :, all( isnan( zeroCAD ), 1 ) ) = []; 

zeroEUR = xlsread('data.xlsx','EUR','B2:AD650')./100;
zeroEUR( :, all( isnan( zeroEUR ), 1 ) ) = []; 

fxUSDCAD = xlsread('data.xlsx','FX','B3:B650');

fxEURCAD = xlsread('data.xlsx','FX','E3:E650');

spreads = xlsread('SpreadsbySector','Communications','L2:R16')./10^4;

% Inputing spread time series for each CDS

cdsGE = cleanData(flipud(xlsread('CDS HIstoric.xlsx', 'GE', 'B2:I758')))./100./100;
cdsCNQCN = flipud(xlsread('CDS HIstoric.xlsx','CNQCN', 'B2:I786'))./100./100;

input = [1, 2, 2, 5 4; 2 3 NaN NaN 3; 7 4 9 10 4; 4 5 5 11 5];

x = cleanData(cdsCNQCN);

%Input risk factors in seperate matrices 

riskFactors = [equities, underlying, fxUSDCAD, fxEURCAD, zeroUSD, zeroCAD, zeroEUR];

% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings);
z.BONDS = 1;
z.CDS = 1;
z.OPTIONS = 1;
z.STOCKS = 1;

[p0, ~, ~, ~, cdsZ] = price(z);


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
riskFactors = [xUSD(:,1), xCAD(:,1), xEUR(:,1)];

riskFactorReturns = zeros(size(riskFactors)- [1 0]);
for y=1:size(riskFactorReturns,2);
    riskFactorReturns(:,y) = riskFactors(2:end,y)./riskFactors(1:end-1,y) - 1;
end

%% Compute correlation matrix of risk factors 

rho = corr(riskFactorReturns);

% Generate normalized correlated Gaussian random variables (can also be
% used for credit modelling) 
delta = 1/252;
T = 1; % Number of years to simulate in the future 
N = T/delta;
nSims = 10;

prices = zeros(nSims,1);

counterPartyRatings =[2 4 4 4 4 4 3 3 6];
impLambda = c.CDS_lambda;
lambdaTimes = c.CDS_lambda_times;

exposures = zeros(N/2,length(counterPartyRatings));

currExp = zeros(N/2,length(counterPartyRatings));
expo = max(cdsZ,0)';

for i=1:nSims

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
plot(1:252+648,[underCalibrateCIRlying(:,3);underylingSim(:,3)])

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


daysToExp = wrkdydif('7/11/2016', '10/24/2016', 1);
spot_at_expiration = equitiesSim(daysToExp/252/delta,1);

x = PricingInput(252, equitiesSim(end,:)', USDsim(end,1), underylingSim(end,:)', spot_at_expiration, impVol, USDsim(end,:), CADsim(end,:), EURsim(end,:), zeroCurveTimes,...
                fxSim(end,1), fxSim(end,2), currentRatings);

[prices(i), ~, ~, ~, cds] = price(x);

for j=1:2:252
    x = PricingInput(j, equitiesSim(j,:)', USDsim(j,1), underylingSim(j,:)', spot_at_expiration, impVol, USDsim(j,:), CADsim(j,:), EURsim(j,:), zeroCurveTimes,...
                fxSim(j,1), fxSim(j,2), currentRatings);
    x.BONDS = 0;
    x.CDS = 1;
    x.OPTIONS = 0;
    x.STOCKS = 0;
    [~, ~, ~, ~, cds] = price(x);
    ind = (j-1)/2 + 1;
    currExp(ind,:) = cds ;

    %exposures(ind,:) = max(cds,0)' ;
end
exposures = exposures + currExp;
end

% Compute the average exposure at each time point 
exposures = exposures / nSims;


CVA = zeros(length(counterPartyRatings),1);
times = 0:2:252;
times = times./252;
for i=1:length(counterPartyRatings)
    lamb = impLambda(counterPartyRatings(i),:);
    q = exp(-interp(times(1:end-1), lambdaTimes, lamb).* times(1:end-1)') -  exp(-interp(times(2:end), lambdaTimes, lamb).* times(2:end)');
    CVA(i) = q' * exposures(:,i);
end

plot(1:252+648,[zeroCAD(:,2); CADsim(:,2)])

deltaP = prices - p0;

hist(deltaP);


