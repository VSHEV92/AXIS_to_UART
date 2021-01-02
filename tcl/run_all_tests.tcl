# --------------------------------------------------------------
# ----- Cкрипт для автоматического запуска всех тестов ---------
# --------------------------------------------------------------

# -----------------------------------------------------------
# процедура для проверки результатов
proc check_test_results {Log_Dir_Name} {
	set Verification_Result 1
	# считываем весь файл
	set fileID [open $Log_Dir_Name/Test_Results.txt r]
	set file_data [read $fileID]
	close $fileID
	# разделяем файл на строки
	set data [split $file_data "\n"]
	foreach line $data {
		if {[string length $line] && [string first "FAIL" $line] != -1} {
			set Verification_Result 0	
			set message $Log_Dir_Name
			append message ": \"" $line "\""
			puts $message
		}
	}
	return $Verification_Result	
}

# -----------------------------------------------------------
# основной скрипт
set Verification_Result 1

# запуск тестов
source tcl/run_uart_tx_tests.tcl
source tcl/run_uart_rx_tests.tcl
source tcl/run_uart_loop_tests.tcl

# проверка результатов
puts ""

set Log_Dir_Name log_uart_tx_test
set Verification_Result [check_test_results $Log_Dir_Name]

set Log_Dir_Name log_uart_rx_test
set Verification_Result [check_test_results $Log_Dir_Name]

set Log_Dir_Name log_uart_loop_test
set Verification_Result [check_test_results $Log_Dir_Name]

# вывод результатов
puts ""
if { $Verification_Result } {
	puts "-------------------------------------------"
	puts "--------- VERIFICATION SUCCESSED ----------"
	puts "-------------------------------------------"
} else {
	puts "-------------------------------------------"
	puts "---------- VERIFICATION FAILED ------------"
	puts "-------------------------------------------"
}



