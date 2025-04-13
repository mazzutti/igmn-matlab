# Regression Example: Sine Function

This example demonstrates the use of the **IGMN-MATLAB** library for regression tasks using a sine function dataset.

## Overview

The purpose of this example is to illustrate how the Incremental Gaussian Mixture Network (IGMN) can be utilized to learn and predict a sine function. The steps include:

- Generating a sine wave dataset.
- Training the IGMN model on the dataset.
- Visualizing the results.

## Prerequisites

Before running this example, ensure the following:

- MATLAB is installed on your system.
- The **IGMN-MATLAB** library is set up correctly. Refer to the [main repository](../../../README.md) for installation instructions.

## How to Run

1. Open MATLAB and navigate to the `examples/regression/sin` directory.
2. Execute the script `run_native.m` by running the following command:

    ```matlab
    run('run_native.m');
    ```

## What to Expect

When you run the script, it will:

1. Create a sine wave dataset.
2. Train the IGMN model using the dataset.
3. Display a plot comparing the original sine wave and the model's predictions.

## Directory Contents

- `run_native.m`: Executes a regression example using the IGMN algorithm.
- `README.md`: Documentation for the sine regression example.

## Additional Resources

For more information about the IGMN algorithm, consult the [IGMN-MATLAB documentation](../../../README.md).

## License

This example is distributed under the same license as the **IGMN-MATLAB** library. See the [LICENSE](../../../LICENSE) file for more details.