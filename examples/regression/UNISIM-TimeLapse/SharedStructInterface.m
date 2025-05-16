classdef SharedStructInterface < coder.ExternalDependency
    %#codegen

    methods (Static)
        function name = getDescriptiveName()
            name = 'SharedStructInterface';
        end

        function tf = isSupportedContext(context)
            % Enable only for mex targets
            tf = context.isCodeGenTarget('mex');
        end

        function updateBuildInfo(buildInfo, ~)
            buildInfo.addIncludePaths(fullfile(pwd));
            buildInfo.addSourcePaths(fullfile(pwd));
            % Register source and include for C++ integration
            buildInfo.addIncludeFiles( ...
                {'shared_struct.h', 'shared_struct_wrapper.h'});
            buildInfo.addSourceFiles( ...
                {'shared_struct.cpp', 'shared_struct_wrapper.cpp'});
        end

        function out = readBool(shmName, field)
            if coder.target('MATLAB')
                out = shared_struct_mex('readBool', shmName, field);
            else
                out = false; %#codegen
                coder.inline('never');
                coder.cinclude('shared_struct_wrapper.h');
                out = coder.ceval('shared_read_bool', ...
                    SharedStructInterface.toCString(shmName), ...
                    SharedStructInterface.toCString(field));
            end
        end

        function out = readInt(shmName, field)
            if coder.target('MATLAB')
                out = int32(shared_struct_mex('readInt', shmName, field));
            else
                coder.inline('never')
                coder.cinclude('shared_struct_wrapper.h');
                out = int32(0); %#codegen
                out = coder.ceval('shared_read_int', ...
                    SharedStructInterface.toCString(shmName), ...
                    SharedStructInterface.toCString(field));
            end
        end

        function writeBool(shmName, field, value)
            if coder.target('MATLAB')
                shared_struct_mex('writeBool', shmName, field, logical(value));
            else
                coder.inline('never');
                coder.cinclude('shared_struct_wrapper.h');
                coder.ceval('shared_write_bool', ...
                    SharedStructInterface.toCString(shmName), ...
                    SharedStructInterface.toCString(field), ...
                    logical(value));
            end
        end

        function writeInt(shmName, field, value)
            if coder.target('MATLAB')
                shared_struct_mex('writeInt', shmName, field, value);
            else
                coder.inline('never');
                coder.cinclude('shared_struct_wrapper.h');
                coder.ceval('shared_write_int', ...
                    SharedStructInterface.toCString(shmName), ...
                    SharedStructInterface.toCString(field), ...
                    int32(value));
            end
        end

        function cleanup(shmName)
            if coder.target('MATLAB')
                shared_struct_mex('cleanup', shmName);
            else
                coder.inline('never');
                coder.cinclude('shared_struct_wrapper.h');
                coder.ceval('shared_cleanup', ...
                    SharedStructInterface.toCString(shmName));
            end
        end
    end

    methods (Static, Access = private)
        function out = toCString(str)
            out = [str, char(0)];
        end
    end
end
