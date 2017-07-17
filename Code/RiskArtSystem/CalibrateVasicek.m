function [theta,sigma,k] = CalibrateVasicek(S,delta)
  n = length(S)-1;
 
  Sx  = sum( S(1:end-1) );
  Sy  = sum( S(2:end) );
  Sxx = sum( S(1:end-1).^2 );
  Sxy = sum( S(1:end-1).*S(2:end) );
  Syy = sum( S(2:end).^2 );
 
  theta  = (Sy*Sxx - Sx*Sxy) / ( n*(Sxx - Sxy) - (Sx^2 - Sx*Sy) );
  k = -log( (Sxy - theta*Sx - theta*Sy + n*theta^2) / (Sxx -2*theta*Sx + n*theta^2) ) / delta;
  a = exp(-k*delta);
  sigmah2 = (Syy - 2*a*Sxy + a^2*Sxx - 2*theta*(1-a)*(Sy - a*Sx) + n*theta^2*(1-a)^2)/n;
  sigma = sqrt(sigmah2*2*k/(1-a^2));
end