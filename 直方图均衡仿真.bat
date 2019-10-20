@echo off
echo 直方图均衡仿真
echo:
cd %~dp0
iverilog\bin\iverilog -o histsim.vvp vfiles\histEqual.v vfiles\histEqual_tb.v
iverilog\bin\vvp -n histsim.vvp -lxt2
del histsim.vvp
echo:
@set /p s1= 输入y显示波形  
echo:
if %s1%==y iverilog\gtkwave\bin\gtkwave lxtwave\hist.lxt
echo:
@set /p s2= 输入y启动matlab显示图片  
echo:
if %s2%==y matlab -nodesktop -nosplash -r M_display_hist
pause



