% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = [];
lambda = [lambdaGE(end,:); lambdaCNQCN(end,:); lambdaSABR(end,:); lambdaHOT(end,:); lambdaFOXA(end,:); lambdaFRANCE(end,:);...
          lambdaCAT(end,:); lambdaWFC(end,:); lambdaHUNT(end,:)];
z = PricingInput(0,equities(end,:)',zeroUSD(end,1), underlying(end,:)',spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), currentRatings, [zeros(9,1), lambda]);
            
z.historical_implied_spreads = bondSpreads(end,:);

[p0, bonds_valueZERO, options_valueZERO, stocks_valueZERO, cds_valuesZERO] = price(z);

bondShort = sum(bonds_valueZERO(bonds_valueZERO<0));
bondLong = sum(bonds_valueZERO(bonds_valueZERO>0));

optionShort = sum(options_valueZERO(options_valueZERO<0));
optionLong = sum(options_valueZERO(options_valueZERO>0));

stockShort = sum(stocks_valueZERO(stocks_valueZERO<0));
stockLong = sum(stocks_valueZERO(stocks_valueZERO>0));

cdsShort = sum(cds_valuesZERO(cds_valuesZERO<0));
cdsLong = sum(cds_valuesZERO(cds_valuesZERO>0));

%p0Short = sum(bondShort) + sum(optionShort) + sum(stockShort) + sum(cdsShort);
%p0Long = sum(bondLong) + sum(optionLong)+ sum(stockLong) + sum(cdsLong);
%p0Vet = sum(bondShort) + sum(bondLong) + sum(optionShort) + sum(optionLong) + sum(stockShort) + sum(stockLong) + sum(cdsShort) + sum(cdsLong);