# IGMN-MATLAB Library

The **IGMN-MATLAB** library provides tools for implementing Incremental Gaussian Mixture Networks (IGMN) for various machine learning tasks, including regression, classification, and geophysical data inversion. This repository contains examples, utilities, and documentation to demonstrate the library's capabilities.

---

## Key Features

- **Incremental Learning**: Train Gaussian Mixture Models incrementally without requiring the entire dataset in memory.
- **Versatile Applications**: Supports regression, classification, and geophysical data inversion tasks.
- **Seamless MATLAB Integration**: Fully compatible with MATLAB, leveraging its computational capabilities.

---

## Getting Started

### Prerequisites

Ensure the following before using the library:

- MATLAB (R2020b or later recommended) is installed.
- The **IGMN-MATLAB** library is set up correctly.
- Some examples may require additional toolboxes, such as:
  - [SeisLab Toolbox](https://www.mathworks.com/matlabcentral/fileexchange/53109-seislab-3-02) for seismic data processing.
  - [GeoStatRockPhysics](https://github.com/leandrofgr/GeoStatRockPhysics) for geostatistical operations.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/mazzutti/igmn-matlab.git
   ```
2. Add the library to your MATLAB path:
   ```matlab
   addpath(genpath('path/to/igmn-matlab'));
   ```
   
---

## Examples

The repository includes several examples to showcase the application of the IGMN algorithm:

### 1. [Sine Function Regression](examples/regression/sin/README.md)
Learn how to use the IGMN algorithm to model and predict a sine function. This example includes:

- Generating a sine wave dataset.
- Training the IGMN model.
- Visualizing the results.


---

### 2. [North Sea 1D Application](examples/regression/NorthSe-1D-Application/README.md)
Apply the IGMN algorithm to a real-world dataset from the North Sea. This example covers:

- Dataset preparation.
- Model training.
- Prediction visualization.

---

### 3. [UNISIM Time-Lapse](examples/regression/UNISIM-TimeLapse/README.md)
This example integrates IGMN with Kriging for spatial conditioning, enabling robust predictions of reservoir properties over time. It includes:

- Loading and preprocessing UNISIM data.
- Training the IGMN model.
- Applying Kriging for spatial conditioning.
- Evaluating results using RMSE metrics.

---

### 4. [Marmousi Inversion](examples/regression/marmousi/README.md)
Explore stratified partitioning of the Marmousi dataset for regression tasks. This example includes:

- Dataset partitioning into training, testing, and validation sets.
- Synthetic data generation using Gaussian Mixture Models (GMMs).
- Model training and evaluation.

---

### 5. [Rock Physics Inversion](examples/regression/rock_physics/README.md)
This example demonstrates the application of IGMN to synthetic rock physics data. It includes:

- Generating synthetic well data.
- Training the IGMN model.
- Predicting rock physics properties such as P-wave velocity, S-wave velocity, and density.
- Comparing results with Rock Physics KDE Inversion.

---

## Usage

1. Navigate to the desired example folder.
2. Add the required dependencies to the MATLAB path:
   ```matlab
   addpath('../../igmn/');
   ```
3. Run the main script (e.g., `run.m`) in the folder to execute the example.

---

## Documentation

For detailed documentation on the IGMN algorithm and its applications, refer to the resources provided in the repository.

---

## License

This project is distributed under the MIT License. See the [LICENSE](LICENSE.md) file for more details.

---

## Author

**Tiago Mazzutti**  
Email: tiagomzt at gmail dot com  

---

## Contributing

Contributions are welcome! If you have suggestions, bug reports, or feature requests, feel free to open an issue or submit a pull request.

---

## Additional Resources

- [SeisLab Toolbox](https://www.mathworks.com/matlabcentral/fileexchange/53109-seislab-3-02)  for seismic data processing.
- [GeoStatRockPhysics](https://github.com/leandrofgr/GeoStatRockPhysics) for geostatistical operations.
- Research papers (TODO) and documentation included in the repository.