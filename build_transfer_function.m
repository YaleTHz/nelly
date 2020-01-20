function [func, prop_func, tran_func, fabr_func] = build_transfer_function(geom, M)

%% propagation part of transfer function
c = physconst('LightSpeed')*1e6; %um/s
prop = @(freq, d, n) exp(-1i*(2*pi*freq*1e12/c)*n*d);
tr = @(n1, n2) 2*n1/(n1+n2);
rf = @(n1, n2) (n1-n2)/(n1+n2);
fp = @(freq, d, n0, n1, n2) prop(freq, d, n1)^2*rf(n1, n2)*rf(n1, n0);

prop_func = @(freq, n_solve) prod(arrayfun(@(m) prop(freq, m.n_func(freq, n_solve),m.d),geom));
tran_func = @(freq, n_solve) tran(freq, n_solve);
fabr_func = @(freq, n_solve) fabr(freq, n_solve);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% transfer %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
func = @(freq, n_solve) tran(freq, n_solve)*...
    fabr(freq, n_solve)*...
    prop_func(freq, n_solve);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% transfer %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % tranmission at the interfaces between layers
    function [t] = tran(freq, n_solve)
        t = 1;
        for ind = 1:numel(geom)-1
            n_j = geom(ind).n_func(freq, n_solve);
            n_k = geom(ind+1).n_func(freq, n_solve);
            t = t*tr(n_j, n_k);
        end
    end

    % fabry-perot reflection terms
    function [coeff] = fabr(freq, n_solve)
        coeff = 1;
        for ind = 2:numel(geom)-1
            %@(freq, d, n0, n1, n2)
            n0 = geom(ind-1).n_func(freq, n_solve);
            n1 = geom(ind  ).n_func(freq, n_solve);
            n2 = geom(ind+1).n_func(freq, n_solve);
            d =  geom(ind  ).d;
            fp_single = fp(freq, d, n0, n1, n2);
                        
            % determine number of reflections 
            % maybe change this to get parameters (t_cut, a_cut) from
            % input? Or automatically read get t_cut from input?
            
            % based on time: include reflections until they would be 
            % separated from the main pulse by t_cut picoseconds
            
            t_refl = 1e12*2*d*real(n1)/c; t_cut = 40;
            m_time = floor(t_cut/t_refl);
            
            % based on amplitude: include reflections until their
            % amplitude if neglible.
            a_cut = 1e-5;
            m_amp = round(log(a_cut)/log(abs(fp_single)));
            
            min([m_time m_amp]);
            %m = 0:min([m_time m_amp]);
            m = [0];
            coeff = coeff*sum(fp_single.^m);
        end
    end
end