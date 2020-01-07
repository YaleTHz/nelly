function [func, prop_func, tran_func] = build_transfer_function(geom)

%% propagation part of transfer function
c = physconst('LightSpeed')*1e6; %um/s
prop = @(freq, d, n) exp(-1i*(2*pi*freq*1e12/c)*n*d);
tr = @(n1, n2) 2*n1/(n1+n2);
rf = @(n1, n2) (n1-n2)/(n1+n2);
fp = @(freq, d, n0, n1, n2) prop(freq, d, n1)^2*rf(n1, n2)*rf(n1, n0);

prop_func = @(freq, n_solve) prod(cellfun(@(m) prop(freq, m.n_func(freq, n_solve),m.d),geom));
tran_func = @(freq, n_solve) tran(freq, n_solve);

func = @(freq, n_solve) tran(freq, n_solve)*...
    prod(cellfun(@(m) prop(freq, m.n_func(freq, n_solve),m.d),...
    geom));

    function [t] = tran(freq, n_solve)
        t = 1;
        % tranmission at the interfaces between layers
        for ind = 1:numel(geom)-1
            n_j = geom{ind}.n_func(freq, n_solve);
            n_k = geom{ind+1}.n_func(freq, n_solve);
            t = t*tr(n_j, n_k);
        end
    end
end