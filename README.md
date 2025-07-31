
Поддержка ComfyUI на видеокартах AMD через ROCm 6.4.  
Тестировалось на RX 6900 XT.

Автоматическая установка одним файлом
!!ТЕСТОВО!!
https://raw.githubusercontent.com/WhyNotNN/ComfyUI_ROCm_6.4/g.sh

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
Что-бы попасть в UI, копируем то что терминал выдал в последней строке http://127.0.0.1:8188, вставляем в адресную строку браузера

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


## Модели и демонстрация генерации

**Внимание:**  
Большинство высококачественных моделей способны генерировать изображения откровенного или провокационного характера.  
Ограничения зависят исключительно от пользовательского запроса и фантазии. Данный инструмент **не предназначен для лиц младше 18 лет**,
даже если в настоящее время отсутствуют прямые законодательные ограничения.

---
<details>
<summary>Для родителей и опекунов</summary>
  
Перед тем как предоставить подросткам или детям доступ к подобным генераторам, обязательно изучите потенциальные риски.  
Данный инструмент **не предназначен для лиц младше 18 лет**, даже если в настоящее время отсутствуют прямые законодательные ограничения.

---
</details>

---
<details>
<summary>Для подростков</summary>
Бесконтрольное использование генеративных моделей может **негативно повлиять на психику**.  
Если вы:
- чувствуете, что тратите слишком много времени на генерацию;
- теряете интерес к реальным людям и событиям;
- не можете остановиться;

немедленно обратитесь за поддержкой — к родителям или психологу.  
Это не стыдно. Это важно.

---
</details>

---


## Примеры генерации и модель

Для загрузки моделей используйте следующие ссылки:

[iLustMix модель](https://civitai.com/api/download/models/2017049?type=Model&format=SafeTensor&size=pruned&fp=fp16)


[vae840000](https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors)


<details>
<summary>Что с ними делать?</summary>
___
Скачайте iLustMix модель, и переместите ее в папку

/home/ComfyUI_ROCm_6.4/models/checkpoints

Скачайте vae модель, и переместите ее в папку

/home/ComfyUI_ROCm_6.4/models/vae
___

Откройте ComfyUI

Нажмите "Рабочий процесс">"Посмотреть шаблоны">"Выберите первый шаблон под названием Генерация изображений"

ComfyUi откроет шаблон и попросит скачать модель, проигнорируйте и закройте (у нас уже есть скачанная модель)

В шаблоне будет несколько разных геометрических нод связаных между собой

Ваша задача найти ноду Cheсkpoint (она самая первая)

В самом низу этой ноды, буде выбор модели, выберите iLustMix_v80.safetensors
____
Найдите ноду KSampler

Установите указанные настройки:

сид - не трогайте
Управление генерации - не трогайте
Шаги - 25
cfg - 7.0
название_семплера - Euler_ancestral
scheduler - не трогайте
Шумоподавление - не трогайте
___

Сделайте пробную генерацию

___

Найдите ноду с названием "Пустое латентное изображение"

Установите значение:

ширина - 832
высота - 1216
размер_пакета - не трогайте
___

Сделайте пробную генерацию
___


<details>
<summary>Пример хорошего промта</summary>
Верхний промт - Положительный

  ```
lazypos,masterpiece, best quality, amazing quality, very aesthetic, detailed eyes, perfect eyes, realistic eyes, absurdres, very awa, (depth of field:1.2),
close up, point of view, from side, dutch angle, (kuroi susumu:1.4), (white gorilla \(okamoto\):1.3),  promotional art, 
simple background, two-tone background, black background, red background, 
1girl, wavy hair, black hair, red hair, medium hair, bright blue eye, fedora,  hat over one eye, evil grin, eye glowing, medium breasts, white lace leotard,   strapless, leather crop jacket, bomber jacket, sleeves rolled up, bracelets,
head down, sideways glance, 
grunge, fashion, high contrast, breasts focus,
multicolored, bright, 
gs_ill,jeddtl02,pinkretroanime,
```

Нижний промт - негативный, то что не хотим видеть

```
lazyneg, poorly detailed, jpeg artifacts, worst quality, bad quality, lowres, bad anatomy, deformed face,animal ears,extra fingers,oversaturation,bad anthropometry, face tattoo,
```
</details>
</details>


