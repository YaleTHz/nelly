function [maps] = error_map(func, tf_exp, tf_freq, n, k, varargin)
if numel(varargin) > 0
    freq = varargin{1};
    tf = interp1(tf_freq, tf_exp, freq);
else
    freq = tf_freq;
    tf = tf_exp;
end

maps = cell(1, numel(freq));

waitbar(0, 'mapping...')

max_pct = 0;
tot = numel(freq)*numel(n);

for ii = 1:numel(freq)
    map = struct('freq', freq(ii));
    data = zeros(numel(k), numel(n));
    for nn = 1:numel(n)
        for kk = 1:numel(k)
            n_solve = complex(n(nn), -k(kk));
            
            t = func(freq(ii), n_solve);

            FractionE = tf(ii);
            Etarget = t;
            chi1 = (log(abs(FractionE)) - log(abs(Etarget)))^2;
            chi2 = (angle(FractionE) - angle(Etarget))^2;
            data(kk, nn) = chi1+chi2;
            
            %data(kk, nn) = norm(func(freq(ii), n_solve)-tf(ii));
            %data(kk, nn) = err_ang^2+err_amp^2;
        end
        waitbar((ii*numel(n) + nn)/tot)
    end
    map.data = data;
    maps{ii} = map;
end

    


