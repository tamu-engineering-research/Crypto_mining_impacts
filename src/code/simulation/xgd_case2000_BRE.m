function xgd_table = xgd_case2000_BRE(mpc)
%XGD_ACTIVSg200r    Additional Generator Data for case_ACTIVSg200r
% 
%   See revise_ACTIVSg200.m for more details about settings
%   Parameters are based on [1].
%   See https://github.com/xb00dx/ACTIVSg200r for more infor about ACTIVSg200r.
% 
% References
%   [1] T. Xu, A. B. Birchfield, K. M. Gegner, K. S. Shetye, and T. J. Overbye,
%   “Application of large-scale synthetic power system models for energy 
%   economic studies,” in Proceedings of the 50th Hawaii International 
%   Conference on System Sciences, 2017.
% 
%   Created by X. Geng (03/14/2020)
% 
%   This file is created for MOST.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See https://github.com/MATPOWER/most for more info about MOST.

% get min-on (MinUp) time and min-off (MinDown) time
% in number of periods (this case delta_t = 1hour)
define_constants;
load('gendata_case2000_BRE.mat'); % get min_on, min_off
ng = size(min_on,1);

%min_on = ones(length(mpc.gen(:,1)),1);  % dummy values
%min_off = ones(length(mpc.gen(:,1)),1);	% dummy values

commitkey = ones(ng,1);
commitkey(strcmp(mpc.genfuel,'nuclear')) = 2;
% commitkey(strcmp(mpc.genfuel,'wind')) = 2;
% commitkey(strcmp(mpc.genfuel,'solar')) = 2;
% commitkey(find(strcmp(mpc.genfuel,'hydro'))) = ;

%% xGenData
% min_on = ones(size(min_on)); min_off = ones(size(min_off));
% xgd_table.colnames = {'CommitKey','MinUp','MinDown'};
% xgd_table.data = [commitkey,min_on, min_off];

xgd_table.colnames = {'CommitKey','CommitSched','MinUp','MinDown'};
xgd_table.data = [commitkey, ones(ng,1), min_on, min_off];

end