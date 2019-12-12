%% Time-Domain Windowing Function (TD_window.m)
% Jacob A. Spies
% 12 Dec 2019

% Windows THz time-domain data to suppress etalons. Currently uses either a
% Gaussian or square (top-hat) filter centered at the peak of the THz
% pulse.

%% Description of input parameters:
% TD_data: data array containing time in column 1 and amplitude in column 2
% type: 'gauss' for Gaussian or 'square' for square windowing. Any other
%           input returns data without windowing.
% width: double setting width of the window. For 'gauss' this is sigma and
%           for 'square' this is the absolute width.

%% Description of output:
% TD_data_windowed: Outputs windowed data, mirroring input TD_data (so it
%           includes time as well.

function amplitude_windowed = TD_window(time,amplitude,type,width)

    % Find maximum of time-domain data (absolute) and define center offset
    [max_A index] = max(abs(amplitude));
    t_offset = time(index);

    if strcmp(type,'gauss')
        % Gaussian windowing
        window = exp(-((time-t_offset)/width).^2);
        amplitude_windowed = amplitude.*window;
        status = 'Gaussian window applied to time-domain data!'
    elseif strcmp(type,'square')
        % Square windowing
        N_pts = length(time);
        amplitude_windowed = amplitude;
        for i = 1:N_pts
            if (time(i) < (t_offset-(width/2))) || (time(i) > (t_offset + (width/2)))
                amplitude_windowed(i) = 0;
            end
        end
        status = 'Square (top-hat) window applied to time-domain data!'
    else
        % No window applied for other input arguments for 'type'
        amplitude_windowed = amplitude;
        status = 'No window applied to time-domain data!'
    end

end