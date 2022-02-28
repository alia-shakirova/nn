filename = 'Figure3.nc';
alb = ncread(filename,'alb');
tsr_a = ncread(filename,'tsr_a');
tsr_ref = ncread(filename,'tsr_ref');
dR_ker_toa = ncread(filename,'dR_ker_toa');
maxlat = 21;
lat = 90:-1:70;
lon = 0:359;
re = 6.37122e06; %earth radius [m]
rad = pi/180; %get radiance
clat = cos(lat*rad) ;        % cosine of latitude
dlon = (lon(2) - lon(1));    % assume dlon is constant
dlat = (lat(2) - lat(1));    % assume dlat is constant
dx = dlon*clat;            % dx at each latitude
dy = dlat*re*rad;          % dy is costant
area = dy*dx ;               % area(nlat)
wy = ones(360,1);
for i = 1:11
    tsr_a_mean(i) = (wy'*tsr_a(:,:,i)*area')./(wy'*ones(360,maxlat)*area');
end
tsr_ref_mean = (wy'*tsr_ref*area')./(wy'*ones(360,maxlat)*area');
alb_clim_mean = (wy'*alb(:,1:maxlat)*area')./(wy'*ones(360,maxlat)*area');

lat = 90:-2.5:70;
lon = 0:2.5:360-2.5;
clat = cos(lat*rad) ;        % cosine of latitude
dlon = (lon(2) - lon(1));    % assume dlon is constant
dlat = (lat(2) - lat(1));    % assume dlat is constant
dx = dlon*clat;            % dx at each latitude
dy = dlat*re*rad;          % dy is costant
area = dy*dx ;               % area(nlat)
wy = ones(144,1);
for i = 1:11
    dtsr_ker_mean(i) = (wy'*dR_ker_toa(:,:,i)*area')./(wy'*ones(144,9)*area');
end


%% Plotting dR
figure(1)
set(gcf, 'Position',  [100, 100, 400, 700])
x = 0.0:0.1:1.0;
coef = 1;
grid minor
hold on
p1=plot(x,(tsr_a_mean-tsr_ref_mean)*coef,'bo-','LineWidth',3);
p2=plot(x,dtsr_ker_mean,'ko-','LineWidth',3);
plot(x,zeros(11,1),'k--','LineWidth',1)
xline(alb_clim_mean,'k--',{'a_{clim}'},'LineWidth',1,'Fontsize',18)
% xlim([0.1,0.9])
set(gca,'FontSize',18,'FontWeight','bold')
hold off
xlabel('a')
ylabel('TOA \DeltaR (Wm^{-2})')
set(gca,'FontSize',16)
title('\DeltaR = R(a,x_{2016}) - R(a_{2016},x_{2016})')
legend([p1,p2],{'RRTM','Kernel'},'Location','SW')

figure_name = '.\Figure3.png';
saveas(gcf,figure_name, 'png')
close(figure(1))