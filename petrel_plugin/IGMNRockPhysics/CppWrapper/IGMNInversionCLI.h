#pragma once

#include "GeoPropertySet.h"

namespace ControllerSRP
{
	public ref class IGMNInversionCLI
	{
		GeoPropertySet* geoProperties;
		System::Runtime::InteropServices::GCHandle dTrainHandle, mTrainHandle;
		float** inputCubes;
		float** outputCubes;
		size_t cubeSize;

	public:
		IGMNInversionCLI(array<float, 2>^% dTrain, array<float, 2>^% mTrain, double gridSize);
		~IGMNInversionCLI();
		!IGMNInversionCLI();

		void SetSeismicCubeData(array<array<float, 3>^>^% dCond, array<array<float, 3>^>^% result);
		void PrepareTrainingData();
		void RunIGMNInversionCLI();
		void RunIGMNInversionCLI(size_t startPos, size_t endPos, int% progess);
	};
}

