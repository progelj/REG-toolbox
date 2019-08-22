
function D = generateSynthGaussDef( ImSize, Gcenter, Gsigma, Gamplitude );

if length(ImSize)!=3
    error('ImSize sould be a 3 element vector providing the image size!')
end
if length(Gcenter)!=3
    error('Gcenter should be a 3 element vector providind the center of the maximum displacement of the synthetic deformation!')
end
if length(Gsigma)!=1
    error('Gsigma should be a scalar providing the width of the sysnthetic deformation!')
end
if length(Gamplitude)==1
    Gamplitude = [Gamplitude Gamplitude Gamplitude];
end
if length(Gamplitude)!=3
    error('Gamplitude should be a 3 element vector providing the amplitude displacement of the synthetic deformation!')
end

D = single( zeros( [ImSize 3] ));
D(Gcenter(1),Gcenter(2), Gcenter(3), 1) = Gamplitude(1);
D(Gcenter(1),Gcenter(2), Gcenter(3), 2) = Gamplitude(2);
D(Gcenter(1),Gcenter(2), Gcenter(3), 3) = Gamplitude(3);

% could also use gaussfilt3d
Filter = fspecial ("gaussian", [6*Gsigma+1,1], Gsigma);
Filter = Filter / max(Filter);
D(:,:,:,1) = convn (D(:,:,:,1), Filter, "same");
D(:,:,:,2) = convn (D(:,:,:,2), Filter, "same");
D(:,:,:,3) = convn (D(:,:,:,3), Filter, "same");
Filter = fspecial ("gaussian", [1, 6*Gsigma+1], Gsigma);
Filter = Filter / max(Filter);
D(:,:,:,1) = convn (D(:,:,:,1), Filter, "same");
D(:,:,:,2) = convn (D(:,:,:,2), Filter, "same");
D(:,:,:,3) = convn (D(:,:,:,3), Filter, "same");
Filter = fspecial ("gaussian", [1, 1, 6*Gsigma+1], Gsigma);
Filter = Filter / max(Filter);
D(:,:,:,1) = convn (D(:,:,:,1), Filter, "same");
D(:,:,:,2) = convn (D(:,:,:,2), Filter, "same");
D(:,:,:,3) = convn (D(:,:,:,3), Filter, "same");