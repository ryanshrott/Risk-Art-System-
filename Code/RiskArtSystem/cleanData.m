function input = cleanData(input)

t = linspace(1, size(input,1), size(input,1));

% indices to NaN values in x 
% (assumes there are no NaNs in t)
nans = isnan(input);

nans = input<=0;


% replace all NaNs in x with linearly interpolated values

for i=1:size(input,2)
    temp = input(:,i);
    input(nans(:,i),i) = interp1(t(~nans(:,i)), temp(~nans(:,i)), t(nans(:,i)));
end


end