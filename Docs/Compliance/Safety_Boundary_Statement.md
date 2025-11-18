# BLE-Control — Safety Boundary Statement

**Document ID:** BLEC-SAFETY-BOUNDARY-A1  
**Revision:** A1  
**Device:** BLE-Control Wearable BLE Controller  
**Prepared by:** C. Donohoe
**Date:** 18/11/2025


**Standards Referenced:**  
- IEC 60601-1 (Basic Safety & Essential Performance)  
- IEC 60601-1-2 (EMC, Class A)  
- ISO 14971 (Risk Management)  
- IEC 62368-1 / IEC 60950-1 (external PSU insulation assumptions)  

---

# 1. Purpose of This Document

This document defines the **electrical, mechanical, and functional safety boundaries** of the BLE-Control device.  
It clarifies:

- What electrical domains BLE-Control contains  
- What protective functions BLE-Control implements  
- What safety functions it **does not** provide  
- What external isolation and compliance requirements BLE-Control relies on  
- What portion of the system is included in risk analysis and EMC justification  

This statement is required for IEC 60601-1 reviewers to evaluate the subsystem in context.

---

# 2. Overview

BLE-Control is a **low-voltage, SELV-only, non-patient-applied external controller**.  
It **does not** connect directly to the patient or to any hazardous voltage sources.

BLE-Control communicates wirelessly (BLE) with a separate implant/device and has **no physical electrical interface** to the body.

All hazardous insulation, mains isolation, patient protection, and stimulation safety are handled **outside** BLE-Control.

---

# 3. Electrical Safety Boundary

## 3.1 Internal Voltage Domains (All SELV)

BLE-Control contains only the following voltage domains:

| Domain | Typical Voltage | Origin | Classification |
|--------|------------------|--------|----------------|
| **VBUS (USB-C)** | 5.0 V | External PSU | SELV |
| **VBAT_RAW** | 3.0–4.2 V | Li-ion cell | SELV |
| **VBAT_PROT** | 3.0–4.2 V | Post reverse-FET | SELV |
| **+3V3_SYS** | 3.3 V | PMIC/LDO | SELV |
| **+3V3_SENS** | 3.3 V | Gated rail | SELV |

There are **no mains voltages**, no intermediate bus > 42 Vpk, and no HV for stimulation.

### **Conclusion: Entire BLE-Control circuitry is SELV.**  
This places BLE-Control **entirely on the secondary side** of the system’s safety insulation barrier.

---

# 4. External Safety Boundary

BLE-Control relies on:

### **4.1 External USB Power Supply (PSU)**
The PSU must be:
- IEC 60601-1 or IEC 62368-1 compliant  
- 2×MOPP isolation between mains ↔ output  
- SELV output (5 V max)

**BLE-Control assumes all mains isolation is provided externally.**

### **4.2 Implantable Device**
The implant system:
- Implements patient isolation  
- Limits stimulation current/voltage  
- Controls therapy safety algorithms  
- Manages patient-applied leakage limits  
- Is the responsibility of the implant manufacturer/system integrator

BLE-Control **does not implement** any patient safety functions.

---

# 5. Safety Functions Provided by BLE-Control

BLE-Control implements **only low-voltage protective functions**:

| Function | Component(s) | Purpose |
|----------|--------------|---------|
| Overcurrent protection | PPTC (F101) | Limits fault current on VBUS |
| Surge/ESD protection | SMF5.0A TVS, USBLC6, PESD5V0 | IEC 61000-4-2/-4/-5 immunity |
| Reverse polarity protection | Q101 | Protects Li-ion cell |
| Battery charging safety | BQ21061 | JEITA profile, OVP/OC protection |
| Power integrity | TPS7A02 LDO, TPS22910 load switch | Stable rails, soft-start recovery |
| EMC/RF containment | RF π-match, ferrites, CMC, shield bleed | Controls emissions & immunity |

### **BLE-Control does NOT provide:**
- Patient isolation  
- Applied part leakage protection  
- Therapy safety  
- MOPP/MOOP insulation  
- Mains safety  
- HV control

---

# 6. Functional Safety Boundary (Essential Performance)

Essential Performance for BLE-Control is defined as:

> **Correct BLE communication with the implant OR safe loss of communication.**

Therefore:

- BLE disconnect = **acceptable** (Criteria B)  
- BLE reconnect required automatically  
- No spurious commands may be emitted during EMC or reset  
- Safe behaviour = “no output”  

BLE-Control **must not generate any unintended RF packets** that could affect therapy.

---

# 7. EMC Boundary (IEC 60601-1-2)

BLE-Control contains only:
- One EMC entry port: **USB-C**  
- One radiating structure: **2.4 GHz antenna**  
- One exposed mechanical input: **tactile button**  
- Enclosure surface (ESD air discharge)

EMC tests apply **only** to BLE-Control up to the SELV boundary.  
Tests involving mains-side surge, dips, voltage fluctuations apply **only to the PSU**, not BLE-Control.

Within BLE-Control:
- Immunity testing covers all SELV circuitry  
- Emissions testing applies to RF and digital switching within BLE-Control  
- RF coexistence testing applies to BLE operation under field exposure

---

# 8. Thermal Safety Boundary

BLE-Control includes:
- A single Li-ion cell  
- Limited charging current (<500 mA)  
- Copper thermal spread around regulator/charger  
- No heater element, no high dissipation devices

Thermal runaway protection is located in:
- **Battery pack protection circuit**  
- **BQ21061 thermal regulation loop**

Device surface temperature remains far below IEC 60601-1 limits.

---

# 9. Cybersecurity / Wireless Safety Boundary

BLE-Control:
- Authenticates BLE communication  
- Does not store dosage/therapy algorithms  
- Does not generate stimulation signals  
- No direct actuation of therapy hardware

Miscommunication results in **loss of control**, not incorrect stimulation.  
Thus BLE-Control is *not* a therapeutic controller.

---

# 10. Summary of Safety Boundaries

### Responsibilities **within BLE-Control**
- Overcurrent protection  
- Battery charging safety  
- ESD/surge/EMC protection  
- Low-voltage power integrity  
- BLE communication integrity  
- Hardware reset control  
- Deterministic startup logic

### Responsibilities **outside BLE-Control**
- Mains isolation  
- Patient safety  
- Applied part leakage  
- Therapy algorithms  
- Implanted stimulation safety  
- Isolation barrier design  
- Any function requiring MOPP/MOOP

---

# 11. Final Statement

BLE-Control is entirely contained within a **SELV safety domain** and **relies on external devices** (PSU and implant) to provide all:
- mains isolation,  
- patient protection,  
- high-voltage insulation,  
- stimulation safety,  
- and Class II/Type BF/CF requirements.

BLE-Control’s compliance responsibilities are limited to:
- SELV electrical safety (IEC 60601-1 SELV section)  
- EMC performance (IEC 60601-1-2)  
- Wireless integrity and safe command behaviour (via essential performance definition)

---

_End of Safety_Boundary_Statement.md_
