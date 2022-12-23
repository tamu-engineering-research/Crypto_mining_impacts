
%% load hourly data 
[demand, hydro, wind, solar, nodal_load_hourly] = Step2_Load_Data( ...
    '../../model/BTE_2000/texas_2020_demand.mat', ...
    '../../model/BTE_2000/texas_2020_hydro.mat', ...
    '../../model/BTE_2000/texas_2020_wind.mat', ...
    '../../model/BTE_2000/texas_2020_solar.mat', ...
    '../../model/BTE_2000/nodal_load_hourly.mat');

%% create crypto mining load
type_crypto_location = 'realmining';
total_crypto_load = 100;
nodal_crypto_size = size(nodal_load_hourly);
[bus_crypto, nodal_crypto_hourly] = Step3_Get_Crypto_Load(type_crypto_location, total_crypto_load, nodal_crypto_size);

%% load MATPOWER model
dir_model = "../../model/BTE_2000/case2000_BRE_PWL.m"; % change the folder accordingly
xGenData_dir = 'xgd_case2000_BRE.m'; % change the folder accordingly
[mpc_UC, mpc_ED, xgd_UC, xgd_ED] = Step1_Load_Model(dir_model, xGenData_dir, bus_crypto);


%% define opf options
timelimit = 2; % upper limit of hours for solving one day
[mpopt_UC, mpopt_ED] = Step4_Define_OPF_Setting(timelimit);

%% run opf for all days
data_folder = ['F:/Crypto_Mining/', 'realmining_2020/']; % change the data folder accordingly
start_day = 180;
end_day = 240;
nt = 24;
flg_flexible = false;
type_flexible = 'price';
price_max = 40;
Step5_Run_OPF_for_Days( ...
    data_folder, mpc_UC, mpc_ED, xgd_UC, xgd_ED, mpopt_UC, mpopt_ED,...
    start_day, end_day, nt, ...
    wind, solar, hydro, ...
    bus_crypto, nodal_load_hourly, nodal_crypto_hourly, ...
    flg_flexible, type_flexible, price_max);