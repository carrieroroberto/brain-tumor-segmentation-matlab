function img_filtered = denoising(img, method)
    switch method
        case "median"
            img_filtered = medfilt2(img, [3 3]);
            
        case "gaussian"
            img_filtered = imgaussfilt(img, 1);
            
        otherwise
            error("Metodo non riconosciuto. Usare median o gaussian");
    end
end