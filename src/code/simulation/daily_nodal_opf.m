function [mdo, ms] = daily_nodal_opf(mpc, xgd, nodal_load, wind_pen, solar_pen, hydro_pen, init, mpopt)

define_constants;

nb = size(mpc.bus, 1); nl = size(mpc.branch, 1); ng = size(mpc.gen, 1);
nt = 24; % 24 hours

if isfield('relax_bounds',mpopt)
    ub_scale = 1 + mpopt.relax_bounds;
    lb_scale = 1 - mpopt.relax_bounds;
else
    ub_scale = 1;
    lb_scale = 1;
end

%warning('the original case does not have consecutive bus numbers');
%% create a mapping: old_bus --> new_bus
old_bus = mpc.bus(:,BUS_I); new_bus = (1:nb)';
% re-number buses
mpc_ordered = mpc;
mpc_ordered.bus(:,BUS_I) = new_bus;

% re-number branches
for i = 1:nl
    f_bus = mpc.branch(i,F_BUS); t_bus = mpc.branch(i,T_BUS);
    f_ind = find(old_bus == f_bus);
    t_ind = find(old_bus == t_bus);
    mpc_ordered.branch(i,[F_BUS,T_BUS]) = new_bus([f_ind,t_ind]);
end
% re-number generators
for i = 1:ng
    g_bus = mpc.gen(i,GEN_BUS);
    g_ind = find(old_bus == g_bus);
    mpc_ordered.gen(i,GEN_BUS) = new_bus(g_ind);
end
%warning('DONE: renumber everything');

iwind = find(strcmp(mpc_ordered.genfuel,'wind'));
isolar = find(strcmp(mpc_ordered.genfuel,'solar'));
ihydro = find(strcmp(mpc_ordered.genfuel,'hydro'));

nwind = length(iwind);
nsolar = length(isolar);
nhydro = length(ihydro);

% mpc_ordered.gencost = zeros(ng,6);
% mpc_ordered.gencost(:,MODEL) = POLYNOMIAL;
% mpc_ordered.gencost(:,NCOST) = 1;

% generate load profiles
%disp('creating load profiles');
bus_ind = mpc_ordered.bus(:,BUS_I);
loadprofile = struct( ...
    'type', 'mpcData', ...
    'table', CT_TLOAD, ...
    'rows', bus_ind, ...
    'col', CT_LOAD_FIX_P, ...
    'chgtype', CT_REP, ...
    'values', [] );
loadprofile.values(:, 1, :) = nodal_load;
profiles = getprofiles(loadprofile);

%disp('creating wind profiles');
windprofile_max = struct( ...
    'type', 'mpcData', ...
    'table', CT_TGEN, ...
    'rows', 1:nwind, ... % 'rows', wind_rows, ...
    'col', PMAX, ...
    'chgtype', CT_REP, ...
    'values', [] );
windprofile_max.values(:, 1, :) = wind_pen * ub_scale;
profiles = getprofiles(windprofile_max,profiles,iwind);

% % % %     windprofile.values(:, 1, :) = zeros(nt,nwind);
% % % windprofile_min = struct( ...
% % %     'type', 'mpcData', ...
% % %     'table', CT_TGEN, ...
% % %     'rows', 1:nwind, ... % 'rows', wind_rows, ...
% % %     'col', PMIN, ...
% % %     'chgtype', CT_REP, ...
% % %     'values', [] );
% % % windprofile_min.values(:, 1, :) = wind_pen * lb_scale;
% % % profiles = getprofiles(windprofile_min,profiles,iwind);


%disp('creating solar profiles');
solarprofile_max = struct( ...
    'type', 'mpcData', ...
    'table', CT_TGEN, ...
    'rows', 1:nsolar, ...%         'rows', solar_rows, ...
    'col', PMAX, ...
    'chgtype', CT_REP, ...
    'values', [] );
solarprofile_max.values(:, 1, :) = solar_pen * ub_scale;
profiles = getprofiles(solarprofile_max,profiles,isolar);

% % % % solarprofile_min = struct( ...
% % % %     'type', 'mpcData', ...
% % % %     'table', CT_TGEN, ...
% % % %     'rows', 1:nsolar, ...%         'rows', solar_rows, ...
% % % %     'col', PMIN, ...
% % % %     'chgtype', CT_REP, ...
% % % %     'values', [] );
% % % % solarprofile_min.values(:, 1, :) = solar_pen * lb_scale;
% % % % profiles = getprofiles(solarprofile_min,profiles,isolar);

%disp('creating hydro profiles');
hydroprofile_max = struct( ...
    'type', 'mpcData', ...
    'table', CT_TGEN, ...
    'rows', 1:nhydro, ...%         'rows', hydro_rows, ...
    'col', PMAX, ...
    'chgtype', CT_REP, ...
    'values', [] );
hydroprofile_max.values(:, 1, :) = hydro_pen * ub_scale;
profiles = getprofiles(hydroprofile_max,profiles,ihydro);

% Construct MOST struct
mdi = loadmd(mpc_ordered, nt, xgd, [], [], profiles);
if ~isempty(init)
    mdi.UC.InitialState = init.commit;% set initial status as the end results of last day
    mdi.UC.InitialPg = init.dispatch;
end

%% Solve SCUC
mdo = most(mdi, mpopt);
% ms = most_summary(mdo);
ms = [];
%     mst(day) = ms;
%     assert(mdo.results.success == 1);
% dispatch_profile = sum(mdo.results.ExpectedDispatch,1);
% test_load = sum(area_load,2)';
    
end
