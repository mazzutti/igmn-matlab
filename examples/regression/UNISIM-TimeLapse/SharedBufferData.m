classdef SharedBufferData
    properties
        shmName
    end

    properties (Dependent)
        useKriging
        inKrigingMode
        krigingStartIteration
        iterationCount
        numCores
    end

    methods
        function obj = SharedBufferData(name)
            if nargin == 0
                name = '/shared_buffer';
            end
            obj.shmName = name;
        end

        % --- Getters ---
        function v = get.useKriging(obj)
            v = logical(SharedStructInterface.readBool(obj.shmName, 'useKriging'));
        end

        function v = get.inKrigingMode(obj)
            v = logical(SharedStructInterface.readBool(obj.shmName, 'inKrigingMode'));
        end

        function v = get.krigingStartIteration(obj)
            v = int32(SharedStructInterface.readInt(obj.shmName, 'krigingStartIteration'));
        end

        function v = get.iterationCount(obj)
            v = int32(SharedStructInterface.readInt(obj.shmName, 'iterationCount'));
        end

        function v = get.numCores(obj)
            v = int32(SharedStructInterface.readInt(obj.shmName, 'numCores'));
        end

        % --- Setters ---
        function obj = set.useKriging(obj, value)
            SharedStructInterface.writeBool(obj.shmName, 'useKriging', value);
        end

        function obj = set.inKrigingMode(obj, value)
            SharedStructInterface.writeBool(obj.shmName, 'inKrigingMode', value);
        end

        function obj = set.krigingStartIteration(obj, value)
            SharedStructInterface.writeInt(obj.shmName, 'krigingStartIteration', value);
        end

        function obj = set.iterationCount(obj, value)
            SharedStructInterface.writeInt(obj.shmName, 'iterationCount', value);
        end

        function obj = set.numCores(obj, value)
            SharedStructInterface.writeInt(obj.shmName, 'numCores', value);
        end

        % --- Utility ---
        function displayState(obj)
            fprintf('useKriging: %d\n', obj.useKriging);
            fprintf('inKrigingMode: %d\n', obj.inKrigingMode);
            fprintf('krigingStartIteration: %d\n', obj.krigingStartIteration);
            fprintf('iterationCount: %d\n', obj.iterationCount);
            fprintf('numCores: %d\n', obj.numCores);
        end

        function cleanup(obj)
            SharedStructInterface.cleanup(obj.shmName);
        end
    end
end
