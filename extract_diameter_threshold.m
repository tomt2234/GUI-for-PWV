 function [Preliminary_points, Input_data, Analysis_data] = extract_diameter_threshold(Images, ECG_signal, Frames)

 Im_each = Images.Im_each; Im_all = Images.Im_all; 

%select the scale
Imagine = Frames(1).Image;
close all;fig = imshow(Imagine(70:end,:,:)); name = 'scale';
title('please select scale both points'); [~,scale_points] = getpts;  scale_points = round(scale_points);
prompt={'Enter the scale you are measuring'}; scale_diff = 'scale measured'; defaultans = {'12'}; options.Interpreter = 'tex'; answer = inputdlg(prompt,name,[1 40],defaultans,options);
scale = abs(str2num(cell2mat(answer))/(scale_points(1) - scale_points(2)));%Input_data.scale = scale;

%delimit the search area
beat = 1;
    close all; figure;set(gcf, 'Position', get(0,'Screensize'));
    %initializing
    Im = Im_all(1:end,1:ECG_signal.R_wave(2)+10);
    fig = imshow(Im);
    title('please select middle line for up'); [~,middle_line_up] = getpts;  middle_line_up = round(middle_line_up); %middle_line = 450;
    title('please select middle line for down'); [~,middle_line_down] = getpts;  middle_line_down = round(middle_line_down); %middle_line = 450;
    title('please select line up'); [~,line_up] = getpts;  line_up = round(line_up);%line_up = 275;
    title('please select line down'); [~,line_down] = getpts;  line_down = round(line_down); %line_down = 700;
Input_data(beat).middle_line_up = middle_line_up;Input_data(beat).middle_line_down = middle_line_down;
Input_data(beat).line_up = line_up;Input_data(beat).line_down = line_down;
Input_data(beat).scale = scale;
Input_data(beat).beat = beat;
Input_data(beat).treshold_up = 45;Input_data(beat).treshold_down = 40;
treshold_up = 45;treshold_down = 40;

for beat=1:size(ECG_signal.R_wave,2)-1
      
%% thresholding

if beat==1; add_on = 1; else add_on = ECG_signal.R_wave(beat)-10; end
if beat~=size(ECG_signal.R_wave,2); add_off = ECG_signal.R_wave(beat+1)+10; else add_off = size(Im_all,2); end

Input_data(beat).add_on = add_on;Input_data(beat).add_off = add_off;
Im_each = Images.Im_each; Im_all = Images.Im_all;
x_start = 1; x_end = size(Im_all,2);
Im = Im_all(1:end,add_on:add_off); 

excl_up = [] - x_start+1;
excl_down = [] - x_start+1;

%************************************************************************
%preliminary tracing
%************************************************************************
    
    poz_fin_up(1:x_start-1) = NaN;
    for j = add_on-add_on+1:add_off-add_on+1%x_start:x_end
        line_raw_up = double(Im(middle_line_up:-1:line_up,j));
        line_raw_up(line_raw_up<treshold_up) = 0;
        poz_up = find(line_raw_up~=0, 1, 'first');
        poz_up(isempty(poz_up)) = NaN;
        poz_fin_up(j) = middle_line_up - poz_up(~isempty(poz_up));
        clear line_raw_up poz_up
    end
    one_beat_up = -poz_fin_up(add_on-add_on+1:add_off-add_on+1);%-poz_fin_up(x_start:x_end);%(ecg(beat):ecg(beat+1));
    one_beat_up_sm = smooth(one_beat_up)';
    k=isnan(one_beat_up);
    one_beat_up(k) = one_beat_up_sm(k);
    [xData, yData] = prepareCurveData( [], one_beat_up );
    ft = fittype( 'smoothingspline' );
    opts = fitoptions( ft );
    opts.SmoothingParam = 0.001;
    ex = excludedata( xData, yData, 'Indices', excl_up );%exclude data
    opts.Exclude = ex;
    [fitresult, gof] = fit( xData, yData, ft, opts );
    figure( 'Name', 'untitled fit 1' );
    h = plot( fitresult, xData, yData, ex );
    % h = plot( fitresult, xData, yData);
    legend( h, 'one_beat_up', 'Excluded one_beat_up', 'untitled fit 1', 'Location', 'NorthEast' );
    ylabel( 'one_beat_up' );
    grid on
    one_beat = get(h,'YData');
    one_beat_up_fit = one_beat{max(size(one_beat))};
    clear xData yData ft h one_beat opts ex



    poz_fin_down(1:x_start-1) = NaN;
    for j = add_on-add_on+1:add_off-add_on+1%x_start:x_end
        line_raw_down = double(Im(middle_line_down:line_down,j));
        line_raw_down(line_raw_down<treshold_down) = 0;
        poz_down = find(line_raw_down~=0, 1, 'first');
        poz_down(isempty(poz_down)) = NaN;
        poz_fin_down(j) = middle_line_down + poz_down(~isempty(poz_down));
        clear line_raw_down poz_down
    end
    one_beat_down = -poz_fin_down(add_on-add_on+1:add_off-add_on+1);%-poz_fin_down(x_start:x_end);%(ecg(beat):ecg(beat+1));
    one_beat_down_sm = smooth(one_beat_down)';
    k=isnan(one_beat_down);
    one_beat_down(k) = one_beat_down_sm(k);
    [xData, yData] = prepareCurveData( [], one_beat_down );
    ft = fittype( 'smoothingspline' );
    opts = fitoptions( ft );
    opts.SmoothingParam = 0.001;
     ex = excludedata( xData, yData, 'Indices', excl_down );%exclude data
     opts.Exclude = ex;
    [fitresult, gof] = fit( xData, yData, ft, opts );
    figure( 'Name', 'untitled fit 1' );
    h = plot( fitresult, xData, yData, ex );
    %h = plot( fitresult, xData, yData);
    legend( h, 'one_beat_down', 'Excluded one_beat_up', 'untitled fit 1', 'Location', 'NorthEast' );
    ylabel( 'one_beat_down' );
    grid on
    one_beat = get(h,'YData');
    one_beat_down_fit = one_beat{max(size(one_beat))};
    clear xData yData ft h one_beat opts ex

    length_before = max(size(one_beat_up_fit));
    one_beat_up_fit    = interp1(1:max(size(one_beat_up_fit)),   one_beat_up_fit,   1:length_before/max(size(one_beat_up)):  max(size(one_beat_up_fit)));
    one_beat_down_fit  = interp1(1:max(size(one_beat_down_fit)), one_beat_down_fit, 1:length_before/max(size(one_beat_down)):max(size(one_beat_down_fit)));
    diameter = (one_beat_up_fit - one_beat_down_fit).*scale;
    
%  this is the initial plot
    try
    close all; figure;set(gcf, 'Position', get(0,'Screensize'));
    subplot(1,2,1);
    if beat==1; add_on = 1; else add_on = ECG_signal.R_wave(beat)-10; end
    if beat~=size(ECG_signal.R_wave,2); add_off = ECG_signal.R_wave(beat+1)+10; else add_off = size(Im_all,2); end
    imshow(Im); hold on
        plot(+poz_fin_up(add_on-add_on+1:add_off-add_on+1),'r-*')
        plot(add_on-add_on+1:add_off-add_on+1, -one_beat_up_fit(add_on-add_on+1:add_off-add_on+1), 'g-.', 'LineWidth',1)
        plot(+poz_fin_down(add_on-add_on+1:add_off-add_on+1),'r-*')
        plot(add_on-add_on+1:add_off-add_on+1, -one_beat_down_fit(add_on-add_on+1:add_off-add_on+1), 'g-.', 'LineWidth',1)

    line([ECG_signal.R_wave(beat)-add_on+1 ECG_signal.R_wave(beat)-add_on+1],[1 size(Im,1)],'Color', 'w');
    line([ECG_signal.R_wave(beat+1)-add_on+1 ECG_signal.R_wave(beat+1)-add_on+1],[1 size(Im,1)],'Color', 'w');
    title(['beat no ', num2str(beat)])
    subplot(1,2,2)
    plot(diameter(add_on-add_on+1:add_off-add_on+1),'k-*')
    line([ECG_signal.R_wave(beat)-add_on+1 ECG_signal.R_wave(beat)-add_on+1],[min(diameter) max(diameter)],'Color', 'k');
    line([ECG_signal.R_wave(beat+1)-add_on+1 ECG_signal.R_wave(beat+1)-add_on+1],[min(diameter) max(diameter)],'Color', 'k');
    end
    
    %for changing the threshold
    for i=1:100
        prompt={'Previously used threshold up','Previously used threshold down'}; 
        dlg_title = 'Modify threshold';num_lines = 1;
        defaultans = {num2str(treshold_up),num2str(treshold_down)};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        
        if (treshold_up ~= str2num(cell2mat(answer(1)))) || (treshold_down ~= str2num(cell2mat(answer(2))))
            treshold_up = str2num(cell2mat(answer(1))); treshold_down = str2num(cell2mat(answer(2)));

            %recalculating the threshold
            poz_fin_up(1:x_start-1) = NaN;
            for j = add_on-add_on+1:add_off-add_on+1%x_start:x_end
                line_raw_up = double(Im(middle_line_up:-1:line_up,j));
                line_raw_up(line_raw_up<treshold_up) = 0;
                poz_up = find(line_raw_up~=0, 1, 'first');
                poz_up(isempty(poz_up)) = NaN;
                poz_fin_up(j) = middle_line_up - poz_up(~isempty(poz_up));
                clear line_raw_up poz_up
            end
            one_beat_up = -poz_fin_up(add_on-add_on+1:add_off-add_on+1);%-poz_fin_up(x_start:x_end);%(ecg(beat):ecg(beat+1));
            one_beat_up_sm = smooth(one_beat_up)';
            k=isnan(one_beat_up);
            one_beat_up(k) = one_beat_up_sm(k);
            [xData, yData] = prepareCurveData( [], one_beat_up );
            ft = fittype( 'smoothingspline' );
            opts = fitoptions( ft );
            opts.SmoothingParam = 0.001;
            ex = excludedata( xData, yData, 'Indices', excl_up );%exclude data
            opts.Exclude = ex;
            [fitresult, gof] = fit( xData, yData, ft, opts );
            figure( 'Name', 'untitled fit 1' );
            h = plot( fitresult, xData, yData, ex );
            % h = plot( fitresult, xData, yData);
            legend( h, 'one_beat_up', 'Excluded one_beat_up', 'untitled fit 1', 'Location', 'NorthEast' );
            ylabel( 'one_beat_up' );
            grid on
            one_beat = get(h,'YData');
            one_beat_up_fit = one_beat{max(size(one_beat))};
            clear xData yData ft h one_beat opts ex



            poz_fin_down(1:x_start-1) = NaN;
            for j = add_on-add_on+1:add_off-add_on+1%x_start:x_end
                line_raw_down = double(Im(middle_line_down:line_down,j));
                line_raw_down(line_raw_down<treshold_down) = 0;
                poz_down = find(line_raw_down~=0, 1, 'first');
                poz_down(isempty(poz_down)) = NaN;
                poz_fin_down(j) = middle_line_down + poz_down(~isempty(poz_down));
                clear line_raw_down poz_down
            end
            one_beat_down = -poz_fin_down(add_on-add_on+1:add_off-add_on+1);%-poz_fin_down(x_start:x_end);%(ecg(beat):ecg(beat+1));
            one_beat_down_sm = smooth(one_beat_down)';
            k=isnan(one_beat_down);
            one_beat_down(k) = one_beat_down_sm(k);
            [xData, yData] = prepareCurveData( [], one_beat_down );
            ft = fittype( 'smoothingspline' );
            opts = fitoptions( ft );
            opts.SmoothingParam = 0.001;
             ex = excludedata( xData, yData, 'Indices', excl_down );%exclude data
             opts.Exclude = ex;
            [fitresult, gof] = fit( xData, yData, ft, opts );
            figure( 'Name', 'untitled fit 1' );
            h = plot( fitresult, xData, yData, ex );
            %h = plot( fitresult, xData, yData);
            legend( h, 'one_beat_down', 'Excluded one_beat_up', 'untitled fit 1', 'Location', 'NorthEast' );
            ylabel( 'one_beat_down' );
            grid on
            one_beat = get(h,'YData');
            one_beat_down_fit = one_beat{max(size(one_beat))};
            clear xData yData ft h one_beat opts ex

            length_before = max(size(one_beat_up_fit));
            one_beat_up_fit    = interp1(1:max(size(one_beat_up_fit)),   one_beat_up_fit,   1:length_before/max(size(one_beat_up)):  max(size(one_beat_up_fit)));
            one_beat_down_fit  = interp1(1:max(size(one_beat_down_fit)), one_beat_down_fit, 1:length_before/max(size(one_beat_down)):max(size(one_beat_down_fit)));
            diameter = (one_beat_up_fit - one_beat_down_fit).*scale;

            %this is showing the results with the new thresholds
            close all; figure;set(gcf, 'Position', get(0,'Screensize'));
            subplot(1,2,1);
            if beat==1; add_on = 1; else add_on = ECG_signal.R_wave(beat)-10; end
            if beat~=size(ECG_signal.R_wave,2); add_off = ECG_signal.R_wave(beat+1)+10; else add_off = size(Im_all,2); end
            imshow(Im); hold on
                plot(+poz_fin_up(add_on-add_on+1:add_off-add_on+1),'r-*')
                plot(add_on-add_on+1:add_off-add_on+1, -one_beat_up_fit(add_on-add_on+1:add_off-add_on+1), 'g-.', 'LineWidth',1)
                plot(+poz_fin_down(add_on-add_on+1:add_off-add_on+1),'r-*')
                plot(add_on-add_on+1:add_off-add_on+1, -one_beat_down_fit(add_on-add_on+1:add_off-add_on+1), 'g-.', 'LineWidth',1)

            line([ECG_signal.R_wave(beat)-add_on+1 ECG_signal.R_wave(beat)-add_on+1],[1 size(Im,1)],'Color', 'w');
            line([ECG_signal.R_wave(beat+1)-add_on+1 ECG_signal.R_wave(beat+1)-add_on+1],[1 size(Im,1)],'Color', 'w');
            title(['beat no ', num2str(beat)])
            subplot(1,2,2)
            plot(diameter(add_on-add_on+1:add_off-add_on+1),'k-*')
            line([ECG_signal.R_wave(beat)-add_on+1 ECG_signal.R_wave(beat)-add_on+1],[min(diameter) max(diameter)],'Color', 'k');
            line([ECG_signal.R_wave(beat+1)-add_on+1 ECG_signal.R_wave(beat+1)-add_on+1],[min(diameter) max(diameter)],'Color', 'k');

        else
            break
        end
    end
    
Preliminary_points(beat).one_beat_up = one_beat_up;Preliminary_points(beat).one_beat_down = one_beat_down;
Preliminary_points(beat).one_beat_up_fit = one_beat_up_fit;Preliminary_points(beat).one_beat_down_fit = one_beat_down_fit;
Input_data(beat).treshold_up = treshold_up;Input_data(beat).treshold_down = treshold_down;


%% *************************************************************************
%exclude points

poz_fin_up = one_beat_up; poz_fin_down = one_beat_down;
%*************************************************************************    
    close all; figure;set(gcf, 'Position', get(0,'Screensize'));
    if beat==1; add_on = 1; else add_on = ECG_signal.R_wave(beat)-10; end
    if beat~=size(ECG_signal.R_wave,2); add_off = ECG_signal.R_wave(beat+1)+10; else add_off = size(Im_all,2); end
    Im = Images.Im_all(1:end,add_on:add_off);
    imshow(Im); hold on
        plot(-one_beat_up(add_on-add_on+1:add_off-add_on+1),'r-*')
        plot(add_on-add_on+1:add_off-add_on+1, -one_beat_up_fit(add_on-add_on+1:add_off-add_on+1), 'g-.', 'LineWidth',1)
        plot(-one_beat_down(add_on-add_on+1:add_off-add_on+1),'r-*')
        plot(add_on-add_on+1:add_off-add_on+1, -one_beat_down_fit(add_on-add_on+1:add_off-add_on+1), 'g-.', 'LineWidth',1)

    line([ECG_signal.R_wave(beat)-add_on+1 ECG_signal.R_wave(beat)-add_on+1],[1 size(Im,1)],'Color', 'w');
    line([ECG_signal.R_wave(beat+1)-add_on+1 ECG_signal.R_wave(beat+1)-add_on+1],[1 size(Im,1)],'Color', 'w');
    title(['beat no ', num2str(beat)])

    %sect points that are gonna be excluded - red ones
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
        Rect_remove(k).rect(Rect_remove(k).rect(1) < 0) = 1;
        %if Rect_remove(k).rect(2) < middle_line_up+50
            for i = 1:length(poz_fin_up)
                if (-poz_fin_up(1,i)>=round(Rect_remove(k).rect(2)))&&(-poz_fin_up(1,i)<=round(Rect_remove(k).rect(2))+round(Rect_remove(k).rect(4))) && (i>=round(Rect_remove(k).rect(1)))&&(i<=round(Rect_remove(k).rect(1))+round(Rect_remove(k).rect(3)))
                    %a=1%excl_up_all(k,i) = poz_fin_up(1,i);% - x_start+1;
                    poz_fin_up(1,i) = NaN;
                end
            end
        %elseif Rect_remove(k).rect(2) > middle_line_down-50
             for i = 1:length(poz_fin_up)
                if (-poz_fin_down(1,i)>=round(Rect_remove(k).rect(2)))&&(-poz_fin_down(1,i)<=round(Rect_remove(k).rect(2))+round(Rect_remove(k).rect(4))) && (i>=round(Rect_remove(k).rect(1)))&&(i<=round(Rect_remove(k).rect(1))+round(Rect_remove(k).rect(3)))
                    %b=2%excl_down_all(k,i) = poz_fin_down(1,i);% - x_start+1;
                    poz_fin_down(1,i) = NaN;
                end
             end
        %end
    end
    end
    
    excl_up = reshape (excl_up_all, 1, size(excl_up_all,1)*size(excl_up_all,2) );
    excl_down = reshape (excl_down_all, 1, size(excl_down_all,1)*size(excl_down_all,2) );
    excl_up(excl_up == 0) = []; excl_up(isnan(excl_up)) = [];
    excl_down(excl_down == 0) = []; excl_down(isnan(excl_down)) = [];



    one_beat_up = poz_fin_up(add_on-add_on+1:add_off-add_on+1);%(ecg(beat):ecg(beat+1));
    one_beat_up_sm = smooth(one_beat_up)';
    k=isnan(one_beat_up);
    one_beat_up(k) = one_beat_up_sm(k);
    [xData, yData] = prepareCurveData( [], one_beat_up );
    ft = fittype( 'smoothingspline' );
    opts = fitoptions( ft );
    opts.SmoothingParam = 0.001;
    ex = excludedata( xData, yData, 'Indices', excl_up );%exclude data
    opts.Exclude = ex;
    [fitresult, gof] = fit( xData, yData, ft, opts );
    figure( 'Name', 'untitled fit 1' );
    h = plot( fitresult, xData, yData, ex );
    % h = plot( fitresult, xData, yData);
    legend( h, 'one_beat_up', 'Excluded one_beat_up', 'untitled fit 1', 'Location', 'NorthEast' );
    ylabel( 'one_beat_up' );
    grid on
    one_beat = get(h,'YData');
    one_beat_up_fit = one_beat{max(size(one_beat))};
    clear xData yData ft h one_beat opts ex



    one_beat_down = poz_fin_down(add_on-add_on+1:add_off-add_on+1);%(ecg(beat):ecg(beat+1));
    one_beat_down_sm = smooth(one_beat_down)';
    k=isnan(one_beat_down);
    one_beat_down(k) = one_beat_down_sm(k);
    [xData, yData] = prepareCurveData( [], one_beat_down );
    ft = fittype( 'smoothingspline' );
    opts = fitoptions( ft );
    opts.SmoothingParam = 0.001;
     ex = excludedata( xData, yData, 'Indices', excl_down );%exclude data
     opts.Exclude = ex;
    [fitresult, gof] = fit( xData, yData, ft, opts );
    figure( 'Name', 'untitled fit 1' );
    h = plot( fitresult, xData, yData, ex );
    %h = plot( fitresult, xData, yData);
    legend( h, 'one_beat_down', 'Excluded one_beat_up', 'untitled fit 1', 'Location', 'NorthEast' );
    ylabel( 'one_beat_down' );
    grid on
    one_beat = get(h,'YData');
    one_beat_down_fit = one_beat{max(size(one_beat))};
    clear xData yData ft h one_beat opts ex

    length_before = max(size(one_beat_up_fit));
    one_beat_up_fit    = interp1(1:max(size(one_beat_up_fit)),   one_beat_up_fit,   1:length_before/max(size(one_beat_up)):  max(size(one_beat_up_fit)));
    one_beat_down_fit  = interp1(1:max(size(one_beat_down_fit)), one_beat_down_fit, 1:length_before/max(size(one_beat_down)):max(size(one_beat_down_fit)));
    diameter = (one_beat_up_fit - one_beat_down_fit).*scale;
    
    
    close all; figure;set(gcf, 'Position', get(0,'Screensize'));
    subplot(1,2,1);
    if beat==1; add_on = 1; else add_on = ECG_signal.R_wave(beat)-10; end
    if beat~=size(ECG_signal.R_wave,2); add_off = ECG_signal.R_wave(beat+1)+10; else add_off = size(Im_all,2); end
    imshow(Im); hold on
        plot(-poz_fin_up(add_on-add_on+1:add_off-add_on+1),'r-*')
        plot(add_on-add_on+1:add_off-add_on+1, -one_beat_up_fit(add_on-add_on+1:add_off-add_on+1), 'g-.', 'LineWidth',1)
        plot(-poz_fin_down(add_on-add_on+1:add_off-add_on+1),'r-*')
        plot(add_on-add_on+1:add_off-add_on+1, -one_beat_down_fit(add_on-add_on+1:add_off-add_on+1), 'g-.', 'LineWidth',1)

    line([ECG_signal.R_wave(beat)-add_on+1 ECG_signal.R_wave(beat)-add_on+1],[1 size(Im,1)],'Color', 'w');
    line([ECG_signal.R_wave(beat+1)-add_on+1 ECG_signal.R_wave(beat+1)-add_on+1],[1 size(Im,1)],'Color', 'w');
    title(['beat no ', num2str(beat)])
    subplot(1,2,2)
    plot(diameter(add_on-add_on+1:add_off-add_on+1),'k-*')
    line([ECG_signal.R_wave(beat)-add_on+1 ECG_signal.R_wave(beat)-add_on+1],[min(diameter) max(diameter)],'Color', 'k');
    line([ECG_signal.R_wave(beat+1)-add_on+1 ECG_signal.R_wave(beat+1)-add_on+1],[min(diameter) max(diameter)],'Color', 'k');


    Analysis_data(beat).one_beat_up_fit = one_beat_up_fit;
    Analysis_data(beat).one_beat_down_fit = one_beat_down_fit;
    Analysis_data(beat).diameter = diameter(ECG_signal.R_wave(beat)-add_on+1:ECG_signal.R_wave(beat+1)-add_on+1);
    
clear answer
prompt={'Keep diameter? yes/no'}; scale_diff = 'diameter'; defaultans = {'yes'}; options.Interpreter = 'tex'; answer = inputdlg(prompt,name,[1 40],defaultans,options);
Flag = answer;
Analysis_data(beat).Flag = Flag;
end







