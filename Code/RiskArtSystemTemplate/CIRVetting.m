%clc;
%clear all;

%r = xlsread('data.xlsx','Hoja1','B2:AW2535');

T = 300/252;   

delta = 1/252;

sims = simVas(r,T,delta);
S = cov(r);

% Eigenvalue decomposition 
[Q, Lambda] = pcacov(S);

Q1 = Q(:,1);
Lambda1 = Lambda(1,1);

x = (diag(Lambda)^(-1/2) * Q' * r')';
x1 = x(:,1);

% CIR Calibration
x1Tilde = x1(1:end-1);
dx = diff(x1);
dx = dx./x1Tilde.^0.5;
regressors = [delta./x1Tilde.^0.5, delta*x1Tilde.^0.5];
drift = regressors\dx; % OLS regressors coefficients estimates
res = regressors*drift - dx;
alpha = -drift(2);
mu = -drift(1)/drift(2);
sigma = sqrt(var(res, 1)/delta);
InitialParams = [alpha mu sigma]; % Vector of initial parameters

% The current known value of x 
x1 = x(:,1);
x_current = x(end,:);
x1_current = x1(end);


N = T / delta;
simulatedx1 = zeros(N,1);
simulatedx1(1) = x1_current + alpha * (mu - x1_current) * delta + sigma * sqrt(x1_current) * normrnd(0,1);


for i=2:length(simulatedx1)
    simulatedx1(i) = simulatedx1(i-1) + alpha * (mu - simulatedx1(i-1)) * delta + sigma * sqrt(simulatedx1(i-1)*delta) * normrnd(0,1);
end

temp = zeros(N,size(r,2)-1);
for i=1:size(r,2)-1
    temp(:,i) = repmat(x_current(i+1), N,1);
end
newX = [simulatedx1, temp];

simulatedRates = (Q * diag(Lambda)^(1/2) * newX')';

plot(1:300, simulatedRates(:,1));

