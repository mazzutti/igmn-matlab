#pragma once

#include <malloc.h>

template <typename T>
class PointerArray {
public:
	T** mem;
	size_t arraySize;

	PointerArray() : arraySize(0), mem(nullptr) {}

	PointerArray(size_t s) : arraySize(s) {
		mem = (T**)malloc(sizeof(T*) * s);
	}

	~PointerArray() {
		if (mem) {
			free(mem);
			mem = nullptr;
		}
	}

	PointerArray& operator=(PointerArray&& other) noexcept {
		arraySize = other.arraySize;
		mem = other.mem;
		other.mem = nullptr;
		return *this;
	}
};