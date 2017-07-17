% %clc;
% %clear all;
% 
% 
% %INPUTS: 1. Historical time series for stocks, interest rates, fx rates, 
% %         2. Implied vol surface (for option pricing)
% %         3. Spread curves for each credit rating 
% %         4. Transition matrices for credit quality  
% 
% % Gathering Risk Factors 
 currentRatings = [3 4 4 5 4 2 4 3 6 4 2 4 3 3 2 3 3 3 4 1 3 4 4 3 1]; % These are the current ratings of each firm 

equities = xlsread('data.xlsx','Stocks','B2:D649');

underlying = xlsread('data.xlsx','Underlying','B3:D650');

impVol = xlsread('portfolio_data.xlsm','Options','K2:K4');


zeroUSD = xlsread('data.xlsx','USD','B6:P649')./100;
zeroCurveTimes = [3/12, 6/12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 30];

zeroCAD = xlsread('data.xlsx','CAD','B7:AD650')./100;
zeroCAD( :, all( isnan( zeroCAD ), 1 ) ) = []; 

zeroEUR = xlsread('data.xlsx','EUR','B7:AD650')./100;
%zeroEUR( :, all( isnan( zeroEUR ), 1 ) ) = []; 

fxUSDCAD = xlsread('data.xlsx','FX','B3:B650');

fxEURCAD = xlsread('data.xlsx','FX','E3:E650');

spreads = xlsread('SpreadsbySector','Communications','L2:R16')./10^4;

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

impLambda = [zeros(9,1), xlsread('Counterparty_Spreads.xlsx','Sheet1','B2:I10')]./100./100;

impLambda = impLambda ./ (1-0.4);

lambda = [lambdaGE(end,:); lambdaCNQCN(end,:); lambdaSABR(end,:); lambdaHOT(end,:); lambdaFOXA(end,:); lambdaFRANCE(end,:);...
          lambdaCAT(end,:); lambdaWFC(end,:); lambdaHUNT(end,:)];
      
%Input risk factors in seperate matrices 
equitiesToday = equities(end,:);
underlyingToday = underlying(end,:);
fxUSDCADToday = fxUSDCAD(end,:);
fxEURCADToday = fxEURCAD(end,:);
riskFactors = [zeroUSD, zeroCAD, zeroEUR, lambdaGE, lambdaCNQCN, lambdaSABR, lambdaHOT, lambdaFOXA,...
               lambdaFRANCE, lambdaCAT, lambdaWFC, lambdaHUNT];

% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]);
    z.historical_implied_spreads = bondSpreads(end,:);

[p0, b, ~, ~, cdsZ] = price(z);


%% Principal component analysis on interest rate curves 

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
riskFactors = [xUSD(:,1), xCAD(:,1), xEUR(:,1), lambdaGE, lambdaCNQCN, lambdaSABR, lambdaHOT, lambdaFOXA,...
               lambdaFRANCE, lambdaCAT, lambdaWFC, lambdaHUNT];

riskFactorReturns = zeros(size(riskFactors)- [1 0]);
for y=1:size(riskFactorReturns,2);
    riskFactorReturns(:,y) = riskFactors(2:end,y)./riskFactors(1:end-1,y) - 1;
end

%% Compute correlation matrix of risk factors 

rho = corr(riskFactorReturns);

%counterPartyRatings =[2 4 4 4 4 4 3 3 6];
counterPartyRatings =[4 5 4 5 4 4 3 4 3];

T = ['2019-12-20';'2020-06-20';'2016-12-20';'2016-12-20';'2016-12-20';'2018-09-20';'2019-12-20';'2021-06-20';'2017-06-20'];
today = ['7-11-2016'; '7-11-2016'; '7/11/2016'; '7/11/2016';'7/11/2016';'7/11/2016';'7/11/2016' ;'7/11/2016';'7/11/2016'];
daysToExp = wrkdydif(today, T, 1);
yearsToExp = daysToExp ./ 252;
lambdaTimes = [0, c.CDS_lambda_times];

% Generate normalized correlated Gaussian random variables (can also be
% used for credit modelling) 
delta = 1/252;
T = max(yearsToExp); % Number of years to simulate in the future 
N = T/delta;
nSims = 100;

prices = zeros(nSims,1);

exposuresCVA = zeros(ceil(N/2),length(counterPartyRatings));
exposuresDVA = zeros(ceil(N/2),length(counterPartyRatings));

currExpCVA = zeros(ceil(N/2),length(counterPartyRatings));
currExpDVA = zeros(ceil(N/2),length(counterPartyRatings));
expPrice = zeros(ceil(N/2),length(counterPartyRatings));
currExpPrice = zeros(ceil(N/2),length(counterPartyRatings));

expo = max(cdsZ,0)';

for i=1:nSims
tic 
z = mvnrnd(zeros(1,size(riskFactors,2)), rho, N);
% Simulate all risk factors using correct models and correlations

zZeroUSD = z(:,1);
zZeroCAD = z(:,2);
zZeroEUR = z(:,3);
zLambda = z(:,4:end);

lambdaSim = simGBM(riskFactors(end,4:end)',mean(riskFactorReturns(:,4:end))'.*252, std(riskFactorReturns(:,4:end))'.*sqrt(252), zLambda, delta,T);

[t, s, k] = CalibrateVasicek(xUSD(:,1),delta);
xSimUSD = simVas(xUSD, T, delta, zZeroUSD, t, s, k, 1); % Simulate under risk neutral measure 
USDsim = (QUSD * diag(LambdaUSD)^(1/2) * xSimUSD')';

[t, s, k] = CalibrateVasicek(xCAD(:,1),delta);
xSimCAD = simVas(xCAD, T, delta, zZeroCAD, t, s, k, 1); % Simulate under risk neutral measure 
CADsim = (QCAD * diag(LambdaCAD)^(1/2) * xSimCAD')';

[t, s, k] = CalibrateVasicek(xEUR(:,1),delta);
xSimEUR = simVas(xEUR, T, delta, zZeroEUR, t, s, k, 1); % Simulate under risk neutral measure 
EURsim = (QEUR * diag(LambdaEUR)^(1/2) * xSimEUR')';

spot_at_expiration = equities(end,1);

for j=1:2:max(daysToExp)   
    x = PricingInput(j, equities(end,:)', USDsim(j,1), underlying(end,:)', spot_at_expiration, impVol, USDsim(j,:), CADsim(j,:), EURsim(j,:), zeroCurveTimes,...
                     fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), reshape(lambdaSim(j,:),8,9)'] );
    %x = PricingInput(j, equities(end,:)', USDsim(j,1), underlying(end,:)', spot_at_expiration, impVol, USDsim(j,:), CADsim(j,:), EURsim(j,:), zeroCurveTimes,...
                   %  fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), c.CDS_lambda]);          
    x.BONDS = 0;
    x.CDS = 1;
    x.OPTIONS = 0;
    x.STOCKS = 0;
    x.historical_implied_spreads = bondSpreads(end,:);

    %[~, ~, ~, ~, cds] = price(x);
    cds = price_cds_cva(x, c);
    ind = (j-1)/2 + 1;

    currExpPrice(ind,:) = cds;
    currExpCVA(ind,:) = max(cds,0);
    currExpDVA(ind,:) = max(-cds,0) ; 
end
expPrice = expPrice + currExpPrice;
exposuresCVA = exposuresCVA + currExpCVA;
exposuresDVA = exposuresDVA + currExpDVA;
toc
end

% Compute the average exposure at each time point 
t = 0:2:max(daysToExp)-1;
t = t ./ 252;
DF = exp(-zeroCAD(end,1) .* t);
exposuresCVA = exposuresCVA / nSims;
exposuresDVA = exposuresDVA / nSims;


%exposuresCVA = exposuresCVAS;
%exposuresDVA = exposuresDVAS;

DiscountFactors = repmat(DF,9,1);
exposuresCVATraspose = exposuresCVA' ;
exposuresDVATraspose = exposuresDVA' ;

exposuresCVA = exposuresCVATraspose .* DiscountFactors .* (1-0.4);
exposuresDVA = exposuresDVATraspose .* DiscountFactors .* (1-0.4);

exposuresCVA = exposuresCVA';
exposuresDVA = exposuresDVA';

cva = zeros(length(counterPartyRatings),1);
dva = zeros(length(counterPartyRatings),1);

times = zeros(length(counterPartyRatings), ceil(max(daysToExp)/2));
for i=1:length(counterPartyRatings)
    times(i,1:length(0:2:daysToExp(i))) = 0:2:daysToExp(i);
end
times = times./252;

lambDVA = impLambda(1,:);
for i=1:length(counterPartyRatings) % moving through CVA calculations for each CDS
    lamb = impLambda(counterPartyRatings(i),:);
    newTimes = [0; nonzeros(times(i,:))];
    qCVA = exp(-interp(yearsToExp(i), lambdaTimes, lamb).* newTimes(1:end-1)')...
        -  exp(-interp(yearsToExp(i), lambdaTimes, lamb).* newTimes(2:end)');
    % Assume that our firm is AA rated so that we take the smallest spreads
    qDVA = exp(-interp(yearsToExp(i), lambdaTimes, lambDVA).* newTimes(1:end-1)')...
        -  exp(-interp(yearsToExp(i), lambdaTimes, lambDVA).* newTimes(2:end)');
    cva(i) = qCVA * exposuresCVA(1:length(newTimes)-1,i);
    dva(i) = qDVA * exposuresDVA(1:length(newTimes)-1,i);
end

Vnew = cdsZ - cva + dva;

