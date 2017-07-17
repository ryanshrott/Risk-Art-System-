

ret = zeros(647,3);
for i=1:1
    ret(:,i) = log(equities(2:end,i)./equities(1:end-1,i));
end


S0 = equities(end,1)';       % Price of underlying today
mu = mean(ret(:,1))'*252;     % expected return
sigma = std(ret(:,1))'*sqrt(252);

delta = 1/252; % time steps
T = 1;

N = T / delta;

z = normrnd(0,1,N,1);


S = zeros(N,length(S0));

S(1) = S0 * exp((mu-sigma.^2/2)*delta + sigma*sqrt(delta) *z(1));

for i=2:N
    S(i) = S(i-1) * exp((mu-sigma.^2/2)*delta + sigma.*sqrt(delta) .*z(i));
end

plot(1:252+648,[equities(:,1); S(:,1)])

