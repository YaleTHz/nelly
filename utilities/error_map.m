% This function produces a visualization of the error function to give a
% sense of the landscape the optimization is navigating. 
% The function takes in:
% func: the theoretical transfer function of two variables (freq, n_solve)
% to be mapped
% tf_exp: the experimental transfer function we are trying to fit. The
% error function will be calculated by comparing these values with the
% corresponding output of func.
% tf_freq: the frequency points (in THz) corresponding to the data in
% tf_exp
% n and k: vectors containing ranges of values of the real (n) and imaginary (k)
% parts of the refractive index. The error function will be calculated at
% every point on the grid these two vectors define--i.e. every value of k
% for every value of n
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
            %fprintf('(%0.2f, %0.2f)\n', n(nn), k(kk))
            n_solve = complex(n(nn), -k(kk));
            
            t = func(freq(ii), n_solve);

            FractionE = tf(ii);
            Etarget = t;
            chi1 = (log(abs(FractionE)) - log(abs(Etarget)))^2;
            chi2 = (angle(FractionE) - angle(Etarget))^2;
            data(kk, nn) = chi1+chi2;
            
            %data(kk, nn) = norm(FractionE-Etarget);
            
            %data(kk, nn) = norm(func(freq(ii), n_solve)-tf(ii));
            %data(kk, nn) = err_ang^2+err_amp^2;
        end
        waitbar((ii*numel(n) + nn)/tot)
    end
    map.data = data;
    maps{ii} = map;
end

    


