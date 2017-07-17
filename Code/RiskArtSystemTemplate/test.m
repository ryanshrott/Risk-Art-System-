% Script to price an Asian put option using a monte-carlo approach.
S0 = [50 48]  ;       % Price of underlying today
mu = [0.03 0.06];     % expected return
sig = [0.05 0.1];     % expected vol.
corr = [1 0.5;0.5 1]; % correlation matrix
dt = 1/365;   % time steps
etime = 50;   % days to expiry
T = dt*etime; % years to expiry

nruns = 1; % Number of simulated paths

% Generate potential future asset paths
S = AssetPathsCorrelated(S0,mu,sig,corr,dt,etime,nruns);

% Plot one set of sample paths
time = etime:-1:0;
plot(time,squeeze(S(:,1,:)),'Linewidth',2);
set(gca,'XDir','Reverse','FontWeight','bold','Fontsize',24);
xlabel('Time to Expiry','FontWeight','bold','Fontsize',24);
ylabel('Asset Price','FontWeight','bold','Fontsize',24);
title('One Set of Simulated Asset Paths','FontWeight','bold','Fontsize',24);
grid on
set(gcf,'Color','w');