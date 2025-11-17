# BLE-Control — EMC Port Classification (IEC 60601-1-2)

**Document ID:** BLEC-EMC-PORTS-A0  
**Revision:** A0  
**Applies to:** BLE-Control Wearable BLE Controller PCB  
**Author:** Caoilte Donohoe  
**Standard:** IEC 60601-1-2 (Edition 4)  
**Environment:** Class A — Professional Healthcare Environment  

---

# 1. Purpose

This document classifies all BLE-Control external and internal ports according to **IEC 60601-1-2**, identifies their EMC protection mechanisms, and defines expected test exposures.  
This supports EMC test planning, risk management (ISO 14971), and system-level safety analysis.

---

# 2. Summary of Port Types (IEC 60601-1-2 Definitions)

IEC 60601-1-2 categorises ports into:

- **AC/DC Input Ports** — powered by an external PSU or USB supply  
- **Signal Input/Output Ports** — digital or analog signal paths  
- **Patient Connections** — *none present on this device*  
- **RF Ports** — connected to wired/wireless antennas  
- **Enclosure Ports** — operator-accessible mechanical interfaces  
- **Power Internal Ports** — battery, gated rails, internal supply domains  
- **Service Ports** — not for operator use, used for debugging or programming  

BLE-Control includes no mains, no high voltage, and no patient-applied circuits.

---

# 3. Port Classification Table

| Port / Interface | IEC 60601-1-2 Port Category | Description | EMC Protection | Required Immunity Tests |
|------------------|------------------------------|-------------|----------------|--------------------------|
| **USB-C (VBUS)** | AC/DC SELV Input Port | External PSU supply (5 V) | PPTC, SMF5.0 TVS, shield R//C | ESD, Burst, Surge, Conducted RF |
| **USB-C (CC1/CC2)** | Signal I/O Port | USB config pins | PESD ESD clamps | ESD |
| **USB FS D+/D–** | Signal I/O Port | USB full-speed data | USBLC6 ESD, CMC, 22 Ω series | ESD, Burst, Conducted RF |
| **Battery Connector (VBAT_RAW)** | Internal Power Port | Single-cell Li-Po input | Reverse FET, charger safety | ESD, Burst |
| **3V3_SYS Rail** | Internal Power Port | Main system rail | Decoupling, ferrites | Burst, Conducted RF |
| **3V3_SENS Rail** | Internal Gated Power Port | Sensor power domain | TPS22910A gating, ferrite | Burst, Radiated RF |
| **RF Antenna Port** | RF Port (Intentional Radiator) | 2.4 GHz BLE antenna | π-match, CPWG, RF ESD option | Radiated Emissions, Radiated Immunity |
| **Button (BTN1)** | Operator Accessible Control | User button | TVS, 470 kΩ PU, RC, 100 Ω | ESD, Burst |
| **LED Indicator** | Operator-Visible Indicator | Status LED | Series resistor | ESD |
| **I²C Sensor Bus — SENS Domain** | Internal Signal Port | TMP117, BMI270, SHTC3 | Pull-ups, ferrite, decoupling | Radiated RF, Conducted RF |
| **Charger I²C** | Internal Signal Port | Charger config/status | Pull-ups, short traces | Burst, ESD |
| **Interrupt Lines (TMP/BMI/BQ)** | Internal Signal Port | Device → MCU | Pull-ups/downs | ESD, Radiated RF |
| **SWD Interface** | Service Port | Debug/programming | Short traces only | Not tested during EMC |
| **Enclosure** | Enclosure Port | Non-conductive enclosure | Indirect via USB shield | ESD (via enclosure) |

---

# 4. EMC Protection Summary (Per Port)

## 4.1 USB-C Port (VBUS, CC, D+, D–)
- **Protection:**  
  - PPTC (overcurrent)  
  - SMF5.0 TVS at connector  
  - USBLC6 ESD on D+/D–  
  - PESD5V0 on CC1/CC2  
  - CMC on D+/D–  
  - Shield referenced via **1 MΩ // 1 nF**
- **Tests:**  
  - ESD (±8 kV contact)  
  - Burst  
  - Conducted RF  
  - Surge (via PSU input path)

## 4.2 Battery Port (Internal)
- **Protection:** Reverse FET, charger protection, pack-level BMS  
- **Tests:** ESD, burst  
- **Not an operator-access port**

## 4.3 Sensor Rail (3V3_SENS)
- **Protection:** TPS22910A gating, ferrite, local decoupling  
- **Tests:** Burst, radiated RF  
- **Sensor rail can be power-cycled for EMC recovery**

## 4.4 RF Port
- **Protection:** π-match, CPWG, RF ESD footprint  
- **Tests:** Radiated emissions and immunity  

## 4.5 Operator Button
- **Protection:** TVS, RC filtering, 470 kΩ PU, 100 Ω series  
- **Tests:** ESD (direct), EFT (via coupling clamp)

## 4.6 SWD Port
- **Not operator accessible**  
- **Not a functional port during EMC testing**  
- Testing not applicable

---

# 5. Expected EMC Test Matrix

| Test | Applies To | Notes |
|------|------------|-------|
| **IEC 61000-4-2 (ESD)** | USB-C, BTN1, enclosure, antenna | Primary operator touch points |
| **IEC 61000-4-3 (Radiated Immunity)** | RF path, MCU, sensors | Class A levels |
| **IEC 61000-4-4 (Burst)** | VBUS, internal rails | Injected via PSU/USB path |
| **IEC 61000-4-5 (Surge)** | External PSU → VBUS | TVS/PPTC required |
| **IEC 61000-4-6 (Conducted RF)** | USB and PSU lines | CMC/ESD/ferrites provide mitigation |
| **IEC 61000-4-8 (Power magnetic fields)** | Not relevant | No inductive coils or mains parts |
| **Radiated Emissions** | BLE antenna, USB | π-match allows post-layout tuning |

---

# 6. Compliance Statement

BLE-Control implements port-level EMC protection consistent with **IEC 60601-1-2 (Ed.4, Class A)** requirements through:

- Protective components (TVS, ESD, CMC, ferrites, RC filters, pull-ups/downs)  
- Robust layout practices (CPWG, short traces, star routing, decoupling close to devices)  
- Defined logic states on all ports  
- Safe defaults during power-up/reset  

Residual EMC risks are minimal and addressed through system-level testing.

---

# End of EMC_Port_Classification.md
