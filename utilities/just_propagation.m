function [freq, ref_index, phase] = just_propagation(freq, tf_spec, d)
    phase = unwrap(angle(tf_spec));
    p = fit(freq(:), phase(:), 'poly1');
    phase = phase - p.p2;
    k = 2*pi*1e12*freq./3e8;
    n = 1- (phase./(d*1e-6*k));
    k = -log(abs(tf_spec))./(d*1e-6*k);
    ref_index = n + 1i*k;
end