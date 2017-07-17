% Ho-Lee Model for Lambda's

%cdsGE = cleanData((xlsread('CDS HIstoric.xlsx', 'SPREAD', 'C7:J650')))./100./100;
%lambdaGE = cdsGE ./ (1-0.4);

plot(lambdaGE)

plot(lambdaGE(end,:))

lambdaThreeYear = lambdaGE(:, 4); % 3 year curve 

forward = lambdaGE(end, 4); % 3 year spot rate at maturity 

lambdaReturns = lambdaThreeYear(2:end)./lambdaThreeYear(1:end-1) - 1;

sigma = std(lambdaReturns) %* sqrt(252);


T = 252;
delta = 1/252;
lambdaSim = zeros(T,1);
lambdaSim(1) = lambdaGE(end, 4); % starting point of the simulation

for i=2:T
   delta = 1/252;
    lambdaSim(i) = lambdaSim(i-1) + (forward + sigma^2 * i/252) * delta  + sigma* normrnd(0,1);
end

plot([lambdaGE(:,4); lambdaSim])
