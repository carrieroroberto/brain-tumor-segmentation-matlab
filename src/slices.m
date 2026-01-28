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

Z = size(V,3);

figure('Name','Navigazione 3D MRI','Color','w');
hAx = axes;
hImg = imshow(rot90(V(:,:,round(Z/2))),[]);
colorbar;

uicontrol('Style','slider',...
    'Min',1,'Max',Z,'Value',round(Z/2),...
    'SliderStep',[1/(Z-1) 10/(Z-1)],...
    'Units','normalized',...
    'Position',[0.2 0.02 0.6 0.04],...
    'Callback',@(s,~) set(hImg,'CData',rot90(V(:,:,round(s.Value)))));
