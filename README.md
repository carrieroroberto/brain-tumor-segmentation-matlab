# Brain Tumor Segmentation in MRI: Comparative Analysis of Single-Sequence vs Multi-Sequence Approaches
![MATLAB R2025b](https://img.shields.io/badge/MATLAB-R2025b-orange?logo=mathworks&logoColor=white)

- **Author:** Roberto Carriero
- **Course:** Image Processing - 2025/2026
- **Program:** M.Sc. Computer Science Engineering (Artificial Intelligence and Data Science) - Politecnico di Bari

---

## Project Overview

The goal of this project is to implement, evaluate and compare a segmentation pipeline for brain tumors using MRI scans from the BraTS (Medical Segmentation Decathlon) dataset. 

The analysis compares 5 distinct experimental configurations:
1. **Single FLAIR**
2. **Single T1c**
3. **Single T2**
4. **Bimodal Fusion (FLAIR + T1c)**
5. **Multimodal Fusion (FLAIR + T1c + T2)**

The segmentation is achieved through a cascaded pipeline: **Multi-level Otsu Thresholding -> Region Growing -> Marker-Controlled Watershed**, which prevents over-segmentation while maintaining high precision.

## Running Instructions

**Step 1: Download Dataset**

The original MRI data (in NIfTI `.nii.gz` format) is required to run the code. Due to file size constraints, they are not included directly in this repository.
1. To download the dataset, visit the following shared OneDrive folder: **[Download Dataset](https://shorturl.at/3DwTw)**
2. Download the `dataset/` folder.
3. Move the downloaded folder into the root of this repository.

**Step 2: Environment Setup**
1. Open **MATLAB**.
2. Set the `brain-tumor-segmentation-matlab` folder as your **Current Folder** in MATLAB (or open the associated .prj file directly).
   
**Step 3: Exploratory Data Analysis (EDA)**
1. Open and run the `data_exploration.m` script.
2. **What to expect:** This script isolates a single patient and generates plots of the 4 MRI sequences, their respective intensity histograms and a 3D rendering (`volshow`) of the volume.

**Step 4: Pipeline Execution**
1. Open and run the `main.m` script.
2. **What to expect:** The script will automatically loop through the dataset. You will see real-time updates in the MATLAB **Command Window** showing the Dice Score for each of the 5 configurations per patient.
3. **Outputs:** The pipeline exports results in the `results/` folder, organized as follows:
   - `metrics/`: Contains `detailed.csv` (per-patient metrics) and `global.csv` (aggregated Dice, Sensitivity, Precision).
   - `plots/<patient_name>/`: A dedicated folder for each patient, further divided into:
     - `pre_processing/`: Breakdown of raw data, Z-Score normalization, median filter for denoising and fusion steps.
     - `segmentation/`: Step-by-step evolution (Otsu -> Region Growing -> Watershed) and the final comparison.
     - `post_processing/`: Before/After morphological refinement comparisons.

## Project Architecture

```text
brain-tumor-segmentation-matlab/
│
├── main.m                          % Runs the pipeline and generates the final comparison plots
├── data_exploration.m              % Script for standalone EDA
├── README.md                       % Project overview and instructions
│
├── dataset/                        % Folder for input NIfTI volumes
│
├── results/                        % Generated outputs during execution
│   ├── metrics/                    % Per-patient and global average metrics in CSV format
│   └── plots/                      % Folder for visual outputs
│       └── <patient_name>/         % Patient-specific folder(s)
│           ├── pre_processing/     % Shows EDA, Z-Score, Denoising and Fusion steps
│           ├── segmentation/       % Shows seed map, segmentation of single sequences and final results.
│           └── post_processing/    % Morphological operations plots
│
├── src/                            % Folders of MATLAB custom functions
│   ├── pre_processing.m            % Z-score, Median Filter, Fusion logic and pre-processing plotting
│   ├── segmentation.m              % Cascaded pipeline (Otsu->RG->Watershed) and evolution plotting
│   ├── region_growing.m            % Custom implementation of the Region Growing algorithm
│   ├── post_processing.m           % Morphological operations and before/after plotting
│   └── evaluation.m                % Computes Dice Score, Sensitivity (Recall) and Precision
│
└── deliverables/                   % Materials to submit
    ├── presentation.pptx           % Project presentation slides
    └── report/                     % Source files of written report
        ├── report.pdf              % Compiled PDF of the report
        └── latex/                  % LaTeX source files