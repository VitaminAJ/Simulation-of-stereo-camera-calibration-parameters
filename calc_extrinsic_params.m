%% Function to calculate the camera rotation and translation
% Pass as parameters the object location, camera location and up vector.
function [R, rot, trans] = calc_extrinsic_params(target, camera, up)
    p = target; C = camera; u = up;
    L = p - C;
    L = L / norm(L);
    s = cross(L,u);
    s = s / norm(s);
    u_prime = cross(s,L);
    rot = [s; u_prime; -L];
    trans = -rot * C';
    R = [rot trans];
    R = [R; [0 0 0 1]];
end