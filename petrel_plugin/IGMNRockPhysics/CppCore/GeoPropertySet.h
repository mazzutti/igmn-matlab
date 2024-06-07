#pragma once

#include <stdio.h>
#include <cassert>
#include <unordered_map>
#include <vector>
#include <cstdint>
#include <numeric>
#include <algorithm>
#include <intrin.h>
#include <immintrin.h>
#include <chrono>

#include "SplitKey.h"
#include "PointerArray.h"

#define MAX_NEIGHBOR_DIMENSIONS ((size_t)4)

class GeoPropertySet {

public:

	GeoPropertySet(
		float* inputPropertyValues, const size_t inputPropertyAmt,
		float* outputPropertyValues, const size_t outputPropertyAmt,
		const size_t sampleAmt, double gridSize);

	~GeoPropertySet();

	void InitOptimizedAccess();
	void NormalizeTrainingData();
	void CalculateBroadAverage();

	inline bool CloseEnough(float* valuesA, float* valuesB) const noexcept {
		for (int d = 0; d < inputPropertyAmt; ++d, ++valuesA, ++valuesB) {
			if (fabs(*valuesA - *valuesB) >= gridSize) {
				return false;
			}
		}
		return true;
	}

	inline void SumArrays(double* accumulator, float* values) const noexcept {
		for (int m = 0; m < outputPropertyAmt; ++m, ++accumulator, ++values) {
			*accumulator += *values;
		}
	}

	inline void ScaleArray(float* values) const noexcept {
		for (int d = 0; d < inputPropertyAmt; ++d, ++values) {
			*values = (*values + gridNormShift[d]) * gridNormScale[d];
		}
	}

	inline void AverageOut(float** values, const size_t i) const noexcept {
		for (int m = 0; m < outputPropertyAmt; ++m) {
			values[m][i] = broadAverage[m];
		}
	}

	void GenerateOutput(float** inputCubes, float** outputCubes, size_t startPos, size_t endPos, int* progress) const noexcept;

	inline float* operator [](size_t i) const noexcept { return dTrainAccess[i]; }
	inline float*& operator [](size_t i) noexcept { return dTrainAccess[i]; }
	inline const PointerArray<float>* operator [](SplitKey k) const noexcept {
		auto it = neighborPoints.find(k.key64[0]);
		return (it != neighborPoints.cend()) ? &it->second : nullptr;
	}

private:
	std::unordered_map<uint64_t, PointerArray<float>> neighborPoints;
	float** dTrainAccess;
	float** mTrainAccess;
	__m128i* keyShifts;
	float* broadAverage;
	float* gridNormShift;
	float* gridNormScale;

	size_t maxDimensions;
	size_t neighborAmt;
	double cellAmt;

	size_t inputPropertyAmt;
	size_t outputPropertyAmt;
	size_t sampleAmt;
	double gridSize;
};

