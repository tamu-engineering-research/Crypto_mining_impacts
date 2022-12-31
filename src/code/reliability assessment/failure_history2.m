%This function is obtained from the following paper: 
%Aljohani, Tawfiq & Beshir, Mohammed. (2017). Matlab Code to Assess the Reliability of the Smart 
%Power Distribution System Using Monte Carlo Simulation. Journal of Power and Energy Engineering. 
function[downT,upT] = failure_history2(MTTF,MTTR,duration)
    duration = duration*24+1;
    cur_t = 0;
    i = 1;
    while (cur_t <= duration)
        TTF = -log(rand(1,1))*MTTF;
        TTR = -log(rand(1,1))*MTTR;
        
        downT(i)=cur_t+TTF;
        upT(i) = downT(i)+TTR;
        cur_t = upT(i);
        i = i+1;
      
    end
    downT(end) = duration;
    upT(end) = duration;
end