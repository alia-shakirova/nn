% Train global NN model for TSR prediction
tic
data_path = '/lustre03/project/6003571/aliia/global_nn/era5_data/';
vars = {'tsr';'tisr';'tciw';'tclw';'tcwv';'hcc';'mcc';'lcc';'sp';'tco3';'fal'};
time = ncread([data_path,'TSR_era5.nc'],'time');
lon = ncread([data_path,'TSR_era5.nc'],'longitude');
lat = ncread([data_path,'TSR_era5.nc'],'latitude');
maxlat = 31;
lat = lat(1:maxlat);
y1 = 1; y2 = 336; %217
time1 = time(y1:y2);
tsr = ncread([data_path,'TSR_era5.nc'],'tsr');
tsr = tsr(:,1:maxlat,y1:y2);
tsr = tsr/24/3600;
numlon = size(lon,1);
numlat = size(lat,1);
numt = size(time1,1);
numy = numt;
nvar = size(vars,1);
%% TSR training
num = numlon*numlat*numy;
nums = floor(num*0.6);  %number of training data // 60% data for training
min_x = zeros(nvar,1);
max_x = zeros(nvar,1);
ind = randperm(num)';
Alldata = zeros(nums,nvar);
for k = 1:nvar
    X = ncread([data_path,upper(vars{k}),'_era5.nc'],vars{k});
    X = X(:,1:maxlat,y1:y2);
    x_train = X(:);
    x_train = x_train(ind);
    if k == 1
        x_train = x_train(1:nums)/24/3600;
    else
        x_train = x_train(1:nums);
    end
    min_x(k) = min(x_train);
    max_x(k) = max(x_train);
    if k ~= 1
        x_train = 2 * (x_train(1:nums) - min_x(k)) / (max_x(k) - min_x(k)) - 1;
    end
    Alldata(:,k) = x_train;
end
Alldata = single(Alldata);
SamIn = Alldata(:,2:end);
SamOut = Alldata(:,1);
net = newff(double(SamIn'),double(SamOut'),15); %construct a new NN model with 15 hidden nodes
toc
tic
% set NN model parameters
net.trainFcn = 'trainlm';  
[net,tr] = train(net,double(SamIn'),double(SamOut'));
%save NN model
save('Net_tsr_arctic.mat','net');
save 'Net_tsr_arctic.mat' max_x min_x -append
toc
