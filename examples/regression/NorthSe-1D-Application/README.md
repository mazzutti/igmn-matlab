# Regression Example: North Sea 1D Application

This example demonstrates the use of the **IGMN-MATLAB** library for regression tasks applied to North Sea 1D data.

## Overview

The purpose of this example is to illustrate how the Incremental Gaussian Mixture Network (IGMN) can be utilized for regression on a real-world dataset. The steps include:

- Preparing the North Sea 1D dataset.
- Training the IGMN model on the dataset.
- Visualizing the results.

## Prerequisites

Before running this example, ensure the following:

- MATLAB is installed on your system.
- The **IGMN-MATLAB** library is set up correctly. Refer to the [main repository](../../../README.md) for installation instructions.

## How to Run

1. Open MATLAB and navigate to the `examples/regression/NorthSe-1D-Application` directory.
2. Execute the main script `run.m` by running the following command:

    ```matlab
    run('run.m');
    ```

## What to Expect

When you run the script, it will:

1. Load the North Sea 1D dataset.
2. Train the IGMN model using the dataset.
3. Display plots comparing the original data and the model's predictions.

## Directory Contents

- `run.m`: Main script for running the regression example.
- `codegen/`: Contains generated code for optimizing and training the IGMN model.
- `README.md`: Documentation for the North Sea 1D regression example.

## Additional Resources

For more information about the IGMN algorithm, consult the [IGMN-MATLAB documentation](../../../README.md).

## License

This example is distributed under the same license as the **IGMN-MATLAB** library. See the [LICENSE](../../../LICENSE.md) file for more details.