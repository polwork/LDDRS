function [I0,I45,I90,I135] = FFC_Polynomial_interpolation(I)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a demosaicking algorithm [1] for recovering four high resolution polarization image from
% an input DoFP image.
%
% [1] Li, N., Zhao, Y., Pan, Q., Kong, S.G.: Demosaicking DoFP images using Newton's polynomial 
%     interpolation and polarization difference model. Optics Express 27(2), 1376¨C1391 (2019)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Copyright (c) Northwestern Polytechnical University.                    %
%                                                                         %
% All rights reserved.                                                    %
% This work should only be used for nonprofit purposes.                   %
%                                                                         %
% AUTHORS:                                                                %
%     Ning Li, Yongqiang Zhao, Quan Pan, Seong G. Kong                    %                                            %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I = padarray(I,[6 6],'replicate','both');
[m,n] = size(I);
R = zeros(m,n,4);
O = zeros(m,n);
O(1:2:m,1:2:n) = 1;
O(1:2:m,2:2:n) = 2;
O(2:2:m,2:2:n) = 3;
O(2:2:m,1:2:n) = 4;
Y1 = I;
Y2 = I;
R(:,:,1) = I;
R(:,:,2) = I;
R(:,:,3) = I;
R(:,:,4) = I;
% parpool open 2
for i = 4:m-3
    for j = 4:n-3
        R(i,j,O(i,j)) = I(i,j);
        R(i,j,O(i,j+1)) = 0.5*I(i,j) + 0.0625*I(i,j-3) - 0.25*I(i,j-2) + 0.4375*I(i,j-1) + 0.4375*I(i,j+1) - 0.25*I(i,j+2) + 0.0625*I(i,j+3);
        R(i,j,O(i+1,j)) = 0.5*I(i,j) + 0.0625*I(i-3,j) - 0.25*I(i-2,j) + 0.4375*I(i-1,j) + 0.4375*I(i+1,j) - 0.25*I(i+2,j) + 0.0625*I(i+3,j);
        Y1(i,j) = 0.5*I(i,j) + 0.0625*I(i-3,j-3) - 0.25*I(i-2,j-2) + 0.4375*I(i-1,j-1) + 0.4375*I(i+1,j+1) - 0.25*I(i+2,j+2) + 0.0625*I(i+3,j+3);
        Y2(i,j) = 0.5*I(i,j) + 0.0625*I(i-3,j+3) - 0.25*I(i-2,j+2) + 0.4375*I(i-1,j+1) + 0.4375*I(i+1,j-1) - 0.25*I(i+2,j-2) + 0.0625*I(i+3,j-3);
%         Y1(i,j) = 0.5*I(i,j) + I(i-3,j-3)/24 - 0.25*I(i-2,j-2) + 11*I(i-1,j-1)/24 + 11*I(i+1,j+1)/24 - 0.25*I(i+2,j+2) + I(i+3,j+3)/24;
%         Y2(i,j) = 0.5*I(i,j) + I(i-3,j+3)/24 - 0.25*I(i-2,j+2) + 11*I(i-1,j+1)/24 + 11*I(i+1,j-1)/24 - 0.25*I(i+2,j-2) + I(i+3,j-3)/24;
    end
end

% mask = [1 0 1 0 1;0 0 0 0 0;1 0 1 0 1;0 0 0 0 0;1 0 1 0 1];

thao = 5.8;%4.8 8.8 5.8
for i = 4:m-3
    for j = 4:n-3
        pha1 = 0;
%         pha1 = sum(sum(abs((Y1(i-2:i+2,j-2:j+2) - I(i-2:i+2,j-2:j+2)).*mask)));
        for k = -2:2:2
            for l = -2:2:2
                pha1 = pha1 + abs(Y1(i+k,j+l) - I(i+k,j+l));
            end
        end
        pha2 = 0;
%         pha2 = sum(sum(abs((Y2(i-2:i+2,j-2:j+2) - I(i-2:i+2,j-2:j+2)).*mask)));
        for k = -2:2:2
            for l = -2:2:2
                pha2 = pha2 + abs(Y2(i+k,j+l) - I(i+k,j+l));
            end
        end
        if (pha1/pha2)>thao
            R(i,j,O(i+1,j+1)) = Y2(i,j);
        end
        if (pha2/pha1)>thao
            R(i,j,O(i+1,j+1)) = Y1(i,j);
        end
        if ((pha1/pha2)<thao)&&((pha2/pha1)<thao)
            d1 = abs(I(i-1,j-1) - I(i+1,j+1)) + abs(2*I(i,j) -I(i-2,j-2) - I(i+2,j+2));
            d2 = abs(I(i+1,j-1) - I(i-1,j+1)) + abs(2*I(i,j) -I(i+2,j-2) - I(i-2,j+2));
            epsl = 0.000000000000001;
            w1 = 1/(d1 + epsl);
            w2 = 1/(d2 + epsl);
            R(i,j,O(i+1,j+1)) = (w1*Y1(i,j) + w2*Y2(i,j))/(w1 + w2);
        end
    end
end

RR = R;

% toc

XX1 = I;
XX2 = I;
YY1 = I;
YY2 = I;
for i = 4:m-3
    for j = 4:n-3
        XX1(i,j) = R(i,j,O(i,j+1));
        XX2(i,j) = 0.5*I(i,j) + 0.0625*R(i-3,j,O(i,j+1)) - 0.25*I(i-2,j) + 0.4375*R(i-1,j,O(i,j+1)) + 0.4375*R(i+1,j,O(i,j+1)) - 0.25*I(i+2,j) + 0.0625*R(i+3,j,O(i,j+1));
        YY1(i,j) = R(i,j,O(i+1,j));
        YY2(i,j) = 0.5*I(i,j) + 0.0625*R(i,j-3,O(i+1,j)) - 0.25*I(i,j-2) + 0.4375*R(i,j-1,O(i+1,j)) + 0.4375*R(i,j+1,O(i+1,j)) - 0.25*I(i,j+2) + 0.0625*R(i,j+3,O(i+1,j));
    end
end

for i = 4:m-3
    for j = 4:n-3
        pha1 = 0;
%         pha1 = sum(sum(abs((XX1(i-2:i+2,j-2:j+2) - I(i-2:i+2,j-2:j+2)).*mask)));
        for k = -2:2:2
            for l = -2:2:2
                pha1 = pha1 + abs(XX1(i+k,j+l) - I(i+k,j+l));
            end
        end
        pha2 = 0;
%         pha2 = sum(sum(abs((XX2(i-2:i+2,j-2:j+2) - I(i-2:i+2,j-2:j+2)).*mask)));
        for k = -2:2:2
            for l = -2:2:2
                pha2 = pha2 + abs(XX2(i+k,j+l) - I(i+k,j+l));
            end
        end
        if (pha1/pha2)>thao
            RR(i,j,O(i,j+1)) = XX2(i,j);
        end
        if (pha2/pha1)>thao
            RR(i,j,O(i,j+1)) = XX1(i,j);
        end
        if ((pha1/pha2)<thao)&&((pha2/pha1)<thao)
            d1 = abs(I(i,j-1) - I(i,j+1)) + abs(2*I(i,j) -I(i,j-2) - I(i,j+2));
            d2 = abs(I(i+1,j) - I(i-1,j)) + abs(2*I(i,j) -I(i+2,j) - I(i-2,j));
            epsl = 0.000000000000001;
            w1 = 1/(d1 + epsl);
            w2 = 1/(d2 + epsl);
            RR(i,j,O(i,j+1)) = (w1*XX1(i,j) + w2*XX2(i,j))/(w1 + w2);
        end
        pha1 = 0;
%         pha1 = sum(sum(abs((YY1(i-2:i+2,j-2:j+2) - I(i-2:i+2,j-2:j+2)).*mask)));
        for k = -2:2:2
            for l = -2:2:2
                pha1 = pha1 + abs(YY1(i+k,j+l) - I(i+k,j+l));
            end
        end
        pha2 = 0;
%         pha2 = sum(sum(abs((YY2(i-2:i+2,j-2:j+2) - I(i-2:i+2,j-2:j+2)).*mask)));
        for k = -2:2:2
            for l = -2:2:2
                pha2 = pha2 + abs(YY2(i+k,j+l) - I(i+k,j+l));
            end
        end
        if (pha1/pha2)>thao
            RR(i,j,O(i+1,j)) = YY2(i,j);
        end
        if (pha2/pha1)>thao
            RR(i,j,O(i+1,j)) = YY1(i,j);
        end
        if ((pha1/pha2)<thao)&&((pha2/pha1)<thao)
            d1 = abs(I(i,j-1) - I(i,j+1)) + abs(2*I(i,j) -I(i,j-2) - I(i,j+2));
            d2 = abs(I(i+1,j) - I(i-1,j)) + abs(2*I(i,j) -I(i+2,j) - I(i-2,j));
            epsl = 0.000000000000001;
            w1 = 1/(d1 + epsl);
            w2 = 1/(d2 + epsl);
            RR(i,j,O(i+1,j)) = (w1*YY2(i,j) + w2*YY1(i,j))/(w1 + w2);
        end
    end
end
R = RR;
I0 = R(7:m-6,7:n-6,3);
I45 = R(7:m-6,7:n-6,4);
I90 = R(7:m-6,7:n-6,1);
I135 = R(7:m-6,7:n-6,2);
end