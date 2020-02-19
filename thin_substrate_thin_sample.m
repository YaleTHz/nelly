function [func] = thin_substrate_thin_sample(d, d_exc, n_n, n_s)

c = physconst('LightSpeed')*1e6; %um/s

prop = @(freq, d, n) exp(-1i*(2*pi*freq*1e12/c)*n*d);
tr = @(n1, n2) 2*n1/(n1+n2);
rf = @(n1, n2) (n1-n2)/(n1+n2);
fp = @(freq, d, n0, n1, n2) 1/(1-rf(n1, n2)*rf(n1, n0)*prop(freq, d, n1)^2);


%% illuminated through 
% sample =  @(freq, n_p) tr(n_substrates, n_p)*...                   %t_sp
%                        prop(freq, d_exc, n_p)*...         %P_p(d_exc)
%                        tr(n_p, n_n)*...                   %t_pn
%                        prop(freq, d-d_exc, n_n)*...       %P_n(d-d_exc)
%                        fp(freq, d_exc, n_s, n_p, n_n)*... %FP_spn
%                        fp(freq, d-d_exc, n_p, n_n, 1);
%                   
% reference = @(freq) tr(n_s, n_n)*...        %t_sn
%                     prop(freq, d, n_n)*...  %P_n(d)
%                     fp(freq, d, n_s, n_n, 1);

%% illuminated through sample 
sample = @(freq, n_p) prop(freq, n_n, d-d_exc)*...          %P_n(d-d_exc)
                      tr(n_n, n_p)*...                      %tr_np
                      prop(freq, n_p, d_exc)*...            %P_p(d_exc)
                      tr(n_p, 1)*...                        %t_pa
                      fp(freq, d-d_exc, n_s, n_n, n_p)*... %FP_snp
                      fp(freq, d_exc, n_n, n_p, 1);        %FP_npa
reference = @(freq)   prop(freq, d, n_n)*...     %P_n(d)
                      tr(n_n, 1)*...           %t_na 
                      fp(freq, d, n_s, n_n, 1);  %FP_sna
                
func = @(freq, n_p) sample(freq, n_p)/reference(freq);