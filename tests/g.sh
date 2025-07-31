#!/bin/bash

# Устанавливаем mesa-utils
sudo apt install mesa-utils -y

# Проверяем информацию о GPU
GPU_INFO=$(glxinfo | grep -i "device\|memory")

# Если информации нет или возникла ошибка
if [[ -z "$GPU_INFO" ]]; then
    echo "Драйвер не установлен или неподходящая GPU."
    echo "Подробности здесь: [ВСТАВЬТЕ_ССЫЛКУ_ЗДЕСЬ]"
    exit 1
fi

# Извлекаем название устройства и объем памяти
DEVICE=$(echo "$GPU_INFO" | grep -i "Device" | head -n 1 | cut -d ":" -f2- | xargs)
MEMORY=$(echo "$GPU_INFO" | grep -i "Video memory" | head -n 1 | grep -o '[0-9]\+')

echo "Обнаружено устройство: $DEVICE"
echo "Объем видеопамяти: ${MEMORY}MB"

# Проверки на неподдерживаемые или сомнительные GPU
if echo "$DEVICE" | grep -i "nvidia" &>/dev/null; then
    echo "Обнаружена видеокарта NVIDIA. Она не поддерживается."
    echo "Нажмите любую клавишу для выхода..."
    read -n 1
    exit 1
fi

# Проверка на поддержку GPU и объём памяти
SERIES_OK=0
case "$DEVICE" in
    *rx5[0-9][0-9][0-9]*|*rx6[0-9][0-9][0-9]*|*rx7[0-9][0-9][0-9]*|*rx9[0-9][0-9][0-9]*|*radeon*pro*5[0-9][0-9][0-9]*|*radeon*pro*6[0-9][0-9][0-9]*|*radeon*pro*7[0-9][0-9][0-9]*|*radeon*pro*9[0-9][0-9][0-9]*)
        SERIES_OK=1
        ;;
esac

if [[ $SERIES_OK -eq 1 ]]; then
    if [[ $MEMORY -lt 4096 ]]; then
        echo "Объем видеопамяти менее 4GB. Установка невозможна."
        exit 1
    fi
else
    if [[ $MEMORY -le 4096 ]]; then
        echo "GPU имеет объем памяти 4GB или меньше и не входит в поддерживаемую серию."
        echo "COMFYUI может не работать. Продолжить установку? [Y/N]"
        read -n 1 RESP
        echo ""
        [[ "$RESP" =~ [Yy] ]] || exit 1
    fi
fi

# Продолжаем установку
sudo apt update
sudo apt upgrade -y
sudo apt install python3.12 python3.12-venv git -y

# Проверка текущей директории
if [[ $PWD != /home/* ]]; then
    echo "Переход в домашнюю директорию..."
    cd ~
fi

# Клонирование репозитория
git clone https://github.com/WhyNotNN/ComfyUI_ROCm_6.4.git
cd ComfyUI_ROCm_6.4

# Создание виртуального окружения
python3.12 -m venv venv
source venv/bin/activate

# Установка ROCm Torch
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.4

# Установка зависимостей проекта
pip install -r requirements.txt

# Генерация скрипта запуска
LOWVRAM_FLAG=""
AOT_FLAG="TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1"
OVERRIDE_VER=""

if echo "$DEVICE" | grep -i "rx7[0-9][0-9][0-9]" &>/dev/null || echo "$DEVICE" | grep -i "radeon.*pro.*7[0-9][0-9][0-9]" &>/dev/null; then
    OVERRIDE_VER="HSA_OVERRIDE_GFX_VERSION=11.0.0"
    if [[ $MEMORY -le 12288 ]]; then
        LOWVRAM_FLAG="--lowvram"
    fi
elif echo "$DEVICE" | grep -i "rx6[0-9][0-9][0-9]" &>/dev/null || echo "$DEVICE" | grep -i "rx5[0-9][0-9][0-9]" &>/dev/null || echo "$DEVICE" | grep -i "radeon.*pro.*[56][0-9][0-9][0-9]" &>/dev/null; then
    OVERRIDE_VER="HSA_OVERRIDE_GFX_VERSION=10.3.0"
    if [[ $MEMORY -lt 12288 ]]; then
        LOWVRAM_FLAG="--lowvram"
    fi
else
    if [[ $MEMORY -lt 4096 ]]; then
        echo "Объем памяти менее 4GB. Установка невозможна."
        exit 1
    fi
    OVERRIDE_VER="HSA_OVERRIDE_GFX_VERSION=10.3.0"
    LOWVRAM_FLAG="--lowvram"
fi

# Создаем скрипт запуска
cat << EOF > start.sh
#!/bin/bash
source venv/bin/activate
$AOT_FLAG $OVERRIDE_VER python main.py --use-pytorch-cross-attention $LOWVRAM_FLAG
EOF

chmod +x start.sh
echo "Установка завершена. Используйте ./start.sh для запуска ComfyUI."
