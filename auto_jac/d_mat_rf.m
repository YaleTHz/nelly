% the elementwise derivative of the matrix corresponding to a 
% Fresnel reflection coefficient between layers with 
% refractive indices nj and nk. The jork argument specifies whether
% the derivative is taken with respect to nj or nk
function [dm_re, dm_im] = d_mat_rf(nj, nk, jork)

njr = real(nj);
nji = imag(nj);
nkr = real(nk);
nki = imag(nk);

A = diag([1/abs(nj+nk)^2 1/abs(nj+nk)^2]);
B = [real(nj+nk) imag(nj+nk); 
    -imag(nj+nk) real(nj+nk)];
C = [real(nj-nk) -imag(nj-nk); 
    imag(nj-nk) real(nj-nk)];

A_njr = diag([-2*real(nj+nk)/abs(nj+nk)^4 -2*real(nj+nk)/abs(nj+nk)^4]);
A_nji = diag([-2*imag(nj+nk)/abs(nj+nk)^4 -2*imag(nj+nk)/abs(nj+nk)^4]);
B_nji = [0 1; -1 0];
C_nji = [0 -1; 1 0];

if strcmp(jork, 'j')
    dm_re = A_njr*B*C + A*C + A*B;
    dm_im = A_nji*B*C + A*B_nji*C + A*B*C_nji;
    return
end

if strcmp(jork, 'k')
    A_nkr = A_njr;    
    A_nki = A_nji;
    B_nki = B_nji;
    C_nki = [0 1; -1 0];
    
    dm_re = A_nkr*B*C + A*C - A*B;
    dm_im = A_nki*B*C + A*B_nki*C + A*B*C_nki;
    return
end
end