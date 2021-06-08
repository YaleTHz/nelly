classdef thz_tim
    properties
        data
        t
        scans
        avg
        std
        path
    end
    
    methods
        % either specify a full path ('path', [path])
        % or date and number ('date', '2020_10_19', 'num', 1)
        function obj = thz_tim(varargin)
            assert(mod(numel(varargin),2) == 0, 'parameters come in pairs')
            args = struct;
            for ii = 1:2:numel(varargin)
                args.(upper(varargin{ii})) = varargin{ii+1};
            end
            
            path = '/home/uri/Desktop/thz_data/';
            
            % either path or date + number must be specified
            assert(isfield(args, 'PATH') || (isfield(args, 'DATE') && ...
                                             isfield(args, 'NUM')), ...
                                  'must specify path or date and scan number')
            % if path is specified explicitly
            if isfield(args, 'PATH')
                path = args.PATH;
            else
                dt = datestr(datetime(args.DATE, 'inputformat', 'yyyy_MM_dd'), 'mmmdd_');
                path = [path args.DATE '/' dt num2str(args.NUM, '%03d') '.tims']
            end
            
            obj.path = path;
            obj.data = importdata(path);
            obj.t = obj.data(:,1);
            obj.scans = obj.data(:, 2:end);
            obj.avg = mean(obj.scans,2);
            obj.std = std(obj.scans, 1, 2);
        end
        
        function [] = plot(obj)
            plot(obj.t, obj.scans, 'r');
            hold on
            plot(obj.t, obj.avg, 'k', 'linewidth', 2)
        end
        
        function [str] = summary(obj)
            fid = fopen([obj.path(1:end-4) 'par']);
            fgets(fid);
            fgets(fid);
            
            str = '';
            while true
                f = fgets(fid);
                if contains(f, 'Iterations Completed')
                    break
                else
                    str = [str strip(f) ' '];
                end
            end
        end
        
        function [dat] = first_n(obj, n)
            dat = obj.data(:, 2:n);
        end
        
        function [dat] = first_n_avg(obj, n)
            dat = mean(obj.data(:, 2:n),2);
        end
        
        % simulates data with n scans
        function [dat] = resample(obj, n)
            noise_gen = (obj.std/sqrt(n)).*randn(size(obj.avg));
            dat = obj.avg + noise_gen;
        end
    end
end