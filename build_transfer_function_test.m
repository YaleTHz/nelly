% check propagation and transmission portion of transfer function
[f1, f2] = twoLayerStaticTranProp(100, 1.5, 150, 2);
freq = 0.2:0.01:2;
n1 = f1(freq);
n2 = arrayfun(@(f) f2(f,0), freq);
assert(norm(n2-n1)/min([norm(n1), norm(n2)]) < 1e-5, ...
    'Function from build_transfer function does not match analytical expression (propagation + transmission)')


function [func_an, func_built] = twoLayerStaticTranProp(d1, n1, d2, n2)
c = physconst('LightSpeed')*1e-6;
func_an =  @(freq) exp(-1i*(d1*n1+d2*n2)*freq*2*pi/c)*...
    (2/(n1+1))*(2*n1/(n1+n2))*(2*n2/(n2+1));

layers = {struct('d', d1, 'n', n1, 'n_func', @(x,y) n1),...
          struct('d', d2, 'n', n2, 'n_func', @(x,y) n2)};

[~, func_prop, func_tran] = build_transfer_function(layers);
func_built = @(f, n_solve) func_prop(f, n_solve)*func_tran(f, n_solve); 
end

