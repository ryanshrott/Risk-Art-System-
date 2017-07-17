function [newRatings] = simRating(currentSim, currentRatings, transitionValues)

newRatings = zeros(length(currentSim),1);
for j=1:length(currentSim)  
        if(currentSim(j) < transitionValues(currentRatings(j), 1))
            newRatings(j) = 1;
        elseif(currentSim(j) < transitionValues(currentRatings(j), 2))
            newRatings(j) = 2;
        elseif(currentSim(j) < transitionValues(currentRatings(j), 3))
            newRatings(j) = 3;
        elseif(currentSim(j) < transitionValues(currentRatings(j), 4))
            newRatings(j) = 4;
        elseif(currentSim(j) < transitionValues(currentRatings(j), 5))
            newRatings(j) = 5;
        elseif(currentSim(j) < transitionValues(currentRatings(j), 6))
            newRatings(j) = 6;
        elseif(currentSim(j) < transitionValues(currentRatings(j), 7))
            newRatings(j) = 7; 
        else
            newRatings(j) = 8; 
        end 
end

end

