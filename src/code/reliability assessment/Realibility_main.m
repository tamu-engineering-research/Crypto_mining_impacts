define_constants;

mpc = loadcase(case2000_BRE_PWL);
demand = load('texas_2020_demand.mat');
hydro = load('texas_2020_hydro.mat');
wind = load('texas_2020_wind.mat');
solar = load('texas_2020_solar.mat');
load('nodal_load_hourly.mat');

%% Define Reliability Calculations
duration = 365; % number of days
N = 598; % number of generators

coal_idx = find(ismember(mpc.genfuel, 'coal'));
hydro_idx = find(ismember(mpc.genfuel, 'hydro'));
ng_idx = find(ismember(mpc.genfuel, 'ng'));
nuclear_idx = find(ismember(mpc.genfuel, 'nuclear'));
solar_idx = find(ismember(mpc.genfuel, 'solar'));
wind_idx = find(ismember(mpc.genfuel, 'wind'));

% Gas:          MTTF: 550   MTTR: 75
% Coal:         MTTF: 1150  MTTR: 100
% Nuclear:      MTTF: 1100  MTTR: 150

%Meant Time To Failure for the Generation Profile
%Initialize all failure rate for all generators - wind and solar will also
%be included but will not be used in the calculation

MTTF = zeros(598, 1);
MTTF(ng_idx, 1) = 550;
MTTF(coal_idx, 1) = 960;
MTTF(nuclear_idx, 1) = 1100;
MTTF(hydro_idx, 1) = 1980; 
MTTF(solar_idx, 1) = 10;
MTTF(wind_idx, 1) = 10;

% Meant Time To Repair for the Generation Profile
MTTR = zeros(598, 1);
MTTR(ng_idx, 1) = 75;
MTTR(coal_idx, 1) = 100;
MTTR(nuclear_idx, 1) = 150;
MTTR(hydro_idx, 1) = 20;
MTTR(solar_idx, 1) = 10;
MTTR(wind_idx, 1) = 10;

Loss=zeros(11, 3); % Loss of Load Hourly vector
Energy=zeros(11, 3); %Expected Energy Not served vector

load_inc = .1; % 10% increase in the firm load in the future scenarios ( in the base system this value is zero)
renew_inc= .5; % 50% percent increase in the renewable capacity in the future scenarios ( in the base system this value is zero)

for c = 1:11 % In this loop we keep increasing the mining load on the system from 0GW to 10GW.
    disp(['running load ', num2str(c)]);
    bitcoin_load = 1000*(c-1) + zeros( 8760, 1 );
    tot_load = (1+load_inc) .*sum(nodal_load_hourly,2) + bitcoin_load;
    wind_gen=(1+renew_inc).*sum(wind.wind_MW,2);
    solar_gen=(1+renew_inc).*sum(solar.solar_MW,2);
    hydro_gen=(1+renew_inc).*sum(hydro.hydro_MW,2);
    renewable= wind_gen+solar_gen+hydro_gen;
    netload=[];
    for i=1:8760
        netload(i)= tot_load(i)- renewable(i);
    end
    
LOLP=0;
EENS=0;
LOLP1=0;
EENS1=0;
LOLP2=0;
EENS2=0;

tic
for loop = 1:100 % we repeat the simulation fo 10000 times untill the reliability indices start to converge.
    
status = ones(N,duration*24); % Generation status with N rows and duration*24 columns (hours)

for k = 1:N 
    [downT,upT] = failure_history2(MTTF(k),MTTR(k),duration); % this functions determines random generation failure in a given period, depending on the MTTF and MTTR.
    if length(downT)>1 
        for indx = 1: length(downT)-1 
            for i =  floor(downT(indx))+1: floor(upT(indx))+1 
                status(k,i) = 0; % generator status is set to "off" during the periods with a generator failure.
            end 
        end 
    end 
end

%% Simulation

full_results = zeros(duration*24, 3);
alternate_mpc = loadcase(case2000_BRE_PWL); 
for i = 1:duration*24
    %The original available generation capacity updated by the random status of the generators.
    mpc.gen(ng_idx, PMAX) = alternate_mpc.gen(ng_idx, PMAX).*status(ng_idx, i); 
    mpc.gen(coal_idx, PMAX) = alternate_mpc.gen(coal_idx, PMAX).*status(coal_idx, i);
    mpc.gen(nuclear_idx, PMAX) = alternate_mpc.gen(nuclear_idx, PMAX).*status(nuclear_idx, i);
    
    % the net load not covered by renewable generation.
    full_results(i, 1) = netload(i); 
    % the total avilable generation capacity not including renewables
    full_results(i, 2) = sum(mpc.gen(:, PMAX)) - sum(mpc.gen(solar_idx, PMAX)) - sum(mpc.gen(wind_idx, PMAX))-sum(mpc.gen(hydro_idx, PMAX)); 
    % the net load minus generation checks the generation adequacy, and if it is positive, it means that there is not enough generation to cover the load.
    full_results(i, 3) = full_results(i, 1) - full_results(i, 2); 
end

EEN=0;
LOL=0;
EEN1=0;
LOL1=0;
EEN2=0;
LOL2=0;

for i=1:length(full_results(:,3))
% the case with no demand flexibility
if full_results(i,3)>0
EEN=EEN+full_results(i,3);
LOL=LOL+1;
end
% the case with demand flexibility between 2pm-8pm
if rem(i,24)>= 15 && rem(i,24)<= 20
if full_results(i,3)>1000*(c-1)
EEN1=EEN1+full_results(i,3);
LOL1=LOL1+1;
end  
else
if full_results(i,3)>0
EEN1=EEN1+full_results(i,3);
LOL1=LOL1+1;
end  
end
% the case with demand flexibility at all time
if full_results(i,3)> 1000*(c-1)
EEN2=EEN2+full_results(i,3);
LOL2=LOL2+1;
end

end
% Taking the cumulative LOLP and EENS of the 10000 rounds of simulation
LOLP = LOLP + LOL;
EENS= EENS + EEN;
LOLP1 = LOLP1 + LOL1;
EENS1= EENS1 + EEN1;
LOLP2 = LOLP2 + LOL2;
EENS2= EENS2 + EEN2;
end
% Taking the average LOLP and EENS of the 10000 rounds of simulation
Loss(c,1)=LOLP/loop;
Loss(c,2)=LOLP1/loop;
Loss(c,3)=LOLP2/loop;

Energy(c,1)=EENS/loop;
Energy(c,2)=EENS1/loop;
Energy(c,3)=EENS2/loop;

end
toc
save('future_10_150.mat','Loss','Energy')

