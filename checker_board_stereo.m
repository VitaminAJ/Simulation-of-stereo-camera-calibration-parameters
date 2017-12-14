% This script intends to generate stereo camera images of checkerboard
% scenes using prbt. We will generate pair images with different settings
% of focal length of the camera, different camera locations, different
% distances between the two cameras, and different

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
%% Load in pbrt scene with a square checkerboard with size 500mm x 500mm
% Jedeye Parameters:
% d-stereo - 66 mm
% focal length - 2.1 mm
% aperture dia - 0.91 mm
% We moved it from 380 - 500 mm from the checkerboard by 20mm each time

%dist_cam_y = [-650, -670, -690, -710, - 730, -750];
%dist_cam_x = [0,-60, 60, -120, 120];
dist_cam_x = [-50,50];
dist_cam_y = [-720,-740,-760, -780];
for i=1:size(dist_cam_x,2)
    for j=1:size(dist_cam_y,2)
        fprintf('i : = %d, j = %d\n',i,j);
        fname = fullfile(piRootPath,'local','texturedPlane','texturedPlane_checkerboard.pbrt');

        if ~exist(fname,'file'), error('File not found'); end

        % Read the main scene pbrt file.  Return it as a recipe
        thisR = piRead(fname);

        % open a scene window to make sure the scene is being created properly
        thisR.outputFile = fullfile(piRootPath,'local','output','test.pbrt');
        thisR.set('from', [dist_cam_x(i) dist_cam_y(i) 0]);
        piWrite(thisR);
        [scene,result]= piRender(thisR);
        vcAddAndSelectObject(scene);
        sceneWindow;

        % extract or define parameters
        aperture_size  = 2;
        film_resolution = 256;
        num_rays = 128;
        lens_option = 1;
        d_stereo = 65;
        y_axis = -800;
        from = [dist_cam_x(1,i) dist_cam_y(1,j) 0];
        up = [0 0 1];
        to = [0 0 0];
        d_stereo_vec = [d_stereo 0 0];

        %% Modify the recipe, thisR, to adjust the rendering, using a realistic camera with a fixed focus. Change into different focuses and compare
        thisR.set('camera','realistic');
        film_diag = thisR.camera.filmdiag.value;
        thisR.set('aperture', aperture_size);  % The number of rays should go up with the aperture
        thisR.set('film resolution',film_resolution); % original setup 256
        thisR.set('rays per pixel',num_rays); % original setup 128

        % We need to move the camera far enough away so we get a decent view.
        % objDist = thisR.get('object distance');
        % thisR.set('object distance',3.5*objDist);
        thisR.set('autofocus',true);

        % NOTE1: Here we want to change the focal distance to see how calibration
        % works differently on different focal distances
        % thisR.set('focaldistance', f_d);


        %%  Make stereo images with a camera positioned adjacent to the original
        % First dimension is right-left
        % Second dimension is towards the object.
        % The up direction is specified in lookAt.up
        [l_oi, r_oi] = recipe2oi(thisR, from, to, up, d_stereo_vec, lens_option)

        %% processiImage processing pipeline following t_introduction2ISET.m
        rgb1 = oi2rgb(l_oi, 3, aperture_size, film_diag);
        rgb2 = oi2rgb(r_oi, 3, aperture_size, film_diag); 

        % TO DO: save the left one and the right one different folders
        img_fname_tree = sprintf('img_lens%d_dstereo_%d_dx_%d_dy_%d)', lens_option, d_stereo, dist_cam_x(1,i),dist_cam_y(1,j));
        % save the left eye image
        l_img_fname = strcat(img_fname_tree, '_left.png')
        temp = fullfile(piRootPath, 'scripts', 'left_lens', l_img_fname);
        imwrite(rgb1, temp);

        % save the right eye image
        r_img_fname = strcat(img_fname_tree, '_right.png')
        temp = fullfile(piRootPath, 'scripts', 'right_lens', r_img_fname);
        imwrite(rgb2, temp);

    end
end

