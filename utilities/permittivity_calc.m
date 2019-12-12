% Calculates permittivity from complex-valued n_fit export from nelly-main
% Arguments: n_fit -- complex-valued refractive index (n and k)
%                     exported from nelly-main
% Output:    eps   -- calculated complex-valued permittivity array


%% Convert n_fit to permittivity (epsilon)
% Jacob A. Spies
% 10 Jan 2020
%
% Revised 07 Feb 2021 to allow new complex-valued n_fit from nelly-main

function eps = permittivity_calc(n_fit)

    eps = (n_fit(1,:)).^2;
    
end