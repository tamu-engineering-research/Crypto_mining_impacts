function carbon_total = Calculate_CarbonEmission(mpc, gen_PG, LCGHG)
    gen_num = size(mpc.gen, 1);
    assert(size(mpc.gen, 1)==length(mpc.genfuel));
    carbon_total = 0;
    for i=1:gen_num
        genfuel_tmp = mpc.genfuel(i);
        switch genfuel_tmp{1}
            case 'ng'
                carbon_pu = LCGHG.gas;
            case 'nuclear'
                carbon_pu = LCGHG.nuclear;
            case 'solar'
                carbon_pu = LCGHG.solar;
            case 'wind'
                carbon_pu = LCGHG.wind;
            case 'hydro'
                carbon_pu = LCGHG.hydro;
            case 'coal'
                carbon_pu = LCGHG.coal;
        end
        carbon_total = carbon_total + gen_PG(i)*carbon_pu;
    end
end