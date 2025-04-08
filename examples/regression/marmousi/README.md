# Marmousi Example

This folder contains scripts and data for applying the Incremental Gaussian Mixture Network (IGMN) to seismic data inversion using the Marmousi model. The Marmousi dataset is widely used in geophysics for testing seismic inversion and imaging algorithms.

## Overview

The Marmousi example demonstrates how IGMN can be used to predict subsurface properties such as P-wave velocity (Vp), S-wave velocity (Vs), and density (Rho) from seismic data. The workflow includes data preparation, synthetic data generation, training the IGMN model, and evaluating its predictions.

## Key Scripts

### Data Preparation
- **`stratifiedPartition.m`**: Partitions data into stratified training, testing, and validation sets. It uses Gaussian Mixture Models (GMMs) to generate synthetic data for training and testing. Validation data is extracted directly from the original dataset.
  - **Inputs**: Dataset structure (`allData`), block size, trace size, and number of samples per block.
  - **Outputs**: Stratified training data, testing data, and validation data.
  - **Features**:
    - Uses parallel processing (`parfor`) for faster GMM fitting.
    - Saves GMMs and validation data to `data/stratifiedData.mat` for reuse.
    - Handles convergence issues by reducing the number of GMM components if necessary.

- **`prepareData.m`**: Prepares training and testing datasets for IGMN.
- **`addSeismicNoise.m`**: Adds noise to seismic data for robustness testing.

### Model Training and Prediction
- **`predictVp.m`**: Predicts P-wave velocity using IGMN.
- **`predictVpOptimization.m`**: Optimizes IGMN hyperparameters for Vp prediction.
- **`run.m`**: Main script for running the Marmousi example.

### Visualization
- **`plotResults.m`**: Visualizes the predicted and true subsurface properties.
- **`plotStds.m`**: Computes and optionally plots the standard deviations of predictions.
- **`plotPredAndStds.m`**: Plots predictions and standard deviations for seismic data.

### Utilities
- **`computeDomainProbabilities.m`**: Computes probabilities for domain discretization.
- **`ProgressBar.m`**: Utility for displaying progress during data processing.

### Data
- **`data/`**: Contains input seismic data and processed results.
- **`cmaps.mat`**: Colormap data for visualization.

## Usage

1. Add the required dependencies to the MATLAB path:
   ```matlab
   addpath('../../../igmn/');
   addpath(genpath('../../../Seislab 3.02'));
   ```
2. Run the main script:
   ```matlab
   run.m
   ```
3. View the results, including predictions and visualizations, in the MATLAB console and figures.

## Key Features
- Synthetic Data Generation: Generates synthetic seismic traces using the Marmousi model.
- Noise Robustness: Tests the model's performance under various noise levels.
- Hyperparameter Optimization: Includes scripts for optimizing IGMN hyperparameters.
- Visualization: Provides detailed plots for analyzing predictions and uncertainties.

## Dependencies
- The igmn folder must be included in the MATLAB path.
- The Seislab toolbox is required for seismic data processing.
- Input data files (e.g., SEG-Y files) must be available in the data/ folder.

## Example Output
- After running the `run.m` script, you may see visualizations such as:

- Predicted vs. true P-wave velocity profiles.
- Uncertainty estimates for predictions.
- Acoustic impedance plots for publication.

## Purpose
This example showcases the application of IGMN to a challenging geophysical problem, demonstrating its ability to handle complex, noisy datasets and provide uncertainty estimates for predictions.

## Author
Tiago Mazzutti