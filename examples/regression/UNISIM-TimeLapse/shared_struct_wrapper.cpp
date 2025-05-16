#include "shared_struct.h"
#include "shared_struct_wrapper.h"

extern "C" {

bool shared_read_bool(const char* shmName, const char* field) {
    return SharedStruct::readBool(std::string(shmName), std::string(field));
}

int shared_read_int(const char* shmName, const char* field) {
    return SharedStruct::readInt(std::string(shmName), std::string(field));
}

void shared_write_bool(const char* shmName, const char* field, bool value) {
    SharedStruct::writeBool(std::string(shmName), std::string(field), value);
}

void shared_write_int(const char* shmName, const char* field, int value) {
    SharedStruct::writeInt(std::string(shmName), std::string(field), value);
}

void shared_cleanup(const char* shmName) {
    SharedStruct::cleanup(std::string(shmName));
}

}
