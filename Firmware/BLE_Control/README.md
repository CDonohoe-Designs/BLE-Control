# BLE-Control — Firmware (STM32WB55CG, UFQFPN-48)

Minimal, self-contained STM32CubeIDE project for the BLE-Control wearable.  
This README is the **source of truth** for toolchain versions, MCU pinout, and bring-up steps.

---

## 1) Project at a glance
- **MCU:** STM32WB55CGUx (UFQFPN-48, dual-core: M4 app + M0+ wireless coprocessor)
- **Role:** BLE central/peripheral + basic sensors (IMU, temp/humidity), fuel gauge, user I/O
- **Clocks/Power:** LSE 32.768 kHz for BLE timing; HSI48+CRS for USB FS; SMPS preferred (if BOM stuffed)
- **Repo layout (firmware)**  


---
### Pinout & Configuration
**[Firmware/BLE_Control/Docs/BLE_Control_PinMap.md](../Firmware/BLE_Control/Docs/BLE_Control_PinMap.md)**.
The **canonical pin map** lives in **[Docs/BLE_Control_PinMap.md](Docs/BLE_Control_PinMap.md)**.  
This README won’t duplicate the table—update the canonical file only.
---

## 2) Toolchain / versions
> Fill these once on first commit so anyone can reproduce the build.

- **STM32CubeIDE:** 1.17.0  
- **STM32CubeWB package:** _e.g., v1.xx.x_  
- **STM32CubeProgrammer:** _e.g., v2.xx_  
- **Wireless coprocessor (CPU2) BLE stack flashed:** _e.g., stm32wb5x_BLE_Stack_full_fw v1.x.x_  
- **C compiler:** GCC (bundled with CubeIDE)

---

## 3) Import, build, run

### A. Import (CubeIDE)
1. **File → Open Projects from File System…** (or *Import → Existing Projects into Workspace*).  
2. Select the `Firmware/` folder.  
3. Build (`Project → Build All`). No hardware required.

> **Code generator settings (CubeMX)**:  
> Project Manager → Code Generator  
> - [x] **Copy only the necessary library files**  
> - [x] **Generate peripheral initialization as a pair of .c/.h files per peripheral**  
> - [x] **Keep User Code when re-generating**

### B. Flash / Debug (ST-LINK)
1. Connect ST-LINK to **SWDIO, SWCLK, NRST, GND, VTref (3V3)**.  
2. **Run → Debug**. CubeIDE will detect ST-LINK and program the M4 app image.

### C. Wireless coprocessor (CPU2) prerequisite
If this is a fresh MCU or new board:  
1. Open **STM32CubeProgrammer**.  
2. Connect via **ST-LINK**.  
3. Use the **FUS/Wireless Upgrade** tab to flash the **BLE stack** matching your app (Full/Light/Concurrent).  
4. Power-cycle the board.

_(We track only the **version** here; binaries stay outside the repo.)_

---

## 4) Clocks, power, and USB
- **LSE 32.768 kHz** enabled → BLE timing & low-power accuracy.  
- **HSI48 + CRS** for **USB FS**; LSE recommended so CRS can auto-trim.  
- **SMPS**: enable in Cube if SMPS BOM is fitted; otherwise use LDO mode.  
- **VDDUSB** must be powered if USB is used.

---

## 5) I²C bus policy
- Pull-ups: **3V3 → 2.2–4.7 kΩ** on SCL/SDA (board-level).  
- Start at **100 kHz**, then 400 kHz once sensors verified.  
- Keep **analog filter ON**, **digital filter = 0** initially.

---

## 6) Bring-up checklist (short)
- [ ] ST-LINK sees device; can mass-erase & program.  
- [ ] CPU2 BLE stack version recorded in this README.  
- [ ] LSE running (check status bit / low-power operation).  
- [ ] I²C scan finds BMI270 / SHTC3 / MAX17048.  
- [ ] **SENS_EN** toggles sensor rail.  
- [ ] Button EXTI fires (PB1), LED blinks (PB0).  
- [ ] Optional: USB CDC enumerates (if enabled).

---

## 7) Troubleshooting tips
- **Can’t connect via ST-LINK:** check VTref, NRST, power, SWDIO/SWCLK continuity.  
- **BLE doesn’t start:** verify CPU2 stack flashed & LSE present.  
- **USB unstable:** confirm **HSI48+CRS** and **VDDUSB** domain powered.  
- **I²C NACKs:** pull-ups fitted, address/config correct, SENS_EN high.

---

## 8) Licensing / third-party
- ST **CMSIS/HAL** inside `Drivers/` are under **BSD-3-Clause** (keep their LICENSE files).  
- Add any middleware licenses here (e.g., FreeRTOS MIT).

---

## 9) Changelog
- **v0.1** — Initial commit. CubeIDE 1.17.0; UFQFPN-48 pinout PB6/PB7 I²C; RF1 single-ended; LSE + HSI48/CRS.


