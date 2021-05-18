@echo off

:main
:: Constant Definition
set USEREMAIL=alexander.wendt@tuwien.ac.at
set MODELNAME=tf2oda_ssdmobilenetv2_300x300_pets_D100_OVFP16
set PYTHONENV=tf24
set SCRIPTPREFIX=..\..\scripts-and-guides\scripts
set LABELMAP=pets_label_map.pbtxt
set HARDWARENAME=Inteli7dp3510
set HARDWARETYPE=CPU

::OpenVino Constant Defintion
::Inference uses a different version than model conversion.
set OPENVINOINSTALLDIR="C:\Program Files (x86)\Intel\openvino_2021.2.185"
set SETUPVARS="C:\Program Files (x86)\Intel\openvino_2021.2.185\bin\setupvars.bat"
::set OPENVINOINSTALLDIR="C:\Projekte\21_SoC_EML\openvino"
::set SETUPVARS="C:\Projekte\21_SoC_EML\openvino\scripts\setupvars\setupvars.bat"


::======== Get model from file name ===============================
::Extract the model name from the current file name
::set THISFILENAME=%~n0
::set MODELNAME=%THISFILENAME:openvino_convert_tf2_to_ir_=%
::echo Current model name extracted from filename: %MODELNAME%
::======== Get file name ===============================

::powershell: cmd /c '"C:\Program Files (x86)\Intel\openvino_2021\bin\setupvars.bat"'
:: cmd: "C:\Program Files (x86)\Intel\openvino_2021\bin\setupvars.bat"

:: Environment preparation
echo Activate environment %PYTHONENV%
call conda activate %PYTHONENV%

:: Setup OpenVino Variables
echo Setup OpenVino Variables %SETUPVARS%
call %SETUPVARS%


call :perform_inference

goto :eof

::===================================================================::

:perform_inference

echo Apply to model %MODELNAME% with precision %HARDWARETYPE%

echo #====================================#
echo # Infer with OpenVino
echo #====================================#
python %SCRIPTPREFIX%\hardwaremodules\openvino\test_write_results.py ^
--model_path="exported-models-openvino/%MODELNAME%/saved_model.xml" ^
--image_dir="images/validation" ^
--device=%HARDWARETYPE% ^
--detections_out="results/%MODELNAME%/%HARDWARENAME%/detections.csv"

echo #====================================#
echo # Convert Detections to Pascal VOC Format
echo #====================================#
echo Convert TF CSV Format (similar to voc) to Pascal VOC XML
python %SCRIPTPREFIX%\conversion\convert_tfcsv_to_voc.py ^
--annotation_file="results/%MODELNAME%/%HARDWARENAME%/detections.csv" ^
--output_dir="results/%MODELNAME%/%HARDWARENAME%/det_xmls" ^
--labelmap_file="annotations/%LABELMAP%"

echo #====================================#
echo # Convert to Pycoco Tools JSON Format
echo #====================================#
echo Convert TF CSV to Pycoco Tools csv
python %SCRIPTPREFIX%\conversion\convert_tfcsv_to_pycocodetections.py ^
--annotation_file="results/%MODELNAME%/%HARDWARENAME%/detections.csv" ^
--output_file="results/%MODELNAME%/%HARDWARENAME%/%MODELNAME%_coco_detections.json"

echo #====================================#
echo # Evaluate with Coco Metrics
echo #====================================#

python %SCRIPTPREFIX%\inference_evaluation\objdet_pycoco_evaluation.py ^
--groundtruth_file="annotations/coco_pets_validation_annotations.json" ^
--detection_file="results/%MODELNAME%/%HARDWARENAME%/%MODELNAME%_coco_detections.json" ^
--output_file="results/performance.csv" ^
--model_name=%MODELNAME% ^
--hardware_name=%HARDWARENAME%

echo "Inference accuray finished"
goto :eof

:end