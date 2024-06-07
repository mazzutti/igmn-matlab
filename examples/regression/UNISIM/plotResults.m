function plotResults(testData, outputs, cubeSize)
    Phi = reshape(testData(:, 5), cubeSize);
    Sw13 = reshape(testData(:, 6), cubeSize);
    Sw24 = reshape(testData(:, 7), cubeSize);

    Ip13 = reshape(testData(:, 1), cubeSize);
    VPVS13 = reshape(testData(:, 2), cubeSize);
    Ip24 = reshape(testData(:, 3), cubeSize);
    VPVS24 = reshape(testData(:, 4), cubeSize);

    Phi_inverted = reshape(outputs(:,1), cubeSize);
    Sw13_inverted = reshape(outputs(:,2), cubeSize);
    Sw24_inverted = reshape(outputs(:,3), cubeSize);

    % data
    figure;
    ax1 = subplot(221);
    imagesc(Ip13);
    clim([4000 16000]);
    title('IP13');
    ax2 = subplot(222);
    imagesc(VPVS13);
    clim([1.35 1.75]);
    title('VPVS13');
    ax3 = subplot(223);
    imagesc(Ip24);
    clim([4000 16000]);
    title('IP24');
    ax4 = subplot(224);
    imagesc(VPVS24);
    clim([1.35 1.75]);
    title('VPVS24');
    linkaxes([ax1, ax2, ax3, ax4], 'xy');
    
    % Estimates
    
    figure;
    ax1 = subplot(231);
    imagesc(Phi);
    clim([0 0.35]);
    title('Reference Porosity');
    ax2 = subplot(232);
    imagesc(Sw13);
    clim([0 1]);
    title('Reference Sw13');
    ax3 = subplot(233);
    imagesc(Sw24);
    clim([0 1]);
    title('Reference Sw24');
    ax4 = subplot(234);
    imagesc(Phi_inverted);
    clim([0 0.35]);
    title('Estimated Porosity');
    ax5 = subplot(235);
    imagesc(Sw13_inverted);
    clim([0 1]);
    title('Estimated Sw13');
    ax6 = subplot(236);
    imagesc(Sw24_inverted);
    clim([0 1]);
    linkaxes([ax1, ax2, ax3, ax4 ax5 ax6], 'xy');
    title('Estimated Sw24');
end

