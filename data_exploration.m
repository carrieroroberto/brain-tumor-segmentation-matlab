clear; clc; close all;

fileName = "dataset/Task01_BrainTumour/imagesTr/BRATS_001.nii.gz";
groundTruth = "dataset/Task01_BrainTumour/labelsTr/BRATS_001.nii.gz";

vol = double(niftiread(fileName));
gt  = double(niftiread(groundTruth));

[dimX, dimY, dimZ, num_channels] = size(vol);
slice_centrale = round(dimZ / 2);

flair_vol = vol(:,:,:,1);
flair_vol = flair_vol / max(flair_vol(:));

ground_slice = gt(:,:,slice_centrale);

figure("Name", "Confronto Canali MRI");
titles = {"FLAIR", "T1", "T1c", "T2", };
for i = 1:4
    subplot(2, 2, i);
    imshow(vol(:,:,slice_centrale,i), []);
    title(titles{i});
end

f_slider = figure("Name", "Esplorazione FLAIR e Istogramma");

ax_img  = subplot(1, 2, 1);
img_handle = imshow(flair_vol(:,:,slice_centrale), "Parent", ax_img);
title(ax_img, sprintf("Slice: %d", slice_centrale));

ax_hist = subplot(1, 2, 2);
hist_handle = histogram(ax_hist, flair_vol(:,:,slice_centrale));
title(ax_hist, "Istogramma Intensità");

uicontrol("Parent", f_slider, "Style", "slider", ...
    "Min", 1, "Max", dimZ, "Value", slice_centrale, ...
    "Units", "normalized", "Position", [0.25 0.02 0.5 0.03], ...
    "Callback", @(es, ~) updateSlice(es, ax_img, img_handle, ax_hist, hist_handle, flair_vol));

disp("Generazione Rendering 3D...");
volshow(flair_vol); 

figure("Name", "Ground Truth");
imshow(ground_slice, []);
title(sprintf("Ground Truth - Slice centrale: %d", slice_centrale));

function updateSlice(slider_obj, ax_img, img_handle, ax_hist, ~, volume)
    idx = round(slider_obj.Value);
    slice_data = volume(:,:,idx);
    img_handle.CData = slice_data;
    title(ax_img, sprintf("Slice: %d", idx));
    
    cla(ax_hist);
    histogram(ax_hist, slice_data);
    title(ax_hist, "Istogramma Intensità");
end