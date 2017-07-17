function [alpha, mu, sigma] = CalibrateCIR(x, delta)
%This function calibrates the CIR model 
% Inputs:
% x = historic term structure
x1Tilde = x(1:end-1);
dx = diff(x);
dx = dx./x1Tilde.^0.5;
regressors = [delta./x1Tilde.^0.5, delta*x1Tilde.^0.5];
drift = regressors\dx; % OLS regressors coefficients estimates
res = regressors*drift - dx;
alpha = -drift(2);
mu = -drift(1)/drift(2);
sigma = sqrt(var(res, 1)/delta);

end

