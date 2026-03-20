# Brain Tumor Segmentation in MRI: Comparative Analysis of Single-Sequence vs Multi-Sequence Approaches
![MATLAB R2025b](https://img.shields.io/badge/MATLAB-R2025b-orange?logo=mathworks&logoColor=white)

- **Author:** Roberto Carriero
- **Course:** Image Processing - 2025/2026
- **Program:** M.Sc. Computer Science Engineering (Artificial Intelligence and Data Science) - Politecnico di Bari

---

## Project Overview

The goal of this project is to implement, evaluate, and compare automatic segmentation paradigms for brain gliomas using MRI scans from the BraTS (Medical Segmentation Decathlon) dataset. 

The analysis compares 5 distinct experimental configurations:
1. **Single FLAIR**
2. **Single T1c**
3. **Single T2**
4. **Bimodal Fusion (FLAIR + T1c)**
5. **Multimodal Fusion (FLAIR + T1c + T2)**

The segmentation is achieved through a cascaded pipeline: **Multi-level Otsu Thresholding -> Region Growing -> Marker-Controlled Watershed**, which effectively prevents over-segmentation while maintaining high precision.

## Running Instructions

**Step 1: Download Dataset**

The original MRI data (in NIfTI `.nii.gz` format) is required to run the code. Due to file size constraints, they are not included directly in this repository.
1. To download the dataset, visit the following shared OneDrive folder: **[Download Dataset](https://shorturl.at/3DwTw)**
2. Download the required files.
3. Move the downloaded content into the `dataset/` folder located in the main directory of this repository.

**Step 2: Environment Setup**
1. Open **MATLAB**.
2. Set the `brain-tumor-segmentation-matlab` folder as your **Current Folder** in MATLAB (or open the associated .prj file directly).
   
**Step 3: Exploratory Data Analysis (EDA)**
1. Open and run the `data_exploration.m` script.
2. **What to expect:** This script isolates a single patient and generates plots of the 4 MRI sequences, their respective intensity histograms, and an interactive 3D rendering (`volshow`) of the volume.

**Step 4: Pipeline Execution**
1. Open and run the `main.m` script.
2. **What to expect:** The script will automatically loop through the dataset. You will see real-time updates in the MATLAB **Command Window** showing the Dice Score for each of the 5 configurations per patient.
3. **Outputs:** The `results/` folder contains:
   - `plots/`: PNG figures generated and saved during the execution for segmentation and intermediate results.
   - `metrics/detailed.csv`: Spreadsheet containing Dice, Sensitivity, and Precision for every single patient.
   - `metrics/global.csv`: The final aggregate metrics.

## Project Architecture

```text
brain-tumor-segmentation-matlab/
│
├── main.m                      % Main script: orchestrates the 5-step ablation study, generating CSV metrics and visual plots
├── data_exploration.m          % Independent script for Exploratory Data Analysis (EDA) with histograms and 3D volshow
├── README.md                   % Project documentation, instructions, and overview
│
├── dataset/                    % Folder for input MRI/NIfTI volumes (e.g., BRATS_001.nii.gz)
│
├── results/                    % Automatically generated outputs during execution
│   ├── plots/                  % High-res, publication-ready 2x3 grid plots comparing GT and 5 predictions
│   └── metrics/                % Detailed per-patient and global average metrics (Dice, Sens, Prec) in CSV format
│
├── src/                        % Collection of MATLAB functions used in the analysis
│   ├── pre_processing.m        % Z-score normalization, CLAHE, Early Fusion logic, and seed map extraction
│   ├── segmentation.m          % The core cascaded pipeline: Otsu -> Region Growing -> Watershed
│   ├── region_growing.m        % Custom Breadth-First Search (BFS) implementation of the Region Growing algorithm
│   ├── post_processing.m       % Morphological regularization (Closing and Hole Filling)
│   ├── evaluation.m            % Computes Dice Score, Sensitivity (Recall), and Precision
│   └── plotting.m              % Handles dynamic background generation and advanced subplot layout with legends
│
└── deliverables/               % Materials prepared for submission
    ├── presentation.pptx       % Project presentation slides
    └── report/                 % Written report and source files
        ├── report.pdf          % Compiled PDF of the academic report
        └── latex/              % LaTeX source files used to generate the report
