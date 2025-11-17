# BLE-Control — MCU Pin Biasing & Input-State Safety Review

**Document ID:** BLEC-MCU-BIAS-A0  
**Revision:** A0  
**Applies to:** BLE-Control Wearable BLE Controller PCB  
**MCU:** STM32WB55CGU6 (QFN48)  
**Author:** C. Donohoe  
**Date:** [Insert Date]

---

## 1. Purpose

This document reviews and verifies **all MCU input pin biasing**, ensuring:

- No floating inputs (reducing EMC susceptibility)
- Deterministic boot and reset states
- Correct pull-ups / pull-downs for I²C, interrupts, and control lines
- Compliance with IEC 60601-1 / 60601-1-2 EMC behavioural requirements

It also specifies the **Unused GPIO Policy** for BLE-Control.

---

## 2. MCU Pins with Confirmed Correct Biasing

### 2.1 BOOT0 (PH3, Pin 4)
- External 100 kΩ pull-down → **BOOT0 = 0 by default**  
- TP17 allows forcing BOOT0 high for bootloader  
- Correct and deterministic

### 2.2 NRST (Pin 7)
- 10 kΩ pull-up + 100 nF reset capacitor  
- Fully compliant STM32 reset network  
- EMC-robust

### 2.3 I²C Lines

#### System I²C (charger, etc.)
- Pull-ups: **4.7 kΩ** to +3V3_SYS  
- Series 22 Ω resistors near MCU  
- Correct

#### Sensor I²C
- Pull-ups: **4.7 kΩ** to +3V3_SENS  
- Series resistors present  
- Correct

### 2.4 Interrupt Lines

| Signal            | Source      | Bias       | Result |
|------------------|-------------|------------|--------|
| TMP117_ALERT     | TMP117     | 10 kΩ up   | Known-high when idle |
| BMI270_INT1/INT2 | BMI270     | 100 kΩ down | Defined low when sensors off |
| BQ_INT           | BQ21061    | 47–100 kΩ up | Default high, active-low IRQ |

All async inputs → **defined states** (no floating lines).

### 2.5 Button Input (BTN1)
- 470 kΩ pull-up  
- 100 Ω series  
- 100 nF RC debounce  
- TVS protection  
- Fully defined and EMC hardened

### 2.6 Control Outputs

#### CE_MCU → Charger Enable
- 100 kΩ pull-up → **Fail-safe ON** power path  
- Correct per design intent

#### SENS_EN → Sensor Rail Switch
- TPS22910A has internal pull-down → **Sensors default OFF**  
- Optional: add external 470 kΩ pull-down (not required)

### 2.7 USB FS Lines
- No pull-up (correct — STM32 handles internal 1.5k)  
- 22 Ω series resistors  
- CMC + ESD upstream  
- Correct for USB FS device mode

### 2.8 SWD Debug Port
- Uses internal STM32 pulls  
- Optional: add 100 kΩ PD on SWCLK / 100 kΩ PU on SWDIO (not required)

---

## 3. Unused GPIO Policy (Important)

Several pins are unconnected (`NetIC3_x` nets).

BLE-Control uses the following policy:

> **All unused STM32WB55 GPIO pins are configured in firmware as  
> ANALOG (no pull-up/down, no digital buffer, no interrupt).**  
>  
> This method prevents floating digital inputs and minimises EMI susceptibility.

No external resistors are required.

Optional (not used): 100–220 kΩ pull-down resistors.

---

## 4. Summary of Required/Optional Biasing Changes

| Item | Status | Action |
|------|--------|--------|
| SENS_EN external pulldown | Optional | Add 470 kΩ to reinforce TPS internal PD |
| SWCLK / SWDIO biasing | Optional | Add weak pulls only if EMC requires |
| Unused GPIO handling | Required | Add schematic note (see below) |

**No critical corrections required.**  
Current design is electrically and EMC-safe.

---

## 5. Conclusion

The STM32WB55 pins on the BLE-Control PCB are:

- Correctly biased  
- EMC-robust  
- Safe for 60601-1-2 behaviour  
- Deterministic on boot/reset  
- Fully compliant with good mixed-signal and wearable design practice  

Only documentation improvements are recommended (see schematic notes).

---

# End of MCU_InputBias_Review.md
