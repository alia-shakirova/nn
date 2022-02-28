function [ ssr ] = nn_sfc(tisr, fal, varargin)
% 
% This function computes SFC net shortwave radiation flux from atmospheric variables.
% ssr = nn_sfc(tisr, fal, tciw, tclw, tcwv, hcc, mcc, lcc, sp, tco3)
%
% ARGIN
%   - Required:
%   tisr: TOA incident solar radiation (W*m**-2), downward positive! 
%   fal: Forecast albedo (0-1)
%   - Optional:
%   tciw: Total column cloud ice water (kg*m**-2), default value = 0.02
%   tclw: Total column cloud liquid water (kg*m**-2), default value = 0.05
%   tcwv: Total column water vapour (kg*m**-2), default value = 18.2
%   hcc: High cloud cover (0-1), default value = 0.33
%   mcc: Medium cloud cover (0-1), default value = 0.30
%   lcc: Low cloud cover (0-1), default value = 0.46
%   sp: Surface pressure (Pa), default value = 9.7e04
%   tco3: Total column ozone (kg*m**-2) , default value = 0.0064
% ARGOUT
%   ssr: SFC net shortwave radiation (W*m**-2), downward positive!
%
% All variables are monthly averaged values.
%
% To get the NN model that predicts the surface net solar radiation
% (SSR) load the file 'nn_ssr.mat':
% >> load(('nn_ssr.mat')
% which contains the NN model and maximum (max_x) and minimum (min_x)
% values of each variable from the training dataset.

%INPUTs check
if nargin < 2
    error('Define TISR and albedo');
elseif nargin > 10
    error('Too many inputs, maximum 10');
end

p = inputParser;
defaultSP = 9.7e04;
defaultTCO3 = 0.0064;
defaultHCC = 0.33;
defaultMCC = 0.30;
defaultLCC = 0.46;
defaultTCIW = 0.02;
defaultTCLW = 0.05;
defaultTCWV = 18.2;

addRequired(p,'tisr',@isnumeric)
addRequired(p,'fal',@isnumeric)
addOptional(p,'tciw',defaultTCIW)
addOptional(p,'tclw',defaultTCLW)
addOptional(p,'tcwv',defaultTCWV)
addOptional(p,'hcc',defaultHCC)
addOptional(p,'mcc',defaultMCC)
addOptional(p,'lcc',defaultLCC)
addOptional(p,'sp',defaultSP)
addOptional(p,'tco3',defaultTCO3)
parse(p,tisr,fal,varargin{:})
tciw = p.Results.tciw;
tclw = p.Results.tclw;
tcwv = p.Results.tcwv;
hcc = p.Results.hcc;
mcc = p.Results.mcc;
lcc = p.Results.lcc;
sp = p.Results.sp;
tco3 = p.Results.tco3;

nn_input.val = [24*3600*tisr(:), tciw(:), tclw(:), tcwv(:), hcc(:), mcc(:), lcc(:), sp(:), tco3(:), fal(:)];
nn_input.name = {'tisr'; 'tciw'; 'tclw'; 'tcwv'; 'hcc'; 'mcc'; 'lcc'; 'sp'; 'tco3'; 'fal'};
nvar = size(nn_input.val,2);
load('nn_ssr.mat')

for k = 1:nvar
        x = nn_input.val(:,k);
        
        % Check the input arguments' values are within the value range
        x(x < min_x(k+1)) = min_x(k+1);
        x(x > max_x(k+1)) = max_x(k+1); 
        
        x = 2 * (x - min_x(k+1))/(max_x(k+1)-min_x(k+1))-1;
        InNN(:,k) = x;
end
OutNN = sim(net,double(InNN'))';
ssr = reshape(OutNN,size(tisr));

end