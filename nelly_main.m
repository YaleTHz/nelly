function [freq, n_fit, freq_full, tf_full, tf_spec, tf_pred, func, spec_smp, spec_ref]...
    = nelly_main(input, t_smp, A_smp, t_ref, A_ref, varargin)
% NELLY_MAIN Runs Nelly data processing code
%
% Arguments: input -- gives input geometry and other settings for the 
%                     calculation. This can either be a filename for a 
%                     JSON file or a struct
%            t_smp -- time points for the reference time domain trace
%            A_smp -- amplitude points corresponding to t_smp
%            t_ref -- time points for the sample time domain trace
%            A_ref -- amplitude points corresponding to t_ref
%            varargin -- additional arguments 
% Output: freq      -- an array containing the frequencies (THz) at which 
%                      the refractive index was calculated
%         n_fit     -- an array of complex values for the refractive index.
%                      The ith element corresponds to the ith element in 
%                      freq. For the imaginary part, positive values 
%                      correspond to loss.
%         freq_full -- an array containing a finer mesh of frequency points
%                      directly from the padded fourier transform.
%         tf_full   -- an array containing the transfer function
%                      (E_smp/E_ref). The ith element corresponds to the
%                      ith element in freq_full
%         tf_spec   -- an array containing the transfer function 
%                      (E_smp/E_ref) at a coarser spacing. The ith element
%                      corresponds to the ith element of freq
%         tf_pred   -- an array containing the predicted transfer function
%                      based on the extracted refractive index values, for
%                      use in assessing the accuracy of the extraction. The 
%                      ith element corresponds to the ith element of freq
%         func      -- an anonymous function which takes two arguments -- 
%                      frequency (THz) and the value for the unknown 
%                      refractive index--and returns the predicted transfer
%                      function values at that frequency assuming that the 
%                      unknown refractive index is the value given. 
%         spec_smp  -- the spectrum for the sample pulse (i.e. E_smp(freq))
%                      The ith element corresponds to the ith element of 
%                      freq.
%         spec_ref  -- the spectrum for the reference pulse (i.e. 
%                      E_ref(freq)). The ith element corresponds to the ith
%                      element of freq.

%% error checking

%% load and process data and input parameters
if ~ isstruct(input)
    input = load_input(input);
end

% process additional arguments
assert(mod(numel(varargin),2) == 0, 'Extra parameters come in pairs')
extra_args = struct;
for ii = 1:2:numel(varargin)
    extra_args.(varargin{ii}) = varargin{ii+1};
end

% fourier transform 
[freq, tf_spec, freq_full, tf_full, spec_smp, spec_ref] = exp_tf(t_smp, A_smp, t_ref, A_ref, input);

fft_sets = input.settings.fft;

% determine time cut off for etalons (relative to peak)
% (for non tree version)
t_cut_exp = t_smp(end) - t_smp(find(A_smp == max(A_smp),1));
switch fft_sets.windowing_type
    case 'gauss'
        t_cut_wind = 3*fft_sets.windowing_width;
    case 'square' 
        t_cut_wind = fft_sets.windowing_width/2;
    otherwise
        t_cut_wind = Inf;
end

t_cut = min([t_cut_exp t_cut_wind]);

% calculate t_cut for tree

t_cut_exp_ref = t_ref(end) - t_ref(find(A_ref == max(A_ref),1));
t_cut_exp_ref = min([t_cut_exp_ref t_cut_wind]);

% estimate of time it takes to pass through reference geometry
ref_ns = arrayfun(@(x) x.n, input.reference);
ref_ds = arrayfun(@(x) x.d, input.reference);
ref_nd = dot(ref_ns, ref_ds);

t_traverse_reference = (1e12*ref_nd/3e14);
t_cut_tree = t_traverse_reference + t_cut_exp_ref;

% estimate starting refractive index 
% real part
delay = t_smp(find(A_smp == max(A_smp),1)) - t_ref(find(A_ref == max(A_ref),1));
n_est = estimate_n(delay, input);
if real(n_est) < 1
    warning('Estimated refractive index is less than 1')
    n_est = 1;
end

% imaginary part
k_mean = mean([min(freq) max(freq)])*2*pi*1e12/3e14;
d_inds = find(strcmp({input.sample.n}, 'solve'));
d_tot = sum(arrayfun(@(ii) input.sample(ii).d, d_inds));
n_prev = [real(n_est) log(mean(abs(tf_spec)))/(d_tot*k_mean)];

%  func_smp = build_transfer_function(input.sample, 't_cut', t_cut);
%  func_ref = build_transfer_function(input.reference, 't_cut', t_cut);
a_cut = input.settings.a_cut;
func_smp = build_transfer_function_tree(input.sample, t_cut_tree, a_cut);
func_ref = build_transfer_function_tree(input.reference, t_cut_tree, a_cut);
func = @(freq, n_solve) func_smp(freq, n_solve)/func_ref(freq, n_solve);

%% perform fitting
n_fit = zeros(2, numel(freq));

for ii = 1:numel(freq)
    err = @(n) n_error(func(freq(ii), complex(n(1), n(2))), tf_spec(ii));
    opts = optimset('PlotFcns',@optimplotfval);
    %opts = optimset();
    n_opt = fminsearch(err, n_prev, opts);

    n_prev = n_opt;
    n_fit(:,ii) = n_opt;
    fprintf('%0.2f THz: n = %s\n', freq(ii), num2str(complex(n_opt(1), n_opt(2))))
end


tf_pred = arrayfun(@(ii) func(freq(ii), complex(n_fit(1,ii), n_fit(2, ii))), 1:numel(freq));
n_fit = n_fit(1,:) - 1i*n_fit(2,:);
end 

function [chi] = n_error(t1, t2)
chi1 = (log(abs(t1)) - log(abs(t2)))^2;
chi2 = (mod(angle(t1),2*pi) - mod(angle(t2),2*pi))^2;
chi = chi1+chi2;
end
