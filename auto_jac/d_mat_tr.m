% the elementwise derivative of the matrix corresponding to a 
% Fresnel transmission coefficient between layers with 
% refractive indices nj and nk. The jork argument specifies whether
% the derivative is taken with respect to nj or nk
function [dm_re, dm_im] = d_mat_tr(nj, nk, jork)

njr = real(nj);
nji = imag(nj);
nkr = real(nk);
nki = imag(nk);

assert(strcmp(jork, 'j') | strcmp(jork, 'k'), ...
    'jork argument must be either j or k')

A = diag([1/abs(nj+nk)^2 1/abs(nj+nk)^2]);
B = [real(nj+nk) imag(nj+nk);
    -imag(nj+nk) real(nj+nk)];
C = [njr -nji; nji njr];

A_njr = diag([-2*real(nj+nk)/abs(nj+nk)^4 -2*real(nj+nk)/abs(nj+nk)^4]);

A_nji = diag([-2*imag(nj+nk)/abs(nj+nk)^4 -2*imag(nj+nk)/abs(nj+nk)^4]);
B_nji = [0 1; -1 0];
C_nji = [0 -1; 1 0];

if strcmp(jork, 'j')
    dm_re = 2*(A_njr*B*C + A*(B+C));
    dm_im = 2*(A_nji*B*C + A*B_nji*C + A*B*C_nji);
    return
end

if strcmp(jork, 'k')
    A_nkr = A_njr;
    
    A_nki = A_nji;
    B_nki = B_nji;
    
    dm_re = 2*(A_nkr*B*C  + A*C);
    dm_im = 2*(A_nki*B*C + A*B_nki*C);
    return
end
end