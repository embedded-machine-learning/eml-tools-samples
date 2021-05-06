@echo off
set test=C:\Projekte\21_SoC_EML\scripts-and-guides-samples\oxford_pets_reduced_openvino
set sss="test"

if not x%sss:te=%==x%sss% echo It contains bcd

if "%test%" == "C:\Projekte\21_SoC_EML\scripts-and-guides-samples\oxford_pets_reduced_openvino" (echo yes) else (echo Not Equal)

if "%test%" == "C:\Projekte\21_SoC_EML\scripts-and-guides-samples\oxford_pets_reduced_openvino" (set sss=Hallo) else (set sss=Kaka)
echo %sss%

set APIFILEEFF=..\..\scripts-and-guides\scripts\hardwaremodules\openvino\openvino_conversion_config\efficient_det_support_api_v2.4.json
set APIFILESSD=..\..\scripts-and-guides\scripts\hardwaremodules\openvino\openvino_conversion_config\ssd_support_api_v2.4.json
set APIFILE=ERROR

set MODELNAME=tf2oda_ssdmobilenetv2_300x300_pets

if not x%MODELNAME:ssd=%==x%MODELNAME% (set APIFILE=%APIFILESSD%) else (echo No SSD MobileNet)
if not x%MODELNAME:effi=%==x%MODELNAME% (set APIFILE=%APIFILEFF%) else (echo No EfficientDet)
echo %APIFILE%