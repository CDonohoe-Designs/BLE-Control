# MCU Design Rationale — STM32WB55CGU6

**Document ID:** BLEC-MCU-RATIONALE-A0  
**Applies to:** BLE-Control PCB, MCU_RF.SchDoc  
**MCU:** STM32WB55CGU6 (QFN48)  
**Author:** Caoilte Donohoe 
**Date:** 17/11/2025

---

## 1. Purpose of Design Rationale

This document explains the **engineering intent** behind the microcontroller input/output biasing, boot configuration, reset strategy, RF connections, and EMC behaviour.  
It demonstrates that the MCU subsystem on BLE-Control has been designed to:

- Boot deterministically  
- Hold no floating inputs  
- Recover safely from EMC disturbances  
- Provide essential performance under IEC 60601-1-2  
- Prevent unsafe states at power-up or reset  
- Minimise susceptibility to EMI and ESD  
- Align with ISO 14971 hazard controls  

---

## 2. Deterministic Boot & Reset Behaviour

### BOOT0 (PH3)
- Pulled **down via 100 kΩ** → safe, deterministic User Flash boot.  
- Test point allows controlled override for programming.  
- Ensures device cannot unintentionally enter DFU/system bootloader.

### NRST
- **10 kΩ pull-up + 100 nF RC network**  
- Ensures clean start-up under noisy conditions.  
- Required for ESD & burst robustness as per IEC 61000-4-2 / 61000-4-4.

**Rationale:**  
Predictable MCU reset behaviour is essential performance.  
A floating reset pin is a common source of:
- intermittent brownout resets  
- unintended resets during EMC tests  
- unsafe or undefined MCU states  

---

## 3. Input Pin Biasing Strategy

The following design goals define the MCU input biasing:

1. **No floating inputs** → eliminates unpredictable logic transitions under RF or ESD.  
2. **All interrupt sources have defined pull-ups/downs** → avoids false triggers.  
3. **All asynchronous inputs are robust to ESD/Burst** → required for 60601-1-2.  
4. **Unused GPIOs are handled in firmware** → avoid unnecessary hardware biasing.

### Interrupt Inputs
- TMP117_ALERT → **10 kΩ pull-up**  
- BMI270_INT1 / INT2 → **100 kΩ pull-downs**  
- BQ_INT → **pull-up to VIO**  

These guarantee a stable logic level even when:
- Sensors are unpowered (3V3_SENS = OFF)  
- EMC transient couples onto sensor lines  
- Firmware has not yet configured GPIOs  

### Button Input (BTN1)
- **470 kΩ pull-up**, 100 Ω series, RC filtering, ESD diode  
- Ensures no false edges during EFT/ESD events  
- Ensures button reads high when unpowered (safe default)

---

## 4. USB FS Data Interface Rationale

### D+ / D– handling:
- **22 Ω series resistors** → edge rate control & EMC damping  
- **USBLC6 ESD** + **CMC** upstream → IEC 61000-4-2 protection  
- No external D+ pull-up → **STM32 internal 1.5 kΩ enabled automatically**  
- Tracks length-matched and routed as differential pair  

**Why:**  
USB device mode on STM32 requires MCU-controlled pull-up.  
External pull-up on D+ would break USB enumeration and suspend/resume behaviour.

---

## 5. Sensor Rail Control Rationale

### SENS_EN (TPS22910A ON pin)
- Internal pulldown provided by TI device → 3V3_SENS defaults **OFF**  
- Safe-state behaviour: sensors disabled until MCU deliberately powers them  
- Minimises EMC susceptibility by reducing number of powered peripherals during startup  

**Reasoning:**  
During ESD/Burst events, unpowered peripherals with floating lines can cause:
- phantom interrupts  
- invalid sensor reads  
- brownout or latch-up  
Having SENS_EN default low prevents this.

---

## 6. RF Pin & Network Rationale

### RF feed (PA14/PA15 RF)
- Connected to 50 Ω CPWG  
- π-match (C-L-C) implemented as **DNP tuning network**  
- RF ESD footprint provided at antenna feed  

**Reasoning:**  
- π-match allows post-layout correction of antenna mismatch, improving radiated emissions.  
- RF ESD diode footprint supports IEC 61000-4-2 contact discharge on antenna.  

---

## 7. Unused GPIO Handling

**Policy:**  
All unused GPIOs are configured in firmware as:

> **Analog mode (no pull, no digital input buffer, no interrupt).**

This:
- eliminates digital switching noise  
- prevents floating CMOS inputs  
- meets EMC best practice  
- avoids unnecessary resistors in a compact wearable design  

---

## 8. Summary of Safety & EMC Intent

- All **asynchronous signals** have explicit biasing → prevents false triggers  
- All **power control lines** default to safe, deterministic states  
- All **sensors** remain off until intentionally enabled  
- USB FS is **fully EMC protected** at the connector and MCU  
- RF pins have **tuning, ESD, and stable reference return paths**  
- No MCU pin is left floating at power-up  
- Design supports **IEC 60601-1-2 Class A** radiated/conducted immunity  
- Input states remain defined during ESD, burst, and radiated RF  

---

## 9. Conclusion

The STM32WB55 pin biasing and configuration strategy is intentional, safe, compliant with IEC 60601 principles, robust to EMC disturbances, and aligned with ISO 14971 risk controls.  

No hardware changes are required beyond documentation improvements.  
