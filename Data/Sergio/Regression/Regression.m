clear;clc
file_path = 'C:\Users\sergio.ortizorendain\Desktop\CDS_Stress.xlsx';
sheet = 'SPREAD';
range = 'A1:BW651';
% All the data will be in raw_data
[~, ~, raw_data] = xlsread(file_path, sheet, range);

% Read the headers of the excel file to know where is what
column_labels = raw_data(1, :);
% Remove the headers once for all to avoid offsetting all the time
raw_data = raw_data(6:650,2:end);

% Index called CDXTIL15 Index ig
% Index called CDXTHL15 Index HY
%% Regression Investment Grade

for i = 3:74
lm = fitlm(cell2mat(raw_data(:,2)),cell2mat(raw_data(:,i)));
a_ig(i) = lm.Coefficients.Estimate(1);
b_ig(i) = lm.Coefficients.Estimate(2);
% sig(i,1) = lm.Coefficients.pValue(1);
% sig(i,2) = lm.Coefficients.pValue(2);
% sig(i,3) = lm.Coefficients.pValue(3);
end

%% Regression High Yield

for i = 3:74
lm = fitlm(cell2mat(raw_data(:,1)),cell2mat(raw_data(:,i)));
a_hy(i) = lm.Coefficients.Estimate(1);
b_hy(i) = lm.Coefficients.Estimate(2);
end


%% Out of Sample
file_path = 'C:\Users\sergio.ortizorendain\Desktop\CDS_Stress.xlsx';
sheet = 'STRESS';
range = 'A1:C753';
% All the data will be in raw_data
[~, ~, raw_data] = xlsread(file_path, sheet, range);

% Read the headers of the excel file to know where is what
column_labels = raw_data(1, :);
raw_data = raw_data(2:end,:);


for i = 3:74
out_sample_ig(:,i-2) = a_ig(i) + b_ig(i)*cell2mat(raw_data(:,3));
out_sample_hy(:,i-2) = a_hy(i) + b_hy(i)*cell2mat(raw_data(:,2));
end
