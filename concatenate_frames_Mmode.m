function [Images, Frames] = concatenate_frames_Mmode(Im,Information)
    clear no_pixels_to_add Frames a Im_subtract Im_each pixels_to_add Im_all Im_all_full Im_each_color
    %this reads all the frames and stores them in the structure as individual images
    for fr = 1:Information.NumberOfFrames
        Frames(fr).Image = Im(:,:,:,fr);
    end
    for fr = 1:Information.NumberOfFrames-1
        count=0;
        %each 2 consecutive images are checked for differences
        Im_subtract = Frames(fr+1).Image(640:672,51:914) - Frames(fr).Image(640:672,51:914);
        Im_subtract(Im_subtract ~= 0) = 1;
        if sum(sum(Im_subtract)) < 500 % 500 is the noise
            %if the difference si small, it means the images are ~ the same
            no_pixels_to_add(fr) = 0;
        else
            %if the images are different
            for kk = 1:50
                %the number of pixels that will be added
                Im_subtract = Frames(fr+1).Image(640:672,51:914-kk) - Frames(fr).Image(640:672,51+kk:914);
                Im_subtract(Im_subtract ~= 0) = 1;
                a(kk) = sum(sum(Im_subtract));
                [~,no_pixels_to_add(fr)] = min(a);
            end
        end
    end
    no_pixels_to_add (no_pixels_to_add ~= 0) = [];   
    for k = 1:floor(Information.NumberOfFrames/size(no_pixels_to_add,2))
        Im_each(k).Photo = rgb2gray(Frames(k*size(no_pixels_to_add,2)).Image(70:end,51:914,:));
        Im_each_color(k).Photo = Frames(k*size(no_pixels_to_add,2)).Image(70:end,51:914,:);
    end  
        Im_subtract = Frames(end).Image(640:672,51:914) - Frames(floor(Information.NumberOfFrames/size(no_pixels_to_add,2))).Image(640:672,51:914);
        Im_subtract(Im_subtract ~= 0) = 1;
        if sum(sum(Im_subtract)) < 500
            pixels_to_add = 0;
        else
            for kk = 1:50
                Im_subtract = Frames(end).Image(640:672,51:914-kk) - Frames(floor(Information.NumberOfFrames/111)).Image(640:672,51+kk:914);
                %determines the number of pixels to be added
                Im_subtract(Im_subtract ~= 0) = 1;
                a(kk) = sum(sum(Im_subtract));
                [~,pixels_to_add] = min(a);
            end
        end
    Im_each(floor(Information.NumberOfFrames/size(no_pixels_to_add,2))+1).Photo = rgb2gray(Frames(end).Image(70:end,914-pixels_to_add:914,:));
    Im_each_color(floor(Information.NumberOfFrames/size(no_pixels_to_add,2))+1).Photo = Frames(end).Image(70:end,914-pixels_to_add:914,:);    
    for kk = 1:floor(Information.NumberOfFrames/size(no_pixels_to_add,2))
        Im_all_full(:,(kk-1)*size(Im_each(kk).Photo,2)+1:kk*size(Im_each(kk).Photo,2)) = Im_each(kk).Photo;
    end
    Im_all = Im_all_full(:,1:size(Im_all_full,2));
    Im_all(:,size(Im_all_full,2)+1:size(Im_all_full,2)+size(Im_each(end).Photo,2)) = Im_each(end).Photo;    
    Images.Im_all = Im_all; Images.Im_each = Im_each; Images.Im_each_color = Im_each_color;    
    close all
    figure;imshow(Im_all)



    
        
        
        
        