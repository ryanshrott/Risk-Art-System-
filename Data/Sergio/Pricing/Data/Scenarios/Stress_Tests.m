%% Stress Scenarios
%% Original Data
clear;clc
file_path = 'C:\Users\sergio.ortizorendain\Documents\MATLAB\Pricing\Data\portfolio_data.xlsm';
value = price_bonds_with_r_and_s(file_path);
%% Black Monday 1987

% CAD rates
[CAD_rates, ~, ~] = xlsread(file_path, 'CAD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
CAD_rates = CAD_rates(end, 1:end);
% EURO rates
[EUR_rates, ~, ~] = xlsread(file_path, 'EUR');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
EUR_rates = EUR_rates(end, 1:end);
% USD rates
[USD_rates, ~, ~] = xlsread(file_path, 'USD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
USD_rates = USD_rates(end, 1:end);
% Stress Impact in rates
CAD_stress = 1 + [-1.648 -1.648	-1.648	-1.648	-1.648	-1.648	-1.648	-1.648	-1.648	-1.648	-1.648	-1.648	-1.648 -1.648 -1.648]./100;
USD_stress = 1 + [-4.63	-4.63	-4.63	-4.63	-4.56	-4.5	-4.43	-3.55	-3.11	-2.67	-2.23	-2.23	-2.23 -2.23	-2.23]./100;
EUR_stress = 1 + [-8 -8	-8	-8	-8	-8	-8	-8	-8	-8	-8	-8	-8	-8	-8]./100;
financial_spreads = 0.07523;
industrial_spreads = 0.0347;
% Calcualtes new rates with stress
CAD_rates = CAD_rates.*CAD_stress;
EUR_rates = EUR_rates.*EUR_stress;
USD_rates = USD_rates.*USD_stress;

value_BM = stress_pricer_bonds(file_path,CAD_rates,EUR_rates,USD_rates);

%% Mexico 1994

% CAD rates
[CAD_rates, ~, ~] = xlsread(file_path, 'CAD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
CAD_rates = CAD_rates(end, 1:end);
% EURO rates
[EUR_rates, ~, ~] = xlsread(file_path, 'EUR');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
EUR_rates = EUR_rates(end, 1:end);
% USD rates
[USD_rates, ~, ~] = xlsread(file_path, 'USD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
USD_rates = USD_rates(end, 1:end);
% Stress Impact in rates

USD_stress = 1 + [-0.98	-0.65	0	-10.96	-10.96	-10.96	-10.96	-10.42	-10.15	-9.88	-9.61	-8.86	-8.1	-7.35	-6.6]./100;
CAD_stress = 1 + [21.26	14.17	0	-7.93	-7.93	-7.94	-7.94	-6.68	-6.05	-5.41	-4.78	-3.58	-2.39	-1.19	0]./100;
EUR_stress = 1 + [-6.46	-6.46	-6.51	-6.6	-5.85	-5.11	-4.36	-3.41	-2.93	-2.46	-1.98	-1.98	-1.98	-1.98	-1.98]./100;
% Calcualtes new rates with stress
CAD_rates = CAD_rates.*CAD_stress;
EUR_rates = EUR_rates.*EUR_stress;
USD_rates = USD_rates.*USD_stress;

value_Mex = stress_pricer_bonds(file_path,CAD_rates,EUR_rates,USD_rates);

%% Asia Currency Crisis and Stock Crisis 97 - 98

% CAD rates
[CAD_rates, ~, ~] = xlsread(file_path, 'CAD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
CAD_rates = CAD_rates(end, 1:end);
% EURO rates
[EUR_rates, ~, ~] = xlsread(file_path, 'EUR');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
EUR_rates = EUR_rates(end, 1:end);
% USD rates
[USD_rates, ~, ~] = xlsread(file_path, 'USD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
USD_rates = USD_rates(end, 1:end);
% Stress Impact in rates

USD_stress = 1 + [-3.51	-4.71	-7.11	-11.9	-12.51	-13.11	-13.72	-13.58	-13.51	-13.44	-13.37	-13.23	-13.09	-12.94	-12.8]./100;
CAD_stress = 1 + [31.13	27.27	19.55	4.11	0.03	-4.05	-8.13	-10.09	-11.08	-12.06	-13.04	-13.04	-13.04	-13.04	-13.04]./100;
EUR_stress = 1 + [12.62	12.62	12.62	12.62	8.27	3.93	-0.42	-3.55	-5.11	-6.68	-8.24	-8.24	-8.24	-8.24	-8.24]./100;
% Calcualtes new rates with stress
CAD_rates = CAD_rates.*CAD_stress;
EUR_rates = EUR_rates.*EUR_stress;
USD_rates = USD_rates.*USD_stress;

value_Asia = stress_pricer_bonds(file_path,CAD_rates,EUR_rates,USD_rates);

%% LTCM and Russian Default (1998)

% CAD rates
[CAD_rates, ~, ~] = xlsread(file_path, 'CAD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
CAD_rates = CAD_rates(end, 1:end);
% EURO rates
[EUR_rates, ~, ~] = xlsread(file_path, 'EUR');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
EUR_rates = EUR_rates(end, 1:end);
% USD rates
[USD_rates, ~, ~] = xlsread(file_path, 'USD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
USD_rates = USD_rates(end, 1:end);
% Stress Impact in rates

USD_stress = 1 + [-5.56	-7.39	-11.04	-18.34	-17.33	-16.32	-15.31	-14.3	-13.79	-13.29	-12.78	-11.56	-10.34	-9.12	-7.9]./100;
CAD_stress = 1 + [5.51	3.24	-1.31	-10.4	-10.68	-10.97	-11.25	-9.72	-8.96	-8.19	-7.43	-7.43	-7.43	-7.43	-7.43]./100;
EUR_stress = 1 + [-14.91	-14.91	-14.91	-14.91	-14.7	-14.48	-14.27	-13.18	-12.63	-12.09	-11.54	-10.56	-9.57	-8.58	-7.6]./100;
% Calcualtes new rates with stress
CAD_rates = CAD_rates.*CAD_stress;
EUR_rates = EUR_rates.*EUR_stress;
USD_rates = USD_rates.*USD_stress;

value_LTCM = stress_pricer_bonds(file_path,CAD_rates,EUR_rates,USD_rates);

%% 9/11

% CAD rates
[CAD_rates, ~, ~] = xlsread(file_path, 'CAD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
CAD_rates = CAD_rates(end, 1:end);
% EURO rates
[EUR_rates, ~, ~] = xlsread(file_path, 'EUR');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
EUR_rates = EUR_rates(end, 1:end);
% USD rates
[USD_rates, ~, ~] = xlsread(file_path, 'USD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
USD_rates = USD_rates(end, 1:end);
% Stress Impact in rates

USD_stress = 1 + [64.58	46.49	10.3	15.31	16.83	18.34	19.86	18.48	17.79	17.1	16.41	12.73	9.06	5.38	1.7]./100;
CAD_stress = 1 + [-10.11	-10.11	-10.11	-2.54	1.09	4.72	5.26	6.36	6.91	7.45	8	7.33	6.65	5.98	5.3]./100;
EUR_stress = 1 + [2.13	-1.6	-9.06	-4.82	-3.46	-2.09	-0.73	-0.13	0.16	0.46	0.76	0.76	0.76	0.76	0.76]./100;
% Calcualtes new rates with stress
CAD_rates = CAD_rates.*CAD_stress;
EUR_rates = EUR_rates.*EUR_stress;
USD_rates = USD_rates.*USD_stress;

value_911 = stress_pricer_bonds(file_path,CAD_rates,EUR_rates,USD_rates);

%% Greece 2010

% CAD rates
[CAD_rates, ~, ~] = xlsread(file_path, 'CAD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
CAD_rates = CAD_rates(end, 1:end);
% EURO rates
[EUR_rates, ~, ~] = xlsread(file_path, 'EUR');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
EUR_rates = EUR_rates(end, 1:end);
% USD rates
[USD_rates, ~, ~] = xlsread(file_path, 'USD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
USD_rates = USD_rates(end, 1:end);
% Stress Impact in rates

USD_stress = 1 + [65.83	55.44	34.66	-6.89	-9.52	-12.14	-14.77	-14.29	-14.06	-13.82	-13.58	-13.22	-12.85	-12.49	-12.12]./100;
CAD_stress = 1 + [19.06	14.18	4.41	-15.12	-13.81	-12.51	-11.2	-9.5	-8.66	-7.81	-6.96	-6.96	-6.95	-6.95	-6.94]./100;
EUR_stress = 1 + [4.17	4.17	-1.82	-13.79	-13.33	-12.88	-12.42	-11.59	-11.17	-10.76	-10.34	-10.34	-10.34	-10.34	-10.34]./100;
% Calcualtes new rates with stress
CAD_rates = CAD_rates.*CAD_stress;
EUR_rates = EUR_rates.*EUR_stress;
USD_rates = USD_rates.*USD_stress;

value_greece = stress_pricer_bonds(file_path,CAD_rates,EUR_rates,USD_rates);

%% Debt Ceiling 2011

% CAD rates
[CAD_rates, ~, ~] = xlsread(file_path, 'CAD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
CAD_rates = CAD_rates(end, 1:end);
% EURO rates
[EUR_rates, ~, ~] = xlsread(file_path, 'EUR');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
EUR_rates = EUR_rates(end, 1:end);
% USD rates
[USD_rates, ~, ~] = xlsread(file_path, 'USD');
% Keep the most recent rates. They are contained in the the last row of the
% Excel file.
USD_rates = USD_rates(end, 1:end);
% Stress Impact in rates

USD_stress = 1 + [8.6	7.66	5.77	-11.17	-11.17	-11.17	-11.17	-14.3	-15.87	-17.43	-19	-18.39	-17.78	-17.17	-16.56]./100;
CAD_stress = 1 + [-2.09	-13.05	-34.98	-42.38	-38.08	-33.79	-29.49	-23.66	-20.75	-17.83	-14.92	-13.54	-12.16	-10.77	-9.39]./100;
EUR_stress = 1 + [-3.5	-8.67	-19	-26	-23.33	-20.67	-18	-14.8	-13.2	-11.6	-10	-10	-10	-10	-10]./100;
% Calcualtes new rates with stress
CAD_rates = CAD_rates.*CAD_stress;
EUR_rates = EUR_rates.*EUR_stress;
USD_rates = USD_rates.*USD_stress;

value_debtus = stress_pricer_bonds(file_path,CAD_rates,EUR_rates,USD_rates);
