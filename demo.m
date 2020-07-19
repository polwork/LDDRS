%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a demo code for basic pre-processing of DoFP image, including denoising, 
% demosaicking and calculating Stokes parameters.
% 
% [1] Li, N., Zhao, Y., Pan, Q., Kong, S.G., J.C.W., "Full-Time Monocular Road Detection 
% Using Zero-Distribution Prior of Angle of Polarization" ECCV, 2020.
%
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
i = 255; % i=1:2113
filename = ['.\RAW\',num2str(i),'.png'];
I = double(imread(filename));
figure;imshow(I,[]) % display raw DoFP image
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
s0 = 0.5*(I0 + I90 + I45 + I135);
s1 = I0 - I90;
s2 = I45 - I135;
dolp = (sqrt(s1.*s1 + s2.*s2))./s0;
dolp(dolp>1) = 1;
dolp(dolp<0) = 0;
aop = (1/2) * atan2(s2,s1)*180/pi;
% display S0, DoP and AoP
S0 = IRHDRv1(s0); % HDR correction of the S0 image
figure;imshow(S0,[]);
figure;imshow(dolp,[]);colormap Parula;colorbar
figure;imshow(aop,[]);colormap HSV;colorbar
%% load label of road and display the road region in green color
filename2 = ['.\label\',num2str(i),'.png'];
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
