function mod_eddy_params(keys_sources)
%
%   mod_eddy_params loads user paths and keys defined in keys_sources.m
%   and sets 2D fields of parameters
%
% Computed parameters:
%   - Dx: Meshgrid size
%   - Rd: First Baroclinic Rossby Radius of Deformation
%   - gama: resolution coefficient which is the number of pixels per Rd.
%   - resol: factor of interpolation of the fields (velocity and ssh)
%       to compute center detection. 2 or 3 seems reasonable in term of
%       computation time for 1/8° AVISO fields.
%   - b: parameter for the computation of LNAM and Local Okubo-Weiss
%       (number of grid points in one of the 4 directions to define
%       the length of the box area used normalize Angular Momentum
%       and Okubo-Weiss fields)
%   - bx: number of grid points to define the initial area to scan
%       streamlines
%
% Fixed parameters
% (you can play with Dt and cut_off but don't touch too much others):
%   - K: LNAM(LOW<0) threshold to detect the potential eddy centers
%   - Dt: delay in days for the tracking tolerance
%   - cut_off: in days for eddies duration filtration after the tracking
%           0 : use the turnover time from each eddies
%           1 : keep all the tracked eddies
%   - D_stp: in steps to define the averaged eddy features during the tracking
%   - C_rad: number of the averaged radius for the search limit area
%   - H: number of scanned streamlines in the initial area
%       for each eddies (see 'box' parameter below)
%   - n_min: minimal number of point to defined a contour as streamlines
%   - vel_epsilon: minimal difference between 2 tests of the velocity
%       to admit an increase
%   - k_vel_decay: coefficient of velmax to detect a decrease
%   - R_lim: limite of the eddy size
%   - nrho_lim: limite of the negative curvature for a single eddy
%   - ds_max: maximal distance between 2 eddies centers to have a potential
%       interaction (merging or splitting)
%   - dc_max: maximal distance between 2 eddies contours
%   - aire_max: maximal surface area of a double contour to be assimilated
%       to a single eddy when only one center is clearly determine
%
%----------------------------------------------
% This parametrisation come from the test with AVISO, ROMS and PIV
% see LE VU et al. paper
%
%-------------------------
%   June 2016 Briac Le Vu
%-------------------------
%
%=========================

%% Load keys and paths file
%----------------------------------------------
run(keys_sources)

%% Calculate the meshgrid size at (x,y) coordinates
%----------------------------------------------

% Read grid
y = double(ncread(nc_dim,y_name))';
x = double(ncread(nc_dim,x_name))';

% Meshgrid size
if grid_ll
    Dx = get_Dx_from_ll(x,y);
else
    Dx = ( abs( diff(x,1,2) ) + abs( diff(y,1,1) ) )/2;
end

% Calculate coriolis parameter
f = 4*pi/T; % in s-1

%% Calculate parameters needed for AMEDA at Dx and a given Rd
%----------------------------------------------

% Interpolate First Baroclinic Rossby Radius of Deformation
% (taken from 2D file Rossby_radius computed using Chelton et al. 1998)
%----------------------------------------------
load(mat_Rd)
Rd = interp2(lon_Rd,lat_Rd,Rd_baroc1,x,y); % 10km in average AVISO 1/8

% Resolution parameters:
%----------------------------------------------
% gama is resolution coefficient which is the number of pixels per Rd.
% After test gama>3 is required to get the max number of eddies.
gama = Rd ./ (Dx*deg); % [0.1-1.5] for AVISO 1/8 (0.8 in average)

% resol is an integer and used to improve the precision of centers detection
% close to 3 pixels per Rd. resol can goes up to 3
resol = max(1,min(3,round(3/min(gama(:))))); % [1 - 3]

% Detection parameters:
%----------------------------------------------
% K is LNAM(LOW<0) threshold to fixed contours where to detect potential center
% (one per contour). After test: no sensibility to K between 0.2 and 0.7
% but 0.7 give better time performance
K = 0.7; % [.4-.8]

% b is half length of the box in pixels used to normalise the LNAM and LOW.
% After test the optimal length of the box ( Lb = 2b*Dx*deg )
% is fixed to one and half the size of Rd (Lb/Rd=1.2).
b = max(1,round((1.2*gama)/2)); % always 1 for AVISO 1/8

% Rb (=Lb/Rd) is to check that the b setting and the gama are optimal.
% !!! Because optimal b is directly linked to gama, you start missing
% smaller eddies when gama is below 2 even at b=1
% (e.g. for AVISO 1/8 (gama~0.8) we have Rb~2.5) !!!
Rb = 2*b ./ gama; % [1-100] for AVISO 1/8 (2.5 in average)

% box is half length of the box used in pixels to find contour streamlines
% in pixels box = 10 times the Rd is enough to start testing any eddies
bx = round(10*gama); % [1-14] for AVISO 1/8 (8 in average)

%% fixed parameters
%----------------------------------------------

% Tracking parameters:
%----------------------------------------------
% maximal delay after its last detection for tracking an eddy [1-15]
Dt = 10; % in days

% minimal duration of recorded eddies [0-100]
% 0 for keeping only eddies longer than their turnover time
cut_off = 0; % in days

% number of steps to define the averaged eddy features during the tracking
D_stp = 4; % in steps

% coefficient to be applied to the averaged radius for the search limit area
C_rad = 2;

% Scanning parameters:
%----------------------------------------------
% H is number of contour scanned in box during detection of potential centers
% (centers0 to centers) and shapes (centers to centers2).
% After test [100-200] seems a good compromise.
% This parameter is directly link to the time computation!
H = 200; % number of contour scanned

% these contours must contain a minimal number of dots ([4-6])
n_min = 4; % minimal number of point to defined a contour as streamlines

% minimal difference ([1-2]*1e-4) between 2 tests of the velocity
% to admit an increase
vel_epsil = 1e-4; % in m/s

% coefficient of velmax to detect a decrease ([0.95-0.99])
k_vel_decay = 0.95; % in term of velmax

% limite of the size ([5-7]Rd) for a single eddy
R_lim = 5*Rd; % [4-7]Rd

% limite of the length of the contour with negative curvature for a single
% eddy from empirical determination based on ROMS, PIV and AVISO tests
nrho_lim = 0.33; % [1/3-1/2]*2piRmax of the equivalent circle

% Double eddy parameters
%----------------------------------------------
% maximal distance distances between 2 eddies centers and between their
% contour to have a potential interaction (merging or splitting) are based
% on von Hardenberg et al. (2000). study and synthesis on vortex merging
% in barotropic flows (ie d=3.3Rmax the critical merging distance).

% maximal distance between 2 eddies contours in term of Rmax
ds_max = 1.5; 

% maximal distance between 2 eddies centers in term of Rmax
dc_max = 3.5; 

% maximal surface area of a double contour to be assimilated to a
% single eddy when only one center is clearly determine (end of a merging
% or beginning of a splitting; ie. see end of mod_eddy_shapes) ([1.5-3])
aire_max = 2; % in term of surface area

%% Save parameters and paths
%----------------------------------------------
save([path_ameda,'param_eddy_tracking'],...
    'postname','domain','sshtype','path_ameda','path_in','path_out',...
    'nc_dim','nc_u','nc_v','nc_ssh','x_name','y_name','m_name','u_name','v_name','s_name',...
    'grid_ll','type_detection','extended_diags','streamlines','daystreamfunction','periodic',...
    'stepF','T','f','dps','deg','Dx','Rd','gama','resol','K','b','Rb','bx','Dt''D_stp','C_rad',...
    'H','n_min','vel_epsil','k_vel_decay','ds_max','dc_max','R_lim','nrho_lim','aire_max')



