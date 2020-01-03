function [str] = geometry_string(input)
mats = input.materials;
geo = input.geometry;

str = cellfun(@(m) sprintf('%s (%0.2f um)', m, mats.(m).d), geo, ...
    'uniformoutput', false)