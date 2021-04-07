# Sample Set Oxford Pets Reduced

## Preparation
Create or download or clone the following folder structure in a base structure ./
- scripts-and-guides-samples
- scripts-and-guides

Setup TF2 Object detection API

Goto ./scripts-and-guides-samples/oxford_pets_reduced

## How to apply the Coco evaluation metric

### Generate Coco ground truth annotations
Files: 
- All Pascal VOC files can be found in annotations/xmls
- annotations/validation_files.txt: Selected files for ground truth for validation data
- annotations/labels.txt: Class labels cat and dog for the images
- coco_pets_validation_annotations.json: Coco ground truth with subset of validation images


Script for ground truth generation: convert_voc_to_coco_ground_truth.bat

Python script to be executed: conversion\convert_voc_to_coco.py

Result: coco_pets_validation_annotations.json

### Execute Inference Engine for TF2ODA
Execution script: tf2oda_inference_from_saved_model_exe.bat

python %SCRIPTPREFIX%\inference_evaluation\tf2oda_inference_from_saved_model.py ^ (python script path)
--model_path="exported-models/%MODELNAME%/saved_model/" ^ (folder of saved model)
--image_dir="images/validation" ^ (folder of validaton images, here only a small subset)
--labelmap="annotations/%LABELMAP%" ^ (TF2 labelmap file ./annotations/pets_label_map.pbtxt)
--detections_out="results/%MODELNAME%/validation_for_inference/detections.csv" ^ (TF2 Detections saved as csv)
--latency_out="results/latency.csv" ^ (Latency output)
--min_score=0.5 ^ (min score to add the detection to detections.csv)
--model_name=%MODELNAME% ^ (Model name long to be used in the evaluation)
--model_short_name=%MODELNAMESHORT% ^ (Model name shortform to be used in the evaluation)
--hardware_name=%HARDWARENAME% (Hardware name long to be used in the evaluation)

Results of inference: latency.csv and detections.csv

Latency.csv is ready for usage in visualization tools

### Convert Detections to Coco Detections Input
Execution script: convert_tfcsv_to_pycocodetections_exe.bat

python %SCRIPTPREFIX%\conversion\convert_tfcsv_to_pycocodetections.py ^ (python script path)
--annotation_file="results/%MODELNAME%/validation_for_inference/detections.csv" ^ (Input file detections.csv)
--output_file="results/%MODELNAME%/validation_for_inference/coco_pets_detection_annotations.json (Coco detections output file for evaluation)

Results: coco_pets_detection_annotations.json

### Coco Evaluation
Execution script: objdet_pycoco_evaluation_exe.bat

python %SCRIPTPREFIX%\inference_evaluation\objdet_pycoco_evaluation.py ^ (python script path)
--groundtruth_file="annotations/coco_pets_validation_annotations.json" ^ (Ground truth in coco format)
--detection_file="results/%MODELNAME%/validation_for_inference/coco_pets_detection_annotations.json" ^ (Detections in coco format)
--output_file="results/performance.csv" ^ (output)
--model_name=%MODELNAME% ^ (Model name in EML syntax for the output file)
--hardware_name="Intel_CPU_i5" (Hardware name)

Results: performance.csv

