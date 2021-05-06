@echo off

:main

@echo #==============================================#
@echo # CDLEML Process TF2 Object Detection on OpenVino
@echo #==============================================#
@echo This script converts TF2 exported models to the OpenVino IR format for FP16 and FP32 and performs inference on the converted models

:: Constant Definition
set USEREMAIL=alexander.wendt@tuwien.ac.at
::set MODELNAME=tf2oda_efficientdetd2_768_576_coco17_pedestrian
set HARDWARENAME=Inteli7dp3510
set PYTHONENV=tf24
set SCRIPTPREFIX=..\..\scripts-and-guides\scripts
set LABELMAP=pets_label_map.pbtxt

:: OpenVino Input
set OPENVINOINSTALLDIR_CONVERT="C:\Projekte\21_SoC_EML\openvino"
set SETUPVARS_CONVERT="C:\Projekte\21_SoC_EML\openvino\scripts\setupvars\setupvars.bat"
set OPENVINOINSTALLDIR="C:\Program Files (x86)\Intel\openvino_2021.2.185"
set SETUPVARS="C:\Program Files (x86)\Intel\openvino_2021.2.185\bin\setupvars.bat"

::set MODELDIR=exported-models\%MODELNAME%\saved_model
::set PIPELINEDIR=exported-models\%MODELNAME%\pipeline.config
::set APIFILE=..\..\scripts-and-guides\scripts\hardwaremodules\openvino\openvino_conversion_config\efficient_det_support_api_v2.4.json
set APIFILE=..\..\scripts-and-guides\scripts\hardwaremodules\openvino\openvino_conversion_config\ssd_support_api_v2.4.json

::Extract the model name from the current file name
::set THISFILENAME=%~n0
::set MODELNAME=%THISFILENAME:tf2oda_inference_and_evaluation_from_saved_model_=%
::echo Current model name extracted from filename: %MODELNAME%

:: Environment preparation
@echo Activate environment %PYTHONENV%
call conda activate %PYTHONENV%

:: only name %%~nxD
:: full path %%~fD
:: THISFILENAME=%~n0

::if not x%str1:bcd=%==x%str1%

:: Setup OpenVino Variables for conversion
echo Setup OpenVino Variables %SETUPVARS_CONVERT%
call %SETUPVARS_CONVERT%

::Use this method to use all folder names in the subfolder as models
echo Convert files
set MODELFOLDER=exported-models
for /d %%D in (%MODELFOLDER%\*) do (
	::For each folder name in exported models, 
	set MODELNAME=%%~nxD
	call :perform_conversion
)

:: Setup OpenVino Variables for inference
echo Setup OpenVino Variables %SETUPVARS%
call %SETUPVARS%

::Use this method to use all folder names in the subfolder as models
echo Perform inference
set MODELFOLDER=exported-models-openvino
for /d %%D in (%MODELFOLDER%\*) do (
	::For each folder name in exported models, 
	set MODELNAME=%%~nxD
	call :perform_inference
)

:: Use this methods to iterate through a list MODELS
::SET MODELS=^
::tf2oda_ssdmobilenetv2_576x256_pedestrian ^
::tf2oda_efficientdet_640x480_pedestrian_D2

::for %%x in (%MODELS%) do (
::		set MODELNAME=%%x
::		call :perform_inference
::      )


goto :end


:perform_conversion
echo Apply to model %MODELNAME%

echo #====================================#
echo # Convert TF2 Model to OpenVino Intermediate Representation
echo #====================================#
echo "Start conversion"
python %OPENVINOINSTALLDIR_CONVERT%\model-optimizer\mo_tf.py ^
--saved_model_dir="exported-models\%MODELNAME%\saved_model" ^
--tensorflow_object_detection_api_pipeline_config=exported-models\%MODELNAME%\pipeline.config ^
--transformations_config=%APIFILE% ^
--reverse_input_channels ^
--data_type FP16 ^
--output_dir=exported-models-openvino\%MODELNAME%

echo "Conversion finished"


:perform_inference
echo Apply to model %MODELNAME%

echo #====================================#
echo # Infer with OpenVino
echo #====================================#
echo "Start latency inference"
python %SCRIPTPREFIX%\hardwaremodules\openvino\run_pb_bench_sizes.py ^
-openvino_path %OPENVINOINSTALLDIR% ^
-hw CPU ^
-batch_size 1 ^
-api sync ^
-niter 100 ^
-xml exported-models-openvino/%MODELNAME%/saved_model.xml ^
-output_dir="results/%MODELNAME%/%HARDWARENAME%/OpenVino"

::-size [1,320,320,3] ^
::-hw (CPU|MYRIAD)
::-size (batch, width, height, channels=3)
::-pb Frozen file

echo #====================================#
echo # Convert Latencies
echo #====================================#
echo "Add measured latencies to result table"
python %SCRIPTPREFIX%\hardwaremodules\openvino\latency_parser\openvino_latency_parser.py ^
--avg_rep results/%MODELNAME%/%HARDWARENAME%/OpenVino_sync\benchmark_average_counters_report_saved_model_CPU_sync.csv ^
--inf_rep results/%MODELNAME%/%HARDWARENAME%/OpenVino_sync\benchmark_report_saved_model_CPU_sync.csv ^
--output_path results/latency.csv

::--save_new #Always append

echo "Inference finished"





::echo #====================================#
::echo # Infer Images from Known Model
::echo #====================================#

::echo Inference from model 
::python %SCRIPTPREFIX%\inference_evaluation\tf2oda_inference_from_saved_model.py ^
::--model_path "exported-models/%MODELNAME%/saved_model/" ^
::--image_dir "images/validation" ^
::--labelmap "annotations/%LABELMAP%" ^
::--detections_out="results/%MODELNAME%/%HARDWARENAME%/detections.csv" ^
::--latency_out="results/latency_%HARDWARENAME%.csv" ^
::--min_score=0.5 ^
::--model_name=%MODELNAME% ^
::--hardware_name=%HARDWARENAME%

::--model_short_name=%MODELNAMESHORT% unused because the name is created in the csv file


::echo #====================================#
::echo # Convert to Pycoco Tools JSON Format
::echo #====================================#
::echo Convert TF CSV to Pycoco Tools csv
::python %SCRIPTPREFIX%\conversion\convert_tfcsv_to_pycocodetections.py ^
::--annotation_file="results/%MODELNAME%/%HARDWARENAME%/detections.csv" ^
::--output_file="results/%MODELNAME%/%HARDWARENAME%/%MODELNAME%_coco_detections.json"

::echo #====================================#
::echo # Evaluate with Coco Metrics
::echo #====================================#

::python %SCRIPTPREFIX%\inference_evaluation\objdet_pycoco_evaluation.py ^
::--groundtruth_file="annotations/coco_pets_validation_annotations.json" ^
::--detection_file="results/%MODELNAME%/%HARDWARENAME%/%MODELNAME%_coco_detections.json" ^
::--output_file="results/performance_%HARDWARENAME%.csv" ^
::--model_name=%MODELNAME% ^
::--hardware_name=%HARDWARENAME%

echo #====================================#
echo # Move executed models to exported inferred
echo #====================================#
md exported-models-inferred
call move .\exported-models\%MODELNAME% exported-models-inferred

goto :eof

:end