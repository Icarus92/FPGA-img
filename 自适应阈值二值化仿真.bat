@echo off
echo 自适应阈值二值化仿真
echo:
cd %~dp0
echo 输入自适应窗口的半径
echo 可选值: 5  10  20  40  80
@set /p s0=
copy vfiles\binarization\b%s0%.v vfiles\binarization.v
copy vfiles\binarization\bt%s0%.v vfiles\binarization_tb.v
iverilog\bin\iverilog -o binsim.vvp vfiles\binarization.v vfiles\binarization_tb.v
iverilog\bin\vvp -n binsim.vvp -lxt2
del binsim.vvp
echo:
@set /p s1= 输入y显示波形  
echo:
if %s1%==y iverilog\gtkwave\bin\gtkwave lxtwave\bin.lxt
echo:
@set /p s2= 输入y启动matlab显示图片  
echo:
if %s2%==y matlab -nodesktop -nosplash -r M_display_bin
pause
