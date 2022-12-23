function [mpopt_UC, mpopt_ED] = Step4_Define_OPF_Setting(timelimit)
    %% opf options 
    mpopt_UC = mpoption('verbose',0);
    mpopt_UC = mpoption(mpopt_UC, 'gurobi.threads', 16);
    mpopt_UC = mpoption(mpopt_UC, 'gurobi.opts.timeLimit', timelimit*60*60); % time-limit = timelimit hours
    mpopt_UC = mpoption(mpopt_UC, 'gurobi.opts.MIPGap', 1e-3); % gap <= 0.1%
    mpopt_UC = mpoption(mpopt_UC, 'gurobi.opts.MIPGapAbs', 0);
    mpopt_UC = mpoption(mpopt_UC, 'gurobi.opts.OptimalityTol',1e-5); % default value is 1e-9
    mpopt_UC = mpoption(mpopt_UC, 'gurobi.opts.BarConvTol',1e-5); % default value is 1e-9
    mpopt_UC = mpoption(mpopt_UC, 'gurobi.opts.IntFeasTol',1e-5); % default value is 1e-9
    mpopt_UC = mpoption(mpopt_UC, 'gurobi.method',1);  % not using barrier, to avoid suboptimal solution
    mpopt_UC = mpoption(mpopt_UC, 'most.dc_model', 1); % consider DC line flow constraints
    mpopt_UC = mpoption(mpopt_UC, 'most.uc.run', 1); % do perform unit commitment
    mpopt_UC = mpoption(mpopt_UC, 'most.skip_prices', 0); % must have price computation for UC
    
    mpopt_ED = mpoption('verbose',0);
    mpopt_ED = mpoption(mpopt_ED, 'gurobi.threads', 16);
    mpopt_ED = mpoption(mpopt_ED, 'gurobi.opts.timeLimit', timelimit*60*60); % time-limit = timelimit hours
    mpopt_ED = mpoption(mpopt_ED, 'gurobi.opts.MIPGap', 1e-3); % gap <= 0.1%
    mpopt_ED = mpoption(mpopt_ED, 'gurobi.opts.MIPGapAbs', 0);
    mpopt_ED = mpoption(mpopt_ED, 'gurobi.opts.OptimalityTol',1e-5); % default value is 1e-9
    mpopt_ED = mpoption(mpopt_ED, 'gurobi.opts.BarConvTol',1e-5); % default value is 1e-9
    mpopt_ED = mpoption(mpopt_ED, 'gurobi.opts.IntFeasTol',1e-5); % default value is 1e-9
    mpopt_ED = mpoption(mpopt_ED, 'gurobi.method',1);  % not using barrier, to avoid suboptimal solution
    mpopt_ED = mpoption(mpopt_ED, 'most.dc_model', 1); % consider DC line flow constraints
    mpopt_ED = mpoption(mpopt_ED, 'most.uc.run', 0); % do perform unit commitment
    mpopt_ED = mpoption(mpopt_ED, 'most.skip_prices', 0); % must have price computation for UC
end