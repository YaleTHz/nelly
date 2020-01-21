function [maps] = error_map(func, tf_exp, tf_freq, n, k, varargin)
if numel(varargin) > 0
    freq = varargin{1};
    tf = interp1(tf_freq, tf_exp, freq);
else
    freq = tf_freq;
    tf = tf_exp;
end

maps = cell(1, numel(freq));

for ii = 1:numel(freq)
    map = struct('freq', freq(ii));
    data = zeros(numel(k), numel(n));
    for nn = 1:numel(n)
        for kk = 1:numel(k)
            n_solve = complex(n(nn), -k(kk));
            data(kk, nn) = norm(func(freq(ii), n_solve)-tf_exp(ii));
        end
    end
    map.data = data;
    maps{ii} = map;
end


    


