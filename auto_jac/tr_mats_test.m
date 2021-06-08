tr = node_constants.tr;

nj = (1+2*rand) + 1i*rand;
nk = (1+2*rand) + 1i*rand;

njr = real(nj);
nji = imag(nj);
nkr = real(nk);
nki = imag(nk);

[tr_njr, tr_nji] = d_mat_tr(nj, nk, 'j');


[tr_nkr, tr_nki] = d_mat_tr(nj, nk, 'k');

%% dtr/dnj plots
njrs = [-1.5e-2:1e-3:1.5e-2] + nj;
njis = 1i*[-1.5e-2:1e-3:1.5e-2] + nj;

nkrs = [-1.5e-2:1e-3:1.5e-2] + nk;
nkis = 1i*[-1.5e-2:1e-3:1.5e-2] + nk;



figure(1)
f_nj = @(x) tr(x, nk);
test_jacobian(f_nj, real(nj), imag(nj), ...
    real(njrs), imag(njis), [tr_njr(:,1), tr_nji(:,1)])


figure(2)
f_nk = @(x) tr(nj, x);
test_jacobian(f_nk, real(nk), imag(nk),...
    real(nkrs), imag(nkis), [tr_nkr(:,1), tr_nki(:,1)])
