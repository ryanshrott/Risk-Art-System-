% Stress Scenarios
[portfolio_value, bonds_value, options_value, stocks_value, cds_value] = main;
[portfolio_valueltcm, bonds_valueltcm, options_valueltcm, stocks_valueltcm, cds_valueltcm] = main_LTCM;
[portfolio_valuegreece, bonds_valuegreece, options_valuegreece, stocks_valuegreece, cds_valuegreece] = main_greece;
[portfolio_value2011, bonds_value2011, options_value2011, stocks_value2011, cds_value2011] = main_2011;
[portfolio_value2008, bonds_value2008, options_value2008, stocks_value2008, cds_value2008] = main_2008;

SS = [portfolio_value portfolio_valueltcm portfolio_valuegreece portfolio_value2011 portfolio_value2008;...
    bonds_value bonds_valueltcm bonds_valuegreece bonds_value2011 bonds_value2008;
    options_value options_valueltcm options_valuegreece options_value2011 options_value2008;
    stocks_value stocks_valueltcm stocks_valuegreece stocks_value2011 stocks_value2008;
    cds_value cds_valueltcm cds_valuegreece cds_value2011 cds_value2008];
bar(SS)
title('Portfolio Value under Stress Scenarios')
legend('Portfolio Value','Russian Crisis and LTCM 1998','Greece Financial Crisis - 2010',...
    'Debt Ceiling Crisis & Downgrade 2011','Lehman Default 2008')
ax = gca;
ax.XTickLabel = {'Portfolio Value','Bonds','Options','Stocks','CDS'};

%% LTCM
Bonds = bonds_value - bonds_valueltcm;
Stocks = stocks_value - stocks_valueltcm;
Options = options_value - options_valueltcm;
CDS = cds_value - cds_valueltcm;
Portfolio = portfolio_value - portfolio_valueltcm;

LTCM = [Portfolio; Bonds; Options; Stocks; CDS];

bar(LTCM)
title('Russian Crisis and LTCM 1998 Scenario Losses')
ax = gca;
ax.XTickLabel = {'Total Losses','Bonds','Options','Stocks','CDS'};

%% Greece
Bonds = bonds_value - bonds_valuegreece;
Stocks = stocks_value - stocks_valuegreece;
Options = options_value - options_valuegreece;
CDS = cds_value - cds_valuegreece;
Portfolio = portfolio_value - portfolio_valuegreece;

greece = [Portfolio; Bonds; Options; Stocks; CDS];

bar(greece)
title('Greece Financial Crisis - 2010 Scenario Losses')
ax = gca;
ax.XTickLabel = {'Total Losses','Bonds','Options','Stocks','CDS'};

%% 2011
Bonds = bonds_value - bonds_value2011;
Stocks = stocks_value - stocks_value2011;
Options = options_value - options_value2011;
CDS = cds_value - cds_value2011;
Portfolio = portfolio_value - portfolio_value2011;

Debt11 = [Portfolio; Bonds; Options; Stocks; CDS];

bar(Debt11)
title('Debt Ceiling Downgrade 2011 Scenario Losses')
ax = gca;
ax.XTickLabel = {'Total Losses','Bonds','Options','Stocks','CDS'};

%% 2008
Bonds = bonds_value - bonds_value2008;
Stocks = stocks_value - stocks_value2008;
Options = options_value - options_value2008;
CDS = cds_value - cds_value2008;
Portfolio = portfolio_value - portfolio_value2008;

Crisis08 = [Portfolio; Bonds; Options; Stocks; CDS];

bar(Crisis08)
title('Lehman Default 2008 Scenario Losses')
ax = gca;
ax.XTickLabel = {'Total Losses','Bonds','Options','Stocks','CDS'};