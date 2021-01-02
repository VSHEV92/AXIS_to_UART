# --------------------------------------------------------------
# ----- Cкрипт для автоматического запуска тестов Uart RX ------
# --------------------------------------------------------------

# -----------------------------------------------------------
proc launch_test_set {Test_Number Log_Dir_Name} {
	# выбераем первый тестовый набор в качествре начального   
	set Test_Set_Name ./hdl/header/test_sets/test_set
	append Test_Set_Name _$Test_Number
	append Test_Set_Name .svh
	file copy -force $Test_Set_Name ./hdl/header/test_set.svh

	# пишим номер теста в log файлы
	set fileID [open $Log_Dir_Name/Test_Results.txt a]
	puts -nonewline $fileID "TEST SET $Test_Number: "
	close $fileID
   
	set fileID [open $Log_Dir_Name/Test_Logs.txt a]
	puts $fileID ""
	puts $fileID "TEST SET $Test_Number: "
	close $fileID
	
	# запускаем моделирование
	launch_simulation
	close_sim -quiet 
}
# -----------------------------------------------------------

set Project_Name uart_rx_test
set Number_of_Test_Sets 6

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
set Test_Set_Name ./hdl/header/test_sets/test_set_1.svh
file copy -force $Test_Set_Name ./hdl/header/test_set.svh

# добавляем заголовочные файлы к проекту
add_files ./hdl/header/Interfaces.svh
add_files ./hdl/header/testbench_settings.svh
add_files ./hdl/header/test_set.svh

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
close $fileID
set fileID [open $Log_Dir_Name/Test_Logs.txt w]
close $fileID

# запускаем тестовые наборы
for {set i 1} {$i <= $Number_of_Test_Sets} {incr i} {
    launch_test_set $i $Log_Dir_Name
}

# закрываем проект после завершения
close_project -quiet

