function  [S] = simGBM(S0, mu, sigma, z, delta, T)
%simGBM: Generates a path of correlated GBM's
%Ouput = S = Simulated Asset Paths
%S0 = vector of intial prices
%mu = vector of expected returns 
%covMat = covariance matrix of returns 
%delta = delta t
%T = Number of years to simulate

N = T / delta;

S = zeros(N,length(S0));
S(1,:) = S0 .* exp((mu-sigma.^2/2)*delta + sigma.*sqrt(delta) .*z(1,:)');

for i=2:N
    S(i,:) = S(i-1,:)' .* exp((mu-sigma.^2/2)*delta + sigma.*sqrt(delta) .*z(i,:)');
end

end


