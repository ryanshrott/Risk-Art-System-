% Bond Vetting

quantity = 1;
notional = 100;
frequency = 2;
daysToMat = 2658;
longShort = 1;
couponRate = 0.06875;
yield = 0.0284;

% USD Term Strucure 
zeroCurve = [0.38	0.3928	0.384	0.37	0.3703	0.3765	0.3812	0.3946	0.4011	0.4094	0.4332	0.4512	0.4925	0.528	0.597	0.683	0.76	1.123];

termTimes = [0.00	0.02	0.04	0.06	0.08	0.17	0.25	0.33	0.42	0.50	0.75	1.00	1.50	2.00	3.00	4.00	5.00	10.00];

bPrice = bondPrice(quantity, notional, couponRate, frequency, daysToMat, termTimes, zeroCurve, longShort);

bPricey = bondPriceyield(quantity, notional, couponRate, frequency, daysToMat, yield, longShort);