function [func, prop_func, tran_func] = build_transfer_function(geom)

%% propagation part of transfer function
c = physconst('LightSpeed')*1e6; %um/s
prop = @(freq, d, n) exp(-1i*(2*pi*freq*1e12/c)*n*d);
prop_func = @(freq, n_solve) prod(cellfun(@(m) prop(freq, m.n_func(freq, n_solve),m.d),geom));

tran_func = @(freq, n_solve) tran(freq, n_solve);

func = @(freq, n_solve) tran(freq, n_solve)*...
    prod(cellfun(@(m) prop(freq, m.n_func(freq, n_solve),m.d),...
    geom));

    function [t] = tran(freq, n_solve)
        % transmission through air interface into first layer of geometry
        n_j = 1;
        n_k = geom{1}.n_func(freq, n_solve);
        t = 2*n_j/(n_j + n_k);
        
        % tranmission at the interfaces between layers
        for ind = 1:numel(geom)-1
            n_j = geom{ind}.n_func(freq, n_solve);
            n_k = geom{ind+1}.n_func(freq, n_solve);
            t = t*2*n_j/(n_j + n_k);
        end
        
        % transmission at interface between final layer and air
        n_j = geom{end}.n_func(freq, n_solve);
        n_k = 1;
        t = t*2*n_j/(n_j + n_k);
    end
end