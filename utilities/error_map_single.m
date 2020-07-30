function [data] = error_map_single(func, freq, tf_exp, n, k)
data = zeros(numel(k), numel(n));

for nn = 1:numel(n)
    for kk = 1:numel(k)
        tf_theory = func(n(nn), k(kk));
    end
end     
        
function [chi] = n_error(t1, t2)

chi1 = (log(abs(t1)) - log(abs(t2)))^2;
chi2 = (angle(t1) - angle(t2))^2;
chi = chi1+chi2;
end
end