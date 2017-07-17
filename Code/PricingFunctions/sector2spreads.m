function y = sector2spreads(sector, unique_sectors, spreads)
% Input arguments:
%     sector  = The name of a sector.
%     spreads = A cellarray containing all the spreads. Each cell
%               corresponds to a different sector.

% Output arguments:
%     y = The spreads of the sector specified in the input argument 'sector'

k = find(strcmp(unique_sectors, sector));
y = spreads{k};

end