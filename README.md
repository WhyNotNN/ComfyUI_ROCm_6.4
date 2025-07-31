Поддержка ComfyUI на видеокартах AMD через ROCm 6.4.  
Тестировалось на RX 6900 XT.

---

## Преимущества ROCm 6.4

- Генерация в 4 раза быстрее, чем через DirectML (20 сек вместо 80).
- В 2 раза быстрее по сравнению с ROCm 6.3 (20 сек вместо 40).
- Более стабильная работа, чем с ROCm 6.3.
- Проблема с мусором в VRAM сохраняется во всех вариантах.

---

## Требования

- Видеокарта AMD: серия RX 6000 / 7000 / 9000 / Pro.
- Ubuntu 24.04 LTS (желательно установленная на NVMe).
- 16–32 ГБ оперативной памяти.
- Минимальные знания Linux. (если вы совсем новичек, так-же попробуйте)

---

## Установка

### Подготовка системы

Обновляем список пакетов и устанавливаем необходимые компоненты:

```bash
sudo apt update              # обновление списка доступных пакетов
sudo apt upgrade -y          # установка последних версий всех установленных пакетов
sudo apt install python3.12 python3.12-venv git -y  # установка Python 3.12, инструментов для виртуального окружения и Git
```

### Проверка ROCm

Проверим наличие драйвера и поддержку вашей видеокарты:

```bash
rocminfo                     # выводит информацию о доступных устройствах ROCm
```

Если команда отсутствует или GPU не отображается — переходите к установке драйвера ниже.

---

### Установка драйвера ROCm 6.4

Скачиваем и устанавливаем драйвер ROCm:

```bash
wget https://repo.radeon.com/amdgpu-install/6.4.60402-1/ubuntu/noble/amdgpu-install_6.4.60402-1_all.deb  # загрузка установщика
sudo apt install ./amdgpu-install_6.4.60402-1_all.deb                                                    # установка пакета
sudo amdgpu-install -y --usecase=graphics,rocm --no-dkms                                                 # установка драйвера с поддержкой ROCm и графики
sudo usermod -a -G render,video $LOGNAME                                                                 # добавление пользователя в группы доступа к GPU
sudo reboot                                                                                              # перезагрузка системы для применения
```

> Используется `--no-dkms`, чтобы избежать ошибок при установке ядра.

---

## Установка ComfyUI

Клонируем репозиторий и настраиваем окружение:

```bash
git clone https://github.com/WhyNotNN/ComfyUI_ROCm_6.4.git   # копируем репозиторий
cd ComfyUI_ROCm_6.4                                           # переходим в папку проекта
python3 -m venv venv                                          # создаем виртуальное окружение
source venv/bin/activate                                      # активируем окружение
```

### Установка PyTorch с поддержкой ROCm 6.4 (рекомендуется)

```bash
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.4
# установка nightly-версий PyTorch, torchvision и torchaudio с поддержкой ROCm 6.4
```
<details>
<summary>Если 6.4 не работает, ссылки на 6.3 и 6.2 тут.</summary>
  
```bash
pip uninstall torch torchvision torchaudio
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.3
# установка PyTorch, torchvision и torchaudio с поддержкой ROCm 6.3
```
```bash
pip uninstall torch torchvision torchaudio
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.2
# установка PyTorch, torchvision и torchaudio с поддержкой ROCm 6.2
```
</details>

### Установка зависимостей проекта

```bash
pip install -r requirements.txt   # установка всех зависимостей, указанных в проекте
```

---

## Запуск

### Проверка запуска

```bash
python main.py   # запускаем ComfyUI вручную для теста
```
Если все в порядке, закрываем терминал

### Рекомендуемый скрипт запуска

Создаем скрипт `start.sh`:

```bash
cd ComfyUI_ROCm_6.4                                           # переходим в папку проекта
```
<details>
<summary>Для карт с памятью объемом 16gb и больше</summary>

```bash
# копируйте все что между полос
_____
cat << 'EOF' > start.sh                                    
#!/bin/bash
source venv/bin/activate
TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1 python main.py --use-pytorch-cross-attention
EOF
_____
```
</details>
<details>
<summary>Для карт с объемом памяти 12gb и меньше</summary>
  
```bash
# копируйте все что между полос
_____
cat << 'EOF' > start.sh                                    
#!/bin/bash
source venv/bin/activate
TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1 HSA_OVERRIDE_GFX_VERSION=10.3.0 python main.py python main.py --use-pytorch-cross-attention --lowvram
EOF
_____

```
</details>
<details>
<summary>Для карт RX7000 с объемом памяти 12gb и меньше</summary>
  
```bash
# копируйте все что между полос
_____
cat << 'EOF' > start.sh                                    
#!/bin/bash
source venv/bin/activate
TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1 HSA_OVERRIDE_GFX_VERSION=11.0.0 python main.py python main.py --use-pytorch-cross-attention --lowvram
EOF
_____
```
</details>

Делаем скрипт исполняемым и запускаем:

```bash
chmod +x start.sh    # даем право на выполнение
./start.sh           # запускаем ComfyUI с рекомендованными параметрами для AMD
```

---

## Обратная связь

Если возникли ошибки — создайте issue в этом репозитории.
