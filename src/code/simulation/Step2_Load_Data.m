function [demand, hydro, wind, solar, nodal_load_hourly] = Step2_Load_Data(demand_path, hydro_path, wind_path, solar_path, nodal_load_path)
    %% load yearly data
    demand = load(demand_path);
    hydro = load(hydro_path);
    wind = load(wind_path);
    solar = load(solar_path);
    nodal_load_hourly = load(nodal_load_path);
    nodal_load_hourly = nodal_load_hourly.nodal_load_hourly;
end