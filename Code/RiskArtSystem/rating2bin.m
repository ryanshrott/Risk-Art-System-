function y = rating2bin(x)
% Input:
%     y = the column in a matrix of spreads to which x belongs
% Output:
%     x = a string representing the rating of a bond

if strcmp(x, 'AAA+')||strcmp(x, 'AAA')||strcmp(x, 'AAA-')
    y = 1;
elseif strcmp(x, 'AA+')||strcmp(x, 'AA')||strcmp(x, 'AA-')
    y = 2;
elseif strcmp(x, 'A+')||strcmp(x, 'A')||strcmp(x, 'A-')
    y = 3;
elseif strcmp(x, 'BBB+')||strcmp(x, 'BBB')||strcmp(x, 'BBB-')
    y = 4;
elseif strcmp(x, 'BB+')||strcmp(x, 'BB')||strcmp(x, 'BB-')
    y = 5;
elseif strcmp(x, 'B+')||strcmp(x, 'B')||strcmp(x, 'B-')
    y = 6;
else
    y = 7;
end

end