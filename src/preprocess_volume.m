function [V_out, mask_brain] = preprocess_volume(V_in, params)
% PREPROCESS_VOLUME (Versione Ottimizzata per dati Pre-Stripped)
% Esegue: Denoising -> Bias Field Correction -> Mask Refinement -> Z-Score

    %% 1. Inizializzazione
    V_out = zeros(size(V_in));
    mask_brain = false(size(V_in));
    
    if nargin < 2
        sigma = 0.8; D0 = 15;
    else
        sigma = params.sigma_denoise; D0 = params.cutoff_freq;
    end
    
    %% 2. Elaborazione Slice-by-Slice
    for z = 1:size(V_in, 3)
        slice = V_in(:,:,z);
        if max(slice(:)) == 0, continue; end % Salta slice vuote
        
        % --- A. Denoising ---
        slice_den = imgaussfilt(slice, sigma);
        
        % --- B. Bias Field Correction ---
        % (Mantieni il codice del filtro omomorfico che ti ho dato prima)
        slice_log = log(slice_den + 1);
        [M, N] = size(slice);
        H = make_homomorphic_filter(M, N, D0); % Usa la funzione helper precedente
        F = fftshift(fft2(slice_log));
        slice_homo = real(ifft2(ifftshift(F .* H)));
        slice_corr = exp(slice_homo) - 1;
        
        % --- C. Mask Refinement (Ex Skull Stripping) ---
        % Poiché i dati sono puliti, usiamo una soglia molto bassa per prendere tutto
        % tranne il nero assoluto di fondo.
        mask = slice_corr > 0.01; % Soglia minima
        
        % Riempimento buchi (IMPORTANTE: Otsu nel tuo esempio aveva buchi neri dentro)
        mask = imfill(mask, 'holes'); 
        
        % Pulizia: tiene solo l'oggetto più grande (il cervello) e rimuove rumore esterno
        mask = bwareafilt(mask, 1); 
        
        mask_brain(:,:,z) = mask;
        
        % --- D. Normalizzazione Z-Score ---
        pixels = slice_corr(mask);
        if ~isempty(pixels)
            mu = mean(pixels);
            sigma_px = std(pixels);
            slice_final = (slice_corr - mu) / (sigma_px + eps);
            slice_final(~mask) = min(slice_final(mask)); % Background uniforme
            V_out(:,:,z) = slice_final;
        end
    end
end

% (Ricordati di includere qui sotto la funzione make_homomorphic_filter che hai già)
function H = make_homomorphic_filter(M, N, D0)
    u = 0:(M-1); v = 0:(N-1);
    idx_u = find(u > M/2); u(idx_u) = u(idx_u) - M;
    idx_v = find(v > N/2); v(idx_v) = v(idx_v) - N;
    [V, U] = meshgrid(v, u);
    D = sqrt(U.^2 + V.^2);
    n = 2; gH = 1.1; gL = 0.5;
    H = (gH - gL) .* (1 ./ (1 + (D0 ./ (D + eps)).^(2*n))) + gL;
end