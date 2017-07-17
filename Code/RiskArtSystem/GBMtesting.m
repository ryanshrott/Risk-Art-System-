

ret = zeros(647,3);
for i=1:3
    ret(:,i) = log(equities(2:end,i)./equities(1:end-1,i));
end
r =  corr(ret);

z = mvnrnd(zeros(3,1), r, 1000);
z = normrnd(0,1,1000,3);

S0 = equities(end,:)';       % Price of underlying today
mu = mean(ret)';     % expected return
sigma = std(ret)';

delta = 1/252; % time steps
T = 1;

N = T / delta;


S = zeros(N,length(S0));
S(1,:) = S0 .* exp((mu-sigma.^2/2)*delta + sigma.*sqrt(delta) .*z(1,:)');

for i=2:N
    S(i,:) = S(i-1,:)' .* exp((mu-sigma.^2/2)*delta + sigma.*sqrt(delta) .*z(i,:)');
end

plot(1:252+648,[equities(:,1); sim(:,1)])

