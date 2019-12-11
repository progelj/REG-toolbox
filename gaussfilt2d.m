% Author: Peter Rogelj <peter.rogelj@upr.si>

function fa=gaussfilt2d(a,sigma)
% a common function for Gaussian filtering for Matlab and Octave
% 2d

%-- initial implementation
%if isoctave() , % Octave
%    fa = imsmooth(a, "Gaussian", sigma); %"Gaussian" filter for octave
%else
%    fa = imgaussfilt(a, sigma, 'Padding', 0);  % for Matlab
%end

%-- second implementation-------
Filter = fspecial ("gaussian", [2*ceil(3*sigma)+1,1], sigma);
Filter = Filter / max(Filter);
fa = convn (a, Filter, "same");
fa = convn (fa, Filter', "same");
