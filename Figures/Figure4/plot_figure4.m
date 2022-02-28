filename = 'Figure4.nc';
alb_clim_mean = ncread(filename,'alb_clim_mean');
tsr_a = ncread(filename,'tsr_a');
tsr_a_nn = ncread(filename,'tsr_a_nn');
tsr_sl = ncread(filename,'tsr_sl');
tsr_ref_nn = ncread(filename,'tsr_ref_nn');
tsr_ref = ncread(filename,'tsr_ref');
tsr_ref_sl = ncread(filename,'tsr_ref_sl');
rmse_nn_tsr = ncread(filename,'rmse_nn_tsr');
rmse_sl_tsr = ncread(filename,'rmse_sl_tsr');
rmse_ker_tsr = ncread(filename,'rmse_ker_tsr');
mbe_nn_tsr = ncread(filename,'mbe_nn_tsr');
mbe_sl_tsr = ncread(filename,'mbe_sl_tsr');
mbe_ker_tsr = ncread(filename,'mbe_ker_tsr');
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
    tsr_sl_mean(i) = (wy'*tsr_sl(:,:,i)*area')./(wy'*ones(360,maxlat)*area');
    tsr_a_nn_mean(i) = (wy'*squeeze(tsr_a_nn(:,:,i))*area')./(wy'*ones(360,maxlat)*area');
    tsr_a_ker_mean(i) = (wy'*squeeze(dR_ker_toa(:,:,i))*area')./(wy'*ones(360,maxlat)*area');
end

tsr_ref_nn_mean = (wy'*tsr_ref_nn*area')./(wy'*ones(360,maxlat)*area');
tsr_ref_mean = (wy'*tsr_ref*area')./(wy'*ones(360,maxlat)*area');
tsr_ref_sl_mean = (wy'*tsr_ref_sl*area')./(wy'*ones(360,maxlat)*area');

%% Plotting dR
figure(1)
set(gcf, 'Position',  [100, 100, 1000, 700])
x = 0.0:0.1:1.0;
coef = 1;
subplot(1,2,1)
grid minor
hold on
p1=plot(x,(tsr_a_mean-tsr_ref_mean)*coef,'bo-','LineWidth',2);
p2=plot(x,(tsr_a_nn_mean-tsr_ref_nn_mean)*coef,'ro-','LineWidth',2);
p3=plot(x,(tsr_sl_mean-tsr_ref_sl_mean)*coef,'go-','LineWidth',2);
p4=plot(x,tsr_a_ker_mean,'ko-','LineWidth',2);
plot(x,zeros(11,1),'k--','LineWidth',1)
xline(alb_clim_mean,'k--',{'a_{clim}'},'LineWidth',1,'Fontsize',18)
set(gca,'FontSize',18)

hold off
xlabel('a')
ylabel('TOA \DeltaR (Wm^{-2})')
set(gca,'FontSize',16)
title('a) \DeltaR = R(a,x_{2016}) - R(a_{2016},x_{2016})')
legend([p1,p2,p3,p4],{'RRTM','NN','SL','Kernel'},'Location','SW')

subplot(1,2,2)
grid minor
hold on
p1=plot(x,mbe_nn_tsr,'ro-','LineWidth',2);
p2=plot(x,mbe_sl_tsr,'go-','LineWidth',2);
p3=plot(x,mbe_ker_tsr,'ko-','LineWidth',2);
p4=plot(x,rmse_nn_tsr,'r:','LineWidth',2);
p5=plot(x,rmse_sl_tsr,'g:','LineWidth',2);
p6=plot(x,rmse_ker_tsr,'k:','LineWidth',2);
plot(x,zeros(11,1),'k--','LineWidth',1)
xline(alb_clim_mean,'k--',{'a_{clim}'},'LineWidth',1,'Fontsize',18)
set(gca,'FontSize',18)
hold off
xlabel('a')
ylabel('MBE, RMSE  (Wm^{-2})')
title('b) MBE and RMSE') 
legend([p1,p2,p3],{'NN','SL','Kernel'},'Location','SE')

figure_name = '.\Figure4.png';
saveas(gcf,figure_name, 'png')
close(figure(1))

