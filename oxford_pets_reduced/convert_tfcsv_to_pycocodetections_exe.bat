echo #==============================================#
echo # CDLEML Process TF2 Object Detection API
echo #==============================================#

echo run this files in the root of a project

:: Constants Definition
set USERNAME=wendt
set USEREMAIL=alexander.wendt@tuwien.ac.at
set MODELNAME=tf2oda_ssdmobilenetv2_300x300_pets
set PYTHONENV=tf24
set BASEPATH=.
set SCRIPTPREFIX=..\..\scripts-and-guides\scripts
set LABELMAP=pets_label_map.pbtxt

:: Environment preparation
echo Activate environment %PYTHONENV%
call conda activate %PYTHONENV%

echo #====================================#
echo # Convert to Pycoco Tools JSON Format
echo #====================================#

python %SCRIPTPREFIX%\conversion\convert_tfcsv_to_pycocodetections.py ^
--annotation_file="results/%MODELNAME%/validation_for_inference/detections.csv" ^
--output_file="results/%MODELNAME%/validation_for_inference/coco_pets_detection_annotations.json
