function manualDefineMask(ImageIndex)
%Manually define image mask using GUI
% for Matlab and Octave
if nargin<1
    error("Required parameter: Image index of the image in the global REG structure.")
    return;
end

global REG
if ~isstruct(REG)
    error("Global REG structure is not defined!")
    return;
end

Ix= ImageIndex; % image index

nz=size(REG.img(Ix).data,3);
%xys=cell([nz,1]);
if ~isequal(size(REG.img(Ix).mask), size(REG.img(Ix).data))
    REG.img(Ix).mask=uint8( zeros(size(REG.img(Ix).data)) );
end
msgHelp= ["left mouse click - define a point on the mask edge" ;
          "right mouse click - close the mask contour" ;
          "c - clear the mask on the current slice" ;
          "n/p - move to the next/previous slice" ;
          "e - end defining the contures" ;
          "h - show this help" ;
          "to extend/shrink mask region draw additional contour starting inside/outside the current mask."];
if isoctave
    msgHelp0=msgHelp;
    for row=1:size(msgHelp0,1)
        msgHelp = strcat( msgHelp, sprintf("%s\n",msgHelp0(row,:)) );
    end
    h = msgbox(msgHelp,"Help");
else
    h = msgbox(msgHelp,"Help");
    uiwait(h);
end

slice=1;
segment=1; 
while segment
    % segment one slice
    hold off;
    imagesc(REG.img(Ix).data(:,:,slice)); colormap gray; colorbar;
    title(["slice nr. " num2str(slice)]);
    axis equal; axis tight;
    %set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
    hold on;
    
    % show the mask if already defined for that slice
    binarymask= REG.img(Ix).mask(:,:,slice);
    if max(binarymask(:))>0
        [B,L] = bwboundaries(binarymask,8,'noholes');
        for k = 1:length(B)
            boundary = B{k};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 0.5);
        end       
    end
    
    % define a new contour and add to the existent mask
    xy=[];
    set(gcf,'pointer','crosshair');
    while 1        
    [X, Y, buttons] = ginput (1); % for Octave and Matlab :-)
        if buttons==1 % add a point
            xy=[xy; [X,Y] ];
            plot(X,Y,'rx');
        end
        
        if buttons==3 % close the curve
            break;
        end
        if buttons=='c' % clear the mask on this slice 
            REG.img(Ix).mask(:,:,slice)=0;
            break;
        end
        if buttons=='n' % end the segmentation
            slice=max(1,min(slice+1,nz));
            break;
        end
        if buttons=='p' % end the segmentation
            slice=max(1,min(slice-1,nz));
            break;
        end
        if buttons=='h' % end the segmentation
            %uiwait(msgbox(msgHelp));
            if isoctave
                h = msgbox(msgHelp,"Help");
            else
                h = msgbox(msgHelp,"Help");
                uiwait(h);
            end
        end
        if buttons=='e' || buttons=='x' % end / exit the segmentation
            segment=0;
            close;
            break;
        end
    end
    
    % create the mask
    if size(xy,1)>2
        bw = poly2mask(xy(:,1), xy(:,2), size(REG.img(Ix).mask,1), size(REG.img(Ix).mask,2));    
        % check value of current mask at first point to add or remove parts to mask
        addRemove = 1;
        if max(binarymask(:))>0
            p1=max(1,min(round(xy(1,1)),size(binarymask,1)));
            p2=max(1,min(round(xy(1,2)),size(binarymask,1)));
            addRemove=REG.img(Ix).mask(p2,p1,slice)>0;
        end
        if addRemove
            binarymask(bw>0) = 1; %(double(binarymask)+double(bw))>0;
        else
            binarymask(bw>0) = 0; %(double(binarymask)+double(bw))>0;
        end
        REG.img(Ix).mask(:,:,slice)=binarymask;
    end
    
end