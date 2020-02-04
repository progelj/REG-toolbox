function  sim  = myRigidCF( x, T0, PSF0 )
%   evaluate similarity for the REG structure with given rigid
%   transformation parameters x.
global REG;

REG.img(REG.movIdx).T = rigidT(x) * T0;

sim = [];
% using a predefined PSF (alternative 1)
if exist('PSF0','var'),
    if isequal(size(PSF0),[256 256])
        h12 = pvi(REG); %pvi
        sim = psmp(h12,PSF0);
    end
end

% without the predefined PSF (alternative 2)
global intensityDistributionfilterWidth % get the global setting
if length(sim)<1
    h12 = pvi(REG);
    h12 = gaussfilt2d( h12, intensityDistributionfilterWidth );  

    sim = SimMI_H( h12 );
    % alternatives: 
    %sim = SimCC_H( h12 ); %
    %sim = SimCR_H( h12 );
    %sim = SimUH_H( h12 );
end
