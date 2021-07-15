nelly_path = fileparts(which('nelly_main'));
assert(numel(nelly_path) ~= 0,...
    'nelly_main not found. Please add the Nelly folder to your MATLAB path or set is as your current folder.');

path = fullfile(nelly_path, 'sample_files', filesep);


% load data
d_smp = importdata([path 'pvb_smp.tim']);
t_smp = d_smp(:,1);
A_smp = flipud(d_smp(:,2));

d_ref = importdata([path 'pvb_ref.tim']);
t_ref = d_ref(:,1);
A_ref = flipud(d_ref(:,2));

input = load_input([path 'pvb_input.json']);

options = optimset('TolX', 1);
d_start = 230;
d = fminbnd(@(x) get_tv(x, input, t_smp, A_smp, t_ref, A_ref),...
    d_start - 30, d_start + 30 , options);

% set thicknesses to optimal value and calculate refractive index
input.sample(2).d = d;
input.reference(1).d = d;
[freq, n] = nelly_main(input, t_smp, A_smp, t_ref, A_ref);
plot(freq, real(n))


function [tv] = get_tv(d, input, t_smp, A_smp, t_ref, A_ref)
% set thickness of unknown layer in sample
input.sample(2).d = d;

% adjust reference thickness (air here) to match sample thickness
% (important!)
input.reference(1).d = d;

[freq, n] = nelly_main(input, t_smp, A_smp, t_ref, A_ref);

tv = sum(abs(diff(real(n)))) + sum(abs(diff(imag(n))));
end
