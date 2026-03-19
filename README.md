# Brain Tumor Segmentation using Traditional Image Processing techniques in MATLAB
![MATLAB R2025b](https://img.shields.io/badge/MATLAB-R2025b-orange?logo=mathworks&logoColor=white)

- **Student:** Roberto Carriero
- **Course:** Image Processing (Computer Vision Module) - 2025/2026
- **Program:** M.Sc. Computer Science Engineering (Artificial Intelligence and Data Science) - Politecnico di Bari

---

The goal of this repository is to implement and compare two paradigms for the automatic segmentation of brain gliomas on MRI scans (BraTS/Decathlon dataset): 
1. **Seeded Region Growing** (similarity-based approach).
2. **Marker-Controlled Watershed** (topographic approach).

The entire pipeline is developed in **MATLAB** (2025b version) without the use of neural networks (Deep Learning) or machine learning, to demonstrate the robustness of classic processing algorithms.

## Dataset Download
The original MRI data (in NIfTI `.nii.gz` format) is required to run the code. Due to file size constraints, they are not included directly in this repository.

**Import Instructions:**
1. To download the dataset, visit the following shared OneDrive folder: **[Download Dataset](https://shorturl.at/3DwTw)**
2. Download the required files.
3. Move the downloaded content into the `dataset/` folder located in the main directory of this repository.

## Project Architecture

```text
brain-tumor-segmentation-matlab/
│
├── main.m                      % main pipeline script: orchestrates the full preprocessing, segmentation, post-processing, and evaluation
├── data_exploration.m          % interactive exploration tool with 2d slider and 3d rendering for dataset inspection
├── README.md                   % project documentation, instructions, and overview
│
├── dataset/                    % folder for input mri/nifti volumes (e.g., brats_sample.nii.gz)
│
├── results/                    % automatically generated outputs during execution
│   ├── plots/                  % saved visualizations comparing original, preprocessed, and segmented images
│   └── metrics/                % numerical evaluation results (e.g., dice score) in csv format
│
├── src/                        % collection of matlab functions used in the analysis
│   ├── pre_processing.m        % automatic marker and seed extraction using multi-level otsu thresholding
│   ├── region_growing.m        % core region growing algorithm with morphological gradient and geodesic reconstruction
│   ├── segmentation.m          % executes the region growing segmentation with 8-connectivity
│   ├── post_processing.m       % refines segmentation output (noise removal, morphological operations)
│   ├── evaluation.m            % computes evaluation metrics like dice coefficient, compares with ground truth
│   └── plotting.m              % functions for generating plots and visualizations for analysis and results
│
└── deliverables/               % materials prepared for submission
    ├── presentation.pptx       % project presentation slides
    └── report/                 % written report and source files
        ├── report.pdf          % compiled pdf of the report
        └── latex/              % latex source files used to generate the report
```
