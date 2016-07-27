% param_eddy_tracking_AVISO.m
%
%   param_eddy_tracking sets user defined paths and parameters for a
%   degradation coefficient of 'deg' which goes from 1 (default)
%   to >10 in some experiment.
%
% Paths:
%   - path_in: directory containing the input files;
%              (default is '..\Data\')
%   - path_out: directory for the output files;
%              (default is '..\Tracks\')
%   - nc_u: full name of the netcdf file with the zonal component of
%           velocity (ssu) and the time index (day)
%   - nc_v: full name of the netcdf file with the meridional component of
%           velocity (ssv) and the time index (day)
%   - nc_dim: full name of the netcdf file with the domain coordinates 
%            (longitude and latitude) and the velocity mask (land-points=0;
%             ocean-points=1)
%
% User option keys:
%   - type_detection: flag to choose the field use as streamlines
%           1 : using velocity fields
%           2 : using ssh
%           3 : using both velocity fields and ssh for eddy contour, 
%               and keep the contour of the last one if it existS.
%   - extended_diags: flag to have extra diags concerning eddies directly
%       computed (like ellipse features or vorticity for each eddy)
%           0 : not computed
%           1 : computed as the same time as eddy detection
%           2 : computed afterward
%   - streamlines and daystreamfunction: save streamlines at steps 
%       'daystreamfunction' and profils of streamlines scanned as well
%   - periodic: flag to activate options for East-West periodic
%               (e.g. global fields or idealized simulations) domains.
%               IMPORTANT: first and last columns of the domain must be
%                          identical for this to work properly!!!!!
%
%-------------------------
% IMPORTANT - Input file requirements:
%
% All the variables are read from netcdf file.
% The package requires 3 different input files:
% 1) nc_dim with variables x(j,i),y(j,i),mask(j,i)
% 2) nc_u with variable ssu(t,j,i), day(t)
% 3) nc_v with variable ssv(t,j,i), day(t)
%
% t is the temporal dimension (number of time steps)
% y is the zonal dimension (number of grid points along latitude)
% x is the meridional dimension (number of grid points along longitude)
%
% The grid is assumed to be rectangular, with orientation N-S and E-W. 
% Grid indices correspond to geography, so that point (1,1) represents the
%      south-western corner of the domain.
% Latitudinal and longitudinal grid spacing can vary within the grid domain.
%
%-------------------------
%   Ver Apr 2015 Briac Le Vu
%-------------------------
%
%=========================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User modification ---------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Experiment setings

% name for the experiment
name = '2016_apr';

% set name of the domain
domname='MED';

% use to diferenciate source field of surface height (adt, ssh, psi,...)
sshname='adt'; % adt or sla

% set the paths
path_in=['/home/blevu/DATA/AVISO/',domname,'/'];
path_out=['/home/blevu/Resultats/AVISO/',domname,'/',sshname,'/'];
path_tracks='/home/blevu/DATA/AVISO/nrt/adt/tracks/';
path_data='/home/blevu/DATA/CORIOLIS/';

% use to submit parallel computation
runname = []; % ex: 1

% input data file absolute name
nc_dim=[path_in,'lon_lat_',sshname,'_',domname,'.nc'];
nc_u=[path_in,'ssu_',sshname,'_',domname,'_',name,'.nc'];
nc_v=[path_in,'ssv_',sshname,'_',domname,'_',name,'.nc'];
nc_ssh=[path_in,'ssh_',sshname,'_',domname,'_',name,'.nc'];

% variable names
lat_name = 'lat';
lon_name = 'lon';

% rotation period (T) per day and time step in days (dps)
T = 3600*24; % day period in seconds
dps = 1; % 24h time step

% degradation factor to test the algorithm
if ~exist('deg','var')
    deg = 1; % from 1 (default) to >10 in some experiment
end

%% Experiment option keys

% grid type
grid_ll = 1;
        % 0 : spatial grid in cartesian coordinates (x,y)
        % 1 : spatial grid in earth coordinates (lon,lat)

% choose the field use as streamlines
type_detection = 3;
        % 1 : using velocity fields
        % 2 : using ssh
        % 3 : using both velocity fields and ssh, 
        %     and keep max velocity along the eddy contour

% if you want extended diags directly computed
extended_diags = 1;
        % 0 : not computed
        % 1 : computed as the same time as eddy detection
        % 2 : computed afterward  

% save streamlines at days daystreamfunction and profil as well
streamlines = 1;
daystreamfunction = 1:90;

% in case of periodic grid along x boundaries
periodic = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of user modification ---------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
