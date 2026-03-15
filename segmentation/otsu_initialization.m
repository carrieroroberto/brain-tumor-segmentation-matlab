function [seed_point, marker_int, marker_ext, img_roi] = otsu_initialization(img)
    % 1. Calcola la soglia solo sulla parte attiva (ignorando lo sfondo nero)
    active_pixels = img(img > 0.05);
    if isempty(active_pixels)
        level = 0.1;
    else
        level = graythresh(active_pixels);
    end

    % 2. Binarizzazione: Questo è il nucleo di sicurezza del tumore
    bin_mask = img > level;
    bin_mask = bwareafilt(logical(bin_mask), 1); % Tieni solo la massa più grande
    bin_mask = imfill(bin_mask, 'holes');

    % 3. Trova il punto più profondo/centrale per il Seme
    dist_map = bwdist(~bin_mask);
    [~, max_idx] = max(dist_map(:));
    [r, c] = ind2sub(size(img), max_idx);
    seed_point = [r, c];

    % 4. Marker per il Watershed
    marker_int = imerode(bin_mask, strel('disk', 3));
    if sum(marker_int(:)) == 0
        marker_int = bin_mask;
    end
    
    % Il marker esterno è il cervello sano (che ora ha valori bassissimi ma > 0)
    marker_ext = (img < (level * 0.3)) & (img > 0); 

    % 5. Preparazione ROI per il Region Growing
    % Diamo un "cuscinetto" attorno al tumore, spegnendo il resto
    roi_mask = imdilate(bin_mask, strel('disk', 15));
    img_roi = img;
    img_roi(~roi_mask) = 0;
end