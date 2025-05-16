#include "mex.h"
#include "shared_struct.h"
#include <string.h>

void mexFunction(int nlhs, mxArray* plhs[],
                 int nrhs, const mxArray* prhs[]) {
    if (nrhs < 2) {
        mexErrMsgTxt("Usage: shared_memory_mex(command, shmName, field, value)");
        return;
    }

    // Parse arguments
    std::string command = mxArrayToString(prhs[0]);
    std::string shmName = mxArrayToString(prhs[1]);
    std::string field = (nrhs >= 3 && mxIsChar(prhs[2])) ? mxArrayToString(prhs[2]) : "";

    if (command == "readBool") {
        bool result = SharedStruct::readBool(shmName, field);
        plhs[0] = mxCreateLogicalScalar(result);
    }
    else if (command == "readInt") {
        int result = SharedStruct::readInt(shmName, field);
        plhs[0] = mxCreateDoubleScalar(static_cast<double>(result));
    }
    else if (command == "writeBool") {
        if (nrhs < 4 || !mxIsLogicalScalar(prhs[3])) {
            mexErrMsgTxt("writeBool requires a logical value as the fourth argument.");
            return;
        }
        bool value = mxIsLogicalScalarTrue(prhs[3]);
        SharedStruct::writeBool(shmName, field, value);
    }
    else if (command == "writeInt") {
        if (nrhs < 4 || !mxIsDouble(prhs[3])) {
            mexErrMsgTxt("writeInt requires a numeric value as the fourth argument.");
            return;
        }
        int value = static_cast<int>(mxGetScalar(prhs[3]));
        SharedStruct::writeInt(shmName, field, value);
    }
    else if (command == "cleanup") {
        SharedStruct::cleanup(shmName);
    }
    else {
        mexErrMsgTxt("Unknown command.");
    }
}
