# --------------------------------------------------------------
# ----- Cкрипт для автоматического запуска тестов Uart RX ------
# --------------------------------------------------------------

set Project_Name uart_rx_test
set Test_Number 1

# если проект с таким именем существует удаляем его
close_sim -quiet 
close_project -quiet
if { [file exists $Project_Name] != 0 } { 
	file delete -force $Project_Name
	puts "Delete old Project"
}

# создаем проект
create_project $Project_Name ./$Project_Name -part xc7vx485tffg1157-1

# выбераем первый тестовый набор в качествре начального   
set Test_Set_Name ./hdl/header/test_sets/test_set
append Test_Set_Name _$Test_Number
append Test_Set_Name .vh
file copy -force $Test_Set_Name ./hdl/header/test_set.vh

# добавляем заголовочные файлы к проекту
add_files ./hdl/header/Interfaces.vh
add_files ./hdl/header/testbench_settings.vh
add_files ./hdl/header/test_set.vh

# добавляем исходники к проекту
add_files ./hdl/source/UART_RX_to_AXIS.sv

# добавляем тестбенч к проекту
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 ./hdl/testbench/UART_to_AXIS_tb.sv

# обновляем иерархию файлов проекта
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# устанавливаем максимальное время моделирования 
set_property -name {xsim.simulate.runtime} -value {100s} -objects [get_filesets sim_1]

# создаем log файл для результатов тестирования
set Log_Dir_Name log_$Project_Name
file mkdir $Log_Dir_Name
set fileID [open $Log_Dir_Name/Test_Results.txt w]
puts -nonewline $fileID "TEST SET $Test_Number: "
close $fileID

set fileID [open $Log_Dir_Name/Test_Logs.txt w]
puts $fileID ""
puts $fileID "TEST SET $Test_Number: "
close $fileID


launch_simulation
close_sim -quiet 
