function [bus_crypto, nodal_crypto_hourly] = Step3_Get_Crypto_Load(type_location, total_crypto_load, nodal_crypto_size)
    bus_crypto = [];
    nodal_crypto_hourly = zeros(nodal_crypto_size);
    if strcmp(type_location, 'low_electricity_price')
        bus_crypto = [8, 9 , 58, 69, 70, 499, 545, 546, 547];
        for i = bus_crypto
            nodal_crypto_hourly(:,i) = total_crypto_load/length(bus_crypto);
        end
    elseif strcmp(type_location, 'close_to_renewable_A1')
        bus_crypto = [122, 140, 157, 159, 178, 202];
        for i = bus_crypto
            nodal_crypto_hourly(:,i) = total_crypto_load/length(bus_crypto);
        end
    elseif strcmp(type_location, 'close_to_renewable_A2')
        bus_crypto = [402, 403, 493, 497, 743, 903];
        for i = bus_crypto
            nodal_crypto_hourly(:,i) = total_crypto_load/length(bus_crypto);
        end
    elseif strcmp(type_location, 'realmining')
        county_crypto_hourly_table = readtable('./Data/large flexible load.csv');
        county_crypto_hourly = table2array(county_crypto_hourly_table(:,2:end));
        county_crypto_hourly = county_crypto_hourly(1:size(nodal_crypto_hourly,1),:);
        county_crypto_name = ["Hood","Bell","Milam","Upton","Denton","Dickens","Ward","Reeves","Deaf Smith"];
        assert(length(county_crypto_name)==size(county_crypto_hourly,2));
        bus2county = readmatrix('./Data/bus2county.csv');
        county_name = readtable('./Data/Texas_county_name.csv');
        for i = 1:length(county_crypto_name)
            county_id = find(strcmp(county_name{:,1}, county_crypto_name(i))) - 1 ; % county id starts from 0
            bus_num = find(bus2county(:,2)==county_id)';
            bus_crypto = [bus_crypto, bus_num];
            for j = bus_num
                nodal_crypto_hourly(:,j) = county_crypto_hourly(:,i)/length(bus_num);
            end
        end
    else
        disp('NO MINING LOADS ARE ADDED.')
    end
end