function [n] = cordouan_main(input_file_name, t_smp, A_smp, t_ref, A_ref)
%% load data
input = load_input(input_file_name);

%% calculate experimental transfer function
[freq_smp spec_smp] = fft_func(t_smp, A_smp, input.settings.fft);
[freq_smp spec_ref] = fft_func(t_ref, A_ref, input.settings.fft);

range = 

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