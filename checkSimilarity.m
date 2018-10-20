% Author: Peter Rogelj <peter.rogelj@upr.si>

% checks different similarity measures at simple rigid transformations of
% a moving image from the REG structure.
% tested measures are:
% - MI (computed using PVI)
% - MI (computed interpolation of intensity)
% - filtered MI (PVI)
% - filtered MI (linear int)

% - PSM for PSF at T0 and interpolation of similarity;
% - PSM for PSF at T0 and interpolation of intensity;
% - filtered PSM for PSF at T0 and interpolation of similarity;
% - filtered PSM for PSF at T0 and interpolation of intensity;

% - linear PSF?

% - point similatity with similarity interpolation (when PSF is provided in REG.img(moving).PSF)
% - point similatity with intensity interpolation (when PSF is provided in REG.img(moving).PSF)
% all methods are limited to selected region  (ROI) and mask (mask).

close all;

p=-10:0.1:10;
i=REG.movIdx;
T0=single(REG.img(i).T);
if isempty(T0)
    T0=single(eye(4));
end

%PSFT0
h12 = pvi(REG);
p12 = h2p(h12);
PSFTOPVI = psfMI(p12);
h12 = gaussfilt2d(h12, 5);
p12 = h2p(h12);
PSFTOPVIf = psfMI(p12);
%--
h12=linearIntHist_(REG);
p12 = h2p(h12);
PSFTOlin = psfMI(p12);
h12 = gaussfilt2d(h12, 5);
p12 = h2p(h12);
PSFTOlinf = psfMI(p12);
% mono modality PSF
PSF0=eye(256);
PSF0 = gaussfilt2d(PSF0, 15) + gaussfilt2d(PSF0, 40); %15
PSF0 = PSF0 / max(PSF0(:));

line=1;
linepos=0;
Sims=zeros(length(p),11); % 10 sim methods
for p1=p
   %display current parameter value
   for (s=1:linepos)
    fprintf("\b",p1t);
   end
   p1t=sprintf("%03.1f  ",  p1); %disp(p1);
   linepos=length(char(p1t));
   fprintf("%s",p1t);

   % define transformation
   REG.img(REG.movIdx).T = single(rigidT([0 p1 0 0 0 0]) * T0);

   % MI
   h12 = pvi(REG);
   Sims(line,1) = SimMI_H( h12 );
   labels{1}='MI';

   % MI linear
   h12=linearIntHist_(REG);
   Sims(line,2) = SimMI_H( h12 );
   labels{2}='MI linear';

   % MI Filtered version
   h12 = pvi(REG);
   %h12 = conv2(filt,filt,h12,'same');
   h12 = gaussfilt2d(h12, 5);  %1.5
   Sims(line,3) = SimMI_H( h12 );
   labels{3}='filtered MI';

   % MI linear, Filtered version
   h12=linearIntHist_(REG);
   %h12 = conv2(filt,filt,h12,'same');
   h12 = gaussfilt2d(h12, 5); %1.5
   Sims(line,4) = SimMI_H( h12 );
   labels{4}='filtered MI linear';

   % =====  PSM --- for PSF at T0 =======================
   [sim, simWeight] = psm(REG, PSFTOPVI);
   Sims(line,5) = sim;
   labels{5}='PSFTOPVI';

   [sim, simWeight] = psm(REG, PSFTOlin);
   Sims(line,6) = sim;
   labels{6}='PSFTOlin';

   [sim, simWeight] = psm(REG, PSFTOPVIf);
   Sims(line,7) = sim;
   labels{7}='PSFTOPVIf';

   [sim, simWeight] = psm(REG, PSFTOlinf);
   Sims(line,8) = sim;
   labels{8}='PSFTOlinf';

   %=================

   [sim, simWeight] = psm(REG, PSF0);
   Sims(line,9) = sim;
   labels{9}='PSF0';

   % =============

   h12 = pvi(REG); %h12=linearIntHist_(REG); %pvi(REG);
   %h12 = gaussfilt2d(h12, 1.5); %??
   Sims(line,10) = SimCC_H(h12);
   labels{10}='CC';

   h12 = pvi(REG); %h12=linearIntHist_(REG); %pvi(REG);
   %h12 = gaussfilt2d(h12, 1.5); %??
   Sims(line,11) = SimCR_H(h12);
   labels{11}='CR';


   % ---
   line=line+1;

end
REG.img(i).T=T0;
fprintf("\n");
figure(1); plot(p,Sims,'.-'); legend(labels); grid;
