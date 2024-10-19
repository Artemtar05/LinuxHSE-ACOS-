#!/bin/bash

IMAGE_FILE="test.img"
IMAGE_SIZE="1000M"

if [ ! -f "$IMAGE_FILE" ]; then
    dd if=/dev/zero of="$IMAGE_FILE" bs=1M count=1000
    mkfs.ext4 "$IMAGE_FILE"
fi

mkdir -p test
sudo mount -o loop "$IMAGE_FILE" test

for i in {1..52}; do
    dd if=/dev/zero of=test/file$i.bin bs=1M count=10
    echo 'file is create!'
done

PERCENTAGE=$(df test | grep -v 'Filesystem' | awk '{print $5}' | sed 's/%//')
echo "Заполнение папки $1: $PERCENTAGE"

# путь к файлу, который проверяется на зааолнение
LOG_DIR="/root/lab/test/"

# путь к backup файлу, в котороый производится архив
BACKUP_DIR="/root/lab/backup/"

#кол-во файлов для архивирования
OLD_FILES="$1"

# threshold 
X="$2"

# Проверка, превышает ли заполнение X%
if [ "$PERCENTAGE" -gt "$X" ]; then
    echo "Заполнение превышает $X%. Архивирование файлов..."
    
    # Поиск старых файлов в папке LOG_DIR
    OLD_FILES_TO_ARCHIVE=$(ls -t "$LOG_DIR" | head -n "$OLD_FILES")
    
    # Архивирование найденных файлов
    if [ ! -z "$OLD_FILES_TO_ARCHIVE" ]; then
        tar -czf "$BACKUP_DIR/archive_$(date +%Y%m%d_%H%M%S).tar.gz" -C "$LOG_DIR" $OLD_FILES_TO_ARCHIVE
        echo "Архивирование завершено: $BACKUP_DIR/archive_$(date +%Y%m%d_%H%M%S).tar.gz"
        
        # Удаление архивированных файлов
        echo "$OLD_FILES_TO_ARCHIVE" | while read -r file; do
            rm "$LOG_DIR/$file"
            echo "Файл $file удалён из $LOG_DIR"
        done
    else
        echo "Нет файлов для архивирования."
    fi
else
    echo "Заполнение не превышает $X%. Архивирование не требуется."
fi
