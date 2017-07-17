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

bondSpreads = xlsread('Implied_Yield','Yield','B2:Z645');

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
      
      
%Input risk factors in seperate matrices 

riskFactors = [equities, underlying, fxUSDCAD, fxEURCAD, zeroUSD, zeroCAD, zeroEUR, lambdaGE, lambdaCNQCN, lambdaSABR, lambdaHOT...
               lambdaFOXA, lambdaFRANCE, lambdaCAT, lambdaWFC, lambdaHUNT, bondSpreads];


% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]); 
z.historical_implied_spreads = bondSpreads(end,:);
z.BONDS = 1;
z.CDS = 1;
z.OPTIONS = 1;
z.STOCKS = 1;


[p0, bonds_valueZERO, options_valueZERO, stocks_valueZERO, cds_valuesZERO] = price(z);


%% Computing returns 

riskFactorReturns = zeros(size(riskFactors)- [1 0]);
for y=1:8;
    riskFactorReturns(:,y) = riskFactors(2:end,y)./riskFactors(1:end-1,y) - 1;
end

for y=9:53
    riskFactorReturns(:,y) = riskFactors(2:end,y) - riskFactors(1:end-1,y);
end

for y=54:125
    riskFactorReturns(:,y) = riskFactors(2:end,y) - riskFactors(1:end-1,y);
end
for y=126:150
    riskFactorReturns(:,y) = riskFactors(2:end,y) - riskFactors(1:end-1,y);
end


%% Compute Market Value at Risk and Incremental Value at Risk

Sigma = cov(riskFactorReturns); % sample covariance matrix of risk factors 
rho = corr(riskFactorReturns); % sample covariance matrix of risk factors 

nSims = 600;

simMovements = mvnrnd(zeros(size(riskFactorReturns,2), 1), Sigma, nSims);

simRiskFactors = repmat(riskFactors(end,:),nSims,1) + simMovements;

% Price the simulated scenarios 

prices = zeros(nSims,1);
bonds_value = zeros(nSims,1); 
options_value = zeros(nSims,1);
stocks_value = zeros(nSims,1);
cds_values = zeros(nSims,1);


equities = simRiskFactors(:,1:3);
underlying = simRiskFactors(:,4:6);
fxUSDCAD = simRiskFactors(:,7);
fxEURCAD = simRiskFactors(:,8);
zeroUSD = simRiskFactors(:,9:23);
zeroCAD = simRiskFactors(:,24:38);
zeroEUR = simRiskFactors(:,39:53);
L = simRiskFactors(:,54:125);
bondSpreads = simRiskFactors(:,126:end);

spot_at_expiration = [];

for i=1:nSims
    priceObject = PricingInput(1,equities(i,:)',zeroUSD(i,1), underlying(i,:)',spot_at_expiration, impVol, zeroUSD(i,:), zeroCAD(i,:), zeroEUR(i,:), zeroCurveTimes,...
                               fxUSDCAD(i), fxEURCAD(i), currentRatings, [zeros(9,1), reshape(L(i,:),8,9)']); 
    priceObject.historical_implied_spreads = bondSpreads(i,:);
    [prices(i), bonds_value(i), options_value(i), stocks_value(i), x] = price(priceObject);
    cds_values(i) = sum(x);
end

deltaP = prices - p0;

VaROneDay99 = prctile(deltaP,1);

VaRTenDay99 = sqrt(10) * VaROneDay99;

CVaROneDay99 = mean(deltaP(deltaP < VaROneDay99));

VaROneDay95 = prctile(deltaP,5);

VaRTenDay95 = sqrt(10) * VaROneDay95;

CVaROneDay95 = mean(deltaP(deltaP < VaROneDay95));


%% Marginal Value at Risk 

ind = prctile(deltaP,0) < deltaP &  deltaP < prctile(deltaP,2);
sum(ind)

MVaRBOND = mean( bonds_value(ind) - bonds_valueZERO);
MVaROPTIONS = mean( options_value(ind) - options_valueZERO);
MVaRSTOCKS = mean( stocks_value(ind) - stocks_valueZERO);
MVaRCDS = mean( cds_values(ind) - sum(cds_valuesZERO));

sVaR = MVaRBOND + MVaROPTIONS + MVaRSTOCKS + MVaRCDS;


nSims = 1000;
%% Incremental Value at Risk Calculations 
prices = zeros(nSims,1);

% Remove Bonds 

% Compute the price today with no bonds 
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]); 
z.BONDS = 0;
z.CDS = 1;
z.OPTIONS = 1;
z.STOCKS = 1;
z.historical_implied_spreads = bondSpreads(end,:);


p0 = price(z);


for i=1:nSims
    priceObject = PricingInput(1,equities(i,:)',zeroUSD(i,1), underlying(i,:)',spot_at_expiration, impVol, zeroUSD(i,:), zeroCAD(i,:), zeroEUR(i,:), zeroCurveTimes,...
                               fxUSDCAD(i), fxEURCAD(i), currentRatings, [zeros(9,1), reshape(L(i,:),8,9)']);
    priceObject.BONDS = 0;
    priceObject.CDS = 1;
    priceObject.OPTIONS = 1;
    priceObject.STOCKS = 1;
    priceObject.historical_implied_spreads = bondSpreads(i,:);

    prices(i) = price(priceObject);
end

deltaP = prices - p0;

VaROneDay99NOBONDS = prctile(deltaP,1);

incVarOneDayBONDS = -VaROneDay99 - -VaROneDay99NOBONDS;

% Remove CDS

prices = zeros(nSims,1);

% Compute the price today with no cds's 
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]); 
z.BONDS = 1;
z.CDS = 0;
z.OPTIONS = 1;
z.STOCKS = 1;
z.historical_implied_spreads = bondSpreads(end,:);

p0 = price(z);
prices = zeros(nSims,1);

for i=1:nSims
    priceObject = PricingInput(1,equities(i,:)',zeroUSD(i,1), underlying(i,:)',spot_at_expiration, impVol, zeroUSD(i,:), zeroCAD(i,:), zeroEUR(i,:), zeroCurveTimes,...
                               fxUSDCAD(i), fxEURCAD(i), currentRatings, [zeros(9,1), reshape(L(i,:),8,9)']);
    priceObject.BONDS = 1;
    priceObject.CDS = 0;
    priceObject.OPTIONS = 1;
    priceObject.STOCKS = 1;
    priceObject.historical_implied_spreads = bondSpreads(i,:);

    prices(i) = price(priceObject);
end

deltaP = prices - p0;

VaROneDay99NOCDS = prctile(deltaP,1);

incVarOneDayCDS = -VaROneDay99 - -VaROneDay99NOCDS; 

% Remove OPTIONS

prices = zeros(nSims,1);

% Compute the price today with no options 
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]); 
z.BONDS = 1;
z.CDS = 1;
z.OPTIONS = 0;
z.STOCKS = 1;
z.historical_implied_spreads = bondSpreads(end,:);


p0 = price(z);
prices = zeros(nSims,1);

for i=1:nSims
    priceObject = PricingInput(1,equities(i,:)',zeroUSD(i,1), underlying(i,:)',spot_at_expiration, impVol, zeroUSD(i,:), zeroCAD(i,:), zeroEUR(i,:), zeroCurveTimes,...
                               fxUSDCAD(i), fxEURCAD(i), currentRatings, [zeros(9,1), reshape(L(i,:),8,9)']);
    priceObject.BONDS = 1;
    priceObject.CDS = 1;
    priceObject.OPTIONS = 0;
    priceObject.STOCKS = 1;
    priceObject.historical_implied_spreads = bondSpreads(i,:);

    prices(i) = price(priceObject);
end

deltaP = prices - p0;

VaROneDay99NOOPTIONS = prctile(deltaP,1);

incVarOneDayOPTIONS = -VaROneDay99 - -VaROneDay99NOOPTIONS; 

% Remove STOCKS

prices = zeros(nSims,1);

% Compute the price today with no stocks 
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]); 
z.BONDS = 1;
z.CDS = 1;
z.OPTIONS = 1;
z.STOCKS = 0;
z.historical_implied_spreads = bondSpreads(end,:);


p0 = price(z);
prices = zeros(nSims,1);

for i=1:nSims
    priceObject = PricingInput(1,equities(i,:)',zeroUSD(i,1), underlying(i,:)',spot_at_expiration, impVol, zeroUSD(i,:), zeroCAD(i,:), zeroEUR(i,:), zeroCurveTimes,...
                               fxUSDCAD(i), fxEURCAD(i), currentRatings, [zeros(9,1), reshape(L(i,:),8,9)']);
    priceObject.BONDS = 1;
    priceObject.CDS = 1;
    priceObject.OPTIONS = 1;
    priceObject.STOCKS = 0;
    priceObject.historical_implied_spreads = bondSpreads(i,:);

    prices(i) = price(priceObject);
end

deltaP = prices - p0;

VaROneDay99NOSTOCKS = prctile(deltaP,1);

incVarOneDaySTOCKS = -VaROneDay99 - -VaROneDay99NOSTOCKS; 



% %%%% NOT USED ANYMORE %%%%
% 
% %% Marginal Value at Risk Calculations 
% % Note that numerical precision is a function of the underlying risk factor
% 
% mPrices = zeros(8,2);
% currMprices = mPrices;
% nSims = 50;
% 
% simMovements = mvnrnd(zeros(size(riskFactorReturns,2), 1), Sigma, nSims);
% 
% simRiskFactors = repmat(riskFactors(end,:),nSims,1) + simMovements;
% 
% for i=1:nSims
%     priceObject = PricingInput(1,equities(i,:)',zeroUSD(i,1), underlying(i,:)',spot_at_expiration, impVol, zeroUSD(i,:), zeroCAD(i,:), zeroEUR(i,:), zeroCurveTimes,...
%                 fxUSDCAD(i), fxEURCAD(i), currentRatings, reshape(L(i,:),8,9)');
%     % Equities
%     epsilon = 0.1;
%     priceObject.stock_prices = equities(i,:)' + epsilon; 
%     currMprices(1, 1) = price(priceObject);
%     priceObject.stock_prices = equities(i,:)' - epsilon; 
%     currMprices(1, 2) = price(priceObject);
%     % Underlying
%     epsilon = 0.1;
%     priceObject.spot_prices = underlying(i,:)' + epsilon; 
%     currMprices(2, 1) = price(priceObject);
%     priceObject.spot_prices = underlying(i,:)' - epsilon; 
%     currMprices(2, 2) = price(priceObject);
%     
%     % Sum the previous simulation 
%     mPrices = mPrices + currMprices;
% end
% 
% % Average the simulations
% mPrices = mPrices ./ nSims;
% % 
% %        num_of_days_elapsed      % Used to calculate times to maturity for all derivatives
% %        stock_prices
% %        risk_free_rate           % 1x1: USD risk-free rate used to price the three options
% %        spot_prices              % 3x1: spot prices of underlyings
% %        spot_at_expiration       % 1x1: spot price at expiration for the first put option
% %        implied_vol              % 3x1: implied vols used in BSM formula
% %        zero_curve_USD
% %        zero_curve_CAD
% %        zero_curve_EUR
% %        rate_time_structure
% %        USDCAD
% %        EURCAD


%%
%% Compute Market Value at Risk and Incremental Value at Risk

Sigma = cov(riskFactorReturns); % sample covariance matrix of risk factors 
rho = corr(riskFactorReturns); % sample covariance matrix of risk factors 

nSims = 5000;

simMovements = mvnrnd(zeros(size(riskFactorReturns,2), 1), Sigma, nSims);

simRiskFactors = repmat(riskFactors(end,:),nSims,1) + simMovements;

% Price the simulated scenarios 

prices = zeros(nSims,1);
bonds_value = zeros(nSims,1); 
options_value = zeros(nSims,1);
stocks_value = zeros(nSims,1);
cds_values = zeros(nSims,1);


equities = simRiskFactors(:,1:3);
underlying = simRiskFactors(:,4:6);
fxUSDCAD = simRiskFactors(:,7);
fxEURCAD = simRiskFactors(:,8);
zeroUSD = simRiskFactors(:,9:23);
zeroCAD = simRiskFactors(:,24:38);
zeroEUR = simRiskFactors(:,39:53);
L = simRiskFactors(:,54:125);
bondSpreads = simRiskFactors(:,126:end);

spot_at_expiration = [];

for i=1:nSims
    priceObject = PricingInput(1,equities(i,:)',zeroUSD(i,1), underlying(i,:)',spot_at_expiration, impVol, zeroUSD(i,:), zeroCAD(i,:), zeroEUR(i,:), zeroCurveTimes,...
                               fxUSDCAD(i), fxEURCAD(i), currentRatings, [zeros(9,1), reshape(L(i,:),8,9)']); 
    priceObject.historical_implied_spreads = bondSpreads(i,:);
    [prices(i), bonds_value(i), options_value(i), stocks_value(i), x] = price(priceObject);
    cds_values(i) = sum(x);
end

deltaP = prices - p0;

VaROneDay99 = prctile(deltaP,1);

VaRTenDay99 = sqrt(10) * VaROneDay99;

CVaROneDay99 = mean(deltaP(deltaP < VaROneDay99));

VaROneDay95 = prctile(deltaP,5);

VaRTenDay95 = sqrt(10) * VaROneDay95;

CVaROneDay95 = mean(deltaP(deltaP < VaROneDay95));


%% Marginal Value at Risk 

ind = prctile(deltaP,0) < deltaP &  deltaP < prctile(deltaP,2);
sum(ind)

MVaRBOND = mean( bonds_value(ind) - bonds_valueZERO);
MVaROPTIONS = mean( options_value(ind) - options_valueZERO);
MVaRSTOCKS = mean( stocks_value(ind) - stocks_valueZERO);
MVaRCDS = mean( cds_values(ind) - sum(cds_valuesZERO));

sVaR = MVaRBOND + MVaROPTIONS + MVaRSTOCKS + MVaRCDS;


nSims = 1000;
%% Asset Class Breakdown Value at Risk Calculations 
prices = zeros(nSims,1);

% Remove Bonds 

% Compute the price today with no bonds 
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]); 
z.BONDS = 1;
z.CDS = 0;
z.OPTIONS = 0;
z.STOCKS = 0;
z.historical_implied_spreads = bondSpreads(end,:);


p0 = price(z);


for i=1:nSims
    priceObject = PricingInput(1,equities(i,:)',zeroUSD(i,1), underlying(i,:)',spot_at_expiration, impVol, zeroUSD(i,:), zeroCAD(i,:), zeroEUR(i,:), zeroCurveTimes,...
                               fxUSDCAD(i), fxEURCAD(i), currentRatings, [zeros(9,1), reshape(L(i,:),8,9)']);
    priceObject.BONDS = 1;
    priceObject.CDS = 0;
    priceObject.OPTIONS = 0;
    priceObject.STOCKS = 0;
    priceObject.historical_implied_spreads = bondSpreads(i,:);

    prices(i) = price(priceObject);
end

deltaP = prices - p0;

VaROneDay99BONDS = prctile(deltaP,1);


% Remove CDS

prices = zeros(nSims,1);

% Compute the price today with no cds's 
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]); 
z.BONDS = 1;
z.CDS = 0;
z.OPTIONS = 0;
z.STOCKS = 0;
z.historical_implied_spreads = bondSpreads(end,:);

p0 = price(z);
prices = zeros(nSims,1);

for i=1:nSims
    priceObject = PricingInput(1,equities(i,:)',zeroUSD(i,1), underlying(i,:)',spot_at_expiration, impVol, zeroUSD(i,:), zeroCAD(i,:), zeroEUR(i,:), zeroCurveTimes,...
                               fxUSDCAD(i), fxEURCAD(i), currentRatings, [zeros(9,1), reshape(L(i,:),8,9)']);
    priceObject.BONDS = 0;
    priceObject.CDS = 1;
    priceObject.OPTIONS = 0;
    priceObject.STOCKS = 0;
    priceObject.historical_implied_spreads = bondSpreads(i,:);

    prices(i) = price(priceObject);
end

deltaP = prices - p0;

VaROneDay99CDS = prctile(deltaP,1);


% Remove OPTIONS

prices = zeros(nSims,1);

% Compute the price today with no options 
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]); 
z.BONDS = 0;
z.CDS = 0;
z.OPTIONS = 1;
z.STOCKS = 0;
z.historical_implied_spreads = bondSpreads(end,:);


p0 = price(z);
prices = zeros(nSims,1);

for i=1:nSims
    priceObject = PricingInput(1,equities(i,:)',zeroUSD(i,1), underlying(i,:)',spot_at_expiration, impVol, zeroUSD(i,:), zeroCAD(i,:), zeroEUR(i,:), zeroCurveTimes,...
                               fxUSDCAD(i), fxEURCAD(i), currentRatings, [zeros(9,1), reshape(L(i,:),8,9)']);
    priceObject.BONDS = 0;
    priceObject.CDS = 0;
    priceObject.OPTIONS = 1;
    priceObject.STOCKS = 0;
    priceObject.historical_implied_spreads = bondSpreads(i,:);

    prices(i) = price(priceObject);
end

deltaP = prices - p0;

VaROneDay99OPTIONS = prctile(deltaP,1);


% Remove STOCKS

prices = zeros(nSims,1);

% Compute the price today with no stocks 
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]); 
z.BONDS = 0;
z.CDS = 0;
z.OPTIONS = 0;
z.STOCKS = 1;
z.historical_implied_spreads = bondSpreads(end,:);


p0 = price(z);
prices = zeros(nSims,1);

for i=1:nSims
    priceObject = PricingInput(1,equities(i,:)',zeroUSD(i,1), underlying(i,:)',spot_at_expiration, impVol, zeroUSD(i,:), zeroCAD(i,:), zeroEUR(i,:), zeroCurveTimes,...
                               fxUSDCAD(i), fxEURCAD(i), currentRatings, [zeros(9,1), reshape(L(i,:),8,9)']);
    priceObject.BONDS = 0;
    priceObject.CDS = 0;
    priceObject.OPTIONS = 0;
    priceObject.STOCKS = 1;
    priceObject.historical_implied_spreads = bondSpreads(i,:);

    prices(i) = price(priceObject);
end

deltaP = prices - p0;

VaROneDay99STOCKS = prctile(deltaP,1);

