function input = load_input(source)
% LOAD_INPUT 
% 
% input = LOAD_INPUT(fname) Generates a struct input from the augmented 
% JSON file (JSON + comments) given by fname
%
% INPUT
% fname -- the filename of the file to load
% 
% OUTPUT
% input -- a struct which contains the information stored in the JSON
%          file. For example if the file has {"settings": {"a_cut": ... } }
%          a_cut can be found with input.settings.a_cut


assert(ischar(source) || isstruct(source), ...
    'input must either be a filename or a struct')
if ischar(source)
    text = fileread(source);
    no_comments = regexprep(text, '/.*?\n', '\n');
    input = jsondecode(no_comments);
else
    input = source;
end
    
   

%%  error checking
% check for required fields (top level)
has_required_fields(input, {'settings', 'sample'})

% checking for required fields (settings)
has_required_fields(input.settings, {'a_cut', 'freq_lo', 'freq_hi', ...
                                     'freq_step', 'fft'})
                                 
% checking for required fields (setting.fft)
has_required_fields(input.settings.fft, {'windowing_type',...
                                         'windowing_width', 'padding'})


assert(isstruct(input.sample), 'load_input:nonuniform_field', ...
    'Each sample entries must have the same fields')
input.sample = generate_n_funcs(input.sample);

%% handle reference geometry
if isfield(input, 'reference')
    assert(isstruct(input.reference), 'load_input:nonuniform_field',...
        'Each sample entries must have the same fields')
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

%% match thicknesses
d_smp = sum(arrayfun(@(x) x.d, input.sample));
d_ref = sum(arrayfun(@(x) x.d, input.reference));

if d_smp > d_ref
    pad = input.sample(end);
    pad.d = d_smp - d_ref;
    input.reference = [input.reference(1:end-1); pad; input.reference(end)];
end

if d_ref > d_smp
    pad = input.reference(end);
    pad.d = d_ref - d_smp;
    input.sample = [input.sample(1:end-1); pad; input.sample(end)];
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

            % skip if n_func is already present
            if isfield(geom_out(ii), 'n_func')
                if isa(geom_out(ii).n_func, 'function_handle')
                    continue
                end
            end
            
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
                % load file from same directory as input file if possible
                input_path = false;
                if ischar(source)
                    input_path = fileparts(source);
                end
                if input_path
                    fname_here = [input_path '/' mat.n];
                    if isfile(fname_here)
                        mat.n = fname_here;
                    end
                end
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
        missing = setdiff(required_fields, fieldnames(struc));
        missing_str = sprintf('%s ', string(missing));
        assert(isempty(missing), 'load_input:missing_field',...
            sprintf('%input is missing fields %s', missing_str))
    end
end