function S = AssetPathsCorrelated(S0,mu,sig,corr,dt,steps,nsims)
% Function to generate correlated sample paths for assets assuming
% geometric Brownian motion.
%
% S = AssetPathsCorrelated(S0,mu,sig,corr,dt,steps,nsims)
%
% Inputs: S0 - stock price
%       : mu - expected return
%       : sig - volatility
%       : corr - correlation matrix
%       : dt - size of time steps
%       : steps - number of time steps to calculate
%       : nsims - number of simulation paths to generate
%
% Output: S - a (steps+1)-by-nsims-by-nassets 3-dimensional matrix where
%             each row represents a time step, each column represents a
%             seperate simulation run and each 3rd dimension represents a
%             different asset.
%
% Notes: This code focuses on details of the implementation of the
%        Monte-Carlo algorithm.
%        It does not contain any programatic essentials such as error
%        checking.
%        It does not allow for optional/default input arguments.
%        It is not optimized for memory efficiency or speed.


% get the number of assets
nAssets = length(S0);

% calculate the drift
nu = mu - sig.*sig/2;

% do a Cholesky factorization on the correlation matrix
R = chol(corr);
% pre-allocate the output
S = nan(steps+1,nsims,nAssets);

% generate correlated random sequences and paths
for idx = 1:nsims
    % generate uncorrelated random sequence
    x = randn(steps,size(corr,2));
    % correlate the sequences
    ep = x*R;

    % Generate potential paths
    S(:,idx,:) = [ones(1,nAssets); ...
        cumprod(exp(repmat(nu*dt,steps,1)+ep*diag(sig)*sqrt(dt)))]*diag(S0);
end

% If only one simulation then remove the unitary dimension
if nsims==1
    S = squeeze(S);
end   