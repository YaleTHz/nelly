function input = load_input(fname)
% LOAD_INPUT Generates a struct from the given augmented JSON file (JSON +
% comments
% 
% INPUT
% fname -- the filename of the file to load
% 
% OUTPUT
% input -- a struct which contains the information stored in the JSON
%          file. For example if the file has {"settings": {"a_cut": ... } }
%          a_cut can be found with input.settings.a_cut

text = fileread(fname);
no_comments = regexprep(text, '/.*?\n', '\n');
input = jsondecode(no_comments);

%%  error checking
% check for required fields (top level)
has_required_fields(input, {'settings', 'sample'})

% checking for required fields (settings)
has_required_fields(input.settings, {'a_cut', 'freq_lo', 'freq_hi', ...
                                     'freq_step', 'fft'})
                                 
% checking for required fields (setting.fft)
has_required_fields(input.settings.fft, {'windowing_type',...
                                         'windowing_width', 'padding'})


input.sample = generate_n_funcs(input.sample);

if isfield(input, 'reference')
    input.reference = generate_n_funcs(input.reference);
else
    % when no reference is specified, defaults to a single air layer
    % with the same thickness as the sample.
    d_tot = sum(arrayfun(@(x) x.d, input.sample));
    input.reference = [struct('d', d_tot,...
        'n', 1,...
        'n_func', @(freq, n_solve) 1,...
        'name', 'air')];
end

    % takes in a geometry--i.e. a struct containing fields n and d--and 
    % returns the same struct with another field n_func. n_func contains
    % a function which takes a frequency (in THz) and a value for the 
    % unknown refractive index (n_solve) and returns the refractive index
    % for the given layer. 
    function [geom_out] = generate_n_funcs(geom)
        geom_out = geom;
        
        for ii = 1:numel(geom)

            mat = geom(ii);    
            
            % check for required entries
            has_required_fields(mat, {'n', 'd'})
            
            % make refractive index retrieval function
            assert(isnumeric(mat.n) | ischar(mat.n), 'refractive index must be number or string')
            
            % static refractive index
            if isnumeric(mat.n)
                geom_out(ii).n_func = @(w, n_solve) mat.n;
                
            % static refractive index (complex or other string)
            elseif numel(str2num(mat.n)) > 0
                geom_out(ii).n_func = @(w, n_solve) conj(str2num(mat.n));
                
            % unknown refractive index (what we're solving for)
            elseif strcmp(mat.n, 'solve')
                geom_out(ii).n_func = @(f, n_solve) n_solve;
                
            % load values for refractive index 
            else
                pwd
                assert(isfile(mat.n),...
                    'Could not find refractive index file %s', mat.n)
                dat = importdata(mat.n);
                freq = dat(:,1);
                n = dat(:,2);
                if size(dat, 2) == 3
                    % positive K corresponds to loss
                    n = n-1i*dat(:,3);
                end
                geom_out(ii).n_func = @(f, n_solve) interp1(freq, n, f);
            end
            fprintf('%d. %0.2f um of material w n from %s\n', ii, mat.d, mat.n)
        end
    end
    
    % checks that the geometry entry has all the necessary fields
    function has_required_fields(struc, required_fields)
        struc
        missing = setdiff(required_fields, fieldnames(struc));
        missing_str = sprintf('%s ', string(missing));
        assert(isempty(missing), sprintf('%s is missing fields %s', fname, missing_str))
    end
end