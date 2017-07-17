function simulatedFX = simCIR(fx0, alpha, mu, sigma, z, T, delta)
% This function simulates rates in the future using the CIR model
% Inputs: 
% fx0 = Current FX rates 
% T = The number of years in future to simulate 
% delta = The number of years for discretization


N = T / delta;
simulatedFX = zeros(N,length(fx0));

simulatedFX(1,:) = fx0 + alpha .* (mu - fx0) .* delta + sigma .* sqrt(fx0.*delta).*z(1,:)';


for i=2:length(simulatedFX)
    simulatedFX(i,:) = simulatedFX(i-1,:)' + alpha .* (mu - simulatedFX(i-1)) .* delta + sigma .* sqrt(simulatedFX(i-1)*delta).*z(i,:)';
end

end


