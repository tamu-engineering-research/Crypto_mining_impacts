function Step5_Run_OPF_for_Days(data_folder, mpc_UC, mpc_ED, xgd_UC, xgd_ED, mpopt_UC, mpopt_ED,...
    start_day, end_day, nt, ...
    wind, solar, hydro, ...
    bus_crypto, nodal_load_hourly, nodal_crypto_hourly, ...
    flg_flexible, type_flexible, price_max)
    define_constants;
    %% run UC and ED along time
    if ~exist(data_folder, 'dir')
        mkdir(data_folder)
    end
    init_UC = [];
    init_ED = [];
    for day = start_day:end_day
        disp(['running UC and ED with CC for day ',num2str(day)]);
        % nodal load
        start_hour = (day-1)*nt+1;
        end_hour = day*nt;
        nodal_load = nodal_load_hourly(start_hour:end_hour,:);
        nodal_crypto  = nodal_crypto_hourly(start_hour:end_hour,:);
        if (day>=221) && (day<=224) % ad hoc modification to make UC feasible
            nodal_load = nodal_load*0.96;
        end
        % add constant crypto load
        nodal_load_UC = nodal_load;
        for i = bus_crypto
            nodal_load_UC(:, i) = nodal_load_UC(:, i)+ nodal_crypto(:, i);
        end
        % renewable capacity
        indices_t = (1:nt) + (day-1)*nt;
        wind_pen = wind.wind_MW(indices_t,:);
        solar_pen = solar.solar_MW(indices_t,:);
        hydro_pen = hydro.hydro_MW(indices_t,:);
        % UC
        UC_file = [data_folder, 'SCUC-results-day-',num2str(day),'.mat'];
        if isfile(UC_file)
            load(UC_file,'mdo_UC','ms_UC');
        else
            [mdo_UC, ms_UC] = daily_nodal_opf(mpc_UC, xgd_UC, nodal_load_UC, wind_pen, solar_pen, hydro_pen, init_UC, mpopt_UC);
            save(UC_file,'mdo_UC','ms_UC');
        end
        try
            init_UC.commit = mdo_UC.UC.CommitSched(:,end);
            init_UC.dispatch = mdo_UC.results.ExpectedDispatch(:,end);
        catch
            disp(['UNSOLVED UC for DAY ', num2str(day)])
            init_UC = [];
            continue;
        end
        
        % add crypto load to ED
        nodal_load_ED = nodal_load;
        active_crypto_ED = [];
        for hour=1:nt
            active_crypto_ED_tmp = 0;
            for i = bus_crypto
                if flg_flexible
                    if strcmp(type_flexible, 'price')
                        if mdo_UC.flow(hour).mpc.bus(i,LAM_P)<=price_max
                            nodal_load_ED(hour, i) = nodal_load_ED(hour, i) + nodal_crypto(hour, i);
                            active_crypto_ED_tmp = active_crypto_ED_tmp + nodal_crypto(hour, i);
                        end
                    else
                        disp('UNEXPECTED FLEXIBILITY TYPE.')
                    end
                else
                    nodal_load_ED(hour, i) = nodal_load_ED(hour, i) + nodal_crypto(hour, i);
                    active_crypto_ED_tmp = active_crypto_ED_tmp + nodal_crypto(hour, i);
                end
            end
            active_crypto_ED = [active_crypto_ED, active_crypto_ED_tmp];
        end
        % ED
        xgd_ED.CommitSched = mdo_UC.UC.CommitSched;
        ED_file = [data_folder, 'SCED-results-day-',num2str(day),'.mat'];
        if isfile(ED_file)
            load(ED_file, 'mdo_ED','ms_ED','nodal_load_ED','active_crypto_ED');
        else
            [mdo_ED, ms_ED] = daily_nodal_opf(mpc_ED, xgd_ED, nodal_load_ED, wind_pen, solar_pen, hydro_pen, init_ED, mpopt_ED);
            save(ED_file,'mdo_ED','ms_ED','nodal_load_ED','active_crypto_ED');
        end
        try
            init_ED.commit = mdo_ED.UC.CommitSched(:,end);
            init_ED.dispatch = mdo_ED.results.ExpectedDispatch(:,end);
        catch
            disp(['UNSOLVED ED for DAY ', num2str(day)])
            init_ED = [];
        end
    end
end