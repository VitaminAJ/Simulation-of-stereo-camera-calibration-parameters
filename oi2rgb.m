% this function takes in an optical image, passes it through the image processing
% pipeline and outputs an rgb image
function rgb = oi2rgb(oi, lensFocalLength, apertureDiameter, filmDiag)
illum = 15;
oi = oiAdjustIlluminance(oi,illum);

oi = oiSet(oi, 'optics focal length', lensFocalLength * 1e-3);
oi = oiSet(oi,'optics fnumber',lensFocalLength/apertureDiameter);

% Compute the horizontal field of view
photons = oiGet(oi, 'photons');
x = size(photons,2);
y = size(photons,1);
d = sqrt(x.^2 + y.^2);  % Number of samples along the diagonal
fwidth= (filmDiag / d) * x;    % Diagonal size by d gives us mm per step
%fov = 2 * atan2d(fwidth / 2, lensFocalLength);
fov = 15;

% Store the horizontal field of view in degrees in the oi
oi = oiSet(oi, 'fov', fov);

% You should double check the dimension of the OI here so that it matches 
% what we set in the recipe. 
vcAddObject(oi); 
oiWindow;

%% Sensor Part: How to export pngs...? something like ipGet
% Create a sensor in which each pixel is aligned with a single sample in
% the OI.  Then produce the sensor data (which will include color filters)
% sampleSpacing = oiGet(oi,'sample spacing','m');
sensor = sensorCreate;
 
% We assume the sensor sampling is the same as the oi sampling
sensor = sensorSet(sensor,'size',oiGet(oi,'size'));
 
% Set auto-exposure
sensor = sensorSet(sensor,'auto Exposure',true);
% sensor = sensorSet(sensor,'exp time',1/250); % in seconds
 
% fov = sensorGet(sensor,'fov')
 
sensor = sensorCompute(sensor,oi);
exposureTime = sensorGet(sensor,'exp time');
fprintf('Exposure Time is 1/%0.2f s \n',1/exposureTime);
 
% Display the sensor data
% You should double check the dimension of the sensor here!
vcAddObject(sensor); 
sensorWindow;
 
%% Interpolate the color filter data to produce a full sensor
 
ip = ipCreate;
ip = ipSet(ip,'demosaic method','bilinear');
ip = ipSet(ip,'correction method illuminant','none');
 
ip = ipCompute(ip,sensor); 
vcAddObject(ip); 
ipWindow;
rgb = ipGet(ip, 'data srgb');
imshow(rgb);
end