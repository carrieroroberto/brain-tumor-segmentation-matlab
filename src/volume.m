clc; clear; close all;

[file, path] = uigetfile({'*.nii;*.nii.gz','NIfTI'}, 'Seleziona NIfTI');
if isequal(file,0); return; end
fullpath = fullfile(path,file);

info = niftiinfo(fullpath);
V = niftiread(info);

% se 4D → usa primo canale
if ndims(V) == 4
    V = V(:,:,:,1);
end

V = single(V);
V = V / max(V(:));   % normalizzazione

volshow(V);
