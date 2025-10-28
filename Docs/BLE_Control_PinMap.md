# BLE-Control — Hardware ⇄ Firmware Pin Map (Single Source)

**MCU:** STM32WB55CGUx (UFQFPN-48).  
This file is the **only** place where pin/function/net mappings are defined. Hardware and firmware docs must link here.

## Pin Table
| Function            | MCU Pin | Net (Schematic) | Dir | CubeIDE Mode / AF           | Pull / Drive      | Notes |
|---|---|---|:--:|---|---|---|
| I²C1 SCL           | PB6     | I2C_SCL         | I/O | I2C1_SCL (AF)               | Open-Drain, No PU | 2.2–4.7 kΩ pull-up to 3V3 on board. |
| I²C1 SDA           | PB7     | I2C_SDA         | I/O | I2C1_SDA (AF)               | Open-Drain, No PU | As above. |
| IMU INT1           | PA0     | BMI270_INT1     | In  | GPIO Input + EXTI           | No Pull (or PD)   | EXTI Rising (typ). |
| IMU INT2           | PA1     | BMI270_INT2     | In  | GPIO Input + EXTI           | No Pull (or PD)   | EXTI Rising (typ). |
| Fuel Gauge ALERT   | PB2     | GAUGE_INT       | In  | GPIO Input + EXTI           | Pull-Up (typ)     | EXTI Falling if ALERT active-low. |
| Sensors Rail EN    | PA8     | SENS_EN         | Out | GPIO Output (Push-Pull)     | No Pull           | Init **Low**; drive High to power `VDD_SENS`. |
| User LED           | PB0     | GPIO_LED        | Out | GPIO Output (Push-Pull)     | No Pull           | ~1–2 mA through 1 kΩ. |
| User Button        | PB1     | BTN_IN          | In  | GPIO Input + EXTI           | Pull-Up           | EXTI Falling (press → GND). |
| USB FS DM (opt)    | PA11    | USB_DM          | I/O | USB Device (FS)             | —                 | Needs HSI48 + CRS; ensure VDDUSB powered. |
| USB FS DP (opt)    | PA12    | USB_DP          | I/O | USB Device (FS)             | —                 | As above. |
| SWDIO              | PA13    | SWDIO           | I/O | Serial-Wire Debug           | —                 | Tag-Connect TC2030-NL. |
| SWCLK              | PA14    | SWCLK           | In  | Serial-Wire Debug           | —                 | — |
| SWO (opt)          | PB3     | SWO             | Out | Trace Async SW (SWO)        | —                 | Enable SWV if used. |
| Reset              | NRST    | NRST            | In  | Reset                       | —                 | 10 k to 3V3 + 100 nF to GND. |
| RF Out             | RF1     | RF_OUT          | —   | RF pin (not GPIO)           | —                 | Single-ended → π-match (DNP) → 50 Ω antenna. |

### Quick copy string
`PB6 I2C_SCL, PB7 I2C_SDA, PA0 BMI270_INT1, PA1 BMI270_INT2, PB2 GAUGE_INT, PA8 SENS_EN, PB0 GPIO_LED, PB1 BTN_IN, PA11 USB_DM, PA12 USB_DP, PA13 SWDIO, PA14 SWCLK, PB3 SWO, NRST, RF1 RF_OUT`
## EXTI Pin Setup (CubeIDE → Pinout & Configuration)

Do this for each pin by **clicking the pin on the die view** → edit in the **GPIO mode and configuration** panel.

### 1) IMU INT1 — `PA0` → `BMI270_INT1`
- **GPIO Mode:** `External Interrupt Mode with Rising edge trigger detection`
- **GPIO Pull-up/Pull-down:** `No pull`  
  _If your IMU rail is sometimes off via `SENS_EN`, choose **Pull-down** to avoid a floating line._
- **User Label:** `BMI270_INT1`

### 2) IMU INT2 — `PA1` → `BMI270_INT2`
- **GPIO Mode:** `External Interrupt Mode with Rising edge trigger detection`
- **GPIO Pull-up/Pull-down:** `No pull`  
  _Or **Pull-down** if the line floats while sensors are unpowered._
- **User Label:** `BMI270_INT2`

### 3) Fuel Gauge ALERT — `PB2` → `GAUGE_INT`
- **GPIO Mode:** `External Interrupt Mode with Falling edge trigger detection`
- **GPIO Pull-up/Pull-down:** `Pull-up`  
  _MAX17048 ALERT is open-drain, active-low; internal PU is fine to start, external PU is more robust._
- **User Label:** `GAUGE_INT`

---

## NVIC (interrupt controller)
**Path:** `System Core → NVIC`

Enable these IRQs and give them a sensible priority (e.g., **5**):
- [ ] **EXTI line0 interrupt** (for `PA0`)
- [ ] **EXTI line1 interrupt** (for `PA1`)
- [ ] **EXTI line2 interrupt** (for `PB2`)

> CubeMX will generate the IRQ handlers in `stm32wbxx_it.c` and route them to `HAL_GPIO_EXTI_Callback()`.

## CubeMX/CubeIDE Notes
- **LSE 32.768 kHz** enabled for BLE; **HSI48+CRS** for USB FS; enable **SMPS** only if BOM stuffed.
- **I²C policy:** 100 kHz start, then 400 kHz; analog filter ON, digital = 0.
- **EXTI:** PA0, PA1, PB1, PB2 with sensible priorities.

## Change Log
- **v0.1 (initial)** — Matches Hardware Guide & Firmware README for UFQFPN-48 (RF1 path).
