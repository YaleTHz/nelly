% takes in refractive indices--photoexcited and unphotoexcited--and
% calculates the materials photoconductivity in S/m
% 
function [sig] = n_to_photocond(freq, n_photo, n_non)

% n_non = handle_data(n_non);
% n_photo = handle_data(n_photo);

e0 = 8.854e-12; %F/m = (C/V)/m
sig = 1i*e0*2*pi*freq*1e12.*(n_non.^2-n_photo.^2);

% function [data, freq] =  handle_data(inpt)
% if isvector(inpt)
%     data = inpt;
% elseif isfile(inpt)
%     imported = importdata(inpt);
%     if ismatrix(imported)
%         % accept either 2 columns (frequency, complex refractive index)...
%         if size(imported) == 2
%             freq = 
%             
%     elseif isstruct(imported)
%         data = imported.data;
%     end
% end
%         