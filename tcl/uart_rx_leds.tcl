# --------------------------------------------------------------
# ------- Cкрипт дл€ автоматического создани€ проекта ----------
# --------------------------------------------------------------
# ƒемонстрационный проект дл€ платы Artix 7A50T Board. »спользуетс€ 
# только Uart RX. ѕрин€тое слово данных выводитс€ на Leds.
# -----------------------------------------------------------

set Project_Name uart_project

# если проект с таким именем существует удал€ем его
close_sim -quiet 
close_project -quiet
if { [file exists $Project_Name] != 0 } { 
	file delete -force $Project_Name
	puts "Delete old Project"
}

# создаем проект
create_project $Project_Name ./$Project_Name -part xc7a50tftg256-1

# запускаем скрипт по упаковке €дра и добавл€ем репозиторий
if { [file exists IP] == 0 } { 
	source tcl/package_IP.tcl
} else {
	close_project -quiet
}
open_project uart_project/uart_project.xpr
set_property  ip_repo_paths IP [current_project]
update_ip_catalog

# добавл€ем топ уровень проекта
add_files hdl/project_top/uart_rx_leds.v

# добавл€ем constraints файлы 
add_files -fileset constrs_1 -norecurse constraints/pins.xdc
add_files -fileset constrs_1 -norecurse constraints/timing.xdc
set_property target_constrs_file constraints/timing.xdc [current_fileset -constrset]

# создаем IP €дро
create_ip -name UART_to_AXIS -vendor VSHEV92 -library user -version 1.0 -module_name UART_to_AXIS_0 -dir uart_project
set_property -dict [list CONFIG.CLK_FREQ {200} CONFIG.RX_TX {RX}] [get_ips UART_to_AXIS_0]
update_compile_order -fileset sources_1