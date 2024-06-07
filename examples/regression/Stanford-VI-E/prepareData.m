function [trainData, testData, cubeSize] = prepareData(nSubSamp, useFacies, slice, include5Years)
   
    %% Read models from petrel 
    data = load('data/data_2TimeLapses.mat');

    indices_highSat = find(data.saturation10yrs > 0.85);
    indices_highSat = indices_highSat(randperm(numel(indices_highSat), nSubSamp));
    indices_midSat = find(data.saturation10yrs < 0.85 & data.saturation10yrs > 0.4 );
    indices_midSat = indices_midSat(randperm(numel(indices_midSat), nSubSamp));
    indices_lowSat = find(data.saturation10yrs < 0.4);
    indices_lowSat = indices_lowSat(randperm(numel(indices_lowSat), nSubSamp));
    
    indices = [indices_highSat' indices_midSat' indices_lowSat'];

    phi_reference = data.porosity(:, :, slice);
    sw_reference10yrs = data.saturation10yrs(:, :, slice);
    data_AI_10yrs = data.acousticimpedance10yrs(:, :, slice);
    data_VPVS_10yrs = data.VPVS10yrs(:, :, slice);
    
    if include5Years
        mtrain = [data.porosity(indices); data.saturation5yrs(indices); data.saturation10yrs(indices)]';
        dtrain = [data.acousticimpedance5yrs(indices); ...
            data.acousticimpedance10yrs(indices); data.VPVS5yrs(indices); data.VPVS10yrs(indices)]';
        sw_reference5yrs = data.saturation5yrs(:, :, slice);
        data_AI_5yrs = data.acousticimpedance5yrs(:, :, slice);
        data_VPVS_5yrs = data.VPVS5yrs(:, :, slice);
    else
        mtrain = [data.porosity(indices); data.saturation10yrs(indices)]';
        dtrain = [data.acousticimpedance10yrs(indices); data.VPVS10yrs(indices)]';
        sw_reference5yrs = [];
        data_AI_5yrs = [];
        data_VPVS_5yrs = [];
    end

    if useFacies
        trainData = [data.facies(indices)', dtrain, mtrain];
        data_facies = data.facies(:, :, slice);
        testData = [data_facies(:), data_AI_5yrs(:), data_AI_10yrs(:), ...
            data_VPVS_5yrs(:), data_VPVS_10yrs(:), phi_reference(:), sw_reference5yrs(:), sw_reference10yrs(:)];
    else
        trainData = [dtrain, mtrain];
        testData = [data_AI_5yrs(:), data_AI_10yrs(:), data_VPVS_5yrs(:), ...
            data_VPVS_10yrs(:), phi_reference(:), sw_reference5yrs(:), sw_reference10yrs(:)];
    end
    cubeSize = size(phi_reference);
end

