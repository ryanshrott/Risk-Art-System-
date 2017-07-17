classdef PricingInput
   properties
       num_of_days_elapsed      % Used to calculate times to maturity for all derivatives
       stock_prices
       risk_free_rate           % 1x1: USD risk-free rate used to price the three options
       spot_prices              % 3x1: spot prices of underlyings
       spot_at_expiration       % 1x1: spot price at expiration for the first put option
       implied_vol              % 3x1: implied vols used in BSM formula
       zero_curve_USD
       zero_curve_CAD
       zero_curve_EUR
       rate_time_structure
       USDCAD
       EURCAD
       bond_ratings             % 25x1: each entry is an integer between 1 and 7. The best rating corresponds to 1 and the worst to 7.
       bond_market_prices
       historical_implied_spreads
       cds_underlying_rating
       % CDS data
       CDS_lambdas
       %    L_GE
       %    L_CNR
       %    L_Sabre
       %    L_Star
       %    L_News
       %    L_France
       %    L_Cat
       %    L_WF
       %    L_Huntsm
       
       % Pricing flags
       CDS     = 1;
       STOCKS  = 1;
       OPTIONS = 1;
       BONDS   = 1;
   end
   %
   methods
       function obj = PricingInput(num_of_days_elapsed_, stock_prices_, risk_free_rate_, spot_prices_,...
               spot_at_expiration_, implied_vol_, zero_curve_USD_, zero_curve_CAD_,...
               zero_curve_EUR_, rate_time_structure_, USDCAD_, EURCAD_,...
               bond_ratings_, lambdas)
           if nargin > 0
               obj.num_of_days_elapsed = num_of_days_elapsed_;
               obj.stock_prices = stock_prices_;
               obj.spot_prices = spot_prices_;
               obj.spot_at_expiration = spot_at_expiration_;
               obj.implied_vol = implied_vol_;
               obj.zero_curve_USD = zero_curve_USD_;
               obj.zero_curve_CAD = zero_curve_CAD_;
               obj.zero_curve_EUR = zero_curve_EUR_;
               obj.rate_time_structure = rate_time_structure_;
               obj.USDCAD = USDCAD_;
               obj.EURCAD = EURCAD_;
               obj.bond_ratings = bond_ratings_;
               obj.risk_free_rate = risk_free_rate_;
               obj.CDS_lambdas = lambdas;
               % obj.historical_implied_spreads = historical_implied_spreads_;
               
               % obj.L_GE = lambdas(1, :);
               % obj.L_CNR = lambdas(2, :);
               % obj.L_Sabre = lambdas(3, :);
               % obj.L_Star = lambdas(4, :);
               % obj.L_News = lambdas(5, :);
               % obj.L_France = lambdas(6, :);
               % obj.L_Cat = lambdas(7, :);
               % obj.L_WF = lambdas(8, :);
               % obj.L_Huntsm = lambdas(9, :);
           end
       end
   end
end