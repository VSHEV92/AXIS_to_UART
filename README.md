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
- constraints - файлы ограничений для демонстрационных проектов
- tcl - скрипты для запуска тестов, упаковки ядра и сборки демонстрационных проектов
- wavedrom - временные диаграммы
- yEd - блок-схемы

------

#### Запуск тестов

Необходимо запустить Vivado Tcl Shell, перейти в директорию, где расположен README файл, и запустить тесты с помощью представленных ниже выражений:

- Тесты для проверки UART RX: 

  ```
  vivado -mode batch –source tcl/run_uart_rx_tests.tcl -notrace
  ```

- Тесты для проверки UART TX: 

  ```
  vivado -mode batch –source tcl/run_uart_tx_tests.tcl -notrace
  ```


- Тесты для проверки передачи из UART TX в UART RX: 

  ```
  vivado -mode batch –source tcl/run_uart_loop_tests.tcl -notrace
  ```


- Запуск всех тестов: 

  ```
  vivado -mode batch –source tcl/run_all_tests.tcl -notrace
  ```

Результаты тестов, появятся в папках log_uart_*_.  Test_Results - краткий отчет. Test_Logs - подробный список ошибок.

------

#### Упаковка ядра из исходников

Необходимо запустить Vivado Tcl Shell, перейти в директорию, где расположен README файл и скрипт с помощью представленного ниже выражения:

```
vivado -mode batch –source tcl/package_IP.tcl -notrace
```

Упакованное ядро, появится в папке IP.  Эту папке нужно добавить в IP репозиторий проекта.

------

#### Создание демонстрационных проектов

Необходимо запустить Vivado Tcl Shell, перейти в директорию, где расположен README файл, и запустить скрипты с помощью представленных ниже выражений:

- UART RX с выводом принятых данных на светодиоды: 

  ```
  vivado -mode batch –source tcl/uart_rx_leds.tcl -notrace
  ```

- Соединение UART RX напрямую с UART TX: 

  ```
  vivado -mode batch –source tcl/uart_loop.tcl -notrace
  ```

После выполнения скрипта, необходимо в Vivado Tcl Shell ввести 

```
open_project uart_project/uart_project.xpr
start_gui
```

