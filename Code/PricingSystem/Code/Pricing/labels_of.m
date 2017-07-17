function y = labels_of(x, column_labels, raw_data)
% ------------------------------------------------------------------------
% x = a string that describes the quantity of interest. E.g, 'Price',
% 'Coupon', 'Duration'.
% y = the values of x
% ------------------------------------------------------------------------

y = raw_data(:, find(strcmp(column_labels, x)));

end