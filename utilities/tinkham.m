function [cond] = tinkham(tf_spec, d, nn)
Z0 = 367.7;  %ohms
cond = conj(((nn+1)/(Z0*d*1e-6))*((1./(tf_spec))-1));