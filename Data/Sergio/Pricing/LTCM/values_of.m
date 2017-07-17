function y = values_of(x)
% ------------------------------------------------------------------------
% x = a string that describes the quantity of interest. E.g, 'Price',
% 'Coupon', 'Duration'.
% y = the values of x
% ------------------------------------------------------------------------

% Against best practices, define global variables to avoid passing data
% around all the time.
global column_labels
global raw_data

y = cell2mat(...
    raw_data(:, find(strcmp(column_labels, x)))...
    );

end