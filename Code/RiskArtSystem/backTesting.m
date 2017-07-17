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
               lambdaFOXA, lambdaFRANCE, lambdaCAT, lambdaWFC,lambdaHUNT];


% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, lambda); 
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

%% Compute Market Value at Risk and Incremental Value at Risk

VaROneDay95 = zeros(125,1);

outSamplePrices = zeros(125+1,1);

for i=1:125+1
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(518+i,:)',zeroUSD(518+i,1), underlying(518+i,:)',spot_at_expiration, impVol, zeroUSD(518+i,:), zeroCAD(518+i,:), zeroEUR(518+i,:), zeroCurveTimes,...
                fxUSDCAD(518+i), fxEURCAD(518+i), currentRatings, lambda); 
z.BONDS = 1;
z.CDS = 1;
z.OPTIONS = 1;
z.STOCKS = 1;

outSamplePrices(i) = price(z);
end

n = 125;

window = 1:5:n; % we move over 125 windows 
% MOVING WINDOW BAKCTESTING 
for j=window
    
inSampleRiskFactorReturns = riskFactorReturns(j:(518+j),:);
inSampleRiskFactors = riskFactors(j:(518+j),:);
Sigma = cov(inSampleRiskFactorReturns); % sample covariance matrix of risk factors 


simMovements = mvnrnd(zeros(size(inSampleRiskFactorReturns,2), 1), Sigma, size(inSampleRiskFactorReturns,1));

simRiskFactors = repmat(inSampleRiskFactors(end,:),size(inSampleRiskFactorReturns,1),1) + simMovements;

pricesB = zeros(size(inSampleRiskFactorReturns,1),1);

% Price the simulated scenarios 

equitiesx = simRiskFactors(:,1:3);
underlyingx = simRiskFactors(:,4:6);
fxUSDCADx = simRiskFactors(:,7);
fxEURCADx = simRiskFactors(:,8);
zeroUSDx = simRiskFactors(:,9:23);
zeroCADx = simRiskFactors(:,24:38);
zeroEURx = simRiskFactors(:,39:53);
Lx = simRiskFactors(:,54:end);

spot_at_expiration = [];

for i=1:size(inSampleRiskFactorReturns,1)
    priceObject = PricingInput(1,equitiesx(i,:)',zeroUSDx(i,1), underlyingx(i,:)',spot_at_expiration, impVol, zeroUSD(i,:), zeroCADx(i,:), zeroEURx(i,:), zeroCurveTimes,...
                               fxUSDCADx(i), fxEURCADx(i), currentRatings, reshape(Lx(i,:),8,9)'); 
    pricesB(i) = price(priceObject);
end


deltaP = pricesB - outSamplePrices(j+1);
hist(deltaP,100);

VaROneDay95(j) = prctile(deltaP,5);
end

changeOutSample = outSamplePrices(2:end)-outSamplePrices(1:end-1);
breach = changeOutSample < VaROneDay95;

percentBreaches = sum(breach(1:10:125)) ./ length(breach(1:10:125));

VaRTenDay99 = sqrt(10) * VaROneDay95;

% hist(prices - p0,50)
% x  = prctile(prices - p0, 1)
% set(get(gca,'child'),'FaceColor','none','EdgeColor','r');
% hold on;
% hist(pricesB - p0,50)
% x  = prctile(pricesB - p0, 1)
% 


