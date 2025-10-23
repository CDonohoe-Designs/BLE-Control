# BLE-Control — BLE-Enabled Wearable Controller

**BLE-Control** is a compact, low-power BLE-enabled wearable controller designed to interface with an external device or implant via Bluetooth Low Energy.  
This project demonstrates end-to-end hardware design with firmware integration points, suitable for medical, wearable, or embedded control applications.

---

## System Block Diagram (Simplified, AFE to be added) 

![BLE-Control Block Diagram](https://github.com/CDonohoe-Designs/BLE-Control/blob/main/Hardware/BLE_Control_BlockDiagram.png)

This diagram outlines the key subsystems:
- STM32WB55 BLE MCU
- LiPo battery and charger (e.g., BQ25120)
- 3.3 V LDO with enable
- USB-UART debug interface
- Button and LED for user control
- Optional ASIC/sensor interface

---

## Hardware Overview

- **MCU:** STM32WB55CGU6 (BLE 5.0 + Cortex-M4)
- **Battery System:** Single-cell LiPo with charger IC
- **Regulation:** 3.3 V LDO with low-Iq and enable control
- **User Interface:** Tactile button and LED
- **Debug:** USB-CDC or UART for diagnostics
- **Interfaces:** GPIO/I²C/SPI for expansion

 Full schematic and layout files can be found in the [`Hardware/`](https://github.com/CDonohoe-Designs/BLE-Control/tree/main/Hardware) folder.

---

## Firmware Features

- BLE advertising under custom name: `BLE-Control`
- UART debug output
- LED blink status
- Button-triggered events
- Low-power STOP/SLEEP modes (planned)

---

## Repo Structure

```
BLE-Control/
├── Hardware/     → Schematic, PCB, block diagram
├── Firmware/     → STM32CubeIDE project, BLE logic
├── Report/       → System overview PDF (WIP)
├── README.md     → Project summary (this file)
└── LICENSE
```

---

## Tools Used

- **Altium Designer** (v20.2) — schematic & PCB layout  
- **STM32CubeIDE** — BLE firmware project  
- **LTspice** (optional) — power simulations  
- **GitHub Pages** — documentation hosting

---

## Status

- [x] Block diagram complete  
- [x] Repo structure in place  
- [ ] Schematic WIP  
- [ ] Firmware: BLE + LED + UART  
- [ ] Report draft  

---
## License & Reuse
- **MIT (code):** `LICENSE_MIT`

**Medical / safety disclaimer**  
This repository is provided for engineering demonstration and education. It is **not a medical device**, is **not certified** to IEC 60601, and must **not** be used for patient diagnosis or care. Content is provided **as is**, without any warranty or liability.

---
## Contact
**Caoilte Donohoe** — Dublin, Ireland  
Email: caoiltedonohoe@gmail.com · LinkedIn: https://www.linkedin.com/in/caoilte-donohoe-17855613 · GitHub: https://github.com/CDonohoe-Designs

---
