function stocks_value = price_stocks(x, c)

stocks_value = x.USDCAD*sum(x.stock_prices'*...
    c.stock_positions);

end

%