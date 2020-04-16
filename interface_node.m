classdef  interface_node < handle
    properties
        from   % index of material after interface
        into   % index of material after interface
        t_acc  % total time accumulated to reach this node
        amp    % amplitude upon reaching this node
        ref    % node to the left in the tree--reflection back into from
        trn    % node to the right in the tree--tranmission into into
        id
    end
    
    methods
        function obj = interface_node(from, into, t_acc, amp, geom, freq,...
                n_solve, t_cut, a_cut)
            obj.into = into;
            obj.from = from;
            obj.amp = amp;
            obj.t_acc = t_acc;

            c = physconst('LightSpeed')*1e6; %um/s
            prop = @(freq, d, n) exp(-1i*(2*pi*freq*1e12/c)*n*d);
            rf = @(n1, n2) (n1-n2)/(n1+n2);
            tr = @(n1, n2) rf(n1, n2) + 1;

            n_from = geom(from).n_func(freq, n_solve);
            d_from = geom(from).d;
            n_into = geom(into).n_func(freq, n_solve);

            
            fprintf('%d -> %d, (%0.2f ps, amp = %0.2f)\n', from, into,...
                t_acc, amp)

            % generate ref node (back into from)
            if from ~= 1 
                fprintf('generating reflection\n')
                % calculate amplitude after this interface 
                % to see if we should include this reflection
                amp_new = amp*abs(prop(freq, d_from, n_from)*rf(n_from, n_into))
                fprintf('amp = %0.2f, prop(d = %0.2f, n %0.2f -> %0.2f) = %0.2f\n', ...
                    amp, d_from, n_from, n_into, ...
                    prop(freq, d_from, n_from))
                dt = (real(n_from)*d_from/c)*1e12; %time in ps
                t_new = t_acc + dt;
                
                if (t_new < t_cut) && (amp_new > a_cut)
                    into_new = from+(from-into);
                    obj.ref = interface_node(from, into_new, t_new, amp_new,...
                        geom, freq, n_solve, t_cut, a_cut);
                end
            end
            
            % generate trn node (proceeding into into)
            if (into < numel(geom)) && (into > 1)
                fprintf('generation transmission\n')
                amp_new = amp*abs(prop(freq, d_from, n_from)*tr(n_from, n_into));
                dt = (real(into)*d_from/c)*1e12; %time in ps
                t_new = t_acc + dt;
                if (t_new < t_cut) && (amp_new > a_cut)
                    from_new = into;
                    into_new = into + (into-from);
                    obj.trn = interface_node(from_new, into_new, t_new, amp_new,...
                        geom, freq, n_solve, t_cut, a_cut);
                end
            end
        end
        
        function nds = all_nodes(obj)
            todo = [obj];
            nds = [];
            while numel(todo) > 0
                curr = todo(1); 
                todo = todo(2:end);
                nds = [nds curr];
                todo = [todo get_children(curr)];
            end
        end
        
        function ret = get_children(obj)
            ret = [];
            if isa(obj.trn, 'interface_node')
                ret = [ret obj.trn];
            end
            
            if isa(obj.ref, 'interface_node')
                ret = [ret obj.ref];
            end
        end
        
        function vec = tree_vec(obj)
            nodes = obj.all_nodes;
            vec = zeros(1, numel(nodes));
            for ii = 1:numel(nodes)
                nodes(ii).id = ii;
            end
            
            for ii = 1:numel(nodes)
                children = nodes(ii).get_children;
                inds = arrayfun(@(x) x.id, children);
                vec(inds) = nodes(ii).id;
            end
        end
    end
end