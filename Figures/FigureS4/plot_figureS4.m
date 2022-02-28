filename = '../Figure3/Figure3.nc';
alb = ncread(filename,'alb');
ssr_a = ncread(filename,'ssr_a');
ssr_ref = ncread(filename,'ssr_ref');
dR_ker_sfc = ncread(filename,'dR_ker_sfc');
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
    ssr_a_mean(i) = (wy'*ssr_a(:,:,i)*area')./(wy'*ones(360,maxlat)*area');
end
ssr_ref_mean = (wy'*ssr_ref*area')./(wy'*ones(360,maxlat)*area');
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
    dssr_ker_mean(i) = (wy'*dR_ker_sfc(:,:,i)*area')./(wy'*ones(144,9)*area');
end


%% Plotting dR
figure(1)
set(gcf, 'Position',  [100, 100, 400, 700])
x = 0.0:0.1:1.0;
coef = 1;
grid minor
hold on
p1=plot(x,(ssr_a_mean-ssr_ref_mean)*coef,'bo-','LineWidth',3);
p2=plot(x,dssr_ker_mean,'ko-','LineWidth',3);
plot(x,zeros(11,1),'k--','LineWidth',1)
xline(alb_clim_mean,'k--',{'a_{clim}'},'LineWidth',1,'Fontsize',18)
set(gca,'FontSize',18,'FontWeight','bold')
hold off
xlabel('a')
ylabel('SFC \DeltaR (Wm^{-2})')
set(gca,'FontSize',16)
title('\DeltaR = R(a,x_{2016}) - R(a_{2016},x_{2016})')
legend([p1,p2],{'RRTM','Kernel'},'Location','SW')

figure_name = '.\FigureS4.png';
saveas(gcf,figure_name, 'png')
close(figure(1))