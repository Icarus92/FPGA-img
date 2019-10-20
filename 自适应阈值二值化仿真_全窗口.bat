@echo off
echo 自适应阈值二值化仿真 
echo 窗口半径 5  10  20  40  80
echo:
cd %~dp0

set s0=5
copy vfiles\binarization\b%s0%.v vfiles\binarization.v
copy vfiles\binarization\bt%s0%.v vfiles\binarization_tb.v
iverilog\bin\iverilog -o binsim.vvp vfiles\binarization.v vfiles\binarization_tb.v
iverilog\bin\vvp binsim.vvp

set s0=10
copy vfiles\binarization\b%s0%.v vfiles\binarization.v
copy vfiles\binarization\bt%s0%.v vfiles\binarization_tb.v
iverilog\bin\iverilog -o binsim.vvp vfiles\binarization.v vfiles\binarization_tb.v
iverilog\bin\vvp binsim.vvp

set s0=20
copy vfiles\binarization\b%s0%.v vfiles\binarization.v
copy vfiles\binarization\bt%s0%.v vfiles\binarization_tb.v
iverilog\bin\iverilog -o binsim.vvp vfiles\binarization.v vfiles\binarization_tb.v
iverilog\bin\vvp binsim.vvp

set s0=40
copy vfiles\binarization\b%s0%.v vfiles\binarization.v
copy vfiles\binarization\bt%s0%.v vfiles\binarization_tb.v
iverilog\bin\iverilog -o binsim.vvp vfiles\binarization.v vfiles\binarization_tb.v
iverilog\bin\vvp binsim.vvp

set s0=80
copy vfiles\binarization\b%s0%.v vfiles\binarization.v
copy vfiles\binarization\bt%s0%.v vfiles\binarization_tb.v
iverilog\bin\iverilog -o binsim.vvp vfiles\binarization.v vfiles\binarization_tb.v
iverilog\bin\vvp binsim.vvp

del binsim.vvp

echo:
@set /p s2= 输入y启动matlab显示图片  
echo:
if %s2%==y matlab -nodesktop -nosplash -r M_display_bin
pause
