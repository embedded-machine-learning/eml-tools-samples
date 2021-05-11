@echo off

:main
:: Constant Definition
set USEREMAIL=alexander.wendt@tuwien.ac.at
::set MODELNAME=tf2oda_ssdmobilenetv2_320x320_pedestrian
set MODELNAME=tf2oda_ssdmobilenetv2_300x300_pets
::set MODELNAME=tf2oda_efficientdet_512x512_pedestrian_D0_LR02
set PYTHONENV=tf24
set SCRIPTPREFIX=..\..\scripts-and-guides\scripts
set LABELMAP=pets_label_map.pbtxt
set HARDWARENAME=Inteli7dp3510

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
python %SCRIPTPREFIX%\hardwaremodules\openvino\result_parser\test_write_results.py ^
--model exported-models-openvino/tf2oda_ssdmobilenetv2_300x300_pets_D100_OVFP16/saved_model.xml ^
--input=images/validation

echo "Inference accuray finished"
goto :eof

:end