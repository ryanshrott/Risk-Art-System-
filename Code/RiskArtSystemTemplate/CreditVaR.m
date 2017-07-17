%% Credit Modelling For CDS's

% Order is Communications, Financial, G
currentRatings = [3 4 4 4 4 2 3 3 6]; % These are the current ratings of each firm 
bondRatings = [3 4 4 5 4 2 4 3 6 4 2 4 3 3 2 3 3 3 4 1 3 4 4 3 1];
%rho = xlsread('portfolio_data (CR).xlsm', 'CreditRisk', 'AD78:BB102');

nFirms = length(currentRatings);
nSectors = 5;
Trans = ...
[100.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00;
0.30	95.21	4.49	0.00	0.00	0.00	0.00	0.00;
0.00	1.48	92.87	5.65	0.00	0.00	0.00	0.00;
0.00	0.06	3.33	91.37	5.24	0.00	0.00	0.00;
0.00	0.00	0.00	3.99	88.00	7.56	0.26	0.18;
0.00	0.00	0.00	0.17	4.13	87.67	5.27	2.76;
0.00	0.00	0.00	0.00	0.00	7.20	61.15	31.65;
zeros(1,7) 100] ./ 100; 

n = 1000;
x = zeros(n,2);
% Use Gaussian Copula model to model credit movements
w = zeros(n,1);
for i=1:n
    w(i) = 1;
y = i/n;
x(i,1) = y;
rho = [1	0.737	0.968	0.887	0.879	0.161	0.913	y	0.828;
0.737	1	0.752	0.709	0.828	0.135	0.713	0.737	0.874;
0.968	0.752	1	0.944	0.908	0.285	0.965	0.968	0.879;
0.887	0.709	0.944	1	0.946	0.539	0.987	0.887	0.827;
0.879	0.828	0.908	0.946	1	0.416	0.935	0.879	0.872;
0.161	0.135	0.285	0.539	0.416	1	0.503	0.161	0.209;
0.913	0.713	0.965	0.987	0.935	0.503	1	0.913	0.844;
y	0.737	0.968	0.887	0.879	0.161	0.913	1	0.828;
0.828	0.874	0.879	0.827	0.872	0.209	0.844	0.828	1;];

if(sum(eig(rho) < 0) > 0)
    x(i,2) = 0;
else
    x(i,2) = 1;
end

end

y = 0.94;
rho = [1	0.737	0.968	0.887	0.879	0.161	0.913	y	0.828;
0.737	1	0.752	0.709	0.828	0.135	0.713	0.737	0.874;
0.968	0.752	1	0.944	0.908	0.285	0.965	0.968	0.879;
0.887	0.709	0.944	1	0.946	0.539	0.987	0.887	0.827;
0.879	0.828	0.908	0.946	1	0.416	0.935	0.879	0.872;
0.161	0.135	0.285	0.539	0.416	1	0.503	0.161	0.209;
0.913	0.713	0.965	0.987	0.935	0.503	1	0.913	0.844;
y	0.737	0.968	0.887	0.879	0.161	0.913	1	0.828;
0.828	0.874	0.879	0.827	0.872	0.209	0.844	0.828	1;];
eig(rho)

cumT = cumsum(Trans,2);

cumT(:,end) = ones(8,1);

transitionValues = norminv(cumT);

transitionValues(isnan( transitionValues )) = inf;

% Compute the portfolio value today using pricers
c = PortfolioConstants;
spot_at_expiration = equities(end,1);

x = PricingInput(1,equities(end,:)',zeroUSD(end,1), underlying(end,:)', spot_at_expiration, impVol, zeroUSD(end,:), zeroCAD(end,:), zeroEUR(end,:), zeroCurveTimes,...
                fxUSDCAD(end), fxEURCAD(end), bondRatings, [zeros(9,1),reshape(lambda,8,9)']);
x.cds_underlying_rating = [3 4 4 4 4 2 3 3 6];
x.historical_implied_spreads = bondSpreads(end,:);
            
p0 = price(x);

nSims = 1000;
sims = mvnrnd(zeros(nFirms,1),rho, nSims);
futureRatings = zeros(nSims,nFirms);

prices = zeros(nSims,1);

x.num_of_days_elapsed = 1;
for i=1:nSims
    futureRatings(i,:) = simRating(sims(i,:), currentRatings, transitionValues);
    x.cds_underlying_rating = futureRatings(i,:);
    x.historical_implied_spreads = bondSpreads(end,:);
    prices(i) = price(x);
end
hist(prices - p0,100);

CreditVaR99 = prctile(prices - p0, 1);
CreditVaR95 = prctile(prices - p0, 5);
CreditVar999 = prctile(prices - p0, 0.1);

% Compute the new price of the portfolio 

% Compute the change in price of the portfolio 