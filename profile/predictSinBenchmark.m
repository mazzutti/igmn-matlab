function [Y, nc] = predictSinBenchmark(trainData, testData) 
    data = [trainData ; testData];
    range = max(data) - min(data);
    
    options = {};
    options.tau = 0.1;
    options.delta = 0.001;
    options.vMin = int32(4);
    options.spMin = int32(3);
    options.compSize = int32(size(trainData, 1));
    
    net = igmn(range, options); 
    net.train(trainData);
    Y = net.predict(testData(:, 1));
    nc = net.nc;
end