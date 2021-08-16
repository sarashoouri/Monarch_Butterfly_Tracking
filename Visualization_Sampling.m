
load('raw_data_test.mat')
T1=Table;
load('Final_Sampled.mat')

D = size(Table.light, 2);
gap = 48/D;
t = (0:D-1)*48/D;

mask = zeros(8,height(Table));
mask(1,:) = Table.month==9  & Table.day>=1  & Table.day<=15;
mask(2,:) = Table.month==9  & Table.day>=16 & Table.day<=30;
mask(3,:) = Table.month==10 & Table.day>=1  & Table.day<=15;
mask(4,:) = Table.month==10 & Table.day>=16 & Table.day<=31;
mask(5,:) = Table.month==11 & Table.day>=1  & Table.day<=15;
mask(6,:) = Table.month==11 & Table.day>=16 & Table.day<=30;
mask(7,:) = Table.month==12 & Table.day>=1  & Table.day<=15;
mask(8,:) = Table.month==12 & Table.day>=16 & Table.day<=31;

NUM = height(Table);
DISPLAY = 0;

% Place to store the results
% 1. Absolute longitude error using only light intensity
% 2. Absolute latitude error using only light intensity
% 3. Absolute longitude error with both light and temperature 
% 4. Absolute latitude error with both light and temperature 
% 5. Averaged divation of longitude for light heatmap 
% 6. Averaged divation of latitude for light heatmap
% 7. Averaged divation of longitude for light&temp heatmap
% 8. Averaged divation of latitude for light&temp heatmap
results_all = zeros(8, NUM);

% The list of data that are evaluated to be invalid
%outlier_list = [732,661,643,627,561,560,.554,536,529,505,499,493,478,472,463,428,421,420,400,397,336,320,303,279,264,192,180,175,166,164,150,148,146,129,102,98,96,85,84,76,63,61,1,12,14,19,36,37,47, 43,48,57, 56, 185, 239, 260, 322, 327, 365, 367, 459, 405];
%outlier_list = [56, 185, 239, 260, 322, 327, 365, 367, 459, 405];
outlier_list=[]
for i = 1:NUM
    
    %load(['./testdata/Test_set_light/',num2str(i),'.mat'])
    load(['./new_test_sampled/',num2str(i),'.mat'])
    p=find(T1.year==Table.year(i) & T1.month==Table.month(i) & T1.day==Table.day(i) & T1.latitude==Table.latitude(i) & T1.longitude==Table.longitude(i))

    load(['./testdata/Test_set_temp/',num2str(p),'.mat'])
    
    % Calculate the number of missing data
    num_miss = sum(temp_mask, 'A');
    
    if ismember(i,outlier_list) 
        results_all(:, i) = NaN;
        continue
    end
    
    long = Table.longitude(i);
    lat = Table.latitude(i);
    
    % Coarse grid
    long_cor = [-10:1:10] + round(long);
    lat_cor = [-30:1:30] + round(lat);
    [long_cor_grid,lat_cor_grid] = meshgrid(long_cor,lat_cor);
    % Fine grid
    long_fine = [-10:0.1:10] + round(long);
    lat_fine = [-30:0.1:30] + round(lat);
    [long_fine_grid,lat_fine_grid] = meshgrid(long_fine,lat_fine);

    % Read the coarse heatmap for both light and temperature
    %load(['./Heatmaps_light/light_',num2str(i),'.mat']);
    load(['./Heatmap_sampled/results/Heatmaps_light/light_',num2str(i),'.mat']);
    heatmap_light = results';
    load(['./Heatmaps_temp/temp_',num2str(p),'.mat']);
    result_temp = results;
    result_temp(temp_mask==1) = NaN;
    result_temp = fillmissing(result_temp,'linear');
    heatmap_temp = result_temp';
    
    % Do coarse estimation on light hetmap
    [max_cor,max_idx] = max(heatmap_light(:));
    [lat_idx, long_idx]=ind2sub(size(heatmap_light),max_idx);
    long_light_coarse = long_cor(long_idx);
    lat_light_coarse = lat_cor(lat_idx);
    
    % Fine estimation for light heatmap
    long_focus_fine = [-2:0.01:2] + long_light_coarse;
    lat_focus_fine = [-2:0.01:2] + lat_light_coarse;
    [long_focus_grid_fine,lat_focus_grid_fine] = meshgrid(long_focus_fine,lat_focus_fine);
    heatmap_focus = interp2(long_cor,lat_cor,heatmap_light,long_focus_grid_fine,lat_focus_grid_fine, 'cubic');
    [max_cor,max_idx] = max(heatmap_focus(:));
    [lat_idx, long_idx]=ind2sub(size(heatmap_focus),max_idx);
    long_light_fine = long_focus_fine(long_idx);
    lat_light_fine = lat_focus_fine(lat_idx);
    
    results_all(1, i) = abs(long_light_fine-long);
    results_all(2, i) = abs(lat_light_fine-lat);
    
    % Combine two heatmaps and do coarse estimation
    heatmap_comb = heatmap_temp .* heatmap_light;
    [max_cor,max_idx] = max(heatmap_comb(:));
    [lat_idx, long_idx]=ind2sub(size(heatmap_comb),max_idx);
    long_comb_coarse = long_cor(long_idx);
    lat_comb_coarse = lat_cor(lat_idx);
    
    % Fine estimation on the combined heatmaps
    long_focus_fine = [-2:0.01:2] + long_comb_coarse;
    lat_focus_fine = [-2:0.01:2] + lat_comb_coarse;
    [long_focus_grid_fine,lat_focus_grid_fine] = meshgrid(long_focus_fine,lat_focus_fine);
    heatmap_focus = interp2(long_cor,lat_cor,heatmap_comb,long_focus_grid_fine,lat_focus_grid_fine, 'cubic');
    [max_cor,max_idx] = max(heatmap_focus(:));
    [lat_idx, long_idx]=ind2sub(size(heatmap_focus),max_idx);
    long_comb_fine = long_focus_fine(long_idx);
    lat_comb_fine = lat_focus_fine(lat_idx);
    
    results_all(3, i) = abs(long_comb_fine-long);
    results_all(4, i) = abs(lat_comb_fine-lat);
    
    % Calculate the deviation of the heatmap to ground truth
    [div_long, div_lat] = deviation(long_cor,lat_cor, heatmap_light, long, lat);
    results_all(5, i) = div_long;
    results_all(6, i) = div_lat;
    
    [div_long, div_lat] = deviation(long_cor,lat_cor, heatmap_comb, long, lat);
    results_all(7, i) = div_long;
    results_all(8, i) = div_lat;
    
    % Calculate the fine heatmap for visualization
    heatmap_light_fine = interp2(long_cor_grid,lat_cor_grid,heatmap_light,long_fine_grid,lat_fine_grid, 'cubic',0);
    heatmap_light_fine(heatmap_light_fine<0) = 0;
    heatmap_light_fine = heatmap_light_fine/max(max(heatmap_light_fine));
    
    heatmap_temp_fine = interp2(long_cor_grid,lat_cor_grid,heatmap_temp,long_fine_grid,lat_fine_grid, 'cubic',0);
    heatmap_temp_fine(heatmap_temp_fine<0) = 0;
    heatmap_temp_fine = heatmap_temp_fine/max(max(heatmap_temp_fine));
    
    heatmap_combined = heatmap_light_fine .* heatmap_temp_fine;
    
    if DISPLAY == 1
        
        figure;
        subplot(2,3,1)
        title(['month:',num2str(Table.month(i)),'  day:', num2str(Table.day(i)), ' LIGHT'])
        surface(long_fine_grid-round(long),lat_fine_grid-round(lat),heatmap_light_fine,'edgecolor', 'None');hold on
        ylim([-20,20])
        xlim([-10,10])
        xlabel('longitude')
        ylabel('latitude')
        
        scatter3(long_light_coarse-round(long), lat_light_coarse-round(lat), 1, 20, 'k', 'filled')
        
        subplot(2,3,2)
        title(['month:',num2str(Table.month(i)),'  day:', num2str(Table.day(i)), ' TEMP'])
        surface(long_fine_grid-round(long),lat_fine_grid-round(lat),heatmap_temp_fine,'edgecolor', 'None');hold on
        ylim([-20,20])
        xlim([-10,10])
        xlabel('longitude')
        ylabel('latitude')
        
        
        subplot(2,3,3)
        title(['month:',num2str(Table.month(i)),'  day:', num2str(Table.day(i)), ' COMBINED'])
        surface(long_fine_grid-round(long),lat_fine_grid-round(lat),heatmap_combined,'edgecolor', 'None');hold on
        ylim([-20,20])
        xlim([-10,10])
        xlabel('longitude')
        ylabel('latitude')
        
        scatter3(long_comb_coarse-round(long), lat_comb_coarse-round(lat), 1, 20, 'k', 'filled')
        
        
        subplot(2,3,4)
        lights = [];
        for j = 1:21
            mm = heatmap_light(:,j) > 0.5;
            if sum(mm)>1
                lights = [lights;squeeze(test_light(j,mm,:))];
            elseif sum(mm)==1
                lights = [lights;squeeze(test_light(j,mm,:))'];
            end
        end
        
        plot(lights'); hold on
        title('Good light curves from discriminator')
        plot(120*ones(1,100), linspace(0,2,100), 'linewidth',2);hold on
        plot(360*ones(1,100), linspace(0,2,100), 'linewidth',2);hold on
        ylim([0,4])
        
        subplot(2,3,5)
        temps = [];
        for j = 1:21
            mm = heatmap_temp(:,j) > 0.5;
            if sum(mm)>1
                temps = [temps;squeeze(test_temp(j,mm,:))];
            elseif sum(mm)==1
                temps = [temps;squeeze(test_temp(j,mm,:))'];
            end
        end
        
        plot(temps'); hold on
        title('Good temperature curves from discriminator')
        ylim([-10,30])
        keyboard
    end
  
    i
end

%%

%%%% Visualize the results
rng = 2;
num_sample= zeros(1,8);
mean_error_comb_lat1 = zeros(1,8);
mean_error_comb_long1 = zeros(1,8);
mean_error_light_lat1 = zeros(1,8);
mean_error_light_long1 = zeros(1,8);
median_error_comb_lat1 = zeros(1,8);
median_error_comb_long1 = zeros(1,8);
median_error_light_lat1 = zeros(1,8);
median_error_light_long1 = zeros(1,8);
mean_div_comb_long1 = zeros(1,8);
mean_div_comb_lat1 = zeros(1,8);
mean_div_light_long1 = zeros(1,8);
mean_div_light_lat1 = zeros(1,8);
median_div_comb_long1 = zeros(1,8);
median_div_comb_lat1 = zeros(1,8);
median_div_light_long1 = zeros(1,8);
median_div_light_lat1 = zeros(1,8);

for n = 1:8
    mean_error_light_long1(n)  = nanmean(abs(results_all(1, mask(n,:)==1)));
    mean_error_light_lat1(n)   = nanmean(abs(results_all(2, mask(n,:)==1)));
    mean_error_comb_long1(n)   = nanmean(abs(results_all(3, mask(n,:)==1)));
    mean_error_comb_lat1(n)    = nanmean(abs(results_all(4, mask(n,:)==1)));
    
    median_error_light_long1(n) = nanmedian(abs(results_all(1, mask(n,:)==1)));
    median_error_light_lat1(n)  = nanmedian(abs(results_all(2, mask(n,:)==1)));
    median_error_comb_long1(n)  = nanmedian(abs(results_all(3, mask(n,:)==1)));
    median_error_comb_lat1(n)   = nanmedian(abs(results_all(4, mask(n,:)==1)));
    
    mean_div_light_long1(n)  = nanmean(results_all(5, mask(n,:)==1));
    mean_div_light_lat1(n)   = nanmean(results_all(6, mask(n,:)==1));
    mean_div_comb_long1(n)   = nanmean(results_all(7, mask(n,:)==1));
    mean_div_comb_lat1(n)    = nanmean(results_all(8, mask(n,:)==1));
    
    median_div_light_long1(n)  = nanmedian(results_all(5, mask(n,:)==1));
    median_div_light_lat1(n)   = nanmedian(results_all(6, mask(n,:)==1));
    median_div_comb_long1(n)   = nanmedian(results_all(7, mask(n,:)==1));
    median_div_comb_lat1(n)    = nanmedian(results_all(8, mask(n,:)==1)); 
end
%%
close all
figure;
%X={'Sep 1st-15th'; 'Sep 16th-30th';  'Oct 1st-15th'; 'Oct 16th-30th'; 'Nov 1st-15th' ;'Nov 16th-30th';'Dec 1st-15th';'Dec 16th-30th'}
X={'9/1-9/15'; '9/16-9/30';  '10/1-10/15'; '10/16-10/30'; '11/1-11/15' ;'11/16-11/30';'12/1-12/15';'12/16-12/30'}
plot(mean_error_light_lat, '-s', 'MarkerSize',12,'linewidth', 5); hold on
plot(mean_error_light_lat1, '-d', 'MarkerSize',12,'linewidth', 5); hold on

plot(mean_error_comb_lat, '-s', 'MarkerSize',12,'linewidth', 5); hold on
plot(mean_error_comb_lat1, '-s', 'MarkerSize',12,'linewidth', 5); hold on

plot(mean_error_light_long, '--^','MarkerSize',12, 'linewidth', 5); hold on
plot(mean_error_light_long1, '--V', 'MarkerSize',12,'linewidth', 5); hold on
plot(mean_error_comb_long, '--V', 'MarkerSize',12,'linewidth', 5); hold on
plot(mean_error_comb_long1, '--V', 'MarkerSize',12,'linewidth', 5); hold on
ylabel('Degree','FontWeight','bold')
title('Mean Absolute Estimation Error ')
lg=legend('Latitude (Light only) -  Yang2021', 'Latitude  (Light only) - mSAIL','Latitude (Light & Temp) -  Yang2021', 'Latitude (Light & Temp) - mSAIL', 'Longitude (Light only) -  Yang2021', 'Longitude (Light only) - mSAIL','Longitude (Light & Temp) -  Yang2021', 'Longitude (Light & Temp) - mSAIL')
 %textobj = findobj(hobj1, 'type', 'text','fontsize', 30);
%set(textobj, 'Interpreter', 'latex', 'fontsize', 18,'linewidth', 3,'FontWeight','bold');
lgd.FontSize = 45;
legend boxoff
grid on
xticklabels(X);
%xtickangle(45)
xlabel('Date')
ax1=gca;
%ax1.YAxis.LineWidth = 2
ax1.XGrid = 'off';
ax1.YGrid = 'on';
set(gcf,'color','w');
set(gca,'FontSize',35)
H=gca;
H.LineWidth=2;
%ylim([0,20]);
%%
close all
plot(median_error_light_lat, '-s', 'linewidth', 2); hold on
plot(median_error_light_lat1, '-d', 'linewidth', 2); hold on
%%
plot(median_error_light_long, '--^', 'linewidth', 2); hold on
plot(median_error_light_long1, '--V', 'linewidth', 2); hold on

ylim([0,15]);
title('Median Absolute Estimation Error ')
legend('Lat -  normal sampling', 'Lat - new Samlping', 'Long -  normal sampling', 'Long - new Samlping')
set(gcf,'color','w');
set(gca,'FontSize',15)
H=gca;
ylabel('Degree')
H.LineWidth=2;
grid on
xticklabels(X);
%%
close all
figure;
X={'Sep 1-15'; 'Sep 16-30';  'Oct 1-15'; 'Oct 16-30'; 'Nov 1-15' ;'Nov 16-30';'Dec 1-15';'Dec 16-30'}


plot(mean_error_comb_lat1, '-x', 'linewidth', 2); hold on
plot(mean_error_light_lat1, '-o', 'linewidth', 2); hold on
plot(mean_error_comb_long1, '--x', 'linewidth', 2); hold on
plot(mean_error_light_long1, '--o', 'linewidth', 2); hold on
ylabel('Degree')
title('Mean Estimation Error using New Sampling method')
legend('Combined lat', 'Light only lat', 'Combined long', 'Light only long')

grid on
xticklabels(X);
set(gcf,'color','w');
set(gca,'FontSize',15)
H=gca;
H.LineWidth=2;
ylim([0,15]);
%%
close all
figure;
X={'Sep 1-15'; 'Sep 16-30';  'Oct 1-15'; 'Oct 16-30'; 'Nov 1-15' ;'Nov 16-30';'Dec 1-15';'Dec 16-30'}


plot(mean_error_comb_lat, '-x', 'linewidth', 2); hold on
plot(mean_error_light_lat, '-o', 'linewidth', 2); hold on
plot(mean_error_comb_long, '--x', 'linewidth', 2); hold on
plot(mean_error_light_long, '--o', 'linewidth', 2); hold on
ylabel('Degree')
title('Mean Estimation Error using normal Sampling method')
legend('Combined lat', 'Light only lat', 'Combined long', 'Light only long')

grid on
xticklabels(X);
set(gcf,'color','w');
set(gca,'FontSize',15)
H=gca;
H.LineWidth=2;
ylim([0,15]);