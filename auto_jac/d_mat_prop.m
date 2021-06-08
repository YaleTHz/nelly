function [dm_re, dm_im] = d_mat_prop(freq, d, tf)  


mat = [real(tf) -imag(tf); imag(tf) real(tf)];


c = 299792458*1e6; %um/s
k_0 = 2*pi*freq*1e12/c;

dm_im = k_0*d*mat;

dm_re = k_0*d*[imag(tf) real(tf);...
    -real(tf) imag(tf)];