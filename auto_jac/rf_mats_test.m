rf = node_constants.rf;

nj = (1+2*rand) + 1i*rand;
nk = (1+2*rand) + 1i*rand;

njr = real(nj);
nji = imag(nj);
nkr = real(nk);
nki = imag(nk);

A = diag([1/abs(nj+nk)^2 1/abs(nj+nk)^2]);
B = [real(nj+nk) imag(nj+nk); 
    -imag(nj+nk) real(nj+nk)];
C = [real(nj-nk) -imag(nj-nk); 
    imag(nj-nk) real(nj-nk)];


[rf_njr, rf_nji] = d_mat_rf(nj, nk, 'j');
[rf_nkr, rf_nki] = d_mat_rf(nj, nk, 'k');

njrs = [-1.5e-2:1e-3:1.5e-2] + real(nj);
njis = [-1.5e-2:1e-3:1.5e-2] + imag(nj);
nkrs = [-1.5e-2:1e-3:1.5e-2] + real(nk);
nkis = [-1.5e-2:1e-3:1.5e-2] + imag(nk);

figure()
f_nj = @(x) rf(x, nk);
test_jacobian(f_nj, real(nj), imag(nj),...
    njrs, njis, [rf_njr(:,1), rf_nji(:,1)])

figure()
f_nk = @(x) rf(nj, x);
test_jacobian(f_nk, real(nk), imag(nk), ...
    nkrs, nkis, [rf_nkr(:,1), rf_nki(:,1)])

%% test inverse
figure()
M = A*B*C;
f_nj_i = @(x) 1/rf(x, nk);
rf_njr_i = -inv(M)*rf_njr*inv(M);
rf_nji_i = -inv(M)*rf_nji*inv(M);

test_jacobian(f_nj_i, real(nj), imag(nj),...
    njrs, njis, [rf_njr_i(:,1), rf_nji_i(:,1)])


figure()
M = A*B*C;
f_nk_i = @(x) 1/rf(nj, x);
rf_nkr_i = -inv(M)*rf_nkr*inv(M);
rf_nki_i = -inv(M)*rf_nki*inv(M);

test_jacobian(f_nk_i, real(nk), imag(nk),...
    nkrs, nkis, [rf_nkr_i(:,1), rf_nki_i(:,1)])