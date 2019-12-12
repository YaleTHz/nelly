function [n] = cordouan_main(input_file_name, t_smp, e_smp, t_ref, e_ref)
%% load data  
%% calculate experimental transfer function
E_smp = fft_func(t_ref, t_thz);
E_ref = fft_func(e

tf_exp = E_smp./E_ref;


%% build transfer function 

transferFunction = build_transfer_function( %layer and interface specification,...
                                     %experimental transfer function )

%% loop over data points

for % freq in frequency range
    %something like:
    n(freq) = fmincom(@(n) transferFunction(n, freq), ...)
end
end