name = 'outdoor_M3_fine2_Month_11_Day_7';
name1 = 'outdoor_M3_Month_11_Day_7';
load(['./Testdata/',name1,'.mat']);
load(['./Testdata/L/',name,'_temp.mat']);
load(['./Testdata/L/',name,'_temp_ws.mat']);
%load(['./my_result/result_',name,'.mat']);
%load(['./my_result/result_',name,'_temp.mat']);
load(['./my_result/M3/result_',name1,'.mat']);
load(['./my_result/M3/result_',name,'_temp.mat']);
% Approximate ground truth
long_tar = [-83.74]; 
lat_tar = [42.28];

index = 1;

lat_fine1 = interp(lat_grid, 5);
long_fine1 = interp(long_grid, 5);

lat_fine1 = lat_fine1(1:end-1);
long_fine1 = long_fine1(1:end-1);

[long_cor_grid1, lat_cor_grid1] = meshgrid(long_grid, lat_grid);
[long_fine_grid1, lat_fine_grid1] = meshgrid(long_fine1, lat_fine1);

light_coarse1 = results';
light_intp1 = interp2(long_cor_grid1,lat_cor_grid1,light_coarse1,long_fine_grid1,lat_fine_grid1, 'cubic', 0);
light_intp1(light_intp1<0) = 0;

temp_coarse1 = results_temp';
temp_coarse1(temp_mask_ws==1) = NaN;
temp_coarse1= fillmissing(temp_coarse1,'linear');

temp_intp1 = interp2(long_cor_grid1,lat_cor_grid1,temp_coarse1,long_fine_grid1,lat_fine_grid1, 'cubic', 0);
temp_intp1(temp_intp1<0) = 0;


% Localization using the heatmap

[long_est1,lat_est1] = localization(light_coarse1, long_grid, lat_grid)

fprintf('Coarse Estimated longitude: %f \n', long_est1);
fprintf('Coarse Estimated latitude: %f \n', lat_est1);

[long_est1,lat_est1] = localization(light_intp1.*temp_intp1, long_fine1, lat_fine1);

fprintf('Fine Estimated longitude: %f \n', long_est1);
fprintf('Fine Estimated latitude: %f \n', lat_est1);
%%






f=figure

    
    subplot(2,3,1)

    title('Fine grid')
    ax =surface(long_fine,lat_fine,light_intp, 'edgecolor', 'None')

    xlabel('longitude','FontWeight','bold')
    ylabel('latitude','FontWeight','bold')
    hold on
    ZMax=max(light_intp(:));
    hold on
    %plot3(long_est, lat_est, ZMax,'mx','MarkerSize',20,'LineWidth',5)
    title({'Light intensity', 'Discriminator'})
    xlim([long_fine(1), long_fine(end)]);
    ylim([lat_fine(1), lat_fine(end)]);
    ylim([35,50])
    xlim([-90, -78])
    
    


    set(gcf,'color','w');
set(gca,'FontSize',35,'LineWidth',4)
H=gca;
H.LineWidth=4;
 colormap(jet)
    subplot(2,3,2)
    ax=surface(long_fine,lat_fine,temp_intp, 'edgecolor', 'None')
    colormap(jet)
    xlabel('longitude','FontWeight','bold')
    ylabel('latitude','FontWeight','bold')
    hold on
    %plot3(long_est, lat_est, ZMax,'mx','MarkerSize',20,'MarkerFaceColor',[.49 1 .63],'LineWidth',5)
    hold on
    ZMax=max(light_intp(:));
     hold on
    title({'Temperature', 'Discriminator'})
    xlim([long_fine(1), long_fine(end)]);
    ylim([lat_fine(1), lat_fine(end)]);
    ylim([35,50])
    xlim([-90, -78])
  
%     

    set(gcf,'color','w');
set(gca,'FontSize',35)
H=gca;
H.LineWidth=4;
 % get the new colormap we just created

subplot(2,3,3)
    title({'Sensor Fusion', 'Output'})
    surface(long_fine,lat_fine,temp_intp.*light_intp, 'edgecolor', 'None')
   
    colormap(jet)
    xlabel('longitude','FontWeight','bold')
    ylabel('latitude','FontWeight','bold')
    hold on
    %scatter3(long_tar, lat_tar, ones(size(long_tar)), 40, 'k', 'filled')
    ZMax=max(light_intp(:));
    plot3(long_est, lat_est, ZMax,'mx','MarkerSize',20,'LineWidth',5)
    %plot3(long_est, lat_est, ZMax,'rx','MarkerSize',10)
     
    %title('Combined Heatmap Fine','FontSize',15)
    xlim([long_fine(1), long_fine(end)]);
    ylim([lat_fine(1), lat_fine(end)]);
    ylim([35,50])
    xlim([-90, -78])
 
    




    set(gcf,'color','w');
set(gca,'FontSize',35)
 colormap(jet)
H=gca;
H.LineWidth=4;

subplot(2,3,4)


    ax =surface(long_fine1,lat_fine1,light_intp1, 'edgecolor', 'None')

    xlabel('longitude','FontWeight','bold')
    ylabel('latitude','FontWeight','bold')
    hold on
    ZMax=max(light_intp1(:));
    
%plot3(long_est1, lat_est1, ZMax,'mx','MarkerSize',20,'LineWidth',5)
    %title('Light intensity Discriminator')
    xlim([long_fine1(1), long_fine1(end)]);
    ylim([lat_fine1(1), lat_fine1(end)]);
    ylim([35,50])
    xlim([-90, -78])
    
    
    
    set(gcf,'color','w');
set(gca,'FontSize',35,'LineWidth',4)
H=gca;
H.LineWidth=2;
 colormap(jet)
  subplot(2,3,5)
    ax=surface(long_fine1,lat_fine1,temp_intp1, 'edgecolor', 'None')
    colormap(jet)
    xlabel('longitude','FontWeight','bold')
    ylabel('latitude','FontWeight','bold')
    hold on
    %plot3(long_est1, lat_est1, ZMax,'mx','MarkerSize',20,'LineWidth',5)
    
    hold on
    ZMax=max(light_intp1(:));
     hold on
   % title('Temperature Discriminator')
    xlim([long_fine1(1), long_fine1(end)]);
    ylim([lat_fine1(1), lat_fine1(end)]);
    ylim([35,50])
    xlim([-90, -78])
    
        set(gcf,'color','w');
set(gca,'FontSize',35)
 colormap(jet)
H=gca;
H.LineWidth=2;
    subplot(2,3,6)
   % title('Sensor Fusion Output')
    surface(long_fine1,lat_fine1,temp_intp1.*light_intp1, 'edgecolor', 'None')
   
    colormap(jet)
    xlabel('longitude','FontWeight','bold')
    ylabel('latitude','FontWeight','bold')
    hold on
    %scatter3(long_tar, lat_tar, ones(size(long_tar)), 40, 'k', 'filled')
    ZMax=max(light_intp1(:));
    hold on
    plot3(long_est1, lat_est1, ZMax,'mx','MarkerSize',20,'LineWidth',5)
    %plot3(long_est, lat_est, ZMax,'rx','MarkerSize',10)
     
    %title('Combined Heatmap Fine','FontSize',15)
    xlim([long_fine1(1), long_fine1(end)]);
    ylim([lat_fine1(1), lat_fine1(end)]);
    ylim([35,50])
    xlim([-90, -78])
    iax=1
    %subaxis(2, 3, 6, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0, 'SpacingVert', 0.03);
  %t= title('(b)');
%set(t,'Position',[0 300],'VerticalAlignment','bottom')

    set(gcf,'color','w');
set(gca,'FontSize',35)
 colormap(jet)
H=gca;
H.LineWidth=4;


  
