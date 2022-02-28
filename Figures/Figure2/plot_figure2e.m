filename = 'Figure2.nc';
tsr_era = ncread(filename,'tsr_era');
tsr = ncread(filename,'tsr');
tsr_corr = corrcoef(tsr_era(:),tsr(:));
tsr_corr = tsr_corr(1,2);

figure(1)
plot(tsr_era(:),tsr(:),'k.','LineWidth',1)
hold on
plot(tsr_era(:),tsr_era(:),'r.','LineWidth',2)
xlim([0 Inf])
ylim([0 Inf])
xlabel('TSR ERA5   (W/m^2)')
ylabel('TSR NN   (W/m^2)')
set(gca,'FontSize',14,'FontWeight','bold')
legend(['R^2 = ',num2str(round(tsr_corr^2,4))],'Location','NW')
title('e) Scatter plot of TSR','Position',[80 400 0])   
figure_name = '.\Figure2e.png';
saveas(gcf,figure_name, 'png')
close(figure(1))