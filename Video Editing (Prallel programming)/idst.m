function b=idst(a,n)
%
% IDST - INVERSE DISCRETE SINE TRANSFORM (USED IN POISSON RECONSTRUCTION)
%
% SYNTAX
%
%   B = IDST (A, N)
%
% INPUT
%
%   A        MATRIX OR VECTOR IN FOURIER SPACE                         
%   N        LENGTH                                    
%
% OUTPUT
%
%   B        NEW MATRIX OR VECTOR IN REGULAR SPACE                                 
%
% DESCRIPTION
%
%   X = IDST(Y) inverts the DST transform, returning the
%   original vector if Y was obtained using Y = DST(X).
%
%   X = IDST(Y,N) pads or truncates the vector Y to length N
%   before transforming.
%
%

if nargin==1
 if min(size(a))==1
 n=length(a);
 else
 n=size(a,1);
 end
end

nn=n+1; 
b=2/nn*dst(a,n); 

return

%% Programmer(s) 
% Original code by Prof. Ramesh Raskar at MIT
%
% 2nd Revision by Fang Liu, Yue Zhang
% 04/21/2016
%
% 3rd Revision by Zekun Cao, Qiwei Han 
% 04/03/2017