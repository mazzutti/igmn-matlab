# Profile Folder

This folder contains scripts for benchmarking and profiling the performance of the Incremental Gaussian Mixture Network (IGMN) implementation.

## Files

### 1. `main.m`
This script serves as the entry point for running the IGMN profiling benchmark. It performs the following tasks:
- Generates synthetic training and testing data based on the sine function.
- Measures the execution time of the IGMN prediction process using MATLAB's `timeit` function.
- Outputs the benchmark results, including the number of training samples, testing samples, and the number of components (`nc`) in the IGMN model.

#### Key Features:
- Uses the `predictSinBenchmark` function to train and predict using the IGMN model.
- Outputs benchmark results to the console.

### 2. `predictSinBenchmark.m`
This function benchmarks the IGMN model's training and prediction process. It:
- Combines training and testing data to calculate the data range.
- Configures IGMN hyperparameters such as `tau`, `delta`, `vMin`, and `spMin`.
- Initializes and trains the IGMN model using the training data.
- Predicts the output for the test data and returns the predictions (`Y`) and the number of components (`nc`) in the trained model.

#### Key Features:
- Configurable hyperparameters for the IGMN model.
- Demonstrates the use of the `igmn` class for training and prediction.

## Usage

1. Add the `igmn` folder to the MATLAB path:
   ```matlab
   addpath('../igmn/');# Profile Folder

This folder contains scripts for benchmarking and profiling the performance of the Incremental Gaussian Mixture Network (IGMN) implementation.

## Files

### 1. `main.m`
This script serves as the entry point for running the IGMN profiling benchmark. It performs the following tasks:
- Generates synthetic training and testing data based on the sine function.
- Measures the execution time of the IGMN prediction process using MATLAB's `timeit` function.
- Outputs the benchmark results, including the number of training samples, testing samples, and the number of components (`nc`) in the IGMN model.

#### Key Features:
- Uses the `predictSinBenchmark` function to train and predict using the IGMN model.
- Outputs benchmark results to the console.

### 2. `predictSinBenchmark.m`
This function benchmarks the IGMN model's training and prediction process. It:
- Combines training and testing data to calculate the data range.
- Configures IGMN hyperparameters such as `tau`, `delta`, `vMin`, and `spMin`.
- Initializes and trains the IGMN model using the training data.
- Predicts the output for the test data and returns the predictions (`Y`) and the number of components (`nc`) in the trained model.

#### Key Features:
- Configurable hyperparameters for the IGMN model.
- Demonstrates the use of the `igmn` class for training and prediction.

## Usage

1. Add the `igmn` folder to the MATLAB path:
   ```matlab
   addpath('../igmn/');