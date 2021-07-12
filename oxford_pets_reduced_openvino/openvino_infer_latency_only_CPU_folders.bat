@echo off

:main
:: Constant Definition
set USEREMAIL=alexander.wendt@tuwien.ac.at
::set MODELNAME=tf2oda_efficientdet_512x512_pedestrian_D0_LR02
set PYTHONENV=tf24
set SCRIPTPREFIX=..\..\scripts-and-guides\scripts
set LABELMAP=label_map.pbtxt
set HARDWARENAME=Inteli7dp3510

::OpenVino Constant Defintion
::Inference uses a different version than model conversion.
set OPENVINOINSTALLDIR="C:\Program Files (x86)\Intel\openvino_2021.2.185"
set SETUPVARS="C:\Program Files (x86)\Intel\openvino_2021.2.185\bin\setupvars.bat"
::set OPENVINOINSTALLDIR="C:\Projekte\21_SoC_EML\openvino"
::set SETUPVARS="C:\Projekte\21_SoC_EML\openvino\scripts\setupvars\setupvars.bat"

set APIMODE=sync


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

::Use this method to use all folder names in the subfolder as models
echo Convert files in the folder exported-models-openvino
set MODELFOLDER=exported-models-openvino
::set MODELFOLDER=tmp\run_subset
for /d %%D in (%MODELFOLDER%\*) do (
	::For each folder name in exported models, 
	set MODELNAME=%%~nxD
	
	for %%x in (CPU) do (
		::For each possible quantization
		set HARDWARETYPE=%%x
		call :perform_inference
	)
)
goto :eof

::===================================================================::

:perform_inference

echo Apply to model %MODELNAME% with precision %HARDWARETYPE%

echo #====================================#
echo # Infer with OpenVino
echo #====================================#
echo "Start latency inference"
python %SCRIPTPREFIX%\hardwaremodules\openvino\run_pb_bench_sizes.py ^
-openvino_path %OPENVINOINSTALLDIR% ^
-hw %HARDWARETYPE% ^
-batch_size 1 ^
-api %APIMODE% ^
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
python %SCRIPTPREFIX%\hardwaremodules\openvino\openvino_latency_parser.py ^
--avg_rep results/%MODELNAME%/%HARDWARENAME%/openvino\benchmark_average_counters_report_%HARDWARETYPE%_%APIMODE%.csv ^
--inf_rep results/%MODELNAME%/%HARDWARENAME%/openvino\benchmark_report_%HARDWARETYPE%_%APIMODE%.csv ^
--output_path results/latency.csv ^
--hardware_name %HARDWARENAME%
::--save_new #Always append



echo "Inference finished"
goto :eof

:end