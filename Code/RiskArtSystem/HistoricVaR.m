clc;
clear all;
% 
%% Gathering Risk Factors 
equities = flipud(xlsread('data.xlsx','Stocks','B6:D649'));

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

% Input risk factors in seperate matrices 
currentRatings = [3 4 4 5 4 2 4 3 6 4 2 4 3 3 2 3 3 3 4 1 3 4 4 3 1]; % These are the current ratings of each firm 

bondSpreads = xlsread('Implied_Yield','Yield','B2:Z645');

% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
lambda = [lambdaGE(end,:); lambdaCNQCN(end,:); lambdaSABR(end,:); lambdaHOT(end,:); lambdaFOXA(end,:); lambdaFRANCE(end,:);...
          lambdaCAT(end,:); lambdaWFC(end,:); lambdaHUNT(end,:)];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]);
            
z.historical_implied_spreads = bondSpreads(end,:);

[p0, bonds_valueZERO, options_valueZERO, stocks_valueZERO, cds_valuesZERO] = price(z);

%% Computing returns 

riskFactors = [equities, underlying, fxUSDCAD, fxEURCAD, zeroUSD, zeroCAD, zeroEUR, lambdaGE, lambdaCNQCN, ...
               lambdaSABR, lambdaHOT, lambdaFOXA, lambdaFRANCE, lambdaCAT, lambdaWFC, lambdaHUNT, bondSpreads];

riskFactorsToday = riskFactors(end,:);
riskFactorReturns = zeros(size(riskFactors)- [1 0]);
for y=1:size(riskFactorReturns,2);
    riskFactorReturns(:,y) = riskFactors(2:end,y)./riskFactors(1:end-1,y) - 1;
end

scenarios = zeros(size(riskFactorReturns));
for i=1:size(scenarios,1)
    scenarios(i,:) = (1+riskFactorReturns(i,:)) .* riskFactorsToday;
end

usdThreeMonth = scenarios(:,9);
scen = scenarios;
scen(find(usdThreeMonth<0),:) = [];

equitiesScen = scen(:,1:3);
underlyingScen = scen(:,4:6);
fxUSDCADScen = scen(:,7);
fxEURCADScen = scen(:,8);
zeroUSDScen = scen(:,9:23);
zeroCADScen = scen(:,24:38);
zeroEURScen = scen(:,39:53);
lambdaScen = scen(:,54:125);
bondSpreadScen = scen(:,126:end);

prices = zeros(size(scen,1),1);
bonds_value = zeros(size(scen,1),1); 
options_value = zeros(size(scen,1),1);
stocks_value = zeros(size(scen,1),1);
cds_values = zeros(size(scen,1),1);

c = PortfolioConstants;


for i=1:size(scen,1)
    x = PricingInput(1,equitiesScen(i,:)',zeroUSDScen(i,1), underlyingScen(i,:)', [], impVol, zeroUSDScen(i,:), zeroCADScen(i,:),...
                    zeroEURScen(i,:), zeroCurveTimes, fxUSDCADScen(i), fxEURCADScen(i), currentRatings, [zeros(9,1), reshape(lambdaScen(i,:),8,9)']);
    x.historical_implied_spreads = bondSpreadScen(i,:);

    [prices(i), bonds_value(i), options_value(i), stocks_value(i), x]= price(x);
end

deltaP = prices - p0;

hist(deltaP, 50);

VaROneDay99 = prctile(deltaP, 1);
VaROneDay95 = prctile(deltaP, 4);
VaR99Ten = sqrt(10) * VaROneDay99;
VaR95Ten = sqrt(10) * VaROneDay95;

CVaROneDay99 = mean(deltaP(deltaP < VaROneDay99));
CVaROneDay95 = mean(deltaP(deltaP < VaROneDay95));

%% Marginal Value at Risk 

ind = prctile(deltaP,0) < deltaP &  deltaP < prctile(deltaP,2);
sum(ind)

MVaRBOND = mean( bonds_value(ind) - bonds_valueZERO);
MVaROPTIONS = mean( options_value(ind) - options_valueZERO);
MVaRSTOCKS = mean( stocks_value(ind) - stocks_valueZERO);
MVaRCDS = mean( cds_values(ind) - sum(cds_valuesZERO));

sVaR = MVaRBOND + MVaROPTIONS + MVaRSTOCKS + MVaRCDS;

%% Incremental Value at Risk Calculations 

% Remove Bonds 

% Compute the price today with no bonds 
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];

lambda = [lambdaGE(end,:); lambdaCNQCN(end,:); lambdaSABR(end,:); lambdaHOT(end,:); lambdaFOXA(end,:); lambdaFRANCE(end,:);...
          lambdaCAT(end,:); lambdaWFC(end,:); lambdaHUNT(end,:)];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings,[zeros(9,1), lambda]);
z.BONDS = 0;
z.CDS = 1;
z.OPTIONS = 1;
z.STOCKS = 1;
z.historical_implied_spreads = bondSpreadScen(end,:);

[p0, bonds_valueZERO, options_valueZERO, stocks_valueZERO, cds_valuesZERO] = price(z);

prices = zeros(size(scen,1),1);

for i=1:size(scen,1)
    priceObject = PricingInput(1,equitiesScen(i,:)',zeroUSDScen(i,1), underlyingScen(i,:)', [], impVol, zeroUSDScen(i,:), zeroCADScen(i,:),...
                    zeroEURScen(i,:), zeroCurveTimes, fxUSDCADScen(i), fxEURCADScen(i), currentRatings, [zeros(9,1),reshape(lambdaScen(i,:),8,9)']);
    priceObject.BONDS = 0;
    priceObject.CDS = 1;
    priceObject.OPTIONS = 1;
    priceObject.STOCKS = 1;
        priceObject.historical_implied_spreads = bondSpreadScen(i,:);

    [prices(i), bonds_value(i), options_value(i), stocks_value(i), x]= price(priceObject);
end

deltaP = prices - p0;

VaROneDay99NOBONDS = prctile(deltaP,1);

incVarOneDayBONDS = -VaROneDay99 - -VaROneDay99NOBONDS;

% Remove CDS 

% Compute the price today with no bonds 
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];

lambda = [lambdaGE(end,:); lambdaCNQCN(end,:); lambdaSABR(end,:); lambdaHOT(end,:); lambdaFOXA(end,:); lambdaFRANCE(end,:);...
          lambdaCAT(end,:); lambdaWFC(end,:); lambdaHUNT(end,:)];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]);
z.BONDS = 1;
z.CDS = 0;
z.OPTIONS = 1;
z.STOCKS = 1;
z.historical_implied_spreads = bondSpreadScen(end,:);


[p0, bonds_valueZERO, options_valueZERO, stocks_valueZERO, cds_valuesZERO] = price(z);

prices = zeros(size(scen,1),1);

for i=1:size(scen,1)
    priceObject = PricingInput(1,equitiesScen(i,:)',zeroUSDScen(i,1), underlyingScen(i,:)', [], impVol, zeroUSDScen(i,:), zeroCADScen(i,:),...
                    zeroEURScen(i,:), zeroCurveTimes, fxUSDCADScen(i), fxEURCADScen(i), currentRatings, [zeros(9,1),reshape(lambdaScen(i,:),8,9)']);
    priceObject.BONDS = 1;
    priceObject.CDS = 0;
    priceObject.OPTIONS = 1;
    priceObject.STOCKS = 1;
        priceObject.historical_implied_spreads = bondSpreadScen(i,:);

    [prices(i), bonds_value(i), options_value(i), stocks_value(i), x]= price(priceObject);
end

deltaP = prices - p0;

VaROneDay99NOCDS = prctile(deltaP,1);

incVarOneDayCDS = -VaROneDay99 - -VaROneDay99NOCDS;

% Remove OPTIONS 

% Compute the price today with no bonds 
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];

lambda = [lambdaGE(end,:); lambdaCNQCN(end,:); lambdaSABR(end,:); lambdaHOT(end,:); lambdaFOXA(end,:); lambdaFRANCE(end,:);...
          lambdaCAT(end,:); lambdaWFC(end,:); lambdaHUNT(end,:)];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]);
z.BONDS = 1;
z.CDS = 1;
z.OPTIONS = 0;
z.STOCKS = 1;
z.historical_implied_spreads = bondSpreadScen(end,:);

[p0, bonds_valueZERO, options_valueZERO, stocks_valueZERO, cds_valuesZERO] = price(z);

prices = zeros(size(scen,1),1);

for i=1:size(scen,1)
    priceObject = PricingInput(1,equitiesScen(i,:)',zeroUSDScen(i,1), underlyingScen(i,:)', [], impVol, zeroUSDScen(i,:), zeroCADScen(i,:),...
                    zeroEURScen(i,:), zeroCurveTimes, fxUSDCADScen(i), fxEURCADScen(i), currentRatings, [zeros(9,1),reshape(lambdaScen(i,:),8,9)']);
    priceObject.BONDS = 1;
    priceObject.CDS = 1;
    priceObject.OPTIONS = 0;
    priceObject.STOCKS = 1;
        priceObject.historical_implied_spreads = bondSpreadScen(i,:);

    [prices(i), bonds_value(i), options_value(i), stocks_value(i), x]= price(priceObject);
end

deltaP = prices - p0;

VaROneDay99NOOPTIONS = prctile(deltaP,1);

incVarOneDayOPTIONS = -VaROneDay99 - -VaROneDay99NOOPTIONS;



% Remove Stocks 

% Compute the price today with no bonds 
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];

lambda = [lambdaGE(end,:); lambdaCNQCN(end,:); lambdaSABR(end,:); lambdaHOT(end,:); lambdaFOXA(end,:); lambdaFRANCE(end,:);...
          lambdaCAT(end,:); lambdaWFC(end,:); lambdaHUNT(end,:)];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]);
z.BONDS = 1;
z.CDS = 1;
z.OPTIONS = 1;
z.STOCKS = 0;
z.historical_implied_spreads = bondSpreadScen(end,:);

[p0, bonds_valueZERO, options_valueZERO, stocks_valueZERO, cds_valuesZERO] = price(z);

prices = zeros(size(scen,1),1);

for i=1:size(scen,1)
    priceObject = PricingInput(1,equitiesScen(i,:)',zeroUSDScen(i,1), underlyingScen(i,:)', [], impVol, zeroUSDScen(i,:), zeroCADScen(i,:),...
                    zeroEURScen(i,:), zeroCurveTimes, fxUSDCADScen(i), fxEURCADScen(i), currentRatings, [zeros(9,1),reshape(lambdaScen(i,:),8,9)']);
    priceObject.BONDS = 1;
    priceObject.CDS = 1;
    priceObject.OPTIONS = 1;
    priceObject.STOCKS = 0;
    priceObject.historical_implied_spreads = bondSpreadScen(i,:);

    [prices(i), bonds_value(i), options_value(i), stocks_value(i), x]= price(priceObject);
end

deltaP = prices - p0;

VaROneDay99NOSTOCKS = prctile(deltaP,1);

incVarOneDaySTOCKS = -VaROneDay99 - -VaROneDay99NOSTOCKS;




