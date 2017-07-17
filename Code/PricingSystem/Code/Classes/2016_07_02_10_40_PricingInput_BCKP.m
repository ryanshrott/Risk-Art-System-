classdef PricingInput
   properties
       num_of_days_elapsed      % Used to calculate times to maturity for all derivatives
       stock_prices
       risk_free_rate           % 1x1: USD risk-free rate used to price the three options
       spot_prices              % 3x1: spot prices of underlyings
       implied_vol              % 3x1: implied vols used in BSM formula
       % options_time_to_maturity % in years
       zero_curve_USD
       zero_curve_CAD
       zero_curve_EUR
       rate_time_structure
       USDCAD
       EURCAD
       bond_ratings             % 25x1: each entry is an integer between 1 and 7. The best rating corresponds to 1 and the worst to 7.
       spread_structure
       % bonds_time_to_maturity   % in years
       % CDS
       % CDS_days_to_maturity     % in days
   end
   %
   methods
       function obj = PricingInput(stock_prices_, risk_free_rate_, spot_prices_,...
               implied_vol_, options_time_to_maturity_, zero_curve_USD_, zero_curve_CAD_,...
               zero_curve_EUR_, rate_time_structure_, USDCAD_, EURCAD_,...
               bond_ratings_, spread_structure_, bonds_time_to_maturity_, ...
               CDS_days_to_maturity_)
           if nargin > 0
               obj.stock_prices = stock_prices_;
               obj.spot_prices = spot_prices_;
               obj.implied_vol = implied_vol_;
               obj.zero_curve_USD = zero_curve_USD_;
               obj.zero_curve_CAD = zero_curve_CAD_;
               obj.zero_curve_EUR = zero_curve_EUR_;
               obj.rate_time_structure = rate_time_structure_;
               obj.USDCAD = USDCAD_;
               obj.EURCAD = EURCAD_;
               obj.bond_ratings = bond_ratings_;
               obj.spread_structure = spread_structure_;
               obj.risk_free_rate = risk_free_rate_;
               obj.options_time_to_maturity = options_time_to_maturity_;
               obj.bonds_time_to_maturity = bonds_time_to_maturity_;
               obj.CDS_days_to_maturity = CDS_days_to_maturity_;
           end
       end
   end
end