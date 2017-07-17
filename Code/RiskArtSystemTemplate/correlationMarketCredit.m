% Considering the correlation between Market and Credit Risk 


CreditVaR = CVaRUpper;
MarketVaR = 8.684251925440446e+07;

rho  = 0:0.001:1;

TotalVaR = sqrt(MarketVaR^2 + CreditVaR^2 + 2 .* rho .*  MarketVaR .* CreditVaR);

plot(rho, TotalVaR);
title('TotalVaR: Showing the correlation relationship')

xlabel('\rho')
ylabel('TotalVaR')

TVaRUpper = TotalVaR(end);
TVaRLower = TotalVaR(1);

CVaR_CDS = 2.004451627069122e+07;
CVaR_BONDS = 2.817924122034073e+06;

rho  = 0:0.001:1;

TotalVaR = sqrt(CVaR_CDS^2 + CVaR_BONDS^2 + 2 .* rho .*  CVaR_CDS .* CVaR_BONDS);

plot(rho, TotalVaR);
title('CreditVaR_{tot}: Showing the correlation relationship')

xlabel('\rho')
ylabel('CVaR')

CVaRUpper = TotalVaR(end);
CVaRLower = TotalVaR(1);
