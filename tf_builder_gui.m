% takes text from textbox in Nelly GUI, interprets, and exports the proper
% structure for the input into nelly_main

%% Nelly GUI Transfer Function Builder
% Jacob A. Spies
% 25 Aug 2020

function out = tf_builder_gui(input)
    N = length(input(:,1));
    out = struct([]);
    
    for i = 1:N
        temp = char(input(i,1));
        len = length(temp);
        comma = find(temp == ',');
        equal = find(temp == '=');
        out(i,1).name = temp(1:comma(1)-1);
        out(i,1).d = str2num(temp(equal(1)+1:comma(2)-1));
        if ~isempty(str2num(temp(equal(2)+1:len)))
            out(i,1).n = str2num(temp(equal(2)+1:len));
        else
            out(i,1).n = temp(equal(2)+1:len);
        end
    end

    out = generate_n_funcs(out);
end