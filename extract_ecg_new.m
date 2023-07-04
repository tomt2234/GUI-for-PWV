function [ECG_signal] = extract_ecg_new(Images)
%the function extracts the ECG based on colour and it will have to be adapted to a new machine for those colour settings
clear Im_each Im_cut ecg_signal_x ecg_signal_y ECG ECG_signal ECG_new ECG_signal_x ECG_signal_y ECG_signal ECG_signal.R_wave_first
clear vec periodicity limit_high 
Im_each = Images.Im_each_color;
for k = 1:size(Im_each,2)
    try
    clear Im_cut ecg_signal_x ecg_signal_y
    %the area where to look for the ECG signal
    Im_cut = Im_each(k).Photo(550:end,:,:);
    count = 0;
    for i = 1:size(Im_cut,2)
        ecg_signal_x(i) = NaN;ecg_signal_y(i) = NaN;
        for j = 1:size(Im_cut,1)
            if (Im_cut(j,i,1) > 15)&&(Im_cut(j,i,1) < 80) && (Im_cut(j,i,2) > 120)&&(Im_cut(j,i,2) < 200) && (Im_cut(j,i,3) > 110)&&(Im_cut(j,i,3) < 190)
                count = count+1;
                %the ECG determined by colour, 3 channels
                ecg_signal_y(i) = i;ecg_signal_x(i) = j;
                break
            end
        end
    end

%     figure;imshow(Im_cut);hold on;
%     plot(ecg_signal_y,ecg_signal_x,'r*')
    
    ECG(k).ecg_signal_y = ecg_signal_x;
    ECG(k).ecg_signal_x = ecg_signal_y;
    end
end
%%%this section is added in case of an error 
for kk =1:size(ECG,2)
    ECG_signal_y((kk-1)*size(ECG(kk).ecg_signal_y,2)+1:kk*size(ECG(kk).ecg_signal_y,2)) = ECG(kk).ecg_signal_y;
    ECG_signal_x((kk-1)*size(ECG(kk).ecg_signal_x,2)+1:kk*size(ECG(kk).ecg_signal_x,2)) = ECG(kk).ecg_signal_x + (kk-1)*size(ECG(kk).ecg_signal_y,2);
end
%the ECG was determined
ECG_signal_y(ECG_signal_y == 0) = NaN;ECG_signal_x(ECG_signal_x == 0) = NaN;
ECG_signal.ECG_signal_y = ECG_signal_y; ECG_signal.ECG_signal_x = ECG_signal_x; 
for i=3:length(ECG_signal.ECG_signal_y)
    if(isnan(ECG_signal.ECG_signal_y(i))==1)
        ECG_signal.ECG_signal_y(i)=ECG_signal.ECG_signal_y(i-1)+0.001;
    end
end
ECG_signal_y=ECG_signal.ECG_signal_y;
% the peaks are determined imposing a min height
limit_high = abs((min(-ECG_signal.ECG_signal_y)-max(-ECG_signal.ECG_signal_y))*0.9)+min(-ECG_signal.ECG_signal_y);
[~,ECG_signal.R_wave_first] = findpeaks(-ECG_signal_y,'MinPeakHeight',limit_high);
vec = diff(ECG_signal.R_wave_first);periodicity_first = mean(vec);
for j = 1:size(vec,2)
    if vec(j) < periodicity_first/2
        vec(j) = NaN;
    end
end
periodicity = min(vec);
% and a determined periodicity 
[~,ECG_signal.R_wave] = findpeaks(-ECG_signal_y,'MinPeakDist',periodicity);
%figure;plot(ECG_signal.ECG_signal_x,-ECG_signal.ECG_signal_y,'LineWidth',3)
for j=1:max(size(ECG_signal.R_wave)) line([ECG_signal.R_wave(j) ECG_signal.R_wave(j)],[1 min(-ECG_signal.ECG_signal_y)],'Color', [0 0 0]); end
line([1 size(ECG_signal.ECG_signal_y,2)],[limit_high limit_high],'Color', [0 0 0]);




