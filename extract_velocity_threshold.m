function [Preliminary_points, Input_data, Analysis_data] = extract_velocity_threshold(Images, ECG_signal, Frames)

try
Im_each = Images.Im_each; Im_all = Images.Im_all;

imshow(Im_all(70:end,1:ECG_signal.R_wave(2)+10));
treshold = 50;
%***************************************
%***************************************
title('please select zero line'); [~,zero_line] = getpts;  zero_line = round(zero_line);
x_start = 1; x_end = size(Im_all,2);name = 'scale';
Imagine = Frames(1).Image;
close all;fig = imshow(Imagine(70:end,:,:)); 
title('please select scale both points'); [~,scale_points] = getpts;  scale_points = round(scale_points);
prompt={'Enter the scale you are measuring'}; scale_diff = 'scale measured'; defaultans = {'1.2'}; options.Interpreter = 'tex'; answer = inputdlg(prompt,name,[1 40],defaultans,options);
scale = abs(str2num(cell2mat(answer))/(scale_points(1) - scale_points(2)));

for beat = 1:size(ECG_signal.R_wave,2)-1
    clear velocity
    
    %thresholding
    if beat==1; add_on = 1; else add_on = ECG_signal.R_wave(beat)-10; end
    if beat~=size(ECG_signal.R_wave,2); add_off = ECG_signal.R_wave(beat+1)+10; else add_off = size(Im_all,2); end

    Input_data(beat).add_on = add_on;Input_data(beat).add_off = add_off;
    Im_each = Images.Im_each; Im_all = Images.Im_all;
    x_start = 1; x_end = size(Im_all,2);
    Im = Im_all(70:end,add_on:add_off); 

    close all; imshow(Im)
    title('please select where to start search'); [~,start_search] = getpts;  start_search = round(start_search);
    %thresholding
    clear poz_fin poz_fin_sm
    poz_fin(1:x_start-1) = NaN;
    for j = add_on-add_on+1:add_off-add_on+1%x_start:x_end
        line_raw = double(Im(start_search:-1:zero_line,j));
        line_raw(line_raw<treshold) = 0;
        poz = find(line_raw~=0, 1, 'first');
        poz(isempty(poz)) = NaN;
        poz_fin(j) =start_search - poz(~isempty(poz));
        clear line_raw
    end
    poz_fin_sm = sgolayfilt(smooth(poz_fin(x_start:end)),5,7);
    %showing the trace
    close all;figure;
    imshow(Im);hold on
    plot(poz_fin,'r-*'); plot(poz_fin_sm, 'g-.')
    line([ECG_signal.R_wave(beat) ECG_signal.R_wave(beat)],[1 size(Im,1)],'Color', 'w');
    line([ECG_signal.R_wave(beat+1) ECG_signal.R_wave(beat+1)],[1 size(Im,1)],'Color', 'w');
    title(['beat no ', num2str(beat)])
    %changing the threshold
    for i=1:100
        prompt={'Previously used threshold'}; 
        dlg_title = 'Modify threshold';num_lines = 1;
        defaultans = {num2str(treshold)};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        
        if (treshold ~= str2num(cell2mat(answer)))
            treshold = str2num(cell2mat(answer));

            poz_fin(1:x_start-1) = NaN;
            for j = add_on-add_on+1:add_off-add_on+1%x_start:x_end
                line_raw = double(Im(start_search:-1:zero_line,j));
                line_raw(line_raw<treshold) = 0;
                poz = find(line_raw~=0, 1, 'first');
                poz(isempty(poz)) = NaN;
                poz_fin(j) =start_search - poz(~isempty(poz));
                clear line_raw
            end
            poz_fin_sm = sgolayfilt(smooth(poz_fin(x_start:end)),5,7);

            close all;figure;
            imshow(Im); hold on
            plot(poz_fin,'r-*'); plot(poz_fin_sm, 'g-.')
            line([ECG_signal.R_wave(beat) ECG_signal.R_wave(beat)],[1 size(Im,1)],'Color', 'w');
            line([ECG_signal.R_wave(beat+1) ECG_signal.R_wave(beat+1)],[1 size(Im,1)],'Color', 'w');
            title(['beat no ', num2str(beat)])

        else
            break
        end
    end

    Preliminary_points(beat).poz_fin = poz_fin;Preliminary_points(beat).poz_fin_sm = poz_fin_sm;
    Input_data(beat).treshold = treshold;

    
    %exclude points
    close all;figure;
    imshow(Im);hold on
    plot(poz_fin,'r-*'); plot(poz_fin_sm, 'g-.')
    line([ECG_signal.R_wave(beat) ECG_signal.R_wave(beat)],[1 size(Im,1)],'Color', 'w');
    line([ECG_signal.R_wave(beat+1) ECG_signal.R_wave(beat+1)],[1 size(Im,1)],'Color', 'w');
    title(['beat no ', num2str(beat)])
    
    name = 'remove_pts';Rect_remove = [];
    for k = 1:100
        prompt={'Are there any points you would like to remove? yes/no'}; scale_diff = 'lines remove'; defaultans = {'no'}; options.Interpreter = 'tex'; answer = inputdlg(prompt,name,[1 40],defaultans,options);
        if strcmp(cell2mat(answer) , 'yes')
            Rect_remove(k).rect = getrect;
        elseif strcmp(cell2mat(answer) , 'no')
            break
        end
    end

    %exclude points - red ones
    if isempty(Rect_remove)
        excl_up_all = []; excl_down_all = [];
    else
    excl_up_all = NaN; excl_down_all = NaN;
    for k=1:size(Rect_remove,2)
        %Rect_remove(k).rect(Rect_remove(k).rect(1) < 0) = 1;
        for i = 1:length(poz_fin)
            if (poz_fin(1,i)>=round(Rect_remove(k).rect(2)))&&(poz_fin(1,i)<=round(Rect_remove(k).rect(2))+round(Rect_remove(k).rect(4))) && (i>=round(Rect_remove(k).rect(1)))&&(i<=round(Rect_remove(k).rect(1))+round(Rect_remove(k).rect(3)))
                poz_fin(1,i) = NaN;
            end
        end
    end
    end
    
    poz_fin_sm = sgolayfilt(smooth(poz_fin(x_start:end)),5,7);
    
velocity = (-zero_line+poz_fin_sm).*scale;

    close all;figure;set(gcf, 'Position', get(0,'Screensize'));
    subplot(1,2,1)
    imshow(Im);hold on
    plot(poz_fin,'r-*'); plot(poz_fin_sm, 'g-.')
    line([ECG_signal.R_wave(beat) ECG_signal.R_wave(beat)],[1 size(Im,1)],'Color', 'w');
    line([ECG_signal.R_wave(beat+1) ECG_signal.R_wave(beat+1)],[1 size(Im,1)],'Color', 'w');
    title(['beat no ', num2str(beat)])
    subplot(1,2,2)
    plot(velocity,'k*-')
    
    Analysis_data(beat).poz_fin = poz_fin;
    Analysis_data(beat).poz_fin_sm = poz_fin_sm;
    Analysis_data(beat).velocity = velocity(ECG_signal.R_wave(beat)-add_on+1:ECG_signal.R_wave(beat+1)-add_on+1);
    
clear answer
prompt={'Keep velocity? yes/no'}; scale_diff = 'velocity'; defaultans = {'yes'}; options.Interpreter = 'tex'; answer = inputdlg(prompt,name,[1 40],defaultans,options);
Flag = answer;
Analysis_data(beat).Flag = Flag;
end
end

