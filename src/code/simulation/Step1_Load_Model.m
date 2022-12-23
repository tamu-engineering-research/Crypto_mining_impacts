function [mpc_UC, mpc_ED, xgd_UC, xgd_ED] = Step1_Load_Model(dir_model, xGenData_dir, bus_crypto)
    define_constants;
    mpc_UC = loadcase(dir_model);
    mpc_UC.gen(strcmp(mpc_UC.genfuel,'solar'),PMIN) = 0;
    mpc_UC.gen(strcmp(mpc_UC.genfuel,'wind'),PMIN) = 0;
    mpc_ED = loadcase(dir_model);
    mpc_ED.gen(strcmp(mpc_ED.genfuel,'solar'),PMIN) = 0;
    mpc_ED.gen(strcmp(mpc_ED.genfuel,'wind'),PMIN) = 0;
    
    xgd_UC = loadxgendata(xGenData_dir, mpc_UC);
    xgd_ED = loadxgendata(xGenData_dir, mpc_ED);
    
    for bus = bus_crypto % create a load if it does not exist at the bus in the original model
        if (mpc_UC.bus(bus, PD)==0) && (mpc_UC.bus(bus, QD)==0)
            mpc_UC.bus(bus, PD)=1;
        end
        if (mpc_ED.bus(bus, PD)==0) && (mpc_ED.bus(bus, QD)==0)
            mpc_ED.bus(bus, PD)=1;
        end
    end
end