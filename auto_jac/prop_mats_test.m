prop = node_constants.prop;

nj = (1+2*rand) + 1i*rand;

njrs = [-1e-2:2e-3:1e-2] + real(nj);
njis = [-1e-2:2e-3:1e-2] + imag(nj);


freq = 0.5;
d = 1;
tf = prop(freq, d, nj);

[d_prop_re, d_prop_im] = d_mat_prop(freq, d, tf);
f = @(n) prop(freq, d, n);

test_jacobian(f, real(nj), imag(nj), njrs, njis,...
    [d_prop_re(:,1) d_prop_im(:,1)])

