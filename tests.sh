#!/bin/bash

# Путь к основному скрипту
MAIN_SCRIPT="root/lab/script.sh"

# путь к файля для архивирования
TEST_BACKUP_DIR="root/lab/backup"

# Функция для проверки, является ли значение числом в диапазоне от 0 до 99
is_number_in_range() {
    local value="$1"
    [[ "$value" =~ ^[0-9]+$ ]] && [ "$value" -ge 0 ] && [ "$value" -le 99 ]
}

# Функция для запуска тестов
run_test() {
    local files_count="$1"
    local threshold="$2"

    # Проверка на ввод чисел и их нахождение в диапазоне
    if ! is_number_in_range "$files_count" || ! is_number_in_range "$threshold"; then
        echo "Ошибка: Нужно ввести число от 0 до 99."
        echo "------------------------------------------------------"
        return
    fi

    # Запуск основного скрипта
    echo "Запуск теста с параметрами: количество файлов = $files_count, порог заполнения = $threshold%"
    bash "$MAIN_SCRIPT" "$files_count" "$threshold"

    # Проверка результатов
    local archived_files=$(ls "$TEST_BACKUP_DIR" | wc -l)

    if [ "$archived_files" -gt 0 ]; then
        echo "Тест прошел успешно: Архивировано файлов = $archived_files"
    else
        echo "Тест не прошел: Файлы не были архивированы."
    fi
    echo "------------------------------------------------------"
}


# очистка backup директории после каждого вызова run_test()
-rf "$TEST_BACKUP_DIR"/*

# Тестовые параметры
run_test 5 50    # Тест с 5 файлами и порогом 50%
run_test 10 70   # Тест с 10 файлами и порогом 70%
run_test 20 80   # Тест с 20 файлами и порогом 80%
run_test 0 100   # Тест с 0 файлами, ожидается ошибка, так как 100 не в диапазоне
run_test 10 10   # Тест с 10 файлами и порогом 10%
run_test "a" 50  # Тест с некорректным параметром, ожидается ошибка
run_test 5 "b"   # Тест с некорректным параметром, ожидается ошибка
run_test 5 101   # Тест с порогом, выходящим за пределы диапазона, ожидается ошибка
run_test -1 50   # Тест с отрицательным числом, ожидается ошибка

