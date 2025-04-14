# Regression Example: UNISIM Time-Lapse

This example demonstrates the use of the **IGMN-MATLAB** library for regression tasks applied to UNISIM Time-Lapse data. The workflow integrates Incremental Gaussian Mixture Networks (IGMN) and Kriging for spatial conditioning, enabling robust predictions of reservoir properties over time.

## Overview

The purpose of this example is to illustrate how IGMN can be combined with Kriging to perform regression on reservoir simulation data. The workflow includes:

1. Loading and preprocessing UNISIM data.
2. Training the IGMN model.
3. Applying Kriging for spatial conditioning.
4. Predicting reservoir properties.
5. Evaluating results using RMSE metrics.
6. Comparing results with DMS inversion.

## Prerequisites

Before running this example, ensure the following:

- MATLAB is installed on your system.
- The **IGMN-MATLAB** library is set up correctly. Add it to your MATLAB path:
    ```matlab
    addpath('../../../igmn/');
    ```
- The **GeoStatRockPhysics** library is installed and added to your MATLAB path:
    ```matlab
    addpath(genpath('../../../GeoStatRockPhysics/'));
    ```

## How to Run

1. Open MATLAB and navigate to the `examples/regression/UNISIM-TimeLapse` directory.
2. Execute the script `run.m` by running the following command:
    ```matlab
    run('run.m');
    ```

## Key Features

### Dependencies
- **IGMN Library**: For incremental learning and regression.
- **GeoStatRockPhysics Library**: For geostatistical operations and Kriging.

### Global Variables
- `iterationCount`: Tracks the number of iterations.
- `inKrigingMode`: Indicates whether Kriging is being used.
- `numCores`: Number of CPU cores for parallel processing.
- `useKriging`: Flag to enable or disable Kriging.
- `krigingStartIteration`: Iteration number to start Kriging.

### Key Parameters
- `nSim`: Number of simulations to load.
- `discretizationSize`: Size of discretization for predictions.
- `showPlots`: Flag to enable or disable plot visualization.
- `exportPlots`: Flag to enable or disable exporting plots.
- `variableNames`: Names of the variables used in the analysis.

## Workflow

1. **Data Loading and Preprocessing**:
    - Load UNISIM model and well data.
    - Normalize data if Kriging is enabled.
    - Extract input and output variable indexes.

2. **Kriging Setup** (if enabled):
    - Prepare conditioning data from well information.
    - Normalize conditioning data.
    - Perform Kriging to compute means and variances for predictions.

3. **Problem Setup**:
    - Define the regression problem using the `Problem` class.
    - Configure optimization options and hyperparameters.

4. **Optimization and Training**:
    - Perform hyperparameter tuning (if enabled).
    - Train the IGMN model using the training data.

5. **Prediction and Evaluation**:
    - Predict outputs for test data.
    - Compute unconditioned and conditioned outputs.
    - Evaluate results using RMSE metrics.
    - Generate plots for visualization of results.

6. **Comparison with DMS Inversion**:
    - Load DMS inversion results.
    - Compare RMSE values for unconditioned and conditioned predictions.

## Outputs

- **RMSE Metrics**:
    - Unconditioned RMSE for predictions.
    - Conditioned RMSE for predictions.
- **Plots**:
    - Real vs predicted values.
    - Regression analysis.
    - Spatial distribution of predictions.

## Directory Contents

- `run.m`: Main script for running the UNISIM Time-Lapse regression example.
- `loadData.m`: Loads and preprocesses UNISIM data.
- `normalizeData.m`: Normalizes data for Kriging and IGMN.
- `plotResults.m`: Visualizes results and comparisons.
- `Kriging_options.m`: Performs Kriging for spatial conditioning.

## Additional Resources

For more information about the IGMN algorithm, consult the [IGMN-MATLAB documentation](../../../README.md).

## License

This example is distributed under the same license as the **IGMN-MATLAB** library. See the [LICENSE](../../../LICENSE.md) file for more details.