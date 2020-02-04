% Author: Peter Rogelj <peter.rogelj@upr.si> 

% Rigidly register images using rigidSim for the criterion function and 
%   NLOPT_LN_COBYLA optimization algorithm.

more off;
global REG; 
global intensityDistributionfilterWidth;
%% ================= LOAD INPUT DATA ======================================
imPath1='/home/peter/programming/REG-toolbox/tests/data/t1_icbm_normal_1mm_pn3_rf0.rawb';
imPath2='/home/peter/programming/REG-toolbox/tests/data/t2_icbm_normal_1mm_pn3_rf0.rawb';
LoadRawVolume( 1, imPath1, [181 217 181], [1 1 1] );
LoadRawVolume( 2, imPath2, [181 217 181], [1 1 1] );
REG.img(2).T=rigidT([1.1 2.2 3.3 4.4 5.5 6.6]);
% settings:
usePSF=false; %true;
intensityDistributionfilterWidth=10;
% =========================================================================
checkData();

% initial transformation
if isempty(REG.img(REG.movIdx).T),
    T0=eye(4);
else
    T0 = REG.img(REG.movIdx).T;
end

% define the criterion function
% cf = criterion function
if  usePSF % unisng point similarity measures
    h12 = pvi(REG);
    if intensityDistributionfilterWidth>0
        h12 = gaussfilt2d(h12, intensityDistributionfilterWidth);  % Gausian filtering as parzen window estimation
    end
    p12 = h2p(h12);
    PSF = psfMI(p12); %% ------ could be psfMI / psfUH / psfMSD / psfMAD
    cf = (@(x) myRigidCF(x, T0, PSF));         
else % standard similarity measures
    cf = (@(x) myRigidCF(x, T0));
end

% nlopt options
opt={};
opt.max_objective = cf;
opt.algorithm = NLOPT_LN_COBYLA;
opt.xtol_rel = 1e-3;
opt.maxeval = 1000;
opt.verbose = 1;
xoptinit = zeros(1,6);
opt.initial_step= [1 1 1 1 1 1];

% do it;
xopt = nlopt_optimize(opt, xoptinit);
REG.img(REG.movIdx).T = rigidT(xopt) * T0;

%disp([double(REG.refIdx) double(REG.movIdx) xopt]);
fprintf("Final optimization parameters: ");
fprintf("%f  ", xopt);
fprintf("\n");
