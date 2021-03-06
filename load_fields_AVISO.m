<<<<<<< HEAD
function load_fields_AVISO(nc_dim,nc_u,nc_v,nc_ssh,b,bx,res,deg)
%load_field(nc_dim,nc_u,nc_v,nc_ssh,b,bx,res {,deg});
=======
function [lon,lat,mask,u,v,ssh] = load_fields_AVISO(stp,resolution,degra)
%[lon,lat,mask,u,v,ssh]=load_field(stp {,resolution,degra});
>>>>>>> ameda_v2
%
%  Get netcdf and load the grid and the velocities field (also ssh if any)
%  for AVISO fields like.
%  degrad ('deg') is a sample factor (use in some experiment).
%  resolution ('resol') is the factor to interpolate the grid (to find centers)
%
%  Enlarge the mask into land by adding b pixels of nil velocities into the
%  land and 1 pixel in land from an averaged of 9 neighbours for ssh
%	u(b)=0,u(~mask(b))=nan;
%	v(b)=0,v(~mask(b))=nan;
%	ssh(b)=mean(ssh)(b-1) or mean(ssh),ssh(~mask(b-1))=nan;
%
%  Output are matlab matrice used with tracking_plot routines and should be
%  saved in fields.mat file fieldsi must be save in fields_inter.mat.
%  fields size must be [lat,lon,time] and output velocities must be in m/s and ssh in m
%
%  Other load_fields routines are used for models or experiment.
%
%  For a description of the input parameters see param_eddy_tracking.m.
%
%-------------------------
%  June 2016 Briac Le Vu
%-------------------------
%
%=========================

<<<<<<< HEAD
global path_out
global path_rossby
global runname
global type_detection

if nargin==7
% No degradation by default
    deg = 1;
end
=======
% load keys_sources and parameters (use mod_eddy_params.m first)
%----------------------------------------
load('param_eddy_tracking')
>>>>>>> ameda_v2

% replace parameters by arguments
%----------------------------------------
if nargin==3
    deg = degra;
    resol = resolution;
elseif nargin==2
    resol = resolution;
end

% get netcdf
%----------------------------------------
lon0 = double(ncread(nc_dim,x_name))';
lat0 = double(ncread(nc_dim,y_name))';
% ! mask0 not constant with time ! don't trust that one
%mask0 = double(ncread(nc_dim,m_name))';
u0 = squeeze(permute(ncread(nc_u,u_name,[1 1 stp],[Inf Inf 1]),[2,1,3]));
v0 = squeeze(permute(ncread(nc_v,v_name,[1 1 stp],[Inf Inf 1]),[2,1,3]));

if type_detection>=2
    ssh0 = squeeze(permute(ncread(nc_ssh,s_name,[1 1 stp],[Inf Inf 1]),[2,1,3]));
else
    ssh0 = [];
end

% produce degraded field 
<<<<<<< HEAD
x = lon0(1:deg:end,1:deg:end);
y = lat0(1:deg:end,1:deg:end);
u = u0(1:deg:end,1:deg:end,:);
v = v0(1:deg:end,1:deg:end,:);
if type_detection>=2
    ssh = ssh0(1:deg:end,1:deg:end,:);
=======
%----------------------------------------
lon0 = lon0(1:deg:end,1:deg:end);
lat0 = lat0(1:deg:end,1:deg:end);
u0 = u0(1:deg:end,1:deg:end);
v0 = v0(1:deg:end,1:deg:end);
if type_detection>=2
    ssh0 = ssh0(1:deg:end,1:deg:end);
>>>>>>> ameda_v2
end

% get degarded b and bx
b = b(1:deg:end,1:deg:end);
bx = bx(1:deg:end,1:deg:end);

% get the grid size
<<<<<<< HEAD
[N,M,stp] = size(u);
=======
[N0,M0] = size(u0);
>>>>>>> ameda_v2

% mask 2d ! AVISO mask changes with time ! use that one
%----------------------------------------
<<<<<<< HEAD
% ! AVISO mask changes with time !

% mask 2d
mask = min((u(:,:,1:max(1,stp-7)).*v(:,:,1:max(1,stp-7)))*0+1,[],3);
mask(isnan(mask)) = 0;

% mask 3d
mask3d = repmat(mask,[1,1,stp]);

%----------------------------------------
% fix fields to 0 in land
u(mask3d==0 | isnan(u)) = 0;
v(mask3d==0 | isnan(v)) = 0;

%----------------------------------------
% Enlarge mask into land by b pixels and compute ssh in the first land pixel if needed

disp('"enlarge coastal mask" by adding b pixels of ocean to the coast')

mask1 = mask;
for n=1:max(b(:))
    mask2 = mask1;
    for i=1:N
        for j=1:M
            if mask1(i,j)==0 && max(max(b(max(i-1,1):min(i+1,N),max(j-1,1):min(j+1,M))))>=n &&...
                sum(sum(mask1(max(i-1,1):min(i+1,N),max(j-1,1):min(j+1,M))))~=0
                mask2(i,j)=1;
                if type_detection>=2
                    for k=1:stp
                        if n==1 && isnan(ssh(i,j,k))
                            ssh1 = ssh(max(i-n,1):min(i+n,N),max(j-n,1):min(j+n,M),k);
                            ssh(i,j,k) = nanmean(ssh1(:));
                        end
=======
mask0 = u0.*v0*0+1;
mask0(isnan(mask0)) = 0;

% fix fields to 0 in land and in miscellaneous AVISO mask
%----------------------------------------
u0(mask0==0) = 0;
v0(mask0==0) = 0;
u0(isnan(u0)) = 0;
v0(isnan(v0)) = 0;
if type_detection>=2
    ssh0(mask0==0) = NaN;
end

% Enlarge mask into land by b pixels
%----------------------------------------
mask1 = mask0;
for n=1:b
	mask2 = mask1;
    for i=1:N0
        for j=1:M0
            if mask1(i,j)==0
                if sum(sum(mask1(max(i-1,1):min(i+1,N0),max(j-1,1):min(j+1,M0))))~=0
                    mask2(i,j)=1;
                    if type_detection>=2 && n==1
                        ssh1 = ssh0(max(i-n,1):min(i+n,N0),max(j-n,1):min(j+n,M0));
                        ssh0(i,j) = nanmean(ssh1(:));
>>>>>>> ameda_v2
                    end
                end
            end
        end
    end
    mask1 = mask2;% enlarged mask
end

<<<<<<< HEAD
% Build mask ssh
maskssh = min(ssh(:,:,1:max(1,stp-7))*0+1,[],3);
maskssh(isnan(maskssh)) = 0;

% Mask velocities with the enlarged mask
mask3d = repmat(mask1,[1,1,stp]);
u(mask3d==0) = NaN;
v(mask3d==0) = NaN;

%----------------------------------------
% Increase resolution r factor by linear interpolation

if res==1

    disp('NO INTERPOLATION')
    
    xi = x;
    yi = y;
    maski = mask;
    ui = u;
    vi = v;
    sshi = ssh;
    bi = b;
    bxi = bx;
    
else

    disp(['"change resolution" by computing 2D SPLINE INTERPOLATION res=',num2str(res)])

    % size for the interpolated grid
    Ni = res*(N-1)+1; % new size in lat
    Mi = res*(M-1)+1; % new size in lon

    % elemental spacing for the interpolated grid with regular grid
    dy = diff(y(1:2,1))/res;
    dx = diff(x(1,1:2))/res;
=======
% Increase resolution r factor by linear interpolation
%----------------------------------------
if resol==1
    lon = lon0;
    lat = lat0;
    u = u0;
    v = v0;
    ssh = ssh0;
    mask = mask0;
    mask0 = mask1;
else
    % size for the interpolated grid
    N = fix(resol*N0); % new size in lat
    M = fix(resol*M0); % new size in lon

    % elemental spacing for the interpolated grid
    dlat = diff(lat0(1:2,1))/resol;
    dlon = diff(lon0(1,1:2))/resol;
>>>>>>> ameda_v2

    % interpolated grid
    [xi,yi] = meshgrid([0:Mi-1]*dx+min(x(:)),[0:Ni-1]*dy+min(y(:)));

    % Increase resolution of the mask
    maski = interp2(x,y,mask,xi,yi);
    maski(isnan(maski) | maski < 1) = 0;
    
    % Increase resolution of the ssh mask
    maskissh = interp2(x,y,maskssh,xi,yi);
    maskissh(isnan(maskissh) | maskissh < 1) = 0;

<<<<<<< HEAD
    % Compute the enlarged mask to the new resolution
    maski1 = interp2(x,y,mask1,xi,yi);
    maski1(isnan(maski1)) = 0;
    maski1(maski1 > 0) = 1;
    
    % initialize interp fields
    ui = zeros([Ni Mi stp]);
    vi = ui;
    if type_detection>=2
        sshi = ui;
=======
    % Increase resolution of fields (interp2 with regular grid)
    u = interp2(lon0,lat0,u0,lon,lat,'*spline');
    v = interp2(lon0,lat0,v0,lon,lat,'*spline');
    if type_detection>=2
        ssh = interp2(lon0,lat0,ssh0,lon,lat,'linear');
>>>>>>> ameda_v2
    else
        sshi = [];
    end
<<<<<<< HEAD
    
    % Increase resolution of fields (interp2 with regular grid)
    for i=1:stp
        disp([' step ',num2str(i)])
        u1 = squeeze(u(:,:,i));
        v1 = squeeze(v(:,:,i));
        u1(isnan(u1)) = 0;
        v1(isnan(v1)) = 0;
        ui(:,:,i) = interp2(x,y,u1,xi,yi,'*spline',0);
        vi(:,:,i) = interp2(x,y,v1,xi,yi,'*spline',0);
        if type_detection>=2
            ssh1 = get_missing_val_2d(x,y,ssh(:,:,i));
            sshi(:,:,i) = interp2(x,y,ssh1,xi,yi,'*spline');
        end
    end
    
    % Compute interpolated b and bx
    bi = round(interp2(x,y,b,xi,yi))*res;
    bxi = round(interp2(x,y,bx,xi,yi))*res;
=======
end
>>>>>>> ameda_v2

    % Mask velocities and ssh with their enlarged mask
    maski3d = repmat(maski1,[1,1,stp]);
    maskissh3d = repmat(maskissh,[1,1,stp]);
    ui(maski3d==0) = NaN;
    vi(maski3d==0) = NaN;
    sshi(maskissh3d==0) = NaN;

<<<<<<< HEAD
end
=======
% Mask velocities with the enlarged mask
%----------------------------------------
u(mask0==0) = NaN;
v(mask0==0) = NaN;
>>>>>>> ameda_v2

% Dx, Rd, gama
load([path_rossby,'Rossby_radius'])
Dx = get_Dx_from_ll(x,y);
Rd = interp2(lon_Rd,lat_Rd,Rd_baroc1_extra,x,y); % 10km in average AVISO 1/8
gama = Rd ./ (Dx*deg);

% Save non interpolated fields
save([path_out,'fields',runname],'x','y','mask','u','v','ssh','b','bx','Dx','Rd','gama','-v7.3')

% Dx, Rd, gama on interpolated grid
Dx = get_Dx_from_ll(xi,yi);
Rd = interp2(lon_Rd,lat_Rd,Rd_baroc1_extra,xi,yi); % 10km in average AVISO 1/8
gama = Rd ./ (Dx*deg)/res;

% Save interpolated fields
x=xi;
y=yi;
mask=maski;
u=ui;
v=vi;
ssh=sshi;
b=bi;
bx=bxi;
save([path_out,'fields_inter',runname],'x','y','mask','u','v','ssh','b','bx','Dx','Rd','gama','-v7.3')
