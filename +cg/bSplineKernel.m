function k = bSplineKernel( step , order)
% function returns 1D B-spline kernel of given order 'order' for a given sampling 'step'
% default order is 3.

switch nargin
    case 0
        error('bSplineKernel invalid input parameters');
    case 1
        order=3;
end

step=double(uint16(abs(step(1))));
order=uint8(order(1));
eps=1e-6;

switch order
case 0
    x=0:1/step:0.5;
    k0r=1+0.*x; %ones(size(0:dx:0.5));
    k0r(x==0.5)=0.5;
    k =[ fliplr(k0r) k0r(2:end) ];
    
case 1
    k1r=1:-1/step:eps;
    k=[ fliplr(k1r) k1r(2:end) ];
  
case 2
    x=0:1/step:0.5;
    k0r=1+0.*x; %ones(size(0:dx:0.5));
    k0r(x==0.5)=0.5;
    k0=[ fliplr(k0r) k0r(2:end) ];
    k1r=1:-1/step:eps;
    k1=[ fliplr(k1r) k1r(2:end) ];
    k=conv(k0,k1);
    
otherwise %case 3
    x=0:1/step:2-eps;
    yf1=(3*x.^3-6*x.^2+4)/6;
    yf2=(2-x).^3/6;
    yf1(x>1)=yf2(x>1);
    k=[ fliplr(yf1) yf1(2:end) ];
  
end

k=single(k);
clear eps;
end
    
