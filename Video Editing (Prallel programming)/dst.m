function b=dst(a,n)
%
% DST - DISCRETE SINE TRANSFORM (USED IN POISSON RECONSTRUCTION)
%
% SYNTAX
%
%   B = DST (A, N)
%
% INPUT
%
%   A        MATRIX OR VECTOR                            
%   N        LENGTH                                    
%
% OUTPUT
%
%   B        NEW MATRIX OR VECTOR IN FOURIER SPACE                                 
%
% DESCRIPTION
%
%   Y = DST(X) returns the discrete sine transform of X.
%
%   Y = DST(X,N) pads or truncates the vector X to length N
%   before transforming.
%
%
error(nargchk(1,2,nargin));

if min(size(a))==1
 if size(a,2)>1
 do_trans = 1;
 else
 do_trans = 0;
 end
 a = a(:);
else
 do_trans = 0;
end

if nargin==1, n = size(a,1); 
end

m = size(a,2);

% Pad or truncate a if necessary
if size(a,1)<n,
 aa = zeros(n,m); 
 aa(1:size(a,1),:) = a;
else
 aa = a(1:n,:);
end

y=zeros(2*(n+1),m,'gpuArray'); 
y(2:n+1,:)=aa; 
y(n+3:2*(n+1),:)=-flipud(aa);
yy=fft(y); 
b=yy(2:n+1,:)/(-2*sqrt(-1));

if isreal(a), b = real(b); end

if do_trans, b = b.'; end 

return

%% Programmer(s) 
% Original code by Prof. Ramesh Raskar at MIT
%
%
% 2nd Revision by Fang Liu, Yue Zhang
% 04/21/2016
%
% 3rd Revision by Zekun Cao, Qiwei Han 
% 04/03/2017
% 