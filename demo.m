%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a demo code for basic pre-processing of DoFP image, including denoising, 
% demosaicking and calculating Stokes parameters.
% 
% [1] Li, N., Zhao, Y., Pan, Q., Kong, S.G., J.C.W., "Full-Time Monocular Road Detection 
% Using Zero-Distribution Prior of Angle of Polarization" ECCV, 2020.
%
% [2] Li, N., Zhao, Y., Pan, Q., Kong, S.G., J.C.W., "Illumination-invariant road detection and tracking
% using LWIR polarization characteristics" ISPRS Journal of Photogrammetry and Remote Sensing, 180, 357-369, 2020.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Copyright (c) Northwestern Polytechnical University.                    %
%                                                                         %
% All rights reserved.                                                    %
% This work should only be used for nonprofit purposes.                   %
%                                                                         %
% AUTHORS:                                                                %
%     Ning Li, Yongqiang Zhao, Quan Pan, Seong G. Kong, and               %
%     Jonathan Cheung-Wai Chan                                            %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear all
close all
%% load raw DoFP image
i = 884; % i=1:2113
filename = ['.\RAW\',num2str(i),'.png']; %add the filepath of RAW DoFP images of LDDRS
I = double(imread(filename));
figure;imshow(I,[]);title('Raw DoFP image') % display raw DoFP image
%% BM3D denoising
maxI = max(max(I));
minI = min(min(I));
widthI = maxI - minI;
I = (I - minI)/widthI;
[~, Id] = BM3D(1, I, 1.2, 'lc', 0);
Id = Id*widthI + minI;
%% Polarization demosaicking
[I0,I45,I90,I135] = FFC_Polynomial_interpolation(Id);
%% Calculate the Stokes parameters,DoP and AoP
[s0, s1, s2] = polar_calibration(I0,I45,I90,I135); % polar calibration
dolp = (sqrt(s1.*s1 + s2.*s2))./s0;
aop = (1/2) * atan2(s2,s1)*180/pi;
% display S0, DoP and AoP
S0 = IRHDRv1(s0); % HDR correction of the S0 image
figure;imshow(S0,[]);title('S_0^{HDR}')
figure;imshow(dolp,[]);colormap Parula;colorbar;title('DoLP')
figure;imshow(aop,[]);colormap HSV;colorbar;title('AoP')
%% load label of road and display the road region in green color
filename2 = ['.\label\',num2str(i),'.png'];%add the filepath of label images of LDDRS
L = imread(filename2);
S0Pc(:,:,1) = S0;
S0Pc(:,:,2) = S0;
S0Pc(:,:,3) = S0;
for x = 1:512
    for y = 1:640
        if L(x,y)==1
            S0Pc(x,y,2) = floor(1.1*double(S0Pc(x,y,1)));
            S0Pc(x,y,1) = 0;
            S0Pc(x,y,3) = 0;
        end
    end
end
figure
imshow(S0Pc)
title('Road region')