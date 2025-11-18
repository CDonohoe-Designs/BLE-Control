# BLE-Control — ISO 14971 Risk Register

**Document ID:** BLEC-RISK-REG-A1  
**Device:** BLE-Control Wearable BLE Controller  
**Revision:** A1  
**Prepared by:** C. Donohoe  
**Standard:** ISO 14971:2019 (Risk Management for Medical Devices)

**Date:** 18/11/2025


---

# 1. Purpose

This document provides the **formal risk register** required under ISO 14971, identifying:

- Hazards  
- Sequence of events  
- Hazardous situations  
- Potential harms  
- Initial & residual risk levels  
- Risk control measures  
- Verification methods  

This risk register applies **only to BLE-Control**, a SELV-only external controller.  
BLE-Control **does not** interface electrically with the patient; therefore, all patient-protection hazards fall outside its boundary.

---

# 2. Risk Scoring System

### **Severity (S)**  
| Score | Description |
|-------|-------------|
| 1 | Negligible discomfort / no injury |
| 2 | Minor, reversible discomfort |
| 3 | Temporary impairment / mild injury |
| 4 | Serious reversible injury |
| 5 | Serious irreversible injury or death |

### **Probability (P)**  
| Score | Description |
|-------|-------------|
| 1 | Remote (<1e-6) |
| 2 | Very low |
| 3 | Low |
| 4 | Medium |
| 5 | High |

### **Risk Priority Number (RPN)**  
`RPN = S × P`

Risk acceptance criteria follow ISO 14971 Annex C guidance.

---

# 3. Risk Register Table

## **A. Electrical & Power Risks (SELV domain)**

| ID | Hazard | Sequence of Events | Hazardous Situation | Harm | S | P | RPN | Controls | Residual Risk |
|----|--------|--------------------|---------------------|------|---|---|-----|----------|----------------|
| E1 | Overcurrent on USB VBUS | Short on board → excessive current | Heating of PCB | Minor burn, device damage | 2 | 2 | 4 | PPTC F101 (500mA), layout spacing | Acceptable |
| E2 | Battery reverse connection | User inserts Li-ion pack backwards | Reverse current path | IC heating, pack damage | 3 | 2 | 6 | Reverse-FET Q101 | Acceptable |
| E3 | Battery overcharge | Charger fault or firmware crash | Over-voltage on battery | Overheating or swelling | 4 | 1 | 4 | BQ21061: OVP, JEITA, CC/CV limits | Acceptable |
| E4 | LDO failure | Short/open internal failure | 3V3_SYS too high or low | Device resets, instability | 2 | 2 | 4 | TPS7A02: thermal/OC, internal limits | Acceptable |
| E5 | Short on 3V3_SENS | Sensor failure → short to GND | Drop in system rail | Device resets | 1 | 3 | 3 | TPS22910 load switch isolates sensor domain | Acceptable |

---

## **B. EMC / ESD / Surge Risks (IEC 60601-1-2)**

| ID | Hazard | Sequence of Events | Hazardous Situation | Harm | S | P | RPN | Controls | Residual Risk |
|----|--------|--------------------|---------------------|------|---|---|-----|----------|----------------|
| M1 | ESD strike (±8 kV contact, ±15 kV air) | User touches USB/button/ enclosure | MCU latch-up or resets | Loss of control | 2 | 3 | 6 | PESD diodes, USBLC6, shield bleed (1MΩ//1nF) | Acceptable |
| M2 | RF interference at 2.4 GHz | Radiated RF at 10 V/m | BLE link corrupted | Temporary loss of communication | 1 | 4 | 4 | Adaptive advertising, watchdog | Acceptable |
| M3 | Surge via PSU | AC surge → PSU failure → VBUS transient | Overvoltage at input | Permanent device damage | 2 | 2 | 4 | SMF5.0 TVS on VBUS, PPTC | Acceptable |
| M4 | EFT/burst coupling | ±1 kV bursts on VBUS | Spurious toggling of button/I2C | False command risk | 3 | 2 | 6 | RC filtering, series resistors, TVS | Acceptable |
| M5 | Conducted RF (150 kHz–80 MHz) | Cable acts as antenna | MCU misbehaves | Loss of comms | 2 | 3 | 6 | USB CMC (ACM2012D), firmware debouncing | Acceptable |

---

## **C. Functional & Software-Controlled Risks**

| ID | Hazard | Sequence of Events | Hazardous Situation | Harm | S | P | RPN | Controls | Residual Risk |
|----|--------|--------------------|---------------------|------|---|---|-----|----------|----------------|
| F1 | BLE disconnect | RF interference / distance | Loss of link | Commands not sent | 1 | 4 | 4 | Auto-reconnect, watchdog | Acceptable |
| F2 | MCU crash | Brown-out / EMC event | Stuck operational state | Loss of control | 2 | 2 | 4 | BOR, watchdog, valid POR | Acceptable |
| F3 | False button activation | ESD/burst noise | Unintended user command | Wrong UI event | 2 | 2 | 4 | RC filter + series R + TVS | Acceptable |
| F4 | Incorrect sensor data | I²C corruption | Wrong algorithmic behavior | Incorrect app info | 1 | 3 | 3 | CRC checks, retries | Acceptable |

---

## **D. Mechanical & Thermal Risks**

| ID | Hazard | Sequence | Hazardous Situation | Harm | S | P | RPN | Controls | Residual Risk |
|----|--------|----------|---------------------|------|---|---|-----|----------|----------------|
| T1 | Overheating | Overload or charging in enclosure | Device becomes hot | Discomfort | 2 | 2 | 4 | Thermal throttling (BQ21061), copper spread | Acceptable |
| T2 | Connector stress | USB cable pulled sideways | Port damage | Device non-functional | 1 | 2 | 2 | Reinforced land, mechanical support | Acceptable |
| T3 | Battery mechanical damage | Drop/impact | Cell deformation | Leakage risk | 4 | 1 | 4 | Battery enclosure spec in Battery Folder | Acceptable |

---

## **E. User Interaction / UI Risks**

| ID | Hazard | Sequence | Hazardous Situation | Harm | S | P | RPN | Controls | Residual |
|----|--------|----------|---------------------|------|---|---|-----|----------|----------|
| U1 | Button jam | Dirt, mechanical failure | No user input | Loss of UI | 1 | 2 | 2 | High-quality switch, gold contacts | Acceptable |
| U2 | LED failure | LED open-circuit | No visual feedback | User confusion | 1 | 3 | 3 | Startup test, non-critical | Acceptable |

---

# 4. Risk Control Measures Summary

### Electrical Safety (SELV)
- Reverse-FET  
- PPTC fuse  
- Charger OVP/OCP  
- No hazardous voltages generated  

### EMC / ESD
- USBLC6  
- PESD on button & antenna  
- TVS on VBUS  
- Ferrite beads & CMC  
- Shield bleed network  

### Functional Safety
- Watchdog  
- BOR + POR  
- GPIO pull-ups/downs  
- Deterministic reset circuit  

### BLE Safety
- No unsafe command generation  
- Communication drop = safe state  
- Auto-reconnect  

---

# 5. Residual Risk Evaluation

All risks after controls fall within acceptable limits according to:

- Internal risk acceptability matrix  
- ISO 14971 Annex C  
- IEC 60601-1 essential performance definitions  
- BLE-Control’s risk boundaries (non-patient-applied, SELV)

Residual risk is **acceptable**.

---

# 6. Risk Management File Linkage

This Risk Register is part of the BLE-Control **Risk Management File (RMF)** and refers to:

- **Safety_Boundary_Statement.md**  
- **Electrical_Safety_Overview.md**  
- **EMC_Precompliance_Notes.md**  
- **MCU_Design_Rationale.md**  
- **Component_Criticality_ChangeControl.md**

Auditors reference these as supporting documents.

---

_End of Risk_Register.md_
