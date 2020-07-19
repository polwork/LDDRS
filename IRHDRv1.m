function I = IRHDRv1(Ib)
l = round(min(min(Ib)));
r = round(max(max(Ib)));
H = zeros(1,r);
B = H;
[m,n] = size(Ib);
for i = 1:m
    for j = 1:n
        H(round(Ib(i,j))) = H(round(Ib(i,j)))+1;
    end
end
H(H<2) = 0;
H(H>=2) = 1;
nv = sum(H);
SH = 0;
for i = l:r
    SH = SH + H(i-1);
    B(i) = SH/nv;
end
for i = 1:m
    for j = 1:n
        Ib(i,j) = 255*B(round(Ib(i,j)));
    end
end
Ib = double(Ib);
g = 2;
w = 1/8*[-g -g -g;
    -g 8*(1+g) -g;
    -g -g -g];
I = uint8(imfilter(Ib,w,'replicate'));
end