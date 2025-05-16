#include "shared_struct.h"

#include <cstring>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>

bool SharedStruct::readBool(const std::string& shmName, const std::string& field) {
    std::string path = "/tmp/" + shmName;

    int fd = open(path.c_str(), O_RDONLY, 0666);
    if (fd == -1) return false;

    void* ptr = mmap(nullptr, SHM_SIZE, PROT_READ, MAP_SHARED, fd, 0);
    if (ptr == MAP_FAILED) {
        close(fd);
        return false;
    }

    char* data = static_cast<char*>(ptr);
    bool result = false;

    if (field == "useKriging")
        result = *reinterpret_cast<bool*>(data);
    else if (field == "inKrigingMode")
        result = *reinterpret_cast<bool*>(data + sizeof(bool));

    munmap(ptr, SHM_SIZE);
    close(fd);
    return result;
}

int SharedStruct::readInt(const std::string& shmName, const std::string& field) {
    std::string path = "/tmp/" + shmName;

    int fd = open(path.c_str(), O_RDONLY, 0666);
    if (fd == -1) return -1;

    void* ptr = mmap(nullptr, SHM_SIZE, PROT_READ, MAP_SHARED, fd, 0);
    if (ptr == MAP_FAILED) {
        close(fd);
        return -1;
    }

    char* data = static_cast<char*>(ptr);
    int result = 0;

    if (field == "krigingStartIteration")
        result = *reinterpret_cast<int*>(data + 2 * sizeof(bool));
    else if (field == "iterationCount")
        result = *reinterpret_cast<int*>(data + 2 * sizeof(bool) + sizeof(int));
    else if (field == "numCores")
        result = *reinterpret_cast<int*>(data + 2 * sizeof(bool) + 2 * sizeof(int));

    munmap(ptr, SHM_SIZE);
    close(fd);
    return result;
}

void SharedStruct::writeBool(const std::string& shmName, const std::string& field, bool value) {
    std::string path = "/tmp/" + shmName;

    int fd = open(path.c_str(), O_RDWR | O_CREAT, 0666);
    if (fd == -1) return;

    ftruncate(fd, SHM_SIZE);
    void* ptr = mmap(nullptr, SHM_SIZE, PROT_WRITE, MAP_SHARED, fd, 0);
    if (ptr == MAP_FAILED) {
        close(fd);
        return;
    }

    char* data = static_cast<char*>(ptr);

    if (field == "useKriging")
        *reinterpret_cast<bool*>(data) = value;
    else if (field == "inKrigingMode")
        *reinterpret_cast<bool*>(data + sizeof(bool)) = value;

    munmap(ptr, SHM_SIZE);
    close(fd);
}

void SharedStruct::writeInt(const std::string& shmName, const std::string& field, int value) {
    std::string path = "/tmp/" + shmName;

    int fd = open(path.c_str(), O_RDWR | O_CREAT, 0666);
    if (fd == -1) return;

    ftruncate(fd, SHM_SIZE);
    void* ptr = mmap(nullptr, SHM_SIZE, PROT_WRITE, MAP_SHARED, fd, 0);
    if (ptr == MAP_FAILED) {
        close(fd);
        return;
    }

    char* data = static_cast<char*>(ptr);

    if (field == "krigingStartIteration")
        *reinterpret_cast<int*>(data + 2 * sizeof(bool)) = value;
    else if (field == "iterationCount")
        *reinterpret_cast<int*>(data + 2 * sizeof(bool) + sizeof(int)) = value;
    else if (field == "numCores")
        *reinterpret_cast<int*>(data + 2 * sizeof(bool) + 2 * sizeof(int)) = value;

    munmap(ptr, SHM_SIZE);
    close(fd);
}

void SharedStruct::cleanup(const std::string& shmName) {
    std::string path = "/tmp/" + shmName;
    unlink(path.c_str());
}
