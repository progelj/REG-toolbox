% Author: Peter Rogelj <peter.rogelj@upr.si>

function createVideo( REG, fname, slice )
%CREATEVIDEO writes a video of images from REG structure to file
% REG - registration structure
% fname - file name of the video to be created
% slice - slice of the images to be used
% all images used in the video are resampled to the reference image, which
% must be correctly set by REG.refIdx.
% An example of calling the function:
% createVideo(REG, 'testVideo.avi', 11);

if isoctave()
    disp("Octave: Using createAnimation instead of createVideo!")
    createAnimation(REG, fname, slice);
else 

    n=length(REG.img);
    %% create a video of the registered sequence
    v = VideoWriter(fname,'Uncompressed AVI');
    %v.VideoCompressionMethod
    v.FrameRate = 5;

    open(v);
    REG.img(REG.refIdx).T=[];
    for i=1:length(REG.img),
        if (i==REG.refIdx)
            A=REG.img(i).data(:,:,slice);
        else
            REG.movIdx=int32(i);
            REG.img(i).T=single(REG.img(i).T);
            A = resampleMov2Ref_(REG);
            A = A(:,:,slice);
            A = insertText( A ,[2,2],i,'FontSize',8);
        end
        writeVideo(v,A);
    end
    close(v);
    disp('video written');
    
end