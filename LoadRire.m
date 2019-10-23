function LoadRire ( REGIdx, headerFile, rawImageFile )
% a funtion for loading RIRE images - image sfrom The retrospective Image Registration Evaluation Project)
% function calling example: 
%    LoadRire(1,'header.ascii','image.bin')
%The image gets loaded into the global REG structure.

global REG

HF = importdata (headerFile); %('header.ascii')

n=length(HF);
for i=1:n
    
    if strncmp(HF(i),'Pixel size :=',10) 
        PixelSize=cell2mat(textscan(HF{i}, "Pixel size := %f : %f"))
    end
    if strncmp(HF(i),'Slice thickness :=',15) 
        SliceThickness=cell2mat(textscan(HF{i}, "Slice thickness := %f"));
    end
    if strncmp(HF(i),'Rows :=', 4) 
        Rows=cell2mat(textscan(HF{i}, "Rows := %f"));
    end
    if strncmp(HF(i),'Columns :=', 7) 
        Columns=cell2mat(textscan(HF{i}, "Columns := %f"));
    end
    if strncmp(HF(i),'Slices :=', 6) 
        Slices=cell2mat(textscan(HF{i}, "Slices := %f"));
    end  
    
end

LoadRawVolume( REGIdx, rawImageFile, [Rows Columns Slices], [PixelSize(1) PixelSize(2) SliceThickness] , 'int16', 'ieee-be' )
