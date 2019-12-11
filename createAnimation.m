% Author: Peter Rogelj <peter.rogelj@upr.si>

function createAnimation( REG, fname, slice )
%CREATEVIDEO writes a video of images from REG structure to file
% REG - registration structure
% fname - file name of the animated GIF to be created
% slice - slice of the images to be used
% all images used in the video are resampled to the reference image, which
% must be correctly set by REG.refIdx.
% The function shall work in GNU Octave
% An example of calling the function:
% createAnimation(REG, 'testAnimation.gif', 11)

if ~isoctave()
    disp("not Octave: Using createVideo instead of createAnimation!")
    createVideo(REG, fname, slice);
else 
    REG.img(REG.refIdx).T=[];
    for i=1:length(REG.img),
        if (i==REG.refIdx)
            A=REG.img(i).data(:,:,slice);
        else
            REG.movIdx=int32(i);
            REG.img(i).T=single(REG.img(i).T);
            A = resampleMov2Ref_(REG);
            A = A(:,:,slice);
            %A = insertText( A ,[2,2],i,'FontSize',8);
        end
        %write image a to GIF
        %Write the first frame to a file named animGif.gif
        if i==1
            imwrite(A,fname,'gif','writemode','overwrite','LoopCount',0,'DelayTime',0.5);
        else
            imwrite(A,fname,'gif','writemode','append','DelayTime',0.5);
        end
    end
    disp('animation written');
end
