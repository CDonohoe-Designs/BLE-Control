# BLE-Control — EMC Pre-Compliance Notes

**Document ID:** BLEC-EMC-PRE-A1  
**Revision:** A1  
**Device:** BLE-Control Wearable BLE Controller  
**Prepared by:** C. Donohoe  
**Standards Referenced:**  
- IEC 60601-1-2 (Edition 4, Class A)  
- IEC 61000-4-2/-3/-4/-5/-6 immunity methods  
- CISPR 11 emissions (Class A device)  
- ISO 14971 (EMC-related risks)

---

# 1. Purpose of This Document

This document defines the **EMC pre-compliance test strategy** for BLE-Control, identifying:

- What tests apply  
- Expected stress levels  
- Acceptance criteria  
- How to interpret pass/fail  
- Critical failure modes to monitor  
- Required monitoring during RF exposure  
- How EMC relates to essential performance and 60601-1-2

This document supports the design review and helps prepare for full 60601-1-2 testing.

---

# 2. Device EMC Context

BLE-Control is:

- A **Class A medical accessory** (professional healthcare environment)  
- A **SELV-only**, battery-powered or USB-powered BLE controller  
- Not a patient-applied device  
- EMC-sensitive due to:
  - BLE 2.4 GHz RF front end  
  - High-impedance sensor interfaces  
  - USB-C interface with data lines  
  - µC logic lines sensitive to ESD/Burst  
  - RF π-match and CMC/ferrite placement

Essential performance is defined as:

> **Maintain BLE communication/control with the implant or fail safe (no unintended commands).**

EMC pre-compliance ensures this function behaves correctly under RF/ESD/Burst disturbances.

---

# 3. EMC Test Matrix (60601-1-2 Mandatory for Class A)

The table below lists **all applicable immunity tests**, IEC 61000-4 test methods, levels, and the expected result.

| Test | IEC Method | Level (Class A) | Injection Path | Expected Result |
|------|-------------|------------------|-----------------|------------------|
| **ESD** | 61000-4-2 | ±8 kV contact, ±15 kV air | USB shell, button, enclosure | No loss of function; reset acceptable if intentional and self-recovered |
| **Radiated RF Immunity** | 61000-4-3 | 10 V/m, 80 MHz–2.7 GHz | Air | BLE RSSI may degrade; no lockup |
| **EFT/Burst** | 61000-4-4 | ±1 kV | VBUS (via external PSU) | No permanent error; temporary sensor glitch acceptable |
| **Surge** | 61000-4-5 | 0.5 kV (line-to-line) | AC side of PSU | TVS on VBUS must clamp; device must not fail |
| **Conducted RF Immunity** | 61000-4-6 | 3 Vrms | VBUS cable | No loss of BLE or MCU lockup |
| **Magnetic Field** | 61000-4-8 | 30 A/m | Ambient | No effect (SELV design) |
| **Voltage Dips / Interruptions** | 61000-4-11 | via PSU only | AC mains | Device may shut down, must recover |

**Note:**  
Because BLE-Control is **USB-powered**, surge and dips apply ***only to the PSU***, but VBUS behaviour must be checked.

---

# 4. EMC-Critical Subsystems to Monitor

During radiated, conducted, and burst tests, the following signals/domains must be monitored:

### 4.1 RF Path
- RSSI (log during sweep)  
- Packet error rate  
- BLE disconnect events  
- Output harmonics (pre-scan recommended)

### 4.2 MCU Core
Watch for:
- Unexpected resets  
- Bootloader entry (BOOT0 stability)  
- Hard faults / watchdog resets  
- GPIO state changes

### 4.3 I²C Sensor Bus
Monitor:
- Bus stalls  
- NACK bursts  
- False interrupts (BMI270/TMP117/BQ_INT)  
- Corrupted readings under RF field

### 4.4 Button Input
- Spurious transitions  
- RC network should prevent bursts causing false edges

### 4.5 USB Interface
- USB noise injection into MCU VDDUSB  
- USBFS D+/D– integrity during fast edges  
- Susceptibility at 150 kHz–80 MHz (conducted RF)

---

# 5. Pre-Compliance Test Setup

### 5.1 Test Environment
- DUT in enclosure (prototype housing if available)  
- USB-C powered by known-good medical PSU  
- BLE link to controlled receiver (phone/test harness)  
- Shielded room preferred, but GTEM or semi-anechoic acceptable

### 5.2 Required Monitoring Equipment
- BLE sniffer (Nordic nRF Sniffer / Ellisys / STM32WB tools)  
- UART logging from MCU (if available)  
- Logic analyzer for I²C  
- Infrared temp sensor for thermal checks  
- Oscilloscope on:
  - 3V3_SYS  
  - 3V3_SENS  
  - USB_VBUS  
  - CE_MCU  
  - SENS_EN  
  - IRQ lines

### 5.3 Cabling
- Keep USB cable ≤ 1 m  
- Avoid coiling USB cable (resonance effects)  
- Ground reference plane under DUT recommended

---

# 6. Pass/Fail Criteria (Aligned to IEC 60601-1-2)

### 6.1 **Criteria A — No degradation**
- Device must operate normally  
- BLE link stable  
- No resets  
- Sensors return valid data

### 6.2 **Criteria B — Temporary degradation allowed**
The device may experience:
- Temporary loss of function  
- A reset  
- BLE link drop  
- Sensor read errors  

**BUT** must **self-recover** without user intervention.

### 6.3 **Criteria C — Unacceptable**
The following are **failures**:
- Device locks up  
- BLE does not reconnect  
- MCU enters invalid state  
- Erroneous command sent to implant system  
- Hardware damage  
- Unrecoverable latch-up in sensors

### For BLE-Control:
**Acceptable:**  
– Temporary BLE link drop  
– Temporary sensor glitches  
– Automatic watchdog reset  
– Momentary button false-trigger (debounced)

**Unacceptable:**  
– Continuous lockup  
– Stuck SENS_EN high/low  
– BQ21061 fault that does not recover  
– Hard faults without retry  
– Latch-up requiring power cycle

---

# 7. Known EMC Risk Areas & Mitigations

| Subsystem | EMC Risk | Mitigation |
|----------|----------|------------|
| USB-C port | ESD, burst, conducted RF | SMF5.0 TVS, USBLC6, CMC, 22 Ω |
| BLE antenna | High RF field | π-match, CPWG, via-fence |
| Sensor rail | Burst/RF coupling | TPS22910 gating, ferrite + decoupling |
| I²C bus | RF-induced bit errors | 4k7 pulls, short traces |
| Button | EFT false triggering | RC + 100 Ω + TVS |
| MCU reset | ESD-induced resets | RC reset network, shield bleed |
| Shield currents | ESD discharge | 1 MΩ // 1 nF bleed network |

---

# 8. Recommended Pre-Scan Emissions Tests

While not mandatory before full testing, the following should be checked:

### 8.1 Radiated Emissions (30–6000 MHz)
- 3 m pre-scan  
- BLE harmonics should be checked at:  
  - 2.4 GHz fundamental  
  - 4.8 GHz 2nd harmonic  
  - 7.2 GHz 3rd harmonic  
- Check USB noise at 240 MHz, 480 MHz

### 8.2 Conducted Emissions
- USB cable on LISN (if available)  
- Focus on switching noise from charger and internal regulators

---

# 9. Pre-Compliance Checklist (Engineer Quick Sheet)

**Before testing:**
- [ ] Place DUT in enclosure  
- [ ] Verify shield bleed RC is populated  
- [ ] Set MCU to full debug logging  
- [ ] Disable power gating only if required to monitor raw signals  
- [ ] Set BLE into continuous advertising mode  
- [ ] Log RSSI on sniffer  
- [ ] Apply fresh USB cable (no braided shielding)

**During testing:**
- [ ] Observe BLE stability  
- [ ] Monitor I²C bus for stalls  
- [ ] Check interrupts for false triggers  
- [ ] Check reset line for unintended pulses  
- [ ] Track sensor voltage rail (3V3_SENS) for dip events

**After testing:**
- [ ] Validate no permanent damage  
- [ ] Validate BLE parameters  
- [ ] Validate charger operation  
- [ ] Validate RF output & match unchanged  
- [ ] Document all Criteria B events

---

# 10. Final Notes for 60601 Compliance

- Class A devices **may degrade** performance temporarily during RF/ESD — this is acceptable if self-recovery occurs.  
- Essential performance = **communication**, not precise sensing.  
- The DUT must never enter an **unsafe command state**, such as generating spurious control commands during EMC stress.

---

_End of EMC_Precompliance_Notes.md_
