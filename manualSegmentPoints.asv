function manualSegmentPoints()
% input par: none (global REG)
% manually segment points that gets stored into REG.img(n).segPtPx
global REG;

msgHelp= ["left mouse click - define a point" ;
          "c - clear the point" ;
          "n/p - move to the next/previous image" ;
          "i/d - increment/decrement point index (i - add new point)";
          "z - reset zoom";
          "s - save the data";
          "x - exit" ;
          "h - show this help" ];
myVer=version();
if isoctave && (myVer(1)<'5')
    msgHelp0=msgHelp;
    for row=1:size(msgHelp0,1)
        msgHelp = strcat( msgHelp, sprintf("%s\n",msgHelp0(row,:)) );
    end
    h = msgbox(msgHelp,"Help");
else
    h = msgbox(msgHelp,"Help");
    uiwait(h);
end


imSize=size(REG.img(1).data);
voxSize=REG.img(1).voxelSize;
% initial settings:
n=1; % the first image displayed
ptnr=1; % point number;
%initialize field REG.img(n).segPtPx
Npts=0;%number of points;

do_stop=0;

h1=subplot(2,2,1);
h2=subplot(2,2,2);
h3=subplot(2,2,3);
aspect_ratio_1=[ voxSize(1) voxSize(2) voxSize(3)];
aspect_ratio_2=[ voxSize(1) voxSize(3) voxSize(2)];
aspect_ratio_3=[ voxSize(3) voxSize(2) voxSize(1)];
x1=round(imSize(1)/2);
x2=round(imSize(2)/2);
x3=round(imSize(3)/2);
while do_stop==0
    % selected point coordinates
    if isfield(REG.img(n),"segPtPx")
        Npts=size(REG.img(n).segPtPx,1);
    else
        REG.img(n).segPtPx=[];
        Npts=0;
    end  
    if ptnr>Npts
        Pt=[0,0,0];
    else 
        Pt=REG.img(n).segPtPx(ptnr,:)+1;
        if size(REG.img(n).segPtPx,1)>=ptnr
            tmpPt=REG.img(n).segPtPx(ptnr,:)+1;
            x1=round(tmpPt(1));
            x2=round(tmpPt(2));
            x3=round(tmpPt(3));
        end
    end
    
    fprintf("imnr=%d, ptnr=%d, X1=%d, X2=%d, X3=%d \n",n, ptnr,x1,x2,x3);
    
    if (0 < x3) && (x3 <= size(REG.img(n).data,3))
        A_1=REG.img(n).data(:,:,x3);
        lines_1=[Pt(1), Pt(2)];
    else
        A_1=REG.img(n).data(:,:,round(imSize(3)/2));
        lines_1=[Pt(1), Pt(2)];
    end
    if (0 < x2) && (x2 <= size(REG.img(n).data,2))
        A_2=squeeze(REG.img(n).data(:,x2,:));
        lines_2=[Pt(1), Pt(3)];
    else
        A_2=squeeze(REG.img(n).data(:,round(imSize(2)/2),:));
        lines_2=[Pt(1), Pt(3)];
    end
    if (0 < x1) && (x1 <= size(REG.img(n).data,1))
        A_3=squeeze(REG.img(n).data(x1,:,:))';
        lines_3=[Pt(3), Pt(2)];
    else
        A_3=squeeze(REG.img(n).data(round(imSize(1)/2),:,:))';
        lines_3=[Pt(3), Pt(2)];
    end
    

    % show it
    Lx1 = get(h1,'xlim');  % Get axes limits.
    Ly1 = get(h1,'ylim');
    if (Lx1(2)-Lx1(1)<3) || (Ly1(2)-Ly1(1)<3)
        Lx1=[0.5 size(A_1,2)+0.5];
        Ly1=[0.5 size(A_1,1)+0.5];
    end
    Lx2 = get(h2,'xlim');  % Get axes limits.
    Ly2 = get(h2,'ylim');
    if (Lx2(2)-Lx2(1)<3) || (Ly2(2)-Ly2(1)<3)
        Lx2=[0.5 size(A_2,2)+0.5];
        Ly2=[0.5 size(A_2,1)+0.5];
    end
    Lx3 = get(h3,'xlim');  % Get axes limits.
    Ly3 = get(h3,'ylim');
    if (Lx3(2)-Lx3(1)<3) || (Ly3(2)-Ly3(1)<3)
        Lx3=[0.5 size(A_3,2)+0.5];
        Ly3=[0.5 size(A_3,1)+0.5];
    end
    %f1=figure(1); 
    h1=subplot(2,2,1); imagesc(A_1); axis equal;  axis tight; colormap gray;
    set(h1,'xlim',Lx1);
    set(h1,'ylim',Ly1);
    daspect(aspect_ratio_1); 
    hold on;
    plot([lines_1(2),lines_1(2)], [1,size(A_1,1)],'r--');
    plot([1,size(A_1,2)], [lines_1(1),lines_1(1)],'r--');
    plot(lines_1(2),lines_1(1),'rx');
    hold off; axis tight
    
    h2=subplot(2,2,2); imagesc(A_2); axis equal; axis tight; colormap gray; set(gca,'xdir','reverse');
    set(h2,'xlim',Lx2);
    set(h2,'ylim',Ly2);
    daspect(aspect_ratio_2);
    hold on;
    plot([lines_2(2),lines_2(2)], [1,size(A_2,1)],'r--');
    plot([1,size(A_2,2)], [lines_2(1),lines_2(1)],'r--');
    plot(lines_2(2),lines_2(1),'rx');
    hold off; axis tight
    
    h3=subplot(2,2,3); imagesc(A_3); axis equal; axis tight; colormap gray; axis xy;
    set(h3,'xlim',Lx3);
    set(h3,'ylim',Ly3);
    daspect(aspect_ratio_3);
    hold on;
    plot([lines_3(2),lines_3(2)], [1,size(A_3,1)],'r--');
    plot([1,size(A_3,2)], [lines_3(1),lines_3(1)],'r--');
    plot(lines_3(2),lines_3(1),'rx');
    hold off; axis tight
    
    %h4=subplot(2,2,4); % imagesc(A4); axis equal; axis tight;
    axes(h1);
    title(["image nr. ", num2str(n) ,", point nr. ", num2str(ptnr)]);

    set(gcf,'pointer','crosshair');
    [X, Y, buttons] = ginput (1); % for Octave and Matlab :-)

    if buttons == 1 %show for new cooordinates
    curpt = get(h1,'currentpoint');
        if curpt(1,1:2)==[X,Y]
            %disp("image 1 clicked!");
            Pt(1)=Y-1;
            x1=min(max(0,round(Pt(1))), imSize(1)-1);
            Pt(2)=X-1;
            x2=min(max(0,round(Pt(2))), imSize(2)-1);
            if Pt(3)==0
                Pt(3)=x3;
            end
        end
        
        curpt = get(h2,'currentpoint');
        if curpt(1,1:2)==[X,Y]
            %disp("image 2 clicked!");
            Pt(1)=Y-1;
            x1=min(max(0,round(Pt(1))), imSize(1)-1);
            Pt(3)=X-1;
            x3=min(max(0,round(Pt(3))), imSize(3)-1);
            if Pt(2)==0
                Pt(2)=x2;
            end
        end
              
        curpt = get(h3,'currentpoint');
        if curpt(1,1:2)==[X,Y]
            %disp("image 3 clicked!");
            Pt(2)=X-1;
            x2=min(max(0,round(Pt(2))), imSize(2)-1);
            Pt(3)=Y-1;
            x3=min(max(0,round(Pt(3))), imSize(3)-1);
            if Pt(1)==0
                Pt(1)=x1;
            end
        end
        REG.img(n).segPtPx(ptnr,:)=Pt-1;
    end
      
    
    if buttons == 2 % invert the cross
        %nothing to do?
    end

    if buttons =='n' % next image
        n=min(max(1,n+1),length(REG.img));
        
        imSize=size(REG.img(n).data);
        voxSize=REG.img(n).voxelSize;
        aspect_ratio_1=[ voxSize(1) voxSize(2) voxSize(3)];
        aspect_ratio_2=[ voxSize(1) voxSize(3) voxSize(2)];
        aspect_ratio_3=[ voxSize(3) voxSize(2) voxSize(1)];
        
        %recompute position on the image (not considering transformations T and D)
        if size(REG.img(n).segPtPx,1)>=ptnr
            tmpPt=REG.img(n).segPtPx(ptnr,:)+1;
            x1=round(tmpPt(1));
            x2=round(tmpPt(2));
            x3=round(tmpPt(3));
        end
        
    end
    if buttons =='p' %previous image
        n=min(max(1,n-1),length(REG.img));
        
        imSize=size(REG.img(n).data);
        voxSize=REG.img(n).voxelSize;
        aspect_ratio_1=[ voxSize(1) voxSize(2) voxSize(3)];
        aspect_ratio_2=[ voxSize(1) voxSize(3) voxSize(2)];
        aspect_ratio_3=[ voxSize(3) voxSize(2) voxSize(1)];
        
        %recompute position on the image (not considering transformations T and D)
        if size(REG.img(n).segPtPx,1)>=ptnr
            tmpPt=REG.img(n).segPtPx(ptnr,:)+1;
            x1=round(tmpPt(1));
            x2=round(tmpPt(2));
            x3=round(tmpPt(3));
        end
        
    end
    if buttons =='i' % next point - increment point index
        %old_ptnr=ptnr;
        ptnr=max(1,ptnr+1);

        %recompute position on the image (not considering transformations T and D)
        if size(REG.img(n).segPtPx,1)>=ptnr
            tmpPt=REG.img(n).segPtPx(ptnr,:)+1;
            x1=round(tmpPt(1));
            x2=round(tmpPt(2));
            x3=round(tmpPt(3));
        end

    end
    if buttons =='d' %previous point - decrement point index
        ptnr=max(1,ptnr-1);
        
        %recompute position on the image (not considering transformations T and D)
        if size(REG.img(n).segPtPx,1)>=ptnr
            tmpPt=REG.img(n).segPtPx(ptnr,:)+1;
            x1=round(tmpPt(1));
            x2=round(tmpPt(2));
            x3=round(tmpPt(3));
        end
        
    end
    if buttons =='c' % clear the point
        Pt=[0 0 0];
        REG.img(n).segPtPx(ptnr,:)=Pt;
    end
    if buttons =='z' % reset zoom
        axes(h1); xlim ("auto"); ylim ("auto"); axis tight;
        axes(h2); xlim ("auto"); ylim ("auto"); axis tight;
        axes(h3); xlim ("auto"); ylim ("auto"); axis tight;
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
    if buttons =='s' % save
        % TODO: remove zeros with nan-s

        [file,path] = uiputfile ('*','Save REG to .mat',"REG-seg.mat");
        SavePath=fullfile(path,file);
        if file~=0
            save( SavePath, 'REG', '-v7');
        end
    end 
    if buttons =='x'  % exit 
        close;
        do_stop =1;
    end


end
