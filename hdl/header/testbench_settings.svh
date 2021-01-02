// ------------------------------------------------------
//---------- настройки тестового окружения --------------
// ------------------------------------------------------
parameter int CLK_FREQ = 100;              // тактовая частота в MHz  
parameter int RESET_DEASSERT_DELAY = 100;  // время снятия сигнала сброса ns
parameter int DATA_WORDS_NUMB = 100;      // число передаваемых слов
parameter int PARITY_ERR_PROB = 7;         // ошибки в передаваемом слове в процентах

parameter int DATA_MIN_DELAY = 5*10e4;      // миниммальная задержка между передачей данных
parameter int DATA_MAX_DELAY = 10e5;      // максимальная задержка между передачей данных

// функция для поиска пути расположения тестового файла
function automatic string find_file_path(input string file_full_name);
    int str_len = file_full_name.len();
    str_len--;
    while (file_full_name.getc(str_len) != "/") begin
        str_len--;
    end
    return file_full_name.substr(0, str_len); 
endfunction