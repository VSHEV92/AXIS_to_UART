# ---------------------------------------------------------------------
# ----- Cкрипт для автоматической упаковки ядра из исходников ---------
# ---------------------------------------------------------------------
set Project_Name edit_ip_project

close_project -quiet
if { [file exists $Project_Name] != 0 } { 
	file delete -force $Project_Name
	puts "Delete old Project"
}

# -----------------------------------------------------------
ipx::infer_core -vendor xilinx.com -library user -taxonomy /UserIP hdl/source
ipx::edit_ip_in_project -upgrade true -name $Project_Name -directory $Project_Name hdl/source/component.xml
ipx::current_core hdl/source/component.xml
set_property top AXIS_to_UART [current_fileset]
update_compile_order -fileset sources_1

# настройка главной страницы
set_property vendor VSHEV92 [ipx::current_core]
set_property name UART_to_AXIS [ipx::current_core]
set_property display_name UART_to_AXIS [ipx::current_core]
set_property description UART_to_AXIS [ipx::current_core]

# параметр выбора режима работы блока
ipx::add_user_parameter RX_TX [ipx::current_core]
set_property value_resolve_type user [ipx::get_user_parameters RX_TX -of_objects [ipx::current_core]]
ipgui::add_param -name {RX_TX} -component [ipx::current_core]
set_property display_name {RX/TX} [ipgui::get_guiparamspec -name "RX_TX" -component [ipx::current_core] ]
set_property tooltip {Set RX and TX functions} [ipgui::get_guiparamspec -name "RX_TX" -component [ipx::current_core] ]
set_property widget {comboBox} [ipgui::get_guiparamspec -name "RX_TX" -component [ipx::current_core] ]
set_property value RX/TX [ipx::get_user_parameters RX_TX -of_objects [ipx::current_core]]
set_property value_validation_type list [ipx::get_user_parameters RX_TX -of_objects [ipx::current_core]]
set_property value_validation_list {RX TX RX/TX} [ipx::get_user_parameters RX_TX -of_objects [ipx::current_core]]

# число бит в слове данных
set_property display_name {Bits per Word} [ipgui::get_guiparamspec -name "BIT_PER_WORD" -component [ipx::current_core] ]
set_property tooltip {Number of bits per  data word} [ipgui::get_guiparamspec -name "BIT_PER_WORD" -component [ipx::current_core] ]
set_property widget {comboBox} [ipgui::get_guiparamspec -name "BIT_PER_WORD" -component [ipx::current_core] ]
set_property value_validation_type list [ipx::get_user_parameters BIT_PER_WORD -of_objects [ipx::current_core]]
set_property value_validation_list {5 6 7 8} [ipx::get_user_parameters BIT_PER_WORD -of_objects [ipx::current_core]]

# битовая скорость
set_property widget {comboBox} [ipgui::get_guiparamspec -name "BIT_RATE" -component [ipx::current_core] ]
set_property value_validation_type list [ipx::get_user_parameters BIT_RATE -of_objects [ipx::current_core]]
set_property value_validation_list {1200 2400 4800 9600 14400 19200 38400 57600 115200 230400 460800 921600} [ipx::get_user_parameters BIT_RATE -of_objects [ipx::current_core]]
set_property tooltip {Bit rate in bits per second} [ipgui::get_guiparamspec -name "BIT_RATE" -component [ipx::current_core] ]
set_property widget {comboBox} [ipgui::get_guiparamspec -name "BIT_RATE" -component [ipx::current_core] ]

# тактовая частота
set_property display_name {Clock Frequence (MHz)} [ipgui::get_guiparamspec -name "CLK_FREQ" -component [ipx::current_core] ]
set_property tooltip {Clock Frequence (MHz)} [ipgui::get_guiparamspec -name "CLK_FREQ" -component [ipx::current_core] ]
set_property widget {textEdit} [ipgui::get_guiparamspec -name "CLK_FREQ" -component [ipx::current_core] ]

# бит четности
set_property tooltip {Value of parity bit} [ipgui::get_guiparamspec -name "PARITY_BIT" -component [ipx::current_core] ]
set_property widget {comboBox} [ipgui::get_guiparamspec -name "PARITY_BIT" -component [ipx::current_core] ]
set_property value_validation_type pairs [ipx::get_user_parameters PARITY_BIT -of_objects [ipx::current_core]]
set_property value_validation_pairs {None 0 Odd 1 Even 2} [ipx::get_user_parameters PARITY_BIT -of_objects [ipx::current_core]]

# число стоп-бит
set_property display_name {Number of stop bits} [ipgui::get_guiparamspec -name "STOP_BITS_NUM" -component [ipx::current_core] ]
set_property tooltip {Number of stop bits} [ipgui::get_guiparamspec -name "STOP_BITS_NUM" -component [ipx::current_core] ]
set_property widget {comboBox} [ipgui::get_guiparamspec -name "STOP_BITS_NUM" -component [ipx::current_core] ]
set_property value_validation_type list [ipx::get_user_parameters STOP_BITS_NUM -of_objects [ipx::current_core]]
set_property value_validation_list {1 2} [ipx::get_user_parameters STOP_BITS_NUM -of_objects [ipx::current_core]]

ipgui::move_param -component [ipx::current_core] -order 0 [ipgui::get_guiparamspec -name "RX_TX" -component [ipx::current_core]] -parent [ipgui::get_pagespec -name "Page 0" -component [ipx::current_core]]
ipgui::move_param -component [ipx::current_core] -order 1 [ipgui::get_guiparamspec -name "CLK_FREQ" -component [ipx::current_core]] -parent [ipgui::get_pagespec -name "Page 0" -component [ipx::current_core]]
ipgui::move_param -component [ipx::current_core] -order 2 [ipgui::get_guiparamspec -name "BIT_RATE" -component [ipx::current_core]] -parent [ipgui::get_pagespec -name "Page 0" -component [ipx::current_core]]
set_property display_name {Parameters} [ipgui::get_pagespec -name "Page 0" -component [ipx::current_core] ]
set_property tooltip {Parameters} [ipgui::get_pagespec -name "Page 0" -component [ipx::current_core] ]

ipx::remove_bus_interface interface_axis [ipx::current_core]

# выходной axis
ipx::add_bus_interface axis_out [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:axis_rtl:1.0 [ipx::get_bus_interfaces axis_out -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:axis:1.0 [ipx::get_bus_interfaces axis_out -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces axis_out -of_objects [ipx::current_core]]
set_property display_name axis_out [ipx::get_bus_interfaces axis_out -of_objects [ipx::current_core]]
ipx::add_port_map TUSER [ipx::get_bus_interfaces axis_out -of_objects [ipx::current_core]]
set_property physical_name out_tuser [ipx::get_port_maps TUSER -of_objects [ipx::get_bus_interfaces axis_out -of_objects [ipx::current_core]]]
ipx::add_port_map TVALID [ipx::get_bus_interfaces axis_out -of_objects [ipx::current_core]]
set_property physical_name out_tvalid [ipx::get_port_maps TVALID -of_objects [ipx::get_bus_interfaces axis_out -of_objects [ipx::current_core]]]
ipx::add_port_map TDATA [ipx::get_bus_interfaces axis_out -of_objects [ipx::current_core]]
set_property physical_name out_tdata [ipx::get_port_maps TDATA -of_objects [ipx::get_bus_interfaces axis_out -of_objects [ipx::current_core]]]
set_property enablement_dependency {$RX_TX != "TX"} [ipx::get_bus_interfaces axis_out -of_objects [ipx::current_core]]
ipx::associate_bus_interfaces -busif axis_out -clock aclk [ipx::current_core]

# входной axis
ipx::add_bus_interface axis_in [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:axis_rtl:1.0 [ipx::get_bus_interfaces axis_in -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:axis:1.0 [ipx::get_bus_interfaces axis_in -of_objects [ipx::current_core]]
set_property display_name axis_in [ipx::get_bus_interfaces axis_in -of_objects [ipx::current_core]]
ipx::add_port_map TVALID [ipx::get_bus_interfaces axis_in -of_objects [ipx::current_core]]
set_property physical_name in_tvalid [ipx::get_port_maps TVALID -of_objects [ipx::get_bus_interfaces axis_in -of_objects [ipx::current_core]]]
ipx::add_port_map TREADY [ipx::get_bus_interfaces axis_in -of_objects [ipx::current_core]]
set_property physical_name in_tready [ipx::get_port_maps TREADY -of_objects [ipx::get_bus_interfaces axis_in -of_objects [ipx::current_core]]]
ipx::add_port_map TDATA [ipx::get_bus_interfaces axis_in -of_objects [ipx::current_core]]
set_property physical_name in_tdata [ipx::get_port_maps TDATA -of_objects [ipx::get_bus_interfaces axis_in -of_objects [ipx::current_core]]]
set_property enablement_dependency {$RX_TX != "RX"} [ipx::get_bus_interfaces axis_in -of_objects [ipx::current_core]]
ipx::associate_bus_interfaces -busif axis_in -clock aclk [ipx::current_core]

# uart
ipx::add_bus_interface uart [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:uart_rtl:1.0 [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:uart:1.0 [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property display_name uart [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
ipx::add_port_map TxD [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property physical_name TX [ipx::get_port_maps TxD -of_objects [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]]
ipx::add_port_map RxD [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]
set_property physical_name RX [ipx::get_port_maps RxD -of_objects [ipx::get_bus_interfaces uart -of_objects [ipx::current_core]]]

# пакуем IP
ipx::merge_project_changes ports [ipx::current_core]
set_property previous_version_for_upgrade xilinx.com:user:UART_RX_to_AXIS:1.0 [ipx::current_core]
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project -delete
close_project
file delete -force $Project_Name

# копируем IP в отдельную папку
if { [file exists IP] != 0 } { 
	file delete -force IP
}
file mkdir IP
file copy hdl/source/ IP/