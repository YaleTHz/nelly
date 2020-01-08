%% check propagation and transmission portion of transfer function for two layer sample
[f1, f2] = twoLayerStaticTranProp(100, 1.5, 150, 2);
freq = 0.2:0.01:2;
n1 = f1(freq);
n2 = arrayfun(@(f) f2(f,0), freq);
assert(norm(n2-n1)/min([norm(n1), norm(n2)]) < 1e-5, ...
    'Function from build_transfer function does not match analytical expression (propagation + transmission)')

%% check fabry-perot term of transfer function for single layer sample
d = 5; n = 2;
[fp_ana, fp_blt] = oneLayerFP(d, n);

freq = 0.2:0.01:2.2;
n_blt = arrayfun(@(f) fp_blt(f,0), freq);

% check for a range of reflections, assuming a delay of no more than 10 ps
% is tolerated
t_max = 10; m_max = 3e8*1e6*t_max*1e-12/(2*d*n);
min_error = Inf;
for m = 0:m_max
    n_ana = arrayfun(@(f) fp_ana(f, m), freq);
    err = norm(n_ana-n_blt)/min([norm(n_ana) norm(n_blt)]);
    min_error = min([min_error, err]); 
end
assert(min_error < 1e-5,...
    'Incorrect fabry-perot term in transfer function for single-layer sample');

function [func_an, func_built] = twoLayerStaticTranProp(d1, n1, d2, n2)
c = physconst('LightSpeed')*1e-6;
func_an =  @(freq) exp(-1i*(d1*n1+d2*n2)*freq*2*pi/c)*...
    (2/(n1+1))*(2*n1/(n1+n2))*(2*n2/(n2+1));

layers = {struct('d', 0, 'n', 1, 'n_func', @(x,y) 1),...
          struct('d', d1, 'n', n1, 'n_func', @(x,y) n1),...
          struct('d', d2, 'n', n2, 'n_func', @(x,y) n2),...
          struct('d', 0, 'n', 1, 'n_func', @(x,y) 1)};

[~, func_prop, func_tran] = build_transfer_function(layers);
func_built = @(f, n_solve) func_prop(f, n_solve)*func_tran(f, n_solve); 
end

function [fp_ana, fp_blt] = oneLayerFP(d, n)
c = physconst('LightSpeed')*1e-6;

r10 = (n-1)/(1+n); 
r12 = (n-1)/(1+n);

fp = @(freq) 1*exp(-(2*1i*d*n*freq*2*pi/c))*r10*r12;
fp_ana = @(freq, m) sum(fp(freq).^(0:m));

layers = {struct('d', 0, 'n', 1, 'n_func', @(x,y) 1),...
          struct('d', d, 'n', n, 'n_func', @(x,y) n),...
          struct('d', 0, 'n', 1, 'n_func', @(x,y) 1)};
[~, ~, ~, fp_blt] = build_transfer_function(layers);
end

