function  optimizeBSpline(SimMethod, NCGmin, PDFfilterSize, h12)
% optimization in one level of registrtion usin BSplines
% inputs:
%   SimMEthod - an index to the similarity measuring method (measure and procedure)
%   NCGmin - minimal number of control points in each direction (scalar)
%   PDFfilterSize - sigma of filter for joint intensity distribution (probability density unction)
% output:
%   stored in global REG structure

global REG

if  nargin () < 3
    PDFfilterSize = 5;
end

% for the case of using point similatity measurement:
if  nargin () < 4
    h12 = pvi(REG);
end
h12 = gaussfilt2d(h12, PDFfilterSize);  % % gausian filtering as parzen window estimation for the case of low image reolution % 1.5 % for Matlab
p12 = h2p(h12);
%PSF = psfUH(p12); %% ------ could be MI /UH : TODO: MAD, MSD
%PSF = psfMI(p12);
%PSF= 10-log(1-psfMSD());


switch SimMethod
    % criterion function type A: always recompute all displacements (for gradient of each parameter)
    case 1
        PSF = psfMI(p12);
        opt.max_objective = @(x)criterionFunction2(x, @psmp, PSF);
    case 2
        PSF = psfUH(p12);
        opt.max_objective = @(x)criterionFunction2(x, @psmp, PSF);
    case 3        
        opt.max_objective = @(x)criterionFunction2(x, @(p)SimMI_H(p,PDFfilterSize));
    case 4
        opt.max_objective = @(x)criterionFunction2(x, @(p)SimUH_H(p,PDFfilterSize));
    case 5
        opt.max_objective = @(x)criterionFunction2(x, @SimCR_H);
    case 6
        opt.max_objective = @(x)criterionFunction2(x, @SimCC_H);
        
    % criterion function type B: compute all displacements onc eonly, for gradients compute displacement differences only
    case 11
        PSF = psfMI(p12);
        opt.max_objective = @(x)criterionFunction2b(x, @psmp, PSF);
    case 12
        PSF = psfUH(p12);
        opt.max_objective = @(x)criterionFunction2b(x, @psmp, PSF);
    case 13
        opt.max_objective = @(x)criterionFunction2b(x, @(p)SimMI_H(p,PDFfilterSize));
    case 14
        opt.max_objective = @(x)criterionFunction2b(x, @(p)SimUH_H(p,PDFfilterSize));
    case 15
        opt.max_objective = @(x)criterionFunction2b(x, @SimCR_H);
    case 16
        opt.max_objective = @(x)criterionFunction2b(x, @SimCC_H);
        
    % criterion function type C: displacements computed as in B, but gradients estimated using only local estimation of similarity difference
    case 21
        PSF = psfMI(p12);
        opt.max_objective = @(x)criterionFunction2c(x, @psmp, PSF);
        %opt.max_objective = @(x)criterionFunction2c(x, @psmp_H, PSF);
    case 22
        PSF = psfUH(p12);
        opt.max_objective = @(x)criterionFunction2c(x, @psmp, PSF);
        %opt.max_objective = @(x)criterionFunction2c(x, @psmp_H, PSF);
    case 23
        opt.max_objective = @(x)criterionFunction2c(x, @psmp, [1 PDFfilterSize]); % psfMI
    case 24
        opt.max_objective = @(x)criterionFunction2c(x, @psmp, [2 PDFfilterSize]); % psfUH
    otherwise
        error("invalid similarity measurement method selected!");
end % endswitch

if  nargin () < 2
    NCGmin = 3;
end

opt.algorithm = NLOPT_LD_LBFGS;
opt.xtol_rel = 1e-8; %1e-3;
opt.ftol_abs = 1e-8; %1e-4;
opt.verbose = 1;
opt.maxeval = 50; %200;
opt.maxtime = 60*60*10; % 10 hours = 60 * 60 * 10

CGstep=floor(  (size(REG.img(REG.movIdx).data)-[1 1 1])  / (NCGmin-1) ) ;
REG.img(REG.movIdx).cg=cg.initialize( size(REG.img(REG.movIdx).data), CGstep , [0 0 0]);
opt.initial_step=  ones( numel(REG.img(REG.movIdx).cg.grid), 1);

if isfield(REG.img(REG.movIdx),'D0')
    rmfield(REG.img(REG.movIdx),'D0');
end

if numel(REG.img(REG.movIdx).D) == 3* numel(REG.img(REG.movIdx).data);
    REG.img(REG.movIdx).D0 = REG.img(REG.movIdx).D;
end
REG.img(REG.movIdx).D=single(zeros( [size(REG.img(REG.movIdx).data) 3] ));

[xopt, fmin, retcode] = nlopt_optimize(opt, double( REG.img(REG.movIdx).cg.grid(:) ) ); 
REG.img(REG.movIdx).cg.grid = single(reshape( xopt,size(REG.img(REG.movIdx).cg.grid) ));
cg.computeDisplacementW(REG.img(REG.movIdx).cg,REG.img(REG.movIdx).D);

if isfield(REG.img(REG.movIdx),'D0')
    REG.img(REG.movIdx).D = REG.img(REG.movIdx).D0 + REG.img(REG.movIdx).D; 
    rmfield(REG.img(REG.movIdx),'D0');
end






