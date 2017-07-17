function newX = simVas(x, T, delta, z, theta, sigma, k, riskNeutral)
% This function simulates rates in the future using the Vasicek model
% Inputs:
% r = historic term structure of rates 
% T = The number of years in future to simulate 
% delta = The number of years for discretization

if nargin < 8
    riskNeutral =   0;
end

% Simulating in risk neutral measure
lambda = -1.2; % The market price of risk for interest rates 
if (riskNeutral ==1)
    theta = theta - lambda * sigma / k; % Adjust the drift of the process
end
    
% The current known value of x 
x1 = x(:,1);
x_current = x(end,:);
x1_current = x1(end);

N = T / delta;
simulatedx1 = zeros(N,1);
simulatedx1(1) = x1_current * exp(-k*delta) + theta * (1 - exp(-k * delta)) + sigma * sqrt((1-exp(-2*k*delta))/2/k) * z(1);

for i=2:length(simulatedx1)
    simulatedx1(i) = simulatedx1(i-1) * exp(-k*delta) + theta * (1 - exp(-k * delta)) + sigma * sqrt((1-exp(-2*k*delta))/2/k) *z(i);
end

temp = zeros(N,size(x,2)-1);
for i=1:size(x,2)-1
    temp(:,i) = repmat(x_current(i+1), N,1);
end

newX = [simulatedx1, temp];

end

