# Brain Tumor Segmentation in MATLAB using Traditional Image Processing techniques
[![MATLAB](https://img.shields.io/badge/matlab)](https://www.matlab.com/)

- **Students:** Roberto Carriero
- **Course:** Image Processing (Computer Vision Module) - 2025/2026
- **Program:** M.Sc. Computer Science Engineering (Artificial Intelligence and Data Science) - Politecnico di Bari

---

The goal of this repository is to implement and compare two paradigms for the automatic segmentation of brain gliomas on MRI scans (BraTS/Decathlon dataset): 
1. **Seeded Region Growing** (similarity-based approach).
2. **Marker-Controlled Watershed** (topographic approach).

The entire pipeline is developed in **MATLAB** without the use of neural networks (Deep Learning) or machine learning, to demonstrate the robustness of classic processing algorithms.

---

## Dataset Download
The original MRI data (in NIfTI `.nii.gz` format) is required to run the code. Due to file size constraints, they are not included directly in this repository.

**Import Instructions:**
1. To download the dataset, visit the following shared OneDrive folder: **[Download Dataset](https://shorturl.at/3DwTw)**
2. Download the required files.
3. Move the downloaded content into the `dataset/` folder located in the main directory of this repository.

## Project Architecture

```text
brain-tumor-segmentation/
│
├── main.m                      % Main pipeline script
├── data_exploration.m          % Interactive tool (2D Slider and 3D Rendering) for EDA
├── README.md                   % This documentation
│
├── dataset/                    % Place NIfTI volumes here (e.g., brats_sample.nii.gz)
│
├── results/                    % Automatically generated outputs
│   ├── plots/                  % Comparison plots saved by plot_manager
│   └── metrics/                % Numerical results (Dice Score) in CSV format
│
├── pre_processing/             % [PHASE 1] MRI signal cleaning
│   ├── denoising.m             % Median Filter (edge-preserving)
│   └── enhancement.m           % CLAHE for edema enhancement (FLAIR)
│
├── segmentation/               % [PHASE 2] Algorithmic core
│   ├── otsu_initialization.m   % Automatic Marker and Seed extraction (Multi-level Otsu)
│   ├── region_growing.m        % Region Growing algorithm (8-connectivity)
│   └── marked_watershed.m      % Morphological Gradient and Geodesic Reconstruction
│
├── post_processing/            % [PHASE 3] Refinement
│   └── refinement.m            % Morphological operators (Opening, Closing, Hole Filling)
│
└── results_manager/            % Support tools
    ├── evaluation.m            % Calculation of Dice Similarity Coefficient (DSC)
    └── plot_manager.m          % Generation and export of high-resolution plots
