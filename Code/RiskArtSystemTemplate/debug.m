c = PortfolioConstants;
spot_at_expiration = [];
z = PricingInput(0,equities(1,:)',zeroUSD(518+1,1), underlying(518+1,:)',spot_at_expiration, impVol, zeroUSD(518+1,:), zeroCAD(518+1,:), zeroEUR(518+1,:), zeroCurveTimes,...
                fxUSDCAD(518+1), fxEURCAD(518+1), currentRatings, [zeros(9,1), lambda]); 
z.BONDS = 1;
z.CDS = 1;
z.OPTIONS = 1;
z.STOCKS = 1;
z.historical_implied_spreads = bondSpreads(100,:);

test = price(z);