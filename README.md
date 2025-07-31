## Что дает ROCm 6.4


<details>
<summary>Подробнее</summary>
Тесты проводились на видеокарте RX6900XT

*Скорость генерации в 4 раза быстрее чем DirectML. Если говорить о цифрах 20с на картинку вместо 80с
*Скорость генерации в 2 раза быстрее чем ROCm 6.3. Если говорить о цифрах 20с на картинку вместо 40с
*Стабильность лучше чем с 6.3 и хуже чем DirectML. 
*Проблема с мусосром в VRAM, сохраняется во всех 3х вариантах

</details>

Что потребуется для установки:

1. Видеокарта AMD RX6000/7000/9000/pro
2. Ubuntu 24.04 LTS установленную на NVME диск
3. 16 или 32gb оперативной памяти
4. Поверхностное представление что такое Linux


Установка на чистую Ubuntu:


Обновление базы пакетов
Установка обновленных пакетов
  ```
  sudo apt update 
  sudo apt upgrade -y
  ```

Установка python3.12 и скриптов окружения
  ```
  sudo apt install python3.12 python3.12-venv -y
  ```
Git должен был установиться после apt upgrade -y, но на всякий установим его отдельно
  ```
  sudo apt install git -y
  ```
Проверим наличие драйвера для GPU
```
rocminfo
```
<details>
<summary>Вариант 1. Если вывод похож на это, то все в порядке, вы можете пропустить установку драйвера</summary>
ROCk module version 6.12.12 is loaded
=====================    
HSA System Attributes    
=====================    
Runtime Version:         1.15
Runtime Ext Version:     1.7
System Timestamp Freq.:  1000.000000MHz
Sig. Max Wait Duration:  18446744073709551615 (0xFFFFFFFFFFFFFFFF) (timestamp count)
Machine Model:           LARGE                              
System Endianness:       LITTLE                             
Mwaitx:                  DISABLED
XNACK enabled:           NO
DMAbuf Support:          YES
VMM Support:             YES

==========               
HSA Agents               
==========               
*******                  
Agent 1                  
*******                  
  Name:                    Intel(R) Core(TM) i7-7800X CPU @ 3.50GHz
  Uuid:                    CPU-XX                             
  Marketing Name:          Intel(R) Core(TM) i7-7800X CPU @ 3.50GHz
  Vendor Name:             CPU                                
  Feature:                 None specified                     
  Profile:                 FULL_PROFILE                       
  Float Round Mode:        NEAR                               
  Max Queue Number:        0(0x0)                             
  Queue Min Size:          0(0x0)                             
  Queue Max Size:          0(0x0)                             
  Queue Type:              MULTI                              
  Node:                    0                                  
  Device Type:             CPU                                
  Cache Info:              
    L1:                      32768(0x8000) KB                   
  Chip ID:                 0(0x0)                             
  ASIC Revision:           0(0x0)                             
  Cacheline Size:          64(0x40)                           
  Max Clock Freq. (MHz):   4000                               
  BDFID:                   0                                  
  Internal Node ID:        0                                  
  Compute Unit:            12                                 
  SIMDs per CU:            0                                  
  Shader Engines:          0                                  
  Shader Arrs. per Eng.:   0                                  
  WatchPts on Addr. Ranges:1                                  
  Memory Properties:       
  Features:                None
  Pool Info:               
    Pool 1                   
      Segment:                 GLOBAL; FLAGS: FINE GRAINED        
      Size:                    32543408(0x1f092b0) KB             
      Allocatable:             TRUE                               
      Alloc Granule:           4KB                                
      Alloc Recommended Granule:4KB                                
      Alloc Alignment:         4KB                                
      Accessible by all:       TRUE                               
    Pool 2                   
      Segment:                 GLOBAL; FLAGS: EXTENDED FINE GRAINED
      Size:                    32543408(0x1f092b0) KB             
      Allocatable:             TRUE                               
      Alloc Granule:           4KB                                
      Alloc Recommended Granule:4KB                                
      Alloc Alignment:         4KB                                
      Accessible by all:       TRUE                               
    Pool 3                   
      Segment:                 GLOBAL; FLAGS: KERNARG, FINE GRAINED
      Size:                    32543408(0x1f092b0) KB             
      Allocatable:             TRUE                               
      Alloc Granule:           4KB                                
      Alloc Recommended Granule:4KB                                
      Alloc Alignment:         4KB                                
      Accessible by all:       TRUE                               
    Pool 4                   
      Segment:                 GLOBAL; FLAGS: COARSE GRAINED      
      Size:                    32543408(0x1f092b0) KB             
      Allocatable:             TRUE                               
      Alloc Granule:           4KB                                
      Alloc Recommended Granule:4KB                                
      Alloc Alignment:         4KB                                
      Accessible by all:       TRUE                               
  ISA Info:                
*******                  
Agent 2                  
*******                  
  Name:                    gfx1030                            
  Uuid:                    GPU-186551e29c59bd0d               
  Marketing Name:          AMD Radeon RX 6900 XT              
  Vendor Name:             AMD                                
  Feature:                 KERNEL_DISPATCH                    
  Profile:                 BASE_PROFILE                       
  Float Round Mode:        NEAR                               
  Max Queue Number:        128(0x80)                          
  Queue Min Size:          64(0x40)                           
  Queue Max Size:          131072(0x20000)                    
  Queue Type:              MULTI                              
  Node:                    1                                  
  Device Type:             GPU                                
  Cache Info:              
    L1:                      16(0x10) KB                        
    L2:                      4096(0x1000) KB                    
    L3:                      131072(0x20000) KB                 
  Chip ID:                 29631(0x73bf)                      
  ASIC Revision:           1(0x1)                             
  Cacheline Size:          128(0x80)                          
  Max Clock Freq. (MHz):   2660                               
  BDFID:                   26368                              
  Internal Node ID:        1                                  
  Compute Unit:            80                                 
  SIMDs per CU:            2                                  
  Shader Engines:          4                                  
  Shader Arrs. per Eng.:   2                                  
  WatchPts on Addr. Ranges:4                                  
  Coherent Host Access:    FALSE                              
  Memory Properties:       
  Features:                KERNEL_DISPATCH 
  Fast F16 Operation:      TRUE                               
  Wavefront Size:          32(0x20)                           
  Workgroup Max Size:      1024(0x400)                        
  Workgroup Max Size per Dimension:
    x                        1024(0x400)                        
    y                        1024(0x400)                        
    z                        1024(0x400)                        
  Max Waves Per CU:        32(0x20)                           
  Max Work-item Per CU:    1024(0x400)                        
  Grid Max Size:           4294967295(0xffffffff)             
  Grid Max Size per Dimension:
    x                        4294967295(0xffffffff)             
    y                        4294967295(0xffffffff)             
    z                        4294967295(0xffffffff)             
  Max fbarriers/Workgrp:   32                                 
  Packet Processor uCode:: 131                                
  SDMA engine uCode::      85                                 
  IOMMU Support::          None                               
  Pool Info:               
    Pool 1                   
      Segment:                 GLOBAL; FLAGS: COARSE GRAINED      
      Size:                    16760832(0xffc000) KB              
      Allocatable:             TRUE                               
      Alloc Granule:           4KB                                
      Alloc Recommended Granule:2048KB                             
      Alloc Alignment:         4KB                                
      Accessible by all:       FALSE                              
    Pool 2                   
      Segment:                 GLOBAL; FLAGS: EXTENDED FINE GRAINED
      Size:                    16760832(0xffc000) KB              
      Allocatable:             TRUE                               
      Alloc Granule:           4KB                                
      Alloc Recommended Granule:2048KB                             
      Alloc Alignment:         4KB                                
      Accessible by all:       FALSE                              
    Pool 3                   
      Segment:                 GROUP                              
      Size:                    64(0x40) KB                        
      Allocatable:             FALSE                              
      Alloc Granule:           0KB                                
      Alloc Recommended Granule:0KB                                
      Alloc Alignment:         0KB                                
      Accessible by all:       FALSE                              
  ISA Info:                
    ISA 1                    
      Name:                    amdgcn-amd-amdhsa--gfx1030         
      Machine Models:          HSA_MACHINE_MODEL_LARGE            
      Profiles:                HSA_PROFILE_BASE                   
      Default Rounding Mode:   NEAR                               
      Default Rounding Mode:   NEAR                               
      Fast f16:                TRUE                               
      Workgroup Max Size:      1024(0x400)                        
      Workgroup Max Size per Dimension:
        x                        1024(0x400)                        
        y                        1024(0x400)                        
        z                        1024(0x400)                        
      Grid Max Size:           4294967295(0xffffffff)             
      Grid Max Size per Dimension:
        x                        4294967295(0xffffffff)             
        y                        4294967295(0xffffffff)             
        z                        4294967295(0xffffffff)             
      FBarrier Max Size:       32                                 
    ISA 2                    
      Name:                    amdgcn-amd-amdhsa--gfx10-3-generic 
      Machine Models:          HSA_MACHINE_MODEL_LARGE            
      Profiles:                HSA_PROFILE_BASE                   
      Default Rounding Mode:   NEAR                               
      Default Rounding Mode:   NEAR                               
      Fast f16:                TRUE                               
      Workgroup Max Size:      1024(0x400)                        
      Workgroup Max Size per Dimension:
        x                        1024(0x400)                        
        y                        1024(0x400)                        
        z                        1024(0x400)                        
      Grid Max Size:           4294967295(0xffffffff)             
      Grid Max Size per Dimension:
        x                        4294967295(0xffffffff)             
        y                        4294967295(0xffffffff)             
        z                        4294967295(0xffffffff)             
      FBarrier Max Size:       32                                 
*** Done ***          

</details>
<details>
<summary>Вариант 2. Если вывод похож на это, то вам необходимо установить драйвера</summary>
-Command 'rocminfo' not found, but can be installed with:                                     -            
-snap install rocminfo  # version 6.4.0, or              
-apt  install rocminfo  # version 5.2.3-3            
-See 'snap info rocminfo' for additional versions.        
</details>
Если вывод после команды не похож ни на что описаное, так-же перейдите к шагу установки драйвера
***если это не поможет, пожайлусто обращайтесь в issue, я постараюсь вам помочь***


<details>
<summary>Установка драйвера ROCm</summary>
  
```
wget https://repo.radeon.com/amdgpu-install/6.4.60402-1/ubuntu/noble/amdgpu-install_6.4.60402-1_all.deb
sudo apt update
sudo apt install ./amdgpu-install_6.4.60402-1_all.deb
sudo amdgpu-install -y --usecase=graphics,rocm --no-dkms
sudo usermod -a -G render,video $LOGNAME
```
Перезагрузка
```
sudo reboot
```
Я предлагаю вариант установки --no-dkms, по причине массовых жалоб на ошибку сборки DKMS 

</details>

Если вы дошли до этого этапа, вы готовы к установке пакетов.

Установка:

Клонируем этот репозитория 
```
git clone https://github.com/WhyNotNN/ComfyUI_ROCm_6.4.git
```
Входим в недавно клонированый репозиторий на вашем пк
```
cd ComfyUI_ROCm_6.4
```
Создаем окружение venv (в папке проекта появится папка venv)
```
python3 -m venv venv
```
Активируем виртуальное окружение
```
source venv/bin/activate
```
___________
Устанавливаем torch-rocm 6.4 *Рекомендуется*
```
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.4
```
___________
Устанавливаем torch-rocm 6.3 *Не рекомедуется*
```
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.3
```
___________
Устанавливаем torcm-romc 6.2 *Не рекомендуется, но если 6.4 и 6.3 дают ошибки попробуйте*
```
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.2
```

Установка зависимостей ComfyUI
```
pip install -r requirements.txt
```
___________

## Все готово к запусу

Проверка запуска
```
python main.py
```

Для AMD, настоятельно рекомендуется создать отдельный скрипт запуска
```
сat << 'EOF' > start.sh
#!/bin/bash
source venv/bin/activate
TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1 python main.py --use-pytorch-cross-attention
EOF
```
указываем что наш скрипт исполняемый
```
chmod +x start.sh
```




