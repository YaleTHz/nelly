% Adds an estimate of the refractive index for each layer. 
% For layers where the thickness is known, the estimate is the average of
% the refractive index in the frequency range specified in the input file. 
% For the unknown layer, the refractive index is estimated using the delay
% of the sample pulse relative to the reference

function [input_new, n_est] = estimate_n(delay, input)
input_new = input;
freq = input.settings.freq_lo:input.settings.freq_step:input.settings.freq_hi;

known_smp = input.sample(~strcmp({input.sample.n}, 'solve'));
unknown_smp = input.sample(strcmp({input.sample.n}, 'solve'));

% d*n for known layers
mean_n = @(layer) mean(arrayfun(@(f) layer.n_func(f, 0), freq));
dn_smp_known = sum(arrayfun(@(layer) mean_n(layer)*layer.d, known_smp));
dn_ref = sum(arrayfun(@(layer) mean_n(layer)*layer.d, input.reference));

% total width of unknown layers (assuming none in reference)
d_unknown = sum([unknown_smp.d]);

% calculate delay between reference and sample
c = physconst('LightSpeed')*1e6; %um/s

% final calculation for n estimate
n_est = (delay*c*1e-12+dn_ref-dn_smp_known)/d_unknown;

for ii = 1:numel(input_new.sample)
    if strcmp(input_new.sample(ii).n, 'solve')
        input_new.sample(ii).n_est = n_est;
    else
        input_new.sample(ii).n_est = mean_n(input_new.sample(ii));
    end
end

for ii = 1:numel(input_new.reference)
    if strcmp(input_new.reference(ii).n, 'solve')
        input_new.reference(ii).n_est = n_est;
    else
        input_new.reference(ii).n_est = mean_n(input_new.reference(ii));
    end
end

