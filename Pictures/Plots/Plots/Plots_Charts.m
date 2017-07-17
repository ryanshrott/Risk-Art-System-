% Exposure Asset Class
[portfolio_value, bonds_value, options_value, stocks_value, cds_value] = main;
X = [bonds_value options_value stocks_value cds_value];
pie(X)
legend('Bonds','Options','Stocks','CDS')

% Exposure Sector

