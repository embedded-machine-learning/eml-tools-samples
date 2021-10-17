echo #==============================================#
echo # CDLEML Process TF2 Object Detection API
echo #==============================================#

:: Constant Definition
set USERNAME=wendt
set USEREMAIL=alexander.wendt@tuwien.ac.at
set MODELNAME=ssd_mobilenet_v2_R300x300_D100_coco17_pets
set PYTHONENV=tf26
set SCRIPTPREFIX=..\..\scripts-and-guides\scripts
::set SCRIPTPREFIX=..\..\..\
set LABELMAP=pets_label_map.pbtxt

:: Environment preparation
echo Activate environment %PYTHONENV%
call conda activate %PYTHONENV%

echo #====================================#
echo # Convert TF CSV Format (similar to voc) to Pascal VOC XML
echo #====================================#

python %SCRIPTPREFIX%\conversion\convert_tfcsv_to_voc.py ^
--annotation_file="results/pt_yolov5s_640x360_oxfordpets_e300/TeslaV100/detections.csv" ^
--output_dir="results/pt_yolov5s_640x360_oxfordpets_e300/TeslaV100/voc_xmls" ^
--labelmap_file="annotations/%LABELMAP%"

