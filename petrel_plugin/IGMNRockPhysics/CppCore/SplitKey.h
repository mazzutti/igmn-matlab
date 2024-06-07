#pragma once

#include <cstdint>
#include <intrin.h>
#include <immintrin.h>

class alignas(16) SplitKey {
public:
	union {
		__m128i keyM;
		uint64_t key64[2];
		uint16_t key16[8];
	};

	SplitKey() : keyM(_mm_setr_epi64x(0, 0)) {}
	SplitKey(const SplitKey& other) : keyM(other.keyM) {}
	SplitKey(SplitKey&& other) noexcept : keyM(other.keyM) {}
	SplitKey(__m128i newKey) : keyM(newKey) {}
	SplitKey(uint64_t newKey) : keyM(_mm_setr_epi64x(newKey, 0)) {}

	SplitKey& operator=(SplitKey&& other) noexcept {
		keyM = other.keyM;
		return *this;
	}

	SplitKey& operator=(SplitKey& other) {
		keyM = other.keyM;
		return *this;
	}

	SplitKey operator=(__m128i newKey) {
		keyM = newKey;
		return *this;
	}

	SplitKey operator=(uint64_t newKey) {
		key64[0] = newKey;
		return *this;
	}

	inline void ShiftKey(uint64_t shift) noexcept {
		ShiftKey(_mm_setr_epi64x(shift, 0));
	}

	inline void ShiftKey(__m128i shift) noexcept {
		keyM = _mm_add_epi16(keyM, shift);
	}

	inline static void MakeKey(SplitKey& retKey, float* values, const int maxDimensions, double cellAmount) noexcept {
		for (int d = 0; d < maxDimensions; ++d) {
			retKey.key16[d] = (uint16_t)((uint32_t)(*(values++) * cellAmount)&0xFFFF);
		}
	}

};