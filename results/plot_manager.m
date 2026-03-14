function plot_manager(img, mask_rg, mask_ws, mask_gt, patient_name, save_path)
    fig = figure('Name', "Analisi " + patient_name, ...
                 'Position', [100, 100, 1400, 600], ...
                 'Visible', 'off'); 
             
    sgtitle("Analisi Risultati - " + patient_name, 'FontSize', 16, 'FontWeight', 'bold');

    subplot(1,3,1); imshow(img, []); hold on;
    visboundaries(mask_gt, 'Color', 'r', 'LineWidth', 1.5);

    h1 = plot(NaN, NaN, 'r', 'LineWidth', 1.5); 
    legend(h1, 'GT (Reale)', 'Location', 'South');

    subplot(1,3,2); imshow(img, []); hold on;
    visboundaries(mask_gt, 'Color', 'r', 'LineStyle', ':', 'LineWidth', 1);
    visboundaries(mask_rg, 'Color', 'g', 'LineWidth', 1.5);

    h2 = plot(NaN, NaN, 'r:', 'LineWidth', 1);
    h3 = plot(NaN, NaN, 'g', 'LineWidth', 1.5);
    legend([h2, h3], {'GT', 'Predizione RG'}, 'Location', 'South');

    subplot(1,3,3); imshow(img, []); hold on;
    visboundaries(mask_gt, 'Color', 'r', 'LineStyle', ':', 'LineWidth', 1);
    visboundaries(mask_ws, 'Color', 'y', 'LineWidth', 1.5);

    h4 = plot(NaN, NaN, 'r:', 'LineWidth', 1);
    h5 = plot(NaN, NaN, 'y', 'LineWidth', 1.5);
    legend([h4, h5], {'GT', 'Predizione WS'}, 'Location', 'South');

    exportgraphics(fig, save_path, 'Resolution', 150);
    close(fig);
end