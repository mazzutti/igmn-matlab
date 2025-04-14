
 # Examples Folder
 
 This folder contains various examples demonstrating the application of the Incremental Gaussian Mixture Network (IGMN) to different problems, including classification and regression tasks. Each subfolder focuses on a specific use case or dataset.
 
 ## Folder Structure
 
 ### Classification
 - **Iris**: Demonstrates the use of IGMN on the Iris dataset.
 
 ### Regression
 - **Marmousi**: Scripts for seismic data inversion using IGMN.
 - **NorthSe-1D-Application**: Scripts for applying IGMN to North Sea 1D data.
 - **Rock Physics**: Scripts for rock physics inversion using IGMN.
 - **Sin**: Demonstrates IGMN on synthetic sine wave data.
 - **UNISIM-TimeLapse**: Time-lapse reservoir simulation experiments.
 
 ## Usage
 
 1. Navigate to the desired example folder.
 2. Add the required dependencies to the MATLAB path:
    ```matlab
    addpath('../../igmn/');
    ```
 3. Run the main script (e.g., `run.m`) in the folder to execute the example.
 
 
 ## Dependencies
 
 - The igmn folder must be included in the MATLAB path.
 - Some examples may require additional toolboxes or external libraries (e.g., Seislab).
 
 ## Purpose
 
 The examples in this folder aim to:
 
 - Showcase the versatility of IGMN across different domains.
 - Provide ready-to-run scripts for testing and benchmarking IGMN.
 - Serve as a starting point for adapting IGMN to new problems.
 
 ## Author
 Tiago Mazzutti