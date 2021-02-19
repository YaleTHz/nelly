% Calculates absorption coefficient from complex-valued n_fit export from
% nelly-main
% Arguments: freq      -- frequency array output from nelly-main
%            n_fit     -- complex-valued refractive index (n and k)
%                         exported from nelly-main
% Output:    abs_coeff -- calculated absorption coefficient array

%% Absorption coefficient from complex refractive index
% Jacob A. Spies
% 31 Mar 2020
%
% Revised 07 Feb 2021 to allow new complex-valued n_fit output from
% nelly-main

function abs_coeff = abs_coeff_calc(freq,n_fit)

    k = imag(n_fit);
    N = length(k);
    c = 2.998e10; % speed of light in cm/s
    abs_coeff = k;
    
    for i = 1:N
        abs_coeff(i) = (4*pi*(freq(i)*(1e12))*k(i))/c;
    end

end