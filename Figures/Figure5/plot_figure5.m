tcc = ncread('TCC_era5.nc','tcc',[1 1 1],[Inf 21 1]); % June 2016
dtsr_a_nn = ncread('Figure5.nc','dtsr_a_nn');
dtsr_a = ncread('Figure5.nc','dtsr_a');
dtsr_a_ker = ncread('Figure5.nc','dtsr_a_ker');

eps = 0.005;

clear Ra_nn Ra_rtm Ra_ker
for aind = 1:17
    for i = 12:19
        [ix,iy]=find(abs(tcc-0.05*i)<eps); % from tcc = 0.6 to 0.95
        Ra_nn(i-11,aind) = mean(dtsr_a_nn(ix,iy,aind),[1 2]);
        Ra_rtm(i-11,aind) = mean(dtsr_a(ix,iy,aind),[1 2]);
        Ra_ker(i-11,aind) = mean(dtsr_a_ker(ix,iy,aind),[1 2]);
    end
end
[X,Y] = meshgrid(0.6:0.05:0.95,-0.8:0.1:0.8);

figure(1)
set(gcf, 'Position',  [100, 100, 700, 1200])
subplot(3,1,1)
p2 = surf(X',Y',Ra_rtm);
view(0,90)
xlim([0.6 0.95])
ylim([-0.8 0.8])
yticks([-0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8])
colorbar
colormap(othercolor('BuDRd_18'))
xlabel('tcc')
ylabel('\Deltaa')
title('(a) \DeltaR_a^{RTM}')
caxis([-250 250])

subplot(3,1,2)
p2 = surf(X',Y',Ra_nn-Ra_rtm);
xlim([0.6 0.95])
ylim([-0.8 0.8])
yticks([-0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8])
view(0,90)
colorbar 
xlabel('tcc')
ylabel('\Deltaa')
title('(b) \DeltaR_a^{NN}-\DeltaR_a^{RTM}')
caxis([-40 40])

subplot(3,1,3)
p3 = surf(X',Y',Ra_ker-Ra_rtm);
xlim([0.6 0.95])
ylim([-0.8 0.8])
yticks([-0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8])
view(0,90)
colorbar
xlabel('tcc')
ylabel('\Deltaa')
caxis([-40 40])
title('(c) \DeltaR_a^{Ker}-\DeltaR_a^{RTM}')
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14);
figure_name = '.\Figure5.png';
saveas(gcf,figure_name, 'png')
close(figure(1))
