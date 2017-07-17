for i=1:nSims
    priceObject = PricingInput(1,equities(i,:)',zeroUSD(i,1), underlying(i,:)',spot_at_expiration, impVol, zeroUSD(i,:), zeroCAD(i,:), zeroEUR(i,:), zeroCurveTimes,...
                               fxUSDCAD(i), fxEURCAD(i), reshape(L(i,:),8,9)'); 
    [prices(i), bonds_value(i), options_value(i), stocks_value(i), x] = price(priceObject);
    cds_values(i) = sum(x);
end
