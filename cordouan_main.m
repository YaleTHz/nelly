function [n] = cordouan_main(input_file_name, t_smp, A_smp, t_ref, A_ref)
%% load data

%% calculate experimental transfer function
spec_smp = fft_func(t_smp, A_smp, input.settings.windowing);
spec_ref = fft_func(t_ref, A_ref, input.settings.windowing);

tf_exp = spec_smp./spec_ref;


%% build transfer function 

transferFunction = build_transfer_function( %layer and interface specification,...
                                     %experimental transfer function )

%% loop over data points

for % freq in frequency range
    %something like:
    n(freq) = fmincom(@(n) transferFunction(n, freq), ...)
end
end