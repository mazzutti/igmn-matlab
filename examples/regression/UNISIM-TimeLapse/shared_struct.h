#ifndef SHARED_STRUCT_H
#define SHARED_STRUCT_H

#include <string>

class SharedStruct {
public:
    static bool readBool(const std::string& shmName, const std::string& field);
    static int readInt(const std::string& shmName, const std::string& field);
    static void writeBool(const std::string& shmName, const std::string& field, bool value);
    static void writeInt(const std::string& shmName, const std::string& field, int value);
    static void cleanup(const std::string& shmName);

private:
    static constexpr size_t SHM_SIZE = 1024 * 1024;
};



#endif // SHARED_STRUCT_H
