function newCurve = interp(times, termTimes, zeroCurve)
% Description: This function interpolates rates based on new times 

% Inputs:
% times = the times you want to interpolate
% termTimes = KNOWN times corresponding to known zeroCurve
% zeroCurve = KNOWN curve corresponding to the KNOWN term times 

newCurve = zeros(length(times), 1);

for i=1:length(times)
    binNum = find(times(i) >= termTimes(1:end-1) & times(i) <= termTimes(2:end), 1);
    newCurve(i) = zeroCurve(:,binNum) + (zeroCurve(:,binNum+1) - zeroCurve(:,binNum)) .* (times(i) - termTimes(binNum)) / (termTimes(binNum+1) - termTimes(binNum));
end

end


