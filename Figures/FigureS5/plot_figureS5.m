filename = '../Figure4/Figure4.nc';
alb_clim_mean = ncread(filename,'alb_clim_mean');
ssr_a = ncread(filename,'ssr_a');
ssr_a_nn = ncread(filename,'ssr_a_nn');
ssr_sl = ncread(filename,'ssr_sl');
ssr_ref_nn = ncread(filename,'ssr_ref_nn');
ssr_ref = ncread(filename,'ssr_ref');
ssr_ref_sl = ncread(filename,'ssr_ref_sl');
rmse_nn_ssr = ncread(filename,'rmse_nn_ssr');
rmse_sl_ssr = ncread(filename,'rmse_sl_ssr');
rmse_ker_ssr = ncread(filename,'rmse_ker_ssr');
mbe_nn_ssr = ncread(filename,'mbe_nn_ssr');
mbe_sl_ssr = ncread(filename,'mbe_sl_ssr');
mbe_ker_ssr = ncread(filename,'mbe_ker_ssr');
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
    ssr_sl_mean(i) = (wy'*ssr_sl(:,:,i)*area')./(wy'*ones(360,maxlat)*area');
    ssr_a_nn_mean(i) = (wy'*squeeze(ssr_a_nn(:,:,i))*area')./(wy'*ones(360,maxlat)*area');
    ssr_a_ker_mean(i) = (wy'*squeeze(dR_ker_sfc(:,:,i))*area')./(wy'*ones(360,maxlat)*area');
end

ssr_ref_nn_mean = (wy'*ssr_ref_nn*area')./(wy'*ones(360,maxlat)*area');
ssr_ref_mean = (wy'*ssr_ref*area')./(wy'*ones(360,maxlat)*area');
ssr_ref_sl_mean = (wy'*ssr_ref_sl*area')./(wy'*ones(360,maxlat)*area');

%% Plotting dR
figure(1)
set(gcf, 'Position',  [100, 100, 1000, 700])
x = 0.0:0.1:1.0;
coef = 1;
subplot(1,2,1)
grid minor
hold on
p1=plot(x,(ssr_a_mean-ssr_ref_mean)*coef,'bo-','LineWidth',2);
p2=plot(x,(ssr_a_nn_mean-ssr_ref_nn_mean)*coef,'ro-','LineWidth',2);
p3=plot(x,(ssr_sl_mean-ssr_ref_sl_mean)*coef,'go-','LineWidth',2);
p4=plot(x,ssr_a_ker_mean,'ko-','LineWidth',2);
plot(x,zeros(11,1),'k--','LineWidth',1)
xline(alb_clim_mean,'k--',{'a_{clim}'},'LineWidth',1,'Fontsize',18)
set(gca,'FontSize',18)

hold off
xlabel('a')
ylabel('SFC \DeltaR (Wm^{-2})')
set(gca,'FontSize',16)
title('a) \DeltaR = R(a,x_{2016}) - R(a_{2016},x_{2016})')
legend([p1,p2,p3,p4],{'RRTM','NN','SL','Kernel'},'Location','SW')

subplot(1,2,2)
grid minor
hold on
p1=plot(x,mbe_nn_ssr,'ro-','LineWidth',2);
p2=plot(x,mbe_sl_ssr,'go-','LineWidth',2);
p3=plot(x,mbe_ker_ssr,'ko-','LineWidth',2);
p4=plot(x,rmse_nn_ssr,'r:','LineWidth',2);
p5=plot(x,rmse_sl_ssr,'g:','LineWidth',2);
p6=plot(x,rmse_ker_ssr,'k:','LineWidth',2);
plot(x,zeros(11,1),'k--','LineWidth',1)
xline(alb_clim_mean,'k--',{'a_{clim}'},'LineWidth',1,'Fontsize',18)
set(gca,'FontSize',18)
hold off
xlabel('a')
ylabel('MBE, RMSE  (Wm^{-2})')
title('b) MBE and RMSE') 
legend([p1,p2,p3],{'NN','SL','Kernel'},'Location','SE')

figure_name = '.\FigureS5.png';
saveas(gcf,figure_name, 'png')
close(figure(1))

