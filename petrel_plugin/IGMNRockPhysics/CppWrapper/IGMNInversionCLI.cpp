#include "IGMNInversionCLI.h"
#include "GeoPropertySet.h"

#pragma warning( disable: 6386 )

using namespace ControllerSRP;
using namespace System;
using namespace System::Runtime::InteropServices;

IGMNInversionCLI::IGMNInversionCLI(array<float, 2>^% dTrain, array<float, 2>^% mTrain, double gridSize) {

    if (dTrain->GetLength(0) != mTrain->GetLength(0)) throw gcnew System::Exception("Inconsistent training data array sizes.");

	GCHandle dTrainHandle = GCHandle::Alloc(dTrain, GCHandleType::Pinned);
	GCHandle mTrainHandle = GCHandle::Alloc(mTrain, GCHandleType::Pinned);

    float* inputPropertyValues = reinterpret_cast<float*>(dTrainHandle.AddrOfPinnedObject().ToPointer());
    float* outputPropertyValues = reinterpret_cast<float*>(mTrainHandle.AddrOfPinnedObject().ToPointer());

	geoProperties = new GeoPropertySet(
		inputPropertyValues, dTrain->GetLength(1),
		outputPropertyValues, mTrain->GetLength(1),
		dTrain->GetLength(0), gridSize);
}

IGMNInversionCLI::~IGMNInversionCLI() {
	if (geoProperties) delete geoProperties;
	if (inputCubes) delete inputCubes;
	if (outputCubes) delete outputCubes;
	this->!IGMNInversionCLI();
}

IGMNInversionCLI::!IGMNInversionCLI() {
	if (dTrainHandle.IsAllocated) dTrainHandle.Free();
	if (mTrainHandle.IsAllocated) mTrainHandle.Free();
}

void IGMNInversionCLI::SetSeismicCubeData(array<array<float, 3>^>^% dCond, array<array<float, 3>^>^% result) {

	if (dCond[0]->Length != result[0]->Length) throw gcnew System::Exception("Inconsistent seismic cube sizes.");

	cubeSize = dCond[0]->Length;

	inputCubes = new float* [dCond->GetLength(0)];
	outputCubes = new float* [result->GetLength(0)];


	for (int i = 0; i < dCond->GetLength(0); ++i) {
		pin_ptr<float> pin = &dCond[i][0, 0, 0];
		inputCubes[i] = pin;
	}

	for (int i = 0; i < result->GetLength(0); ++i) {
		pin_ptr<float> pin = &result[i][0, 0, 0];
		outputCubes[i] = pin;
	}

}

void IGMNInversionCLI::PrepareTrainingData() {
	geoProperties->NormalizeTrainingData();
	geoProperties->CalculateBroadAverage();
	geoProperties->InitOptimizedAccess();
}

void IGMNInversionCLI::RunIGMNInversionCLI() {
	geoProperties->GenerateOutput(inputCubes, outputCubes, 0, cubeSize, nullptr);
}

void IGMNInversionCLI::RunIGMNInversionCLI(size_t startPos, size_t endPos, int% progress) {
	pin_ptr<int> pin = &progress;
	geoProperties->GenerateOutput(inputCubes, outputCubes, startPos, endPos, pin);
}