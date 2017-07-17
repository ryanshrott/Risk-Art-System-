%% Stressed VaR Computation

riskFactors = xlsread('RiskFactors_UnderStress2.xlsx','Sheet2','B2:DV751');

riskFactorsToday = riskFactors(end,:);
riskFactorReturns = zeros(size(riskFactors)- [1 0]);
for y=1:size(riskFactorReturns,2);
    riskFactorReturns(:,y) = riskFactors(2:end,y)./riskFactors(1:end-1,y) - 1;
end

priceToday = zeros(250,1);

scenarios = zeros(size(riskFactorReturns));
for i=1:size(scenarios,1)
    scenarios(i,:) = (1+riskFactorReturns(i,:)) .* riskFactorsToday;
end

equitiesScen = scenarios(:,1:3);
underlyingScen = scenarios(:,4:6);
fxUSDCADScen = scenarios(:,7);
fxEURCADScen = scenarios(:,8);
zeroUSDScen = scenarios(:,9:23);
zeroCADScen = scenarios(:,24:38);
zeroEURScen = scenarios(:,39:53);
lambda = scenarios(:,54:125);
bondSpreadScen = scenarios(

for i=1:250 
% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equitiesScen(499+i,:)',zeroUSDScen(499+i,1), underlyingScen(499+i,:)',spot_at_expiration, impVol, zeroUSDScen(499+i,:), zeroCADScen(499+i,:), zeroEURScen(499+i,:), zeroCurveTimes,...
                fxUSDCADScen(499+i), fxEURCADScen(499+i), currentRatings, lambda); 
z.BONDS = 1;
z.CDS = 1;
z.OPTIONS = 1;
z.STOCKS = 1;

priceToday(i) = price(z);
end

VaR99 = zeros(250,1);

n = 250;
for j=1:5:250 % moving window 
equitiesScen = scenarios(0+j:499+j,1:3);
underlyingScen = scenarios(0+j:499+j,4:6);
fxUSDCADScen = scenarios(0+j:499+j,7);
fxEURCADScen = scenarios(0+j:499+j,8);
zeroUSDScen = scenarios(0+j:499+j,9:23);
zeroCADScen = scenarios(0+j:499+j,24:38);
zeroEURScen = scenarios(0+j:499+j,39:53);
lambda = scenarios(0+j:499+j,54:125);


c = PortfolioConstants;

prices = zeros(size(equitiesScen,1),1);

for i=1:size(equitiesScen,1)
    x = PricingInput(1,equitiesScen(i,:)',zeroUSDScen(i,1), underlyingScen(i,:)', [], impVol, zeroUSDScen(i,:), zeroCADScen(i,:),...
                    zeroEURScen(i,:), zeroCurveTimes, fxUSDCADScen(i), fxEURCADScen(i), currentRatings, reshape(lambda(i,:),8,9)');
    prices(i) = price(x);
end

disp(j);
deltaP = prices - priceToday(j+1);

VaR99(j) = prctile(deltaP, 1);

end
hist(deltaP)
% Find the index corresponding to the minimum value in the array

[minVal, index] = min(VaR99);

plot(VaR99(1:5:250))
title('Value At Risk from 03/01/07 - 12/31/09 Weekly Movement');
xlabel('Starting 500 Day Window Measured in Weeks Past 03/01/07')
