% Plot Figure 5
filename = '../Figure4/Figure4.nc';
tsr_a = ncread(filename,'tsr_a');
tsr_a_nn = ncread(filename,'tsr_a_nn');
tsr_sl = ncread(filename,'tsr_sl');
tsr_ref_nn = ncread(filename,'tsr_ref_nn');
tsr_ref = ncread(filename,'tsr_ref');
tsr_ref_sl = ncread(filename,'tsr_ref_sl');
dR_ker_toa = ncread(filename,'dR_ker_toa');

lon = ncread(filename,'longitude');
lat = ncread(filename,'latitude');
alb = ncread(filename,'alb');
eps = 0.001;
[ixmin,iymin]=find(alb==min(alb,[],'all'));
ixmin=ixmin(24);iymin=iymin(24); %24!%6
min_alb = alb(ixmin,iymin);
[ixmax,iymax]=find(alb==max(alb,[],'all'));
ixmax=ixmax(1);iymax=iymax(1);
max_alb = alb(ixmax,iymax);
[ix,iy]=find(abs(alb-0.54)<eps);
ix=ix(2);iy=iy(2);
alb_05 = alb(ix,iy);
%%
%Plotting dR
f = figure(1);
% f.WindowState = 'maximized';
set(gcf,'WindowState','maximized')
%%% Grid box with a = 0.06
lat_coor = iymin; lon_coor = ixmin;  % min alb = 0.0569
a = 0.0:0.1:1.0;
set(gcf, 'Position',  [0, 0, 1200, 1000])
subplot(1,3,1)
grid minor
hold on
p1=plot(a,squeeze(tsr_a(lon_coor,lat_coor,:)-tsr_ref(lon_coor,lat_coor)),'bo-','LineWidth',2);
p2=plot(a,squeeze(tsr_a_nn(lon_coor,lat_coor,:)-tsr_ref_nn(lon_coor,lat_coor)),'ro-','LineWidth',2);
p3=plot(a,squeeze(tsr_sl(lon_coor,lat_coor,:)-tsr_ref_sl(lon_coor,lat_coor)),'go-','LineWidth',2);
% p4=plot(a,squeeze(-100*dR_ker_toa(lon_coor_k,lat_coor_k,:)),'ko-','LineWidth',2);
p4=plot(a,squeeze(dR_ker_toa(lon_coor,lat_coor,:)),'ko-','LineWidth',2);
p5 = plot(alb(lon_coor,lat_coor),0,'bo','MarkerSize',10);
set(p5, 'markerfacecolor', get(p5, 'color'));
plot(a,zeros(11,1),'k--');
xl=xline(alb(lon_coor,lat_coor),'k--',{strcat('a=',num2str(round(alb(lon_coor,lat_coor),2)))},'Fontsize',14);
xl.LabelVerticalAlignment = 'bottom';
hold off
xlabel('a')
ylabel('TOA \DeltaR (Wm^{-2})')
set(gca,'FontSize',14)
title('a) TOA \DeltaR = R(a,x_{2016}) - R(a_{2016},x_{2016})')
legend([p1,p2,p3,p4],{'RRTM','NN','Analyt','Kernel'},'Location','NE')

% %%% Grid box with a = 0.54
lat_coor = iy; lon_coor = ix;  % alb = 0.54
subplot(1,3,2)
grid minor
hold on
p1=plot(a,squeeze(tsr_a(lon_coor,lat_coor,:)-tsr_ref(lon_coor,lat_coor)),'bo-','LineWidth',2);
p2=plot(a,squeeze(tsr_a_nn(lon_coor,lat_coor,:)-tsr_ref_nn(lon_coor,lat_coor)),'ro-','LineWidth',2);
p3=plot(a,squeeze(tsr_sl(lon_coor,lat_coor,:)-tsr_ref_sl(lon_coor,lat_coor)),'go-','LineWidth',2);
% p4=plot(a,squeeze(-100*dR_ker_toa(lon_coor_k,lat_coor_k,:)),'ko-','LineWidth',2);
p4=plot(a,squeeze(dR_ker_toa(lon_coor,lat_coor,:)),'ko-','LineWidth',2);
p5 = plot(alb(lon_coor,lat_coor),0,'bo','MarkerSize',10);
set(p5, 'markerfacecolor', get(p5, 'color'));
plot(a,zeros(11,1),'k--');
xl=xline(alb(lon_coor,lat_coor),'k--',{strcat('a=',num2str(round(alb(lon_coor,lat_coor),2)))},'Fontsize',14);
xl.LabelVerticalAlignment = 'bottom';
hold off
xlabel('a')
ylabel('TOA \DeltaR (Wm^{-2})')
set(gca,'FontSize',14)
title('b) TOA \DeltaR = R(a,x_{2016}) - R(a_{2016},x_{2016})')
legend([p1,p2,p3,p4],{'RRTM','NN','Analyt','Kernel'},'Location','NE')

lat_coor = iymax; lon_coor = ixmax;  % alb = 0.85
subplot(1,3,3)
grid minor
hold on
p1=plot(a,squeeze(tsr_a(lon_coor,lat_coor,:)-tsr_ref(lon_coor,lat_coor)),'bo-','LineWidth',2);
p2=plot(a,squeeze(tsr_a_nn(lon_coor,lat_coor,:)-tsr_ref_nn(lon_coor,lat_coor)),'ro-','LineWidth',2);
p3=plot(a,squeeze(tsr_sl(lon_coor,lat_coor,:)-tsr_ref_sl(lon_coor,lat_coor)),'go-','LineWidth',2);
% p4=plot(a,squeeze(-100*dR_ker_toa(lon_coor_k,lat_coor_k,:)),'ko-','LineWidth',2);
p4=plot(a,squeeze(dR_ker_toa(lon_coor,lat_coor,:)),'ko-','LineWidth',2);
p5 = plot(alb(lon_coor,lat_coor),0,'bo','MarkerSize',10);
set(p5, 'markerfacecolor', get(p5, 'color'));
plot(a,zeros(11,1),'k--');
xl=xline(alb(lon_coor,lat_coor),'k--',{strcat('a=',num2str(round(alb(lon_coor,lat_coor),2)))},'Fontsize',14);
xl.LabelVerticalAlignment = 'middle';
hold off
xlabel('a')
ylabel('TOA \DeltaR (Wm^{-2})')
set(gca,'FontSize',14)
title('c) TOA \DeltaR = R(a,x_{2016}) - R(a_{2016},x_{2016})')
legend([p1,p2,p3,p4],{'RRTM','NN','Analyt','Kernel'},'Location','NE')

figure_name = 'FigureS1.png';
saveas(gcf,figure_name, 'png');
close(f)

