function img_enh = enhancement(img, clip_limit)

    img_enh = adapthisteq(img, 'ClipLimit', clip_limit, 'Distribution', 'rayleigh');

end