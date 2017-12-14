function [l_oi, r_oi] = recipe2oi(thisR, from, to, up, d_stereo_vec, lens_option)

% TO THINK HOW TO CHANGE THIS PARAMETER
% thisR.set('focaldistance', 3);
switch lens_option
    case 2
        thisR.set('lensFile','/Users/Anqi/git_repo/pbrt2ISET/data/lens/wide.40deg.3.0mm.dat');
    case 3
        thisR.set('lensFile','dgauss.22deg.3.0mm.dat');
end

% Set the camera location
thisR.set('from', from);
thisR.set('to',to); % VERIFY THIS! THIS IS BY ASSUMING CHECKERBOARD AT ORIGIN!!
thisR.set('up',up);
left_thisR = thisR.copy;
right_thisR = thisR.copy;

% Get position of left and right camera in world coordinates
[R,~,~] = calc_extrinsic_params(to,from,up);
pos1 = [(d_stereo_vec/2)'; 1];
pos2 = [(-d_stereo_vec/2)'; 1];
right_pos = inv(R) * pos1;
left_pos = inv(R) * pos2;
right_pos = right_pos(1:3,1)';
left_pos = left_pos(1:3,1)';
% Set the distances between two cameras, we also want to varify this parameters
right_thisR.set('from',right_pos);
left_thisR.set('from',left_pos);

% Write out the recipe for left camera and show it in ISET
new_fname_left = fullfile(piRootPath,'local','output','Checkerboard_left.pbrt');
left_thisR.outputFile = new_fname_left;
piWrite(left_thisR);
l_oi = piRender(left_thisR);
vcAddObject(l_oi);
oiWindow; %oiSet(left_ieObject,'gamma',0.5);

% Write out the recipe for right camera and show it in ISET
new_fname_right = fullfile(piRootPath,'local','output','Checkerboard_right.pbrt');
right_thisR.outputFile = new_fname_right;
piWrite(right_thisR);
r_oi = piRender(right_thisR);
vcAddObject(r_oi); oiWindow; % oiSet(right_ieObject,'gamma',0.5);
end