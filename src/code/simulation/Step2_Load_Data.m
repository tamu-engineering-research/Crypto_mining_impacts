function [demand, hydro, wind, solar, nodal_load_hourly] = Step2_Load_Data(demand_path, hydro_path, wind_path, solar_path, nodal_load_path)
    %% load yearly data
    demand = load('./Model/BTE_2000/texas_2020_demand.mat');
    hydro = load('./Model/BTE_2000/texas_2020_hydro.mat');
    wind = load('./Model/BTE_2000/texas_2020_wind.mat');
    solar = load('./Model/BTE_2000/texas_2020_solar.mat');
    nodal_load_hourly = load('./Model/BTE_2000/nodal_load_hourly.mat');
    nodal_load_hourly = nodal_load_hourly.nodal_load_hourly;
end