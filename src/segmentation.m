function V_seg = segmentation(V, mask, method)
    % SEGMENTATION_PIPELINE
    % Input: V (volume preprocessato), mask (skull stripping), method (stringa)
    
    V_seg = false(size(V));
    
    switch method
        case 'otsu' 
            % Otsu Classico
            % Calcola soglia globale sui pixel del cervello
            brain_pixels = V(mask);
            if isempty(brain_pixels), return; end
            T = multithresh(brain_pixels, 2); % 2 livelli: background, brain, tumor?
            % Spesso il tumore è iperintenso in FLAIR, prendiamo la soglia più alta
            V_seg(mask) = V(mask) > T(end);
            
        case 'region_growing'
            % Seed automatico basato su intensità massima
            for z = 1:size(V, 3)
                slice = V(:,:,z);
                roi_mask = mask(:,:,z);
                if sum(roi_mask(:)) == 0, continue; end
                
                % Seed automatico: max intensity nella ROI
                [maxVal, maxIdx] = max(slice(:) .* roi_mask(:));
                if maxVal > 2.0 % Soglia minima z-score per considerare anomalia
                     [r, c] = ind2sub(size(slice), maxIdx);
                     % Region growing con tolleranza adattiva
                     V_seg(:,:,z) = grayconnected(slice, r, c, 0.2 * maxVal); 
                end
            end
            
        case 'canny'
            % Canny + Morphological Closing + Sobel logic
            for z = 1:size(V, 3)
                slice = V(:,:,z);
                % Canny edge detection
                edges = edge(slice, 'canny');
                % Sobel per rinforzare gradienti forti
                [~, Gmag] = imgradient(slice, 'sobel');
                strong_edges = edges & (Gmag > mean(Gmag(:)) + std(Gmag(:)));
                % Closing per chiudere contorni tumorali
                closed_edges = imclose(strong_edges, strel('disk', 5));
                % Riempimento buchi
                V_seg(:,:,z) = imfill(closed_edges, 'holes');
            end
    end
end