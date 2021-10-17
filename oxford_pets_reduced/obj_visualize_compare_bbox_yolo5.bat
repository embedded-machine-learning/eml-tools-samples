@echo off 
setlocal enabledelayedexpansion 

set USERNAME=wendt
set USEREMAIL=alexander.wendt@tuwien.ac.at
set MODELNAME=tf2oda_ssdmobilenetv2_320x320_emlvideo_LR08
set PYTHONENV=tf26
set SCRIPTPREFIX=..\..\scripts-and-guides\scripts

echo #######################################
echo # View images                         #
echo #######################################

set FOLDERLIST[0]=Abyssinian_179.jpg
set FOLDERLIST[1]=american_bulldog_19.jpg
set FOLDERLIST[2]=american_bulldog_100.jpg
set FOLDERLIST[3]=american_bulldog_105.jpg
set FOLDERLIST[4]=american_bulldog_126.jpg
set FOLDERLIST[5]=american_bulldog_129.jpg

set SUBFOLDER=validation

rem SET IMAGESET=PETS09_S1L1_t1357_view001

:: Environment preparation
echo Activate environment %PYTHONENV%
call conda activate %PYTHONENV%

for /l %%n in (0, 1, 2) do ( 
   echo !FOLDERLIST[%%n]!
   call python %SCRIPTPREFIX%\inference_evaluation\obj_visualize_compare_bbox.py ^
   --labelmap="annotations/pets_label_map.pbtxt" ^
   --color_gt ^
   --output_dir="results/pt_yolov5s_640x360_oxfordpets_e300/TeslaV100/inference_images" ^
   --image_path1="images/%SUBFOLDER%/!FOLDERLIST[%%n]!" --annotation_dir1="annotations/xmls" --title1="Oxford Pets Example GT" ^
   --image_path2="images/%SUBFOLDER%/!FOLDERLIST[%%n]!" --annotation_dir2="results/pt_yolov5s_640x360_oxfordpets_e300/TeslaV100/det_xmls" --title2="YoloV5 640x360"
::   --image_path3="images/train/!FOLDERLIST[%%n]!_frame_0101.jpg" --annotation_dir3="annotations/xmls/train" --title3="!FOLDERLIST[%%n]! Image 0101" 
::   --use_three_images
)

echo Finished
