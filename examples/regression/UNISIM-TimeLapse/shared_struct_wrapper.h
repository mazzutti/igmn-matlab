// shared_struct_wrapper.h
#ifndef SHARED_STRUCT_WRAPPER_H
#define SHARED_STRUCT_WRAPPER_H

#ifdef __cplusplus
extern "C" {
#endif

bool shared_read_bool(const char* shmName, const char* field);
int  shared_read_int(const char* shmName, const char* field);
void shared_write_bool(const char* shmName, const char* field, bool value);
void shared_write_int(const char* shmName, const char* field, int value);
void shared_cleanup(const char* shmName);

#ifdef __cplusplus
}
#endif

#endif // SHARED_STRUCT_WRAPPER_H
