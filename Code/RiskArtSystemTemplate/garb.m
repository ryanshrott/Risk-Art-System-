clear all
% GBM stock price

t = 250;
nsim = 1000;

S = NaN(nsim, t);
Sminus = NaN(nsim, t);


dt = 1/250;

S(:,1) = 100;
mu = 0.08;
sigma = 0.2;
r = 0.08;

epsilon = normrnd(0,1,nsim,t);

% Stock Price Path

for i = 2:250
    S(:,i) = S(:,i-1).*exp((mu-0.5*sigma^2)*dt+sigma*sqrt(dt).*epsilon(:,i));
end