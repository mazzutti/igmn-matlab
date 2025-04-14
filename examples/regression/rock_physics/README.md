# Regression Example: Rock Physics

This example demonstrates the use of the **IGMN-MATLAB** library for regression tasks applied to synthetic rock physics data. The workflow includes generating synthetic well data, configuring the regression problem, training the Incremental Gaussian Mixture Network (IGMN) model, and visualizing the results. Additionally, the example provides an optional comparison with Kernel Density Estimation (KDE)-based inversion.

## Overview

The purpose of this example is to illustrate how IGMN can be applied to predict rock physics properties such as P-wave velocity (Vp), S-wave velocity (Vs), density (Rho), porosity (Phi), clay volume (v_clay), and water saturation (sw). The workflow includes:

1. Generating synthetic well data.
2. Configuring the regression problem.
3. Training the IGMN model.
4. Predicting rock physics properties.
5. Visualizing results and confidence intervals.
6. Comparing results with KDE-based inversion.

## Prerequisites

Before running this example, ensure the following:

- MATLAB is installed on your system.
- The **IGMN-MATLAB** library is set up correctly. Add it to your MATLAB path:
    ```matlab
    addpath('../../../igmn/');
    ```
- The **Seislab 3.02** and **GeoStatRockPhysics/SeReM** libraries are installed and added to your MATLAB path:
    ```matlab
    addpath(genpath('../../../Seislab 3.02'));
    addpath(genpath('../../../GeoStatRockPhysics/SeReM/'));
    ```

## How to Run

1. Open MATLAB and navigate to the `examples/regression/rock_physics` directory.
2. Execute the script `run.m` by running the following command:
    ```matlab
    run('run.m');
    ```

## Key Features

### Dependencies
- **IGMN Library**: For incremental learning and regression.
- **Seislab 3.02**: For seismic data processing.
- **GeoStatRockPhysics/SeReM**: For geostatistical operations and synthetic data generation.

### Key Parameters
- `nSim`: Number of simulations to generate synthetic well data.
- `discretizationSize`: Size of discretization for output probabilities.
- `useFacies`: Boolean flag to include facies in the analysis.
- `normalize`: Boolean flag to normalize data.
- `inputVars`: Indices of input variables.
- `outputVars`: Indices of output variables.

### Functions Used
- `genPseudoWell`: Generates synthetic well data.
- `normalizeData`: Normalizes data to a specified range.
- `Problem`: Configures the IGMN problem.
- `compile`: Compiles the IGMN functions for execution.
- `optimize`: Optimizes IGMN hyperparameters.
- `train_mex`: Trains the IGMN model.
- `predict_mex`: Predicts outputs using the trained IGMN model.
- `plotResults`: Visualizes the results of the inversion.

## Workflow

1. **Synthetic Well Data Generation**:
    - Generate synthetic well data for training and testing.
    - Include facies information if enabled.

2. **Problem Configuration**:
    - Define input and output variables.
    - Normalize data if required.
    - Configure IGMN hyperparameters and optimization options.

3. **Training and Prediction**:
    - Train the IGMN model using the synthetic training data.
    - Predict rock physics properties for the test data.

4. **Visualization**:
    - Plot predicted outputs, confidence intervals, and domain probabilities.
    - Visualize results along the depth of the well.

5. **Comparison**:
    - Optionally compare results with KDE-based inversion.

## Outputs

- **Predicted Properties**:
    - P-wave velocity (Vp), S-wave velocity (Vs), density (Rho), porosity (Phi), clay volume (v_clay), and water saturation (sw).
- **Confidence Intervals**:
    - Visualized for each predicted property.
- **Domain Probabilities**:
    - Probabilities for each output variable across the discretized domain.
- **Plots**:
    - Real vs predicted values.
    - Depth profiles of predicted properties.

## Directory Contents

- `run.m`: Main script for running the rock physics regression example.
- `genPseudoWell.m`: Generates synthetic well data.
- `normalizeData.m`: Normalizes data for IGMN.
- `plotResults.m`: Visualizes results and confidence intervals.
- `kdeInversion.m`: Performs KDE-based inversion for comparison.

## Additional Resources

For more information about the IGMN algorithm, consult the [IGMN-MATLAB documentation](../../../README.md).

## License

This example is distributed under the same license as the **IGMN-MATLAB** library. See the [LICENSE](../../../LICENSE.md) file for more details.