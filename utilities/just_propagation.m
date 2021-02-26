function [freq, ref_index, phase] = just_propagation(freq, tf_spec, d, varargin)
    assert(mod(numel(varargin), 2) == 0, 'Extra parameters must come in pairs')
    
    n_off = 1;
    if numel(varargin) > 0
        if strcmp(varargin{1}, 'n_off')
            assert(isnumeric(varargin{2}), 'n_off must be a number')
            n_off = varargin{2};
        end
    end
    
    phase = unwrap(angle(tf_spec));
    p = fit(freq(:), phase(:), 'poly1');
    phase = phase - 2*pi*round(abs(p.p2)/(2*pi));
    k = 2*pi*1e12*freq./3e8;
    n = n_off - (phase./(d*1e-6*k));
    k_ = -log(abs(tf_spec))./(d*1e-6*k);
    ref_index = n + 1i*k_;
end