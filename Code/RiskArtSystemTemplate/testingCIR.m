clc;
clear all;

% Gather interest rate time series 
r = xlsread('data.xlsx','Hoja1','B2:AW2535');

% Preparing data for a Principle Component Analysis 
S = cov(r);

% Eigenvalue decomposition 
[Q, Lambda] = pcacov(S);

Q1 = Q(:,1);
Lambda1 = Lambda(1,1);

% Define artificial variable 
x = (diag(Lambda)^(-1/2) * Q' * r')';

%% Vasicek Model Example 
% Calibrate the model 
[theta, sigma, k] = CalibrateVasicek(x(:,1), 1/252); % Only calibrate first PCA 

% Simulate the first PC and assume other PC's are constant
xVasicek = simVas(x, 3, 1/252, theta, sigma, k);
%           ARGS: x = PC's, numYears in Future, delta, theta, sigma, k)    
%           Note that the params only correspond to the first PCA 

% Transform back to interest rate world  
simRatesVas = (Q * diag(Lambda)^(1/2) * xVasicek')';
for i=1:48
    plot(1:756, simRatesVas(:,i));
    hold on;
end
hold off;
%% CIR Model Example 
% Calibration the model
clc;
[alpha1, mu1, sigma1] = CalibrateCIR(r(:,1), 1/252); 
[alpha2, mu2, sigma2] = CalibrateCIR(r(:,10), 1/252); 
[alpha3, mu3, sigma3] = CalibrateCIR(r(:,40), 1/252); 

alpha = [alpha1;alpha2;alpha3];
mu = [mu1;mu2;mu3];
sigma = [sigma1;sigma2;sigma3];
cor = corr(r(:,[1,10,40]));

delta = 1/252;
T = 25;
N = T/delta;

rCIR = simCIR(r(end,[1,10,40])', alpha, mu, sigma, cor, T, delta);

for i=[1,10,40]
    plot(1:length(r), r(:,i));
    hold on;
end
hold off;

for i=1:3
    plot([1:N+length(r)], [r(:,[1,10,40]); rCIR]);
    hold on;
end
hold off;
