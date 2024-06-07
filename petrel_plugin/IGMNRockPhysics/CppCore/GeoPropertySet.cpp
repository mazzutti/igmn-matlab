#include "GeoPropertySet.h"
#include "SplitKey.h"

// As of VS2019, these warnings give multiple false positives and have to be disabled
#pragma warning( disable: 6385 )
#pragma warning( disable: 6386 )
#pragma warning( disable: 6011 )

using namespace std;

GeoPropertySet::GeoPropertySet(
	float* inputPropertyValues, const size_t inputPropertyAmt,
	float* outputPropertyValues, const size_t outputPropertyAmt,
	const size_t sampleAmt, double gridSize) {

	const int totalPropertyAmt = inputPropertyAmt + outputPropertyAmt;

	this->inputPropertyAmt = inputPropertyAmt;
	this->outputPropertyAmt = outputPropertyAmt;
	this->sampleAmt = sampleAmt;
	this->gridSize = abs(gridSize);
	keyShifts = nullptr;
	broadAverage = nullptr;
	gridNormShift = nullptr;
	gridNormScale = nullptr;

	maxDimensions = min(inputPropertyAmt, MAX_NEIGHBOR_DIMENSIONS);
	neighborAmt = pow(3, maxDimensions);
	cellAmt = floor(1.0 / gridSize);
	if (cellAmt > 32767) cellAmt = 32767;

	dTrainAccess = (float**)malloc(sizeof(float*) * sampleAmt);
	mTrainAccess = (float**)malloc(sizeof(float*) * sampleAmt);

	for (int i = 0; i < sampleAmt; ++i) {
		dTrainAccess[i] = inputPropertyValues;
		mTrainAccess[i] = outputPropertyValues;
		inputPropertyValues += inputPropertyAmt;
		outputPropertyValues += outputPropertyAmt;
	}

	keyShifts = (__m128i*)malloc(sizeof(__m128i) * neighborAmt);
	if (keyShifts != nullptr) {
		SplitKey auxKey = 0;
		for (int i = 0; i < neighborAmt; ++i) {
			auxKey = 0;
			for (int d = 0; d < maxDimensions; ++d) {
				auxKey.key16[d] = (i / ((int)pow(3, d)) % 3) - 1;
			}
			keyShifts[i] = auxKey.keyM;
		}
	}

}

GeoPropertySet::~GeoPropertySet() {
	if (dTrainAccess) free(dTrainAccess);
	if (mTrainAccess) free(mTrainAccess);
	if (keyShifts) free(keyShifts);
	if (broadAverage) free(broadAverage);
	if (gridNormShift) free(gridNormShift);
	if (gridNormScale) free(gridNormScale);
}

void GeoPropertySet::InitOptimizedAccess() {

	neighborPoints.clear();

	unordered_multimap<uint64_t, float*> auxMap;
	auxMap.reserve(sampleAmt * neighborAmt);

	SplitKey currentKey = 0;
	float* propertyValues = dTrainAccess[0];
	for (int i = 0; i < sampleAmt; ++i, propertyValues += inputPropertyAmt) {
		SplitKey::MakeKey(currentKey, propertyValues, maxDimensions, cellAmt);
		for (int n = 0; n < neighborAmt; ++n) {
			SplitKey newKey = currentKey.keyM;
			newKey.ShiftKey(keyShifts[n]);
			auxMap.insert(pair(newKey.key64[0], propertyValues));
		}
	}

	neighborPoints.reserve(sampleAmt * neighborAmt);
	for (auto it = auxMap.begin(); it != auxMap.end(); )
	{
		auto key = it->first;
		auto range = auxMap.equal_range(key);
		size_t bucketSize = distance(range.first, range.second);

		PointerArray<float> fpArr(bucketSize);

		int j = 0;
		for (auto bItr = range.first; bItr != range.second; ++bItr) {
			fpArr.mem[j++] = bItr->second;
		}

		neighborPoints[key] = move(fpArr);

		it = range.second;
	}
}

void GeoPropertySet::NormalizeTrainingData() {

	if (gridNormShift) free(gridNormShift);
	if (gridNormScale) free(gridNormScale);

	gridNormShift = (float*)malloc(sizeof(float) * inputPropertyAmt);
	gridNormScale = (float*)malloc(sizeof(float) * inputPropertyAmt);

	for (int d = 0; d < inputPropertyAmt; ++d) {
		float minVal = INFINITY;
		float maxVal = -INFINITY;
		for (int i = 0; i < sampleAmt; ++i) {
			const float dVal = dTrainAccess[i][d];
			if (dVal < minVal) minVal = dVal;
			if (dVal > maxVal) maxVal = dVal;
		}

		gridNormShift[d] = - minVal;
		gridNormScale[d] = (maxVal > minVal) ? (float)(1.0/((double)maxVal - (double)minVal)) : 1.0;
	}

	for (int i = 0; i < sampleAmt; ++i) {
		ScaleArray(dTrainAccess[i]);
	}

}

void GeoPropertySet::CalculateBroadAverage() {
	if (broadAverage) free(broadAverage);
	broadAverage = (float*)malloc(sizeof(float) * outputPropertyAmt);

	double* dAverage = (double*)malloc(sizeof(double) * outputPropertyAmt);
	if (dAverage) memset(dAverage, 0, sizeof(double) * outputPropertyAmt);

	for (int i = 0; i < sampleAmt; ++i) {
		for (int m = 0; m < outputPropertyAmt; ++m) {
			dAverage[m] += mTrainAccess[i][m];
		}
	}

	for (int m = 0; m < outputPropertyAmt; ++m) {
		broadAverage[m] = (float)(dAverage[m] / (double)sampleAmt);
	}

	free(dAverage);
}

void GeoPropertySet::GenerateOutput(float** inputCubes, float** outputCubes, size_t startPos, size_t endPos, int* progress) const noexcept {

	double* neighborAverage = (double*)malloc(sizeof(double) * outputPropertyAmt);
	if (neighborAverage) memset(neighborAverage, 0, sizeof(double) * outputPropertyAmt);

	float* currentPoint = (float*)malloc(sizeof(float) * inputPropertyAmt);
	SplitKey pointKey = 0;

	int dummyProgress = 0;
	if (!progress) progress = &dummyProgress;

	for (int i = startPos; i < endPos; ++i, ++(*progress)) {

		for (int j = 0; j < inputPropertyAmt; ++j) {
			const float pVal = inputCubes[j][i];
			if (pVal != pVal) { // NAN value
				currentPoint[0] = pVal;
				j = inputPropertyAmt;
			} else {
				currentPoint[j] = inputCubes[j][i];
			}
		}

		if (!(currentPoint[0] != currentPoint[0])) {
			ScaleArray(currentPoint);
			SplitKey::MakeKey(pointKey, currentPoint, maxDimensions, cellAmt);
			if (auto neighbors = (*this)[pointKey]) {
				double neighborQtd = 0;
				for (int n = 0; n < neighbors->arraySize; ++n) {
					if (CloseEnough(neighbors->mem[n], currentPoint)) {
						SumArrays(neighborAverage, mTrainAccess[(neighbors->mem[n] - dTrainAccess[0])/inputPropertyAmt ] );
						neighborQtd++;
					}
				}
				if (neighborQtd > 0) {
					for (int m = 0; m < outputPropertyAmt; ++m) {
						outputCubes[m][i] = neighborAverage[m] / neighborQtd;
						neighborAverage[m] = 0.0;
					}
				} else AverageOut(outputCubes, i);
			} else AverageOut(outputCubes, i);
		} else AverageOut(outputCubes, i);
	}

	free(neighborAverage);
	free(currentPoint);
}
