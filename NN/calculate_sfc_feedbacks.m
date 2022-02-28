% This script calculates shortwave radiative feedbacks at the surface 
% in the Arctic between two climate states. State 1 - September 1992, 
% State 2 - September 2012. Feedback is defined as dR = R2 - R1.
% 
% To get the NN model that predicts the surface net solar radiation
% (SSR) use the function nn_sfc.m:
% >> ssr = nn_sfc(tisr,fal,tciw,tclw,tcwv,hcc,mcc,lcc,sp,tco3)

clc; clear

data_path = '../era5_grid1_data/';
varnames = {'tisr';'fal';'tciw';'tclw';'tcwv';'hcc';'mcc';'lcc';'sp';'tco3'}; %  input variables
nvar = size(varnames,1);
time = ncread([data_path,'TISR_era5.nc'],'time');
lon = double(ncread([data_path,'TISR_era5.nc'],'longitude'));
lat = double(ncread([data_path,'TISR_era5.nc'],'latitude'));
maxlat = 21; % 70 N
lat = lat(1:maxlat);
y1 = 1; % Sept 1992
y2 = 2; % Sept 2012
time_str = datetime(time/24 + datenum('1900-01-01 00:00:00'),'ConvertFrom','datenum');
vars = cell(nvar);

% R1 = R(a1,c1,w1)
for k = 1:nvar
        x = zeros(360,maxlat);
        X = ncread([data_path,upper(varnames{k}),'_era5.nc'],varnames{k});
        X = X(:,1:maxlat,y1);        
        vars{k} = X;
end
[tisr,fal,tciw,tclw,tcwv,hcc,mcc,lcc,sp,tco3] = vars{:};
ssr1 = nn_sfc(tisr/24/3600,fal,tciw,tclw,tcwv,hcc,mcc,lcc,sp,tco3);

% R2 = R(a2,c2,w2)
for k = 1:nvar
        x = zeros(360,maxlat);
        X = ncread([data_path,upper(varnames{k}),'_era5.nc'],varnames{k});
        X = X(:,1:maxlat,y2);        
        vars{k} = X;
end
[tisr,fal,tciw,tclw,tcwv,hcc,mcc,lcc,sp,tco3] = vars{:};
ssr2 = nn_sfc(tisr/24/3600,fal,tciw,tclw,tcwv,hcc,mcc,lcc,sp,tco3);
 
% R(a2,c1,w1)
for k = 1:nvar
        x = zeros(360,maxlat);
        X = ncread([data_path,upper(varnames{k}),'_era5.nc'],varnames{k});
        if strcmp(varnames{k},'fal')
            X = X(:,1:maxlat,y2); 
        else
            X = X(:,1:maxlat,y1);
        end
        vars{k} = X;
end
[tisr,fal,tciw,tclw,tcwv,hcc,mcc,lcc,sp,tco3] = vars{:};
ssr_a = nn_sfc(tisr/24/3600,fal,tciw,tclw,tcwv,hcc,mcc,lcc,sp,tco3);
Ra = ssr_a - ssr1; % albedo feedback

% R(a1,c1,w2)
for k = 1:nvar
        x = zeros(360,maxlat);
        X = ncread([data_path,upper(varnames{k}),'_era5.nc'],varnames{k});
        if strcmp(varnames{k},'tcwv')
            X = X(:,1:maxlat,y2); 
        else
            X = X(:,1:maxlat,y1);
        end
        vars{k} = X;
end
[tisr,fal,tciw,tclw,tcwv,hcc,mcc,lcc,sp,tco3] = vars{:};
ssr_wv = nn_sfc(tisr/24/3600,fal,tciw,tclw,tcwv,hcc,mcc,lcc,sp,tco3);
Rwv = ssr_wv - ssr1; % water vapor feedback

% R(a1,c2,w1)
for k = 1:nvar
        x = zeros(360,maxlat);
        X = ncread([data_path,upper(varnames{k}),'_era5.nc'],varnames{k});
        if strcmp(varnames{k},'tclw') || strcmp(varnames{k},'tciw')|| strcmp(varnames{k},'hcc')...
                || strcmp(varnames{k},'mcc') || strcmp(varnames{k},'lcc')
            X = X(:,1:maxlat,y2); 
        else
            X = X(:,1:maxlat,y1);
        end
        vars{k} = X;
end
[tisr,fal,tciw,tclw,tcwv,hcc,mcc,lcc,sp,tco3] = vars{:};
ssr_c = nn_sfc(tisr/24/3600,fal,tciw,tclw,tcwv,hcc,mcc,lcc,sp,tco3);
Rc = ssr_c - ssr1; % cloud feedback

% Save to a file 
dim = [length(1:360),length(1:maxlat)];
outfile = 'nn_sfc_feedbacks_091992_092012.nc';
ncid = netcdf.create(outfile,'CLOBBER');

%-----------------------------DEFINE DIMENSION----------------------------
dimidx = netcdf.defDim(ncid,'lon',dim(1));
dimidy = netcdf.defDim(ncid,'lat',dim(2));

%----------------------------DEFINE NEW VARIABLES-------------------------
var_lon = netcdf.defVar(ncid,'longitude','NC_FLOAT',dimidx);
var_lat = netcdf.defVar(ncid,'latitude','NC_FLOAT',dimidy);
varid1 = netcdf.defVar(ncid,'Ra','NC_FLOAT',[dimidx dimidy]);
varid2 = netcdf.defVar(ncid,'Rc','NC_FLOAT',[dimidx dimidy]);
varid3 = netcdf.defVar(ncid,'Rwv','NC_FLOAT',[dimidx dimidy]);
varid4 = netcdf.defVar(ncid,'ssr1','NC_FLOAT',[dimidx dimidy]);
varid5 = netcdf.defVar(ncid,'ssr2','NC_FLOAT',[dimidx dimidy]);
varid6 = netcdf.defVar(ncid,'dR','NC_FLOAT',[dimidx dimidy]);

%---------------------------GIVE VALUES TO VARIABLES-----------------------
netcdf.endDef(ncid)
netcdf.putVar(ncid,var_lon,lon);
netcdf.putVar(ncid,var_lat,lat);
netcdf.putVar(ncid,varid1,Ra);
netcdf.putVar(ncid,varid2,Rc);
netcdf.putVar(ncid,varid3,Rwv);
netcdf.putVar(ncid,varid4,ssr1);
netcdf.putVar(ncid,varid5,ssr2);
netcdf.putVar(ncid,varid6,ssr2-ssr1);
netcdf.close(ncid);