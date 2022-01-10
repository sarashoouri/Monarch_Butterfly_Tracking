
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('../Utils'));
addpath(genpath('../'));
fprintf('Add path done !!\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate the test set by sampling around the ground truth
% LIGHT: 1) get the true sunrise and sunset time 2) shift & scale the light curve
% TEMPERATURE: 1) 

load('raw_data_2019_test.mat')

LIGHT_LENGTH = 48;
TEMP_LENGTH = 32;

[N, light_len] = size(light_test);
temp_len = size(temp_test,2);
 
time_unit = LIGHT_LENGTH/light_len;

time_light = (0:light_len-1)*time_unit;
time_temp_w = 0:TEMP_LENGTH-1;
time_temp = (0:temp_len-1)*time_unit;
time_buff = zeros(1,10);

% For each test data, generate the corresponding input to neural network
for num = 1:N
    
    year = Table.year(num);
    month = Table.month(bum);
    day = Table.day(num);
    [month_next, day_next] = next_day(month, day, 1);
    
    long = Table.longitude(num);
    lat = Table.latitude(num);
    shift = Table.shift(num);
    
    [mm_next, dd_next] = next_day(month, day, 1);
    [mm_next3, dd_next3] = next_day(month, day, 3);
    
    longitude_range = round(longitude) + [-10:1:10];
    latitude_range  = round(latitude) + [-30:1:30];
    
    time_start = datetime(2019,month,day,0,0,0);
    time_end   = datetime(2019,mm_next3,dd_next3,0,0,0);
    
    
    test_light = zeros(length(longitude_range), length(latitude_range), light_len/2);
    test_tmp = zeros(length(longitude_range), length(latitude_range), 48);
    test_cloud = zeros(length(longitude_range), length(latitude_range), 24);
    test_sunrise = zeros(length(longitude_range), length(latitude_range));
    test_sunset = zeros(length(longitude_range), length(latitude_range));
    temp_mask  = zeros(length(longitude_range), length(latitude_range));
    cloud_mask = zeros(length(longitude_range), length(latitude_range));
    
    light_intensity = log10(light_test(num,:)+1);
    tmp_true = temp_test(num,:);
    
    for m = 1:length(longitude_range)
        for n = 1:length(latitude_range)
            % For each grid point around the ground truth
            tic;
            long = longitude_range(m);
            lat = latitude_range(n);
            
            [sunrise_time_prev, sunset_time_prev] = get_sun_data_offline(lat, long, 2018, month, day);
            [sunrise_time_next, sunset_time_next] = get_sun_data_offline(lat, long, 2018, mm_next, dd_next);
            
            [time_w,cloud,temp] = get_weather_data(time_start,time_end,long,lat);
            
            % If some problems with sunrise and sunset te
            if sunrise_time_next == -1000 || sunset_time_next== -1000 || sunrise_time_prev == -1000 || sunset_time_prev == -1000
                test_light(m,n,:) = -1000*ones(size(test_light,3),1);
                test_sunrise(m,n) = -1000;
                test_sunset(m,n) = -1000;
                continue;
            end
            
            sunrise = sunrise_time_next+24;
            sunset = sunset_time_prev;
            
            set = sunset - shift*time_unit;
            rise = sunrise - shift*time_unit;
            light_intensity_new = reshape_curve_double_new(light_intensity, set, rise, 18, 30, time_unit, 24);
            light_intensity_new(light_intensity_new<0) = 0;
            test_light(m,n,:) = light_intensity_new;
            test_sunrise(m,n) = rise;
            test_sunset(m,n) = set;
            
            if sum(temp==-1000 | isnan(temp)) > 0
                temp_mask(m,n) = 1;
            end
            
            if sum(cloud==-1000 | isnan(cloud)) > 0
                cloud_mask(m,n) = 1;
            end
            
            if isempty(cloud) || isempty(temp) || max(time_w - time_w(1))/3600 < 71
                temp_mask(m,n) = 1;
                cloud_mask(m,n) = 1;
                test_tmp(m,n,:) = -1000*ones(size(test_tmp,3),1);
                test_cloud(m,n,:) = -1000*ones(size(test_cloud,3),1);
                continue;
            end
            
            center = (sunrise + sunset)/2;
            time_w = (time_w - time_w(1))/60/60;

            temp_s = interp1(time_temp,tmp_true,time_temp_w,'linear');
            temp_w = interp1(time_w,temp,time_temp_w,'linear');    
            cloud = interp1(time_w,cloud,time_temp_w,'linear');    
                
            center_idx_w = round(center);    
                
            temp_from_sensor = temp_s(center_idx_w-12:center_idx_w+11);
            temp_from_station = temp_w(center_idx_w-12:center_idx_w+11);
            cloud_from_station = cloud(center_idx_w-12:center_idx_w+11);
                
            test_tmp(m,n,:) = [temp_from_sensor, temp_from_station];
            test_cloud(m,n,:) = cloud_from_station;
                
            
            t = toc;
            
            time_buff = circshift(time_buff,-1);
            time_buff(end)=t;
        
            format = 'Reading the %dth test date. Completed %f. Estimated time remaining: %fh\n';
            completed_read =  (num-1)*length(longitude_range)*length(latitude_range) + (m-1)*length(latitude_range) + n
            percentage = completed_read/(N*length(longitude_range)*length(latitude_range))*100;
            expected_time = ((N*length(longitude_range)*length(latitude_range))- completed_read)*mean(time_buff)/3600;
            fprintf(format, num, percentage, expected_time);
        end
    end
            
           
    %save(['Test_set_60s_latest_light/',num2str(num),'.mat'], 'test_tmp', 'test_cloud', 'test_light','test_sunrise','test_sunset','mask');
   % save(['../data/Test_set_30s_2019/',num2str(num),'.mat'], 'test_light', 'test_tmp', 'test_cloud', 'test_sunrise','test_sunset', 'temp_mask', 'cloud_mask');
end
