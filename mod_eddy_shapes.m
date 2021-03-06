<<<<<<< HEAD
function mod_eddy_shapes(update)
%mod_eddy_shapes({,update})
=======
function [centers2,shapes1,shapes2,profil2,warn_shapes,warn_shapes2] = ...
    mod_eddy_shapes(source,stp,fields,centers,bxarea)
%[centers2,shapes1,shapes2,profil2] =
%       mod_eddy_shapes(source,stp,fields,centers {,bxarea})
>>>>>>> ameda_v2
%
%  Computes the shapes (if any) of eddies identified with their potential
%  centers by mod_eddy_centers.m and stored as {centers(t)} in
%  [path_out,'eddy_centers',runname]
%
<<<<<<< HEAD
%  - update is a flag allowing to update an existing detection:
%       update = number of time steps backward to consider
%       update = 0 (default) to compute all the {centers} time serie
=======
% - 'source' is the type of netcdf data (AVISO, NEMO, ROMS,...) that
%   determine which load_field_'source'is  used in the routine
% - 'fields' is the step 'stp' of the detection_fields computed with
%   mod_eddy_fields.m
% - 'bxarea' defines the area where the streamfunction (PSI) is firstly computed
>>>>>>> ameda_v2
%
%  For a description of the input parameters see param_eddy_tracking.m

%
%  Then [path_out,'eddy_centers',runname] is updated with the structure
%  {centers2(t)} including coordinates of validated centers as eddies.
%  Fields of the main centers(indice 1) and double centers(indice 2),
%  if any, are:
%  - x1,y1(n): coordinates of the main centers
%  - x2,y2(n): coordinates of the double center if any (NaN otherwise)
%
%  Also features of validated eddy are saved/updated in
%  [path_out,'eddy_shapes',runname] as structure arrays:
%  - {shapes1(t)} for the main center and
%  - {shapes2(t)} for double eddies (if any).
%
%  Features inside these structure include: 
%  - xy(n): xy is a [2xm double] cell array, containing
%    the coordinates of the m vertices that define the
%    boundaries of the n-th eddy of the t-th step
%  - velmax(n): velmax is the maximum mean velocity along the contour xy
%  - tau(n): tau is the minimal eddy turnover time inside
%    the eddy bourndaries
%  - deta(n): deta is the difference between the ssh on the
%    limiting contour and the ssh in the extremum in the middle (max or min)
%  - nrho(n): part of the local curvature along the coutour n
%  - rmax(n): rmax is the averaged radius from the eddy centre to
%    the boundary vertices (see 'mean_radius' for more details)
%  - aire(n): aire is the area delimited by the eddy boundaries
%    (see 'mean_radius.m' for more details)
%  - mu, rsquare, rmse: fitting result from compute_best_fit
%
%  Also:
%
%  if extended_diags =1, you save in {shapes1 or 2}:
%  - xbary,ybary,ellip: the ellipse features
%  - ke,vort,VortM,OW,LNAM: fields inside the eddy
%
%  if streamlines =1, you save all streamlines scanned during shapes
%  computation at t=daystreamfunction in {profil2(t)}, with:
%  - step,nc(n): time step and number of centers at t
%  - eta(n),rmoy(n),vel(n),tau(n): profil scanned
%  - myfit: fitting result with curve (form factor) and err (error fitting)
%
%  Another file which contains information on the process to  compute eddy 
%  shapes is saved as [path_out,'warnings_shapes',runname] in
%  {warn_shapes(t)}:
%  - no_curve(n): 1 if no closed contour of PSI was found
%    around the eddy center;
%  - Rd(n): first baroclinic deformation radius of Rossby at the center
%  - gama(n): resolution factor at the center (Rd/DX/deg*res)
%  - bx(n): area where the shape is computed (bx*fac)
%  - calcul_curve(n): 1 if the closed contour as been obtain
%    through the computation of psi field thanks to 'compute_psi' in the
%    case ssh do not allowed to close contour around the center
%  - large_curve(n): 1 if no closed contour around the
%    center with increasing velocity across. Shape is defined by just
%    the larges closed contour;
%  - too_large2(n): 1 if double eddy shapes is too large and removed
%
%  (t is the time step index; n is the indice of eddy detected at t)
%
%
%  The function returns also a log file
%  [path_out,'log_eddy_shapes',runname,'.txt'] which contains additional
%  information on the process to compute eddy shapes.
%  (NOTE: if the file already exist, the new log file will be append to it)
%  
%  'eddy_dim' is used to compute eddy shapes. Check the documentation in 
%  eddy_dim.m for further details.
%
%-------------------------
%   Ver. 3.2 Apr.2015 Briac Le Vu
%   Ver. 3.1 2014 LMD from Nencioli et al. routines
%-------------------------
%
%=========================

%---------------------------------------------
% read fields and initialisation
%---------------------------------------------

disp(['  Step ',num2str(stp),' %-------------'])

% load key_source and parameters
%----------------------------------------------
load('param_eddy_tracking')

<<<<<<< HEAD
% No update by default
if nargin==0
    update = 0;
end

% load the computed field in mod_fields
load([path_out,'fields_inter',runname]);
% begin the log file
diary([path_out,'log_eddy_shapes',runname,'.txt']);
% load eddy centers
load([path_out,'eddy_centers',runname]);
=======
% replace parameters by arguments
%----------------------------------------
if nargin==5
    bx = bxarea;
end

% load 2D velocity fields (m/s) for step stp
%----------------------------------------
eval(['[x,y,mask,uu,vv,sshh] = load_fields_',source,'(stp,1,deg);'])
>>>>>>> ameda_v2

% initialise centers as structure
%----------------------------------------
centers2 = struct('step',[],'type',[],'x1',[],'y1',[],'x2',[],'y2',[],'dc',[],'ds',[]);

shapes1 = struct('step',[],'xy',[],'velmax',[],'taumin',[],'deta',[],'nrho',[],'rmax',[],'aire',[],...
                'xy_end',[],'vel_end',[],'deta_end',[],'r_end',[],'aire_end',[]);
shapes2 = struct('step',[],'xy',[],'velmax',[],'deta',[],'nrho',[],'rmax',[],'aire',[]);

if streamlines
    profil2 = struct('step',[],'nc',[],'eta',[],'rmoy',[],'vel',[],'tau',[],'myfit',[]);

    struct1 = struct('alpha',[],'rsquare',[],'rmse',[]);
    names1 = [fieldnames(shapes1); fieldnames(struct1)];
    shapes1 = cell2struct([struct2cell(shapes1); struct2cell(struct1)], names1, 1);

<<<<<<< HEAD
    switch extended_diags
        case {0, 2}
            if streamlines
                shapes1 = struct('xy',{},'velmax',{},'taumin',{},'deta',{},'nrho',{},'rmax',{},'aire',{},...
                    'xy_end',{},'vel_end',{},'deta_end',{},'r_end',{},'aire_end',{},...
                    'alpha',{},'rsquare',{},'rmse',{});
            else
                shapes1 = struct('xy',{},'velmax',{},'taumin',{},'deta',{},'nrho',{},'rmax',{},'aire',{},...
                    'xy_end',{},'vel_end',{},'deta_end',{},'r_end',{},'aire_end',{});
            end
            shapes2 = struct('xy',{},'velmax',{},'taumin',{},'deta',{},'nrho',{},'rmax',{},'aire',{});
        case 1
            if streamlines
                shapes1 = struct('xy',{},'velmax',{},'taumin',{},'deta',{},'nrho',{},'rmax',{},'aire',{},...
                    'xy_end',{},'vel_end',{},'deta_end',{},'r_end',{},'aire_end',{},...
                    'alpha',{},'rsquare',{},'rmse',{},...
                    'xbary',{},'ybary',{},'ellip',{},...
                    'ke',{},'vort',{},'vortM',{},'OW',{},'LNAM',{});
            else
                shapes1 = struct('xy',{},'velmax',{},'taumin',{},'deta',{},'nrho',{},'rmax',{},'aire',{},...
                    'xy_end',{},'vel_end',{},'deta_end',{},'r_end',{},'aire_end',{},...
                    'xbary',{},'ybary',{},'ellip',{},...
                    'ke',{},'vort',{},'vortM',{},'OW',{},'LNAM',{});
            end
            shapes2 = struct('xy',{},'velmax',{},'deta',{},'nrho',{},'rmax',{},'aire',{},...
                'xbary',{},'ybary',{},'ellip',{});
        otherwise
            display('Wrong choice of extended_diags option')
            stop
    end
    
    centers2 = struct('step',{},'type',{},'x1',{},'y1',{},'x2',{},'y2',{},'dc',{},'ds',{});
    
    % shapes struct for the possible second shape with 2 centers
    warn_shapes = struct('no_curve',{},'Rd',{},'gama',{},'bx',{},'calcul_curve',{},...
	'large_curve1',{},'large_curve2',{},'too_large2',{});
    warn_shapes2 = warn_shapes;
    
    if streamlines
        profil2 = struct('step',{},'nc',{},'eta',{},'rmoy',{},'vel',{},'tau',{},'myfit',{});
    end
    
    step0 = 1;
    
=======
>>>>>>> ameda_v2
end
if extended_diags==1
    struct1 = struct('xbary',[],'ybary',[],'ellip',[],...
                'ke',[],'vort',[],'vortM',[],'OW',[],'LNAM',[]);
    struct2 = struct('xbary',[],'ybary',[],'ellip',[]);
    names1 = [fieldnames(shapes1); fieldnames(struct1)];
    names2 = [fieldnames(shapes2); fieldnames(struct2)];
    shapes1 = cell2struct([struct2cell(shapes1); struct2cell(struct1)], names1, 1);
    shapes2 = cell2struct([struct2cell(shapes2); struct2cell(struct2)], names2, 1);
end

<<<<<<< HEAD
disp(['Determine contour shapes for ',runname])
=======
% shapes struct for the possible second shape with 2 centers
warn_shapes = struct('no_curve',[],'fac',[],'bx',[],'calcul_curve',[],...
                'large_curve1',[],'large_curve2',[],'too_large2',[]);
warn_shapes2 = warn_shapes;
>>>>>>> ameda_v2

% Compute eddy shape
%----------------------------------------------

if streamlines
    profil2.step = centers.step;
end

centers2.step = centers.step;
shapes1.step = centers.step;
shapes2.step = centers.step;
shapes1.xy = {};
shapes1.xy_end = {};
shapes1.velmax = nan(1,length(centers.type));
shapes2.xy = {};
shapes2.velmax = nan(1,length(centers.type));
warn_shapes.no_curve = ones(1,length(centers.type));

% loop through all centers detected for a given step
%----------------------------------------------
for ii=1:length(centers.type)

<<<<<<< HEAD
        % center indice
        c_j = centers(i).j(ii);
        c_i = centers(i).i(ii);
        
        % initialization
        bound = 1; % flag that indicates that permit to increase the small area
        fac = 0; % increase factor for the area where PSI is computed
        tmp_large = ones(1,2); % flag on: No maximum found for single and double eddy
        tmp_CD = nan(2,2); % centers coordinates in case of double eddy 
        tmp_xy = cell(1,3); % contour for single (max and final) and double eddy
        tmp_allines = []; % streamlines features to be tested every eddy_dim computation
        tmp_velmax = zeros(1,3); % velocity to be tested every eddy_dim computation
        tmp_tau = 9999; % turnover time
        tmp_deta = zeros(1,3); % delta ssh 
        tmp_nrho = nan(1,2); % local curvature along the single and double eddy 
=======
    disp([' === Center ',num2str(ii),' ==='])
>>>>>>> ameda_v2

    % initialization
    bound = 1; % flag that indicates that permit to increase the small area
    fac = 0; % increase factor for the area where PSI is computed
    tmp_large = ones(1,2); % flag on: No maximum found for single and double eddy
    tmp_CD = nan(2,2); % centers coordinates in case of double eddy 
    tmp_xy = cell(1,3); % contour for single (max and final) and double eddy
    tmp_allines = []; % streamlines features to be tested every eddy_dim computation
    tmp_velmax = zeros(1,3); % velocity to be tested every eddy_dim computation
    tmp_tau = 9999; % turnover time
    tmp_deta = zeros(1,3); % delta ssh 
    tmp_nrho = nan(1,2); % local curvature along the single and double eddy 
    
    while bound
        % factor which increases the area where psi is computed
        % if eddy dimensions are too big (bound=1)
        fac = fac + 1; % this determine larger area

<<<<<<< HEAD
            % xy is the computed shape;
            % the others are flags output by eddy_dim, and saved in 'warnings_shapes';
            %----------------------------------------------
            [CD,xy,allines,velmax,tau,deta,nrho,large,warn,calcul] =...
                eddy_dim(uu,vv,sshh,mask,x,y,centers(i),ii,Rd(c_j,c_i),fac*bx(c_j,c_i));
=======
        % xy is the computed shape;
        % the others are flags output by eddy_dim, and saved in 'warnings_shapes';
        %----------------------------------------------
        [CD,xy,allines,velmax,tau,deta,nrho,large,warn,calcul] =...
            eddy_dim(uu,vv,sshh,mask,x,y,centers,ii,fac*bx);
>>>>>>> ameda_v2

        % flags exploitation
        %----------------------------------------------
        if warn
            disp('   No significant streamlines closed around the center')
            bound = 0;
        else
            % if eddy max velocity is still increasing then temporary save eddy_dim(1)
            if velmax(1) > tmp_velmax(1) + vel_epsil
                bound = 1;
                % temporary save eddy till true eddy found
                if tmp_large(1)==1
                    tmp_large(1)  = large(1);
                    tmp_xy(1)     = xy(1);
                    tmp_velmax(1) = velmax(1);
                    tmp_tau       = tau;
                    tmp_deta(1)   = deta(1);
                    tmp_nrho      = nrho;
                end
            else
                % stop if no significant increasing of the velocity
                bound = 0;
            end
            % if last contour velocity is still increasing then temporary save eddy_dim(3)
            if size(xy{3},2) > size(tmp_xy{3},2)
                bound = 1;
                % temporary save flags
                tmp_xy(3)     = xy(3);
                tmp_velmax(3) = velmax(3);
                tmp_deta(3)   = deta(3);
                tmp_allines   = allines;
            else
                % stop if no significant increasing of last contour size
                bound = 0;
            end
            % if double eddy not found yet
            if isnan(large(2)) && fac==1
                % test double eddy in larger area
                bound = 1;
            % if double contour is still increasing then temporary save eddy_dim(2)
            elseif velmax(2) > tmp_velmax(2) + vel_epsil
                bound = 1;
                % temporary save eddy till true double eddy found 
                if tmp_large(2)==1
                    tmp_large(2)  = large(2);
                    tmp_CD        = CD;
                    tmp_xy(2)     = xy(2);
                    tmp_velmax(2) = velmax(2);
                    tmp_deta(2)   = deta(2);
                    tmp_nrho(2)   = nrho(2);
                    tmp_allines   = allines;
                else
                    % stop if true double eddy found
                    bound = 0;
                end
            else
               % stop after 2 scans if no significant increase of the velocity
               bound = 0;
            end
            % if no closed curve more intense in the larger area then
            % final eddy shape is the one computed in the smaller area
            if bound
                disp(['   Big eddy: going to fac = ',num2str(fac+1)])
            else
                disp(['   No closed or largest curve at fac ',num2str(fac),...
                    ' back to the largest curve at fac ',num2str(fac-1)])
                % stop enlarging the area
                fac = fac - 1;
                % go back to saved eddy_shape
                large   = tmp_large;
                CD      = tmp_CD;
                xy      = tmp_xy;
                allines = tmp_allines;
                velmax  = tmp_velmax;
                tau     = tmp_tau;
                deta    = tmp_deta;
                nrho    = tmp_nrho;
            end
        end
    end % end while loop

    % write out which kind of eddy found
    %----------------------------------------------
    if ~warn
        if large(2) == 0
            disp('   Eddy with 2 centers')
        elseif large(1) == 0
            disp('   Eddy with 1 center')
        elseif large(2) == 1
            disp('   Largest with 2 centers')
        else
            disp('   Largest with 1 center')
        end
    end

    % save eddy_dim results in a struct array shapes end the single eddies
    %----------------------------------------------------------
    if ~isempty(xy{3})
        centers2.type(ii) = centers.type(ii);
        centers2.x1(ii)   = centers.x(ii);
        centers2.y1(ii)   = centers.y(ii);
        [rmax,aire,~,~] = mean_radius(xy{3},grid_ll);
        shapes1.xy_end(ii)   = xy(3);
        shapes1.vel_end(ii)  = velmax(3);
        shapes1.deta_end(ii) = deta(3);
        shapes1.r_end(ii)    = rmax(1);
        shapes1.aire_end(ii) = aire;
    else
        names = fieldnames(centers2);
        for n=2:length(names)
            centers2.(names{n})(ii) = NaN;
        end
        shapes1.xy{ii} = NaN;
        names = fieldnames(shapes1);
        for n=3:8
            shapes1.(names{n})(ii) = NaN;
        end
        shapes1.xy_end{ii} = NaN;
        for n=10:length(names)
            shapes1.(names{n})(ii) = NaN;
        end
        if streamlines
            if find(daystreamfunction==stp)
                names = fieldnames(profil2);
                for n=2:length(names)-1
                    profil2.(names{n}){ii} = NaN;
                end
                profil2.myfit(ii).curve = NaN;
                profil2.myfit(ii).err   = NaN;
            end
        end
    end
    % save eddy_dim results in a struct array shapes1 the single eddies
    %----------------------------------------------------------
    if ~isempty(xy{1})
        [rmax,aire,~,~] = mean_radius(xy{1},grid_ll);
        shapes1.xy(ii)     = xy(1);
        shapes1.velmax(ii) = velmax(1);
        shapes1.taumin(ii) = tau;
        shapes1.deta(ii)   = deta(1);
        shapes1.nrho(ii)   = nrho(1);
        shapes1.rmax(ii)   = rmax(1);
        shapes1.aire(ii)   = aire;
        if extended_diags==1
            [xbary,ybary,~,a,b,~,~] = compute_ellip(xy{1},grid_ll);
            shapes1.xbary(ii) = xbary;
            shapes1.ybary(ii) = ybary;
            if a>=b && a~=0
                shapes1.ellip(ii) = 1-b/a;
            elseif a<b && b~=0
                shapes1.ellip(ii) = 1-a/b;
            else
                shapes1.ellip(ii) = NaN;
            end
            in_eddy = inpolygon(x,y,xy{1}(1,:),xy{1}(2,:));
            ke   = fields.ke(in_eddy~=0);
            vort = fields.vort(in_eddy~=0);
            OW   = fields.OW(in_eddy~=0);
            LNAM = fields.LNAM(in_eddy~=0);
            shapes1.ke(ii)   = nansum(ke(:));
            shapes1.vort(ii) = nanmean(vort(:));
            if nanmean(vort(:)) > 0
                shapes1.vortM(ii) = nanmax(vort);
            elseif nanmean(vort(:)) < 0
                shapes1.vortM(ii) = nanmin(vort);
            else
                display('vort==0?')
            end
            shapes1.OW(ii)   = nanmean(OW(:));
            shapes1.LNAM(ii) = nanmean(LNAM(:));
        end
        % save the streamlines features at i=daystreamfunction
        %----------------------------------------------------------
        if streamlines
            if find(daystreamfunction==stp)
                names = fieldnames(profil2);
                for n=2:length(names)-1
                    profil2.(names{n}){ii} = allines(:,n-1)';
                end
                % compute and save curve fitting stats at step i for the eddy ii
                [curve,err] = compute_best_fit(allines,rmax(1),velmax(1));
                if ~isempty(curve)
                    profil2.myfit(ii).curve = curve;
                    profil2.myfit(ii).err   = err;
                    shapes1.alpha(ii)   = curve.a;
                    shapes1.rsquare(ii) = err.rsquare;
                    shapes1.rmse(ii)    = err.rmse;
                else
                    profil2.myfit(ii).curve = NaN;
                    profil2.myfit(ii).err   = NaN;
                    shapes1.alpha(ii)   = NaN;
                    shapes1.rsquare(ii) = NaN;
                    shapes1.rmse(ii)    = NaN;
                end
            end
        end
    end
    % save eddy_dim results in a struct array shapes2 double eddies
    %----------------------------------------------------------
    if ~isempty(xy{2})
        if CD(1,1)==centers.x(ii) && CD(2,1)==centers.y(ii)
            centers2.x2(ii) = CD(1,2);
            centers2.y2(ii) = CD(2,2);
        elseif CD(1,2)==centers.x(ii) && CD(2,2)==centers.y(ii)
            centers2.x2(ii) = CD(1,1);
            centers2.y2(ii) = CD(2,1);
        end
        if grid_ll
            centers2.dc(ii) = sw_dist(CD(2,:),CD(1,:),'km');
        else
            centers2.dc(ii) = sqrt(diff(CD(1,:)).^2 + diff(CD(2,:)).^2); % km
        end
        centers2.ds(ii)    = NaN;
        [rmax,aire,~,~] = mean_radius(xy{2},grid_ll);
        shapes2.xy(ii)     = xy(2);
        shapes2.velmax(ii) = velmax(2);
        shapes2.deta(ii)   = deta(2);
        shapes2.nrho(ii)   = nrho(2);
        shapes2.rmax(ii)   = rmax(1);
        shapes2.aire(ii)   = aire;
        if extended_diags==1
            [xbary,ybary,~,a,b,~,~] = compute_ellip(xy{2},grid_ll);
            shapes2.xbary(ii) = xbary;
            shapes2.ybary(ii) = ybary;
            if a>=b && a~=0
                shapes2.ellip(ii) = 1-b/a;
            elseif a<b && b~=0
                shapes2.ellip(ii) = 1-a/b;
            else
                shapes2.ellip(ii) = NaN;
            end
        end
<<<<<<< HEAD
        %----------------------------------------------------------
        % warnings from shape computation
        warn_shapes(i).no_curve(ii)     = warn;
        warn_shapes(i).Rd(ii)           = Rd(c_j,c_i);
        warn_shapes(i).gama(ii)         = gama(c_j,c_i);
        warn_shapes(i).bx(ii)           = bx(c_j,c_i)*fac;
        warn_shapes(i).calcul_curve(ii) = calcul;
        warn_shapes(i).large_curve1(ii) = large(1);
        warn_shapes(i).large_curve2(ii) = large(2);
        warn_shapes(i).too_large2(ii)   = 0;

    end % ii=last eddy

    if isempty(centers2(i).type)
        %----------------------------------------------------------
        % Initialize warn_shape for eddies with shapes1
        warn_shapes(i).no_curve = [];
        warn_shapes2(i) = warn_shapes(i);
=======
>>>>>>> ameda_v2
    else
        names = fieldnames(centers2);
        for n=5:length(names)
            centers2.(names{n})(ii) = NaN;
        end
        shapes2.xy{ii} = NaN;
        names = fieldnames(shapes2);
        for n=3:length(names)
            shapes2.(names{n})(ii) = NaN;
        end
    end

    % warnings from shape computation
    %----------------------------------------------------------
    warn_shapes.no_curve(ii)     = warn;
    warn_shapes.fac(ii)          = fac;
    warn_shapes.bx(ii)           = bx;
    warn_shapes.calcul_curve(ii) = calcul;
    warn_shapes.large_curve1(ii) = large(1);
    warn_shapes.large_curve2(ii) = large(2);
    warn_shapes.too_large2(ii)   = 0;

end % ii=last eddy

if isempty(centers2.type)
    % Initialize warn_shape for eddies with shapes1
    %----------------------------------------------------------
    warn_shapes.no_curve = [];
    warn_shapes2 = warn_shapes;
else
    % Initialize warn_shape for eddies with shapes1
    %----------------------------------------------------------
    warn_shapes2 = warn_shapes;

    % remove the shapes and centers where no closed contour was found
    %----------------------------------------------------------
    replace = find(isnan(shapes1.vel_end));
    names = fieldnames(centers2);
    for n=2:length(names)
        centers2.(names{n})(replace)=[];
    end
    names = fieldnames(shapes1);
    for n=2:length(names)
        shapes1.(names{n})(replace)=[];
    end
    names = fieldnames(shapes2);
    for n=2:length(names)
        shapes2.(names{n})(replace)=[];
    end
    names = fieldnames(warn_shapes2);
    for n=1:length(names)
        warn_shapes2.(names{n})(replace)=[];
    end
    if streamlines
        if find(daystreamfunction==stp)
            names = fieldnames(profil2);
            for n=2:length(names)
                profil2.(names{n})(replace)=[];
            end
        end
    end

<<<<<<< HEAD
        %----------------------------------------------------------
        % Remove shapes2 too big or too weak (a first try):
        % if 2 shapes1 exist
        %   remove shapes 2 if double eddy too weak
        %	calcul ds = distance between 2 shapes1 (rmax1 & rmax2)
        %   remove shapes2 with ds > 1.5 (rmax1 + rmax2)/2
        %   if 2 shapes2 exist remove the calculated and the weakest
        % else
        %	calcul dc = distance between 2 centers
        %   remove shapes2 if dc > 3.5 * rmax
        %   replace shapes1 by shapes2 if shapes2 small
        % end
        disp(' ')
        for ii=1:length(shapes2(i).velmax)
            % test shapes2(ii) exists
            if ~isnan(shapes2(i).velmax(ii))
                mv=0;
                ll1 = shapes1(i).xy{ii}; % shapes1(ii)
                % find indice of the other center
                ind = find(centers2(i).x1==centers2(i).x2(ii) &...
                       centers2(i).y1==centers2(i).y2(ii));
                % check that double centers are different type
                if centers2(i).type(ii)~=centers2(i).type(ind)
                    disp(['   Double eddy ',num2str(ii),' mistaken around 2 different type of eddy !!!'])
=======
    %----------------------------------------------------------
    % Remove shapes2 too big or too weak (a first try):
    % if 2 shapes1 exist
    %   remove shapes 2 if double eddy too weak
    %	calcul ds = distance between 2 shapes1 (rmax1 & rmax2)
    %   remove shapes2 with ds > 1.5 * (rmax1 + rmax2)/2
    %   if 2 shapes2 exist remove the calculated and the weakest
    % else
    %	calcul dc = distance between 2 centers
    %   remove shapes2 if dc > 3.5 * rmax
    %   replace shapes1 by shapes2 if shapes2 small
    % end
    %----------------------------------------------------------
    disp(' ')
    for ii=1:length(shapes2.velmax)
        % test shapes2(ii) exists
        if ~isnan(shapes2.velmax(ii))
            mv=0;
            ll1 = shapes1.xy{ii}; % shapes1(ii)
            % find indice of the other center
            ind = find(centers2.x1==centers2.x2(ii) &...
                   centers2.y1==centers2.y2(ii));
            % check that double centers are different type
            if centers2.type(ii)~=centers2.type(ind)
                disp(['   Double eddy ',num2str(ii),' mistaken around 2 different type of eddy !!!'])
                mv=1;
            % test shapes1(ind) exists
            elseif ~isempty(ind)
                ll2 = shapes1.xy{ind}; % shapes1(ind)
                % calcul distance between shapes1(ii) and shapes1(ind)
                centers2.ds(ii) = min_dist_shapes(ll1,ll2,grid_ll);
                % remove shapes2(ii) when shapes1(ind) gots higher velocity
                %----------------------------------------------------------
                if shapes2.velmax(ii) < shapes1.velmax(ind)
                    disp(['   Double eddy ',num2str(ii),' weaker than eddy ',num2str(ind),' !!!'])
>>>>>>> ameda_v2
                    mv=1;
                % remove shapes2(ii) when shapes1 far one from the other
                %----------------------------------------------------------
                elseif centers2.ds(ii) > ds_max*(shapes1.rmax(ii)+shapes1.rmax(ind))/2
                    disp(['   Double eddy ',num2str(ii),' too large space between 2 shapes !!!'])
                    mv=1;
                % test shapes2(ind) exist
                elseif ~isnan(shapes2.velmax(ind))
                    % test shapes2 both calculated or both not calculated
                    if warn_shapes2.calcul_curve(ii)==warn_shapes2.calcul_curve(ind)
                        % remove shapes2 if weakest
                        %----------------------------------------------------------
                        if shapes2.velmax(ii) < shapes2.velmax(ind)
                            mv = 1;
                        elseif shapes2.velmax(ii) == shapes2.velmax(ind)
                            if abs(shapes2.deta(ii)) < abs(shapes2.deta(ind))
                                mv = 1;
                            end
                        end
<<<<<<< HEAD
                    end
                % if shapes1(ind) doesn't exist remove shapes2(ii) with centers
                % very far from each ones and record small shapes2 as shapes1
                else
                    if centers2(i).dc(ii) > 5*shapes1(i).rmax(ii)
                        disp(['   Double eddy ',num2str(ii),' too large distance between 2 centers !!!'])
                        mv = 1;
                    end
                    if shapes2(i).aire(ii) < 2*shapes1(i).aire(ii) &&...
                            shapes2(i).rmax(ii) < 5*warn_shapes2(i).Rd(ii) &&...
                            shapes2(i).nrho(ii) < 0.33
                        disp(['   Small double eddies ',num2str(ii),' replace by single eddy !!!'])
                        name = fieldnames(centers2);
                        for n=5:length(name)
                            centers2(i).(name{n})(ii) = NaN;
=======
                        if mv
                            disp(['   Double eddy ',num2str(ii),' weaker than double eddy ',num2str(ind),' !!!'])
>>>>>>> ameda_v2
                        end
                    else
                        % remove shapes2(ii) if calculated
                        %----------------------------------------------------------
                        if warn_shapes2.calcul_curve(ii)==1
                            disp(['   Calculated double eddy ',num2str(ii),' removed  !!!'])
                            mv= 1 ;
                        end
                    end
                end
            % if shapes1(ind) doesn't exist remove shapes2(ii) with centers
            % very far from each ones and record small shapes2 as shapes1
            %----------------------------------------------------------
            else
                if centers2.dc(ii) > dc_max*shapes1.rmax(ii)
                    disp(['   Double eddy ',num2str(ii),' too large distance between 2 centers !!!'])
                    mv = 1;
                end
                if shapes2.aire(ii) < aire_max*shapes1.aire(ii) &&...
                        shapes2.rmax(ii) < R_lim &&...
                        shapes2.nrho(ii) < nrho_lim
                    disp(['   Small double eddies ',num2str(ii),' replace by single eddy !!!'])
                    names = fieldnames(centers2);
                    for n=5:length(names)
                        centers2.(names{n})(ii) = NaN;
                    end
                    names = fieldnames(shapes2);
                    for n=2:length(names)
                        shapes1.(names{n})(ii) = shapes2.(names{n})(ii);
                    end
                    warn_shapes2.large_curve1(ii) = warn_shapes2.large_curve2(ii);
                    mv = 1;
                end
            end

            % then remove shapes2 too big or mistaken as explain above
            %----------------------------------------------------------
            if mv
                shapes2.xy{ii} = NaN;
                names = fieldnames(shapes2);
                for n=3:length(names)
                    shapes2.(names{n})(ii) = NaN;
                end
                warn_shapes2.too_large2(ii) = 1;
            end
        end
    end

    disp(' ')

<<<<<<< HEAD
if streamlines
    save([path_out,'eddy_shapes',runname],'shapes1','shapes2','warn_shapes','warn_shapes2','profil2')
else
    save([path_out,'eddy_shapes',runname],'shapes1','shapes2','warn_shapes','warn_shapes2')
end

% close log file
diary off

=======
end

>>>>>>> ameda_v2
