function stocks_value = price_stocks(x)

stocks_value = x.USDCAD*sum(x.stock_prices'*...
    PortfolioConstants.stock_positions);

end







%