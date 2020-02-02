% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ d ] = manualCrossView( A, B, voxSize )
%manualCrossView shows two images in a cross pattern that can be dynamically changed by mouse clicks and keyboard shortcuts
% shows two 3D images and enables selection of view, position of cross center in 3D - three 2D views.
% optional voxelSize parameter enables realistic aspect ratios. 

msgHelp= ["left mouse click - define a central point of view" ;
          "middle mouse click (i) - inverse view, switch images" ;
          "right click (d) - change direction of view" ;
          "x - exit" ;
          "h - show this help" ];
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


if nargin<3
    voxSize=[1 1 1];
end

perspective = 1; % 1=xy, 2=xz, 3=yz
s1=size(A,1);
s2=size(A,2);
s3=size(A,3);
x1=floor(size(A,1)/2);
x2=floor(size(A,2)/2);
x3=floor(size(A,3)/2);
inversion=0;

do_stop=0;
aspect_ratio=[1 1 1];
while do_stop==0
    if perspective == 1
        Ap=A(:,:,x3);
        Bp=B(:,:,x3);
        c1=repmat((1:s1)', [1,s2]);
        c2=repmat( 1:s2  , [s1,1]);   
        c = xor (c1<x1, xor( c2<x2, inversion));
        aspect_ratio=[ voxSize(1) voxSize(2) voxSize(3)];
    end
    if perspective == 2
        Ap=squeeze(A(:,x2,:));
        Bp=squeeze(B(:,x2,:));
        c1=repmat((1:s1)', [1,s3]);
        c2=repmat( 1:s3  , [s1,1]);  
        c = xor (c1<x1, xor(c2<x3, inversion));
        aspect_ratio=[ voxSize(1) voxSize(3) voxSize(2)];
    end
    if  perspective == 3
        Ap=squeeze(A(x1,:,:));
        Bp=squeeze(B(x1,:,:));
        c1=repmat((1:s2)', [1,s3]);
        c2=repmat( 1:s3  , [s2,1]);  
        c = xor (c1<x2, xor(c2<x3, inversion));
        aspect_ratio=[ voxSize(2) voxSize(3) voxSize(1)];
    end
       
    % compose it
    d = zeros(size(Ap));
    d(c==1) = Ap(c==1);
    d(c==0) = Bp(c==0);

    % show it
    Lx = get(gca,'xlim');  % Get axes limits.
    Ly = get(gca,'ylim');
    if (Lx(2)-Lx(1)<3) || (Ly(2)-Ly(1)<3)
        Lx=[0.5 size(Ap,2)+0.5];
        Ly=[0.5 size(Ap,1)+0.5];
    end
    imagesc(d); axis equal; axis tight; colormap gray;
    daspect(aspect_ratio);
    set(gca,'xlim',Lx);
    set(gca,'ylim',Ly);

    %set(gcf,'Pointer','crosshair');
    %[X,Y]= getpts(h); % for Matlab
    [X, Y, buttons] = ginput (1); % for Octave and Matlab :-)

    if buttons == 1 %show for new cooordinates
        if perspective == 1
            x1=round(Y); %floor(Y);
            x2=round(X); %floor(X);
        end
        if perspective == 2
            x1=round(Y); %floor(Y);
            x3=round(X); %floor(X);
        end
        if perspective == 3
            x2=round(Y); %floor(Y);
            x3=round(X); %floor(X);
        end

    end
    if buttons == 2 % invert the cross
        inversion = inversion==0; %negate
    end
    if buttons == 3 % change perspective
        perspective=rem(perspective,3)+1;
    end
    if buttons =='i' || buttons =='I'
        %fprintf("--- inverse ---\n");
        inversion = inversion==0; %negate
    end
    if buttons =='d' || buttons =='D' % change perspective
        %fprintf("--- change direction of view ---\n");
        perspective=rem(perspective,3)+1;
    end
    if buttons =='x' %exit
        close;
        do_stop =1;
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

end
