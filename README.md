------

### ASIX_to_UART

IP-ядро, преобразующее AXI-Stream в UART и обратно

------

#### Иерархия файлов

- doc - документация на ядро
- hdl - исходные файлы и тесты на HDL
  - header - заголовочные файлы
  - source - файлы исходников
  - testbench - тесты
  - project_top - топ-файлы для демонстрационных проектов

- tcl - скрипты для запуска тестов, упаковки ядра и сборки демонстрационных проектов
- wavedrom - временные диаграммы
- yEd - блок-схемы

------

#### Запуск тестов

Необходимо запустить Vidado Tcl Shell, перейти директорию, где расположен README файл, и запустить тесты с помощью представленных ниже выражений:

- Тесты для проверки UART RX: 

  ```
  vivado -mode batch –source tcl/run_uart_rx_tests.tcl
  ```

- Тесты для проверки UART TX: 

  ```
  vivado -mode batch –source tcl/run_uart_tx_tests.tcl
  ```


- Тесты для проверки передачи из UART TX в UART RX: 

  ```
  vivado -mode batch –source tcl/run_uart_loop_tests.tcl
  ```


Результаты тестов, появятся в папках log_uart_*_.  Test_Results - краткий отчет. Test_Logs - подробный список ошибок.