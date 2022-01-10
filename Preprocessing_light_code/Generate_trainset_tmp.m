
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('../Utils'));
addpath(genpath('../'));
fprintf('Add path done !!\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate the train set to train the temp neural network

load('./data/30s_raw_data_clean_2019');
%%
N = length(month_clean);

tmp_set = [];
labels = [];
long_set = [];
lat_set = [];
month_set = [];
day_set = [];

index = [];
sig_len = size(temp_clean,2);

res = 1;
WIN_LEN = 16;
WIN_RANGE = [-WIN_LEN/2:res:WIN_LEN/2-res];

time_gap = 72/sig_len;

fprintf('Loading the maps...')
load('maps_new.mat')

N_false_sample = 15;
N_true_sample = 5;
count = 0;
%%
for i = 1:N
    
    tmp_true = temp_clean(i,:);
    time_s = (0:sig_len-1)*time_gap;
    
    longitude = longitude_clean(i);
    latitude = latitude_clean(i);
    month = month_clean(i);
    day = day_clean(i);
    
    [mm_next, dd_next] = next_day(month, day, 2);
    [mm_next1, dd_next1] = next_day(month, day, 1);
    
    time_start = datetime(2020,month,day,0,0,0);
    time_end   = datetime(2020,mm_next,dd_next,0,0,0);
    time_grid_w = 0:47;
    
    for n=1:N_true_sample+N_false_sample
        
        lat = lat_map(i,n); 
        long= long_map(i,n);
        
        lat_set = [lat_set, lat];
        long_set = [long_set, long];
        month_set = [month_set, month];
        day_set = [day_set, day];
        
        [time_w,cloud,temp] = get_weather_data(time_start,time_end,long,lat); 
        [sunrise_time_prev, sunset_time_prev] = get_sun_data_offline(lat, long, 0, 2019, month, day, 0);
        [sunrise_time_next, sunset_time_next] = get_sun_data_offline(lat, long, 0, 2019, mm_next1, dd_next1, 0);
        
        sunrise = sunrise_time_next+24;
        sunset = sunset_time_prev;
        center = (sunrise + sunset)/2;
        
        if isempty(time_w)
            tmp_set = [tmp_set; -1000*ones(1,size(tmp_set,2))];
            labels = [labels, -1];
        else
            
            time_w = (time_w - time_w(1))/60/60;
            focus_grid = center + WIN_RANGE;
            
            temp_from_sensor = interp1(time_s,tmp_true,focus_grid,'linear');
            temp_from_station = interp1(time_w,temp,focus_grid,'linear');
            
            temp_pair = [temp_from_sensor, temp_from_station];
            
            tmp_set = [tmp_set; temp_pair];
            
            if n > N_false_sample
                labels = [labels, 1];
            else
                labels = [labels, 0];
            end
            count = count + 1
        end
    end
end

%% Filter out invalid data points

mask = sum(tmp_set < -100, 2)>0;
tmp_set = tmp_set(~mask,:);
labels = labels(~mask);
lat_set = lat_set(~mask);
long_set = long_set(~mask);
month_set = month_set(~mask);
day_set = day_set(~mask);

mask = isnan(sum(tmp_set,2));
tmp_set = tmp_set(~mask,:);
labels = labels(~mask);

lat_set = lat_set(~mask);
long_set = long_set(~mask);
month_set = month_set(~mask);
day_set = day_set(~mask);

%save('Temp_train_latest_all', 'tmp_set', 'cloud_set', 'labels');

%% Divide it into train set and validation set

N = length(tmp_set);
pos = randperm(N);

tmp_set_all = tmp_set;
labels_all = labels;
lat_set_all = lat_set;
long_set_all = long_set;
month_set_all = month_set;
day_set_all = day_set;

tmp_set = tmp_set_all(pos(1:3500),:);
labels = labels_all(pos(1:3500));
lat_set = lat_set_all(pos(1:3500));
long_set = long_set_all(pos(1:3500));
month_set = month_set_all(pos(1:3500));
day_set = day_set_all(pos(1:3500));

save('../data/Temp_valid_60m', 'tmp_set', 'labels');

tmp_set = tmp_set_all(pos(3501:end),:);
labels = labels_all(pos(3501:end));
lat_set = lat_set_all(pos(3501:end));
long_set = long_set_all(pos(3501:end));
month_set = month_set_all(pos(3501:end));
day_set = day_set_all(pos(3501:end));

save('../data/Temp_train_60m', 'tmp_set', 'labels');

save('../data/data_combined', 'tmp_set', 'lat_set', 'long_set', 'month_set', 'day_set', 'labels')
