function plot_manager(img, mask_rg, mask_ws, mask_gt, info_text)
    % PLOT_MANAGER: Visualizzazione comparativa finale con Ground Truth

    figure('Name',"Validazione Finale: " + string(info_text),'Position',[50 50 1500 500]);

    %% Subplot 1: Ground Truth
    subplot(1,3,1);
    imshow(img, []); hold on;
    h_gt = visboundaries(mask_gt, 'Color', 'r', 'LineWidth', 2);
    title('Ground Truth (Radiologo)');
    legend(h_gt, {'GT (Reale)'}, 'Location', 'southoutside');

    %% Subplot 2: Region Growing vs GT
    subplot(1,3,2);
    imshow(img, []); hold on;
    h_gt2 = visboundaries(mask_gt, 'Color', 'r', 'LineStyle', ':', 'LineWidth', 1);
    h_rg = visboundaries(mask_rg, 'Color', 'g', 'LineWidth', 2);
    title('Region Growing');
    legend([h_gt2,h_rg], {'GT','Predizione RG'}, 'Location', 'southoutside');

    %% Subplot 3: Watershed vs GT
    subplot(1,3,3);
    imshow(img, []); hold on;
    h_gt3 = visboundaries(mask_gt, 'Color', 'r', 'LineStyle', ':', 'LineWidth', 1);
    h_ws = visboundaries(mask_ws, 'Color', 'y', 'LineWidth', 2);
    title('Marker-Controlled Watershed');
    legend([h_gt3,h_ws], {'GT','Predizione WS'}, 'Location', 'southoutside');

    %% Titolo globale
    sgtitle(['Analisi Risultati - ', info_text]);
end