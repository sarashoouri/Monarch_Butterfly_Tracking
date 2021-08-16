load('dataset/raw_data_2019.mat') % load any data from the dataset
%%
N = size(Table, 1);
Table_new = Table;

%filename = 'testAnimated1.gif';
%h = figure;
list = [139, 179, 269, 276, 283, 289, 319, 330, 386, 399, 406, 428, 586, 593, ...
    633, 665, 719, 783, 794, 808, 828, 862, 919, 958, 972, 988, 1004, 1057, 1069, ...
    1079, 1189, 1300, 1311, 1330, 1364, 1528, 1620, 1627, 1669, 1677, 1695, 1709, 1909, ...
    2039, 2050, 2066, 2118];
for i = 1:N
    
    if ismember(i, list)
        continue
    end
    L = length(light);
    light = Table.light(i,:);
    
    light_long = [light(end-L/4+1:end), light, light(1:L/4)];
   
    time_stamp = 30*(0:(length(light_long)-1));
    input = [time_stamp',light_long'];
    output = resample_day(input);
    
    block1_mask = output(:,1)>60*60*60;
    block4_mask = output(:,1)<=60*60*60;
    
    time_stamp_block1 = output(block1_mask==1,1)-60*60*60;
    light_block1 = output(block1_mask==1,2);
    
    time_stamp_block4 = output(block4_mask==1,1)-12*60*60;
    light_block4 = output(block4_mask==1,2);
    
    light_t = [light(end-L/2+1:end), light(1:L/2)];
    light_long = [light_t(end-L/4+1:end), light_t, light_t(1:L/4)];
   
    time_stamp = 30*(0:(length(light_long)-1));
    input = [time_stamp',light_long'];
    output = resample_day(input);
    
    block2_mask = output(:,1)<=60*60*60;
    block3_mask = output(:,1)>60*60*60;
    
    time_stamp_block2 = output(block2_mask==1,1)-36*60*60;
    light_block2 = output(block2_mask==1,2);
    
    time_stamp_block3 = output(block3_mask==1,1)-36*60*60;
    light_block3 = output(block3_mask==1,2);
    
    time_stamp_new = [time_stamp_block1;time_stamp_block2;time_stamp_block3;time_stamp_block4];
    light_new = [light_block1;light_block2;light_block3;light_block4];
    
    time_stamp = 30*(0:(length(light)-1));
    %plot(time_stamp, light); hold on
    %plot(time_stamp_new, light_new,'linewidth', 1.5);
    
    light(light<2) = 0;
    light = log10(light+1);
    Table.light(i,:) = light;
    
    %hold off
    new = interp1(time_stamp_new, light_new, time_stamp);
    new(new<2) = 0;
    new(isnan(new)) = 0;
    new = log10(new+1);
    Table_new.light(i,:) = new;
    
    %plot(time_stamp, log10(light+1));hold on
    %(time_stamp, log10(new+1), 'linewidth', 1.5);hold off
    
%     frame = getframe(h); 
%     im = frame2im(frame); 
%     [imind,cm] = rgb2ind(im,256); 
%     % Write to the GIF File 
%     if i == 1 
%         imwrite(imind,cm,filename,'gif', 'DelayTime',1, 'Loopcount',inf); 
%     else 
%         imwrite(imind,cm,filename,'gif','DelayTime',1,'WriteMode','append'); 
%     end 
      
    %pause(0.5);
    
    %new = interp1(time_stamp_new, light_new, time_stamp);
    %new(new<2) = 0;
    %figure;
   % new(isnan(new)) = 0;
    %plot(time_stamp, log10(new+1))
    i
end
%%

NN = length(index);
index = 1:N;
index(list)=0;
index = index(index~=0);
index_rand = index(randperm(NN));

index_train = index_rand(1:1736);
index_test = index_rand(1737:end);

Table_temp = Table;

%%
Table = Table_temp(index_train,:);
save('dataset/raw_data_2019_train.mat', 'Table');
Table = Table_temp(index_test,:);
save('dataset/raw_data_2019_test.mat', 'Table');

%%
Table = Table_new(index_train,:);
save('dataset/raw_data_2019_resampled_train.mat', 'Table');
Table = Table_new(index_test,:);
save('dataset/raw_data_2019_resampled_test.mat', 'Table');


