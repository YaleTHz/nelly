function [cond] = tinkham(tf_spec, d, nn)
% TINKHAM(tf_spec, d, n) extracts the photoconductivity from the given transfer function
%
% Arguments: tf_spec -- an array containing the transfer function
%                      (E_smp/E_ref)
%            d       -- the thickness of the conductive layer (in microns)
%            nn      -- the refractive index of the non photoexcited or
%                       substrate material
Z0 = 367.7;  %ohms
cond = conj(((nn+1)/(Z0*d*1e-6))*((1./(tf_spec))-1));