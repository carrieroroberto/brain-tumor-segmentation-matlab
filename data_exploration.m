clear; clc; close all;

fileName = "dataset/Task01_BrainTumour/imagesTr/BRATS_001.nii.gz";
vol = double(niftiread(fileName));

[~, ~, num_slices, ~] = size(vol);
slice_centrale = round(num_slices / 2);

flair_vol = vol(:,:,:,4);
flair_vol = flair_vol / max(flair_vol(:));

figure("Name", "Confronto Canali MRI");
titles = {"T1", "T1c", "T2", "FLAIR"};
for i = 1:4
    subplot(2, 2, i);
    imshow(vol(:,:,slice_centrale,i), []);
    title(titles{i});
end

f_slider = figure("Name", "Esplorazione FLAIR e Istogramma");

ax_img = subplot(1, 2, 1);
img_handle = imshow(flair_vol(:,:,slice_centrale), "Parent", ax_img);
title(ax_img, sprintf("Slice: %d", slice_centrale));

ax_hist = subplot(1, 2, 2);
slice_iniziale = flair_vol(:,:,slice_centrale);
hist_handle = histogram(ax_hist, slice_iniziale);
title(ax_hist, "Istogramma Intensità");

uicontrol("Parent", f_slider, "Style", "slider", "Min", 1, "Max", num_slices, "Value", slice_centrale, ...
    "SliderStep", [1/(num_slices-1), 10/(num_slices-1)], ...
    "Callback", @(es, ~) update(es, ax_img, img_handle, hist_handle, flair_vol));

disp("Generazione Rendering 3D...");
volshow(flair_vol); 

function update(slider_obj, ax_img, img_handle, hist_handle, volume)
    idx = round(slider_obj.Value);
    slice_data = volume(:,:,idx);
    img_handle.CData = slice_data;
    title(ax_img, sprintf("Slice: %d", idx));
    hist_handle.Data = slice_data;
end