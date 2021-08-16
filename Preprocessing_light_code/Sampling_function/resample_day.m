%% resample_day
% v2.0: Sampling last threshold in sunset

% resample_day takes in a 2-column array data = [epoch time, light]
% and returns the resampled array
% The only constraint is that the start time should be in the middle of the
% day, before sunrise and after sunset
% the resampled array includes the first sunset and sunrise when the
% light value crosses the threshold (2 lux)
% the max time range of the resampled array is (sunset + sunrise) / 2 +- 43200 
function light_map = resample_day(data)
light_map = [];

EDGE_THRESHOLD = 2;
THRESHOLD_IDX_SHIFT = 8;
resample_indices = [4, 12, 16, 1000];
interval_indices = [1, 2, 8, 32];

% Find sunset
found_time = 0;
min_time = 0;
min_light = 10000000000;
day_state_start_time = data(1, 1);
day_state_end_time = data(end, 1);

% init running avg
avg_light = 0;
last_avg_light = 0;
running_avg = [0, 0, 0, 0, 0, 0, 0, 0];
s = 0;
running_avg_idx = 0;
init_d = interp1(data(:,1), data(:,2), day_state_start_time);
for i=1:8
    running_avg(i) = init_d;
end
s = init_d * 8;
avg_light = init_d;
last_avg_light = init_d;

for t=day_state_start_time:60:day_state_end_time
    d = interp1(data(:,1), data(:,2), t);
    s = s - running_avg(running_avg_idx + 1);
    s = s + d;
    running_avg(running_avg_idx + 1) = d;
    running_avg_idx = mod(running_avg_idx + 1, 8);

    last_avg_light = avg_light;
    avg_light = s / 8;

    if(last_avg_light > EDGE_THRESHOLD && avg_light <= EDGE_THRESHOLD)
        found_time = t;
        % Attempting to sampling the last threshold of the sunset
        %break;
    end
    if(avg_light < min_light) 
        min_light = avg_light;
        min_time = t;
    end
end

if(found_time == 0) 
    start_time = min_time;
else
    start_time = found_time + THRESHOLD_IDX_SHIFT * 60;
end

sunset = start_time;

% find sunrise
found_time = 0;
min_time = 0;
min_light = 10000000000;
day_state_start_time = sunset + 3 * 3600;
day_state_end_time = data(end, 1);

% init running avg
avg_light = 0;
last_avg_light = 0;
running_avg = [0, 0, 0, 0, 0, 0, 0, 0];
s = 0;
running_avg_idx = 0;
init_d = interp1(data(:,1), data(:,2), day_state_start_time);
for i=1:8
    running_avg(i) = init_d;
end
s = init_d * 8;
avg_light = init_d;
last_avg_light = init_d;

for t=day_state_start_time:60:day_state_end_time
    d = interp1(data(:,1), data(:,2), t);
    s = s - running_avg(running_avg_idx + 1);
    s = s + d;
    running_avg(running_avg_idx + 1) = d;
    running_avg_idx = mod(running_avg_idx + 1, 8);

    last_avg_light = avg_light;
    avg_light = s / 8;

    if(last_avg_light < EDGE_THRESHOLD && avg_light >= EDGE_THRESHOLD)
        found_time = t;
        break;
    end
    if(avg_light < min_light) 
        min_light = avg_light;
        min_time = t;
    end
end

if(found_time == 0) 
    start_time = min_time;
else
    start_time = found_time - THRESHOLD_IDX_SHIFT * 60;
end

sunrise = start_time;

day_state_start_time = (sunset + sunrise) / 2 - 43200;
if(day_state_start_time < data(1, 1))
    day_state_start_time = data(1, 1);
end

day_state_end_time = (sunset + sunrise) / 2 + 43200;
if(day_state_end_time > data(end, 1))
   day_state_end_time = data(end, 1); 
end

% resample sunrise
idx = 0;
next_sample_idx = 0;
interval_idx = 0;
resample_idx = 0;
for t=sunrise:60:day_state_end_time
    if(idx == next_sample_idx) 
        d = interp1(data(:,1), data(:,2), t);
        light_map(end+1, :) = [t, d];
        resample_idx = resample_idx + 1;
        if(resample_idx == resample_indices(interval_idx + 1))
            interval_idx = interval_idx + 1;
        end
        next_sample_idx = next_sample_idx + interval_indices(interval_idx + 1);
    end
    idx = idx + 1;
end

% resample sunset
idx = 0;
next_sample_idx = 0;
interval_idx = 0;
resample_idx = 0;
for t=sunset:-60:day_state_start_time
    if(idx == next_sample_idx) 
        d = interp1(data(:,1), data(:,2), t);
        light_map(end+1, :) = [t, d];
        resample_idx = resample_idx + 1;
        if(resample_idx == resample_indices(interval_idx + 1))
            interval_idx = interval_idx + 1;
        end
        next_sample_idx = next_sample_idx + interval_indices(interval_idx + 1);
    end
    idx = idx + 1;
end


[light_map(:,1), k] = sort(light_map(:,1), 'ascend');
light_map(:,2) = light_map(k,2);


return

end
