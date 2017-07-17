clc;
clear all;

r = xlsread('data.xlsx','Hoja1','B2:AW2535');

T = 300/252;   

delta = 1/252;

sims = simVas(r,T,delta);
S = cov(r);

% Eigenvalue decomposition 
[Q, Lambda] = pcacov(S);

Q1 = Q(:,1);
Lambda1 = Lambda(1,1);

x = (diag(Lambda)^(-1/2) * Q' * r')';

% Calibration
[theta sigma k] = CalibrateVasicek(x(:,1), 1/252);

% The current known value of x 
x1 = x(:,1);
x_current = x(end,:);
x1_current = x1(end);

N = T / delta;
simulatedx1 = zeros(N,1);
simulatedx1(1) = x1_current * exp(-k*delta) + theta * (1 - exp(-k * delta)) + sigma * sqrt((1-exp(-2*k*delta))/2/k) * normrnd(0,1);

for i=2:length(simulatedx1)
    simulatedx1(i) = simulatedx1(i-1) * exp(-k*delta) + theta * (1 - exp(-k * delta)) + sigma * sqrt((1-exp(-2*k*delta))/2/k) * normrnd(0,1);
end

temp = zeros(N,size(r,2)-1);
for i=1:size(r,2)-1
    temp(:,i) = repmat(x_current(i+1), N,1);
end
newX = [simulatedx1, temp];

simulatedRates = (Q * diag(Lambda)^(1/2) * newX')';
