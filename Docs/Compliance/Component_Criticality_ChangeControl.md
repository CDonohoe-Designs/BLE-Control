# BLE-Control — Component Criticality & Change Control Requirements

**Document ID:** BLEC-CC-CLASS-A0  
**Revision:** A0  
**Applies to:** BLE-Control Wearable BLE Controller  
**Prepared by:** C. Donohoe  
**Standards Referenced:** ISO 13485:2016, ISO 14971:2019, IEC 60601-1, IEC 60601-1-2, FDA 21 CFR 820.30 / 820.181
**Date:** 17/11/2025

---

# 1. Purpose

This document defines:
- Component criticality classes (A, B, C, D)  
- How changes to components affect safety, EMC, and essential performance  
- What level of **Change Control Review** is required for each class  

This enables compliance with:
- ISO 13485 (design control & change management)  
- ISO 14971 (risk management traceability)  
- IEC 60601-1 (electrical safety)  
- IEC 60601-1-2 (EMC performance)

---

# 2. Summary of Criticality Classes

The BLE-Control BoM uses four standardized criticality levels:

### **Class A — Safety-Critical Components**
Components whose failure, removal, or substitution could affect:
- Electrical safety  
- Battery safety  
- Surge/ESD protection  
- Reverse polarity protection  
- Current limiting  
- User-accessible protection paths  
- Essential performance (reset/boot/function safety)

Class A must meet the highest level of change control.

### **Class B — EMC-Critical Components**
Components whose characteristics influence:
- Radiated emissions  
- Conducted emissions  
- Radiated immunity  
- Conducted immunity  
- ESD susceptibility  
- RF matching / antenna performance

Class B does not necessarily threaten *basic safety*, but can affect **essential performance**, especially BLE communication stability.

### **Class C — Function-Critical Components**
Components required for correct operation, but whose substitution typically does not affect safety or EMC if rated appropriately.

Examples:
- MCU, sensors, resistors/pull-ups, decoupling capacitors, crystal load capacitors.

### **Class D — Non-Critical Components**
Changes have negligible impact on safety or performance.
Includes:
- LEDs  
- Switches  
- Test points  
- Mechanical connectors (when not safety/EMC paths)

---

# 3. Change Control Requirements by Class

## **Class A — Safety-Critical**
**Examples**  
PPTC fuse, TVS diodes, USBLC6 ESD array, PESD diodes, Q101 (reverse FET), BQ21061 charger IC, TPS22910 switch, RF π-match components, USB-C connector (J2).

**Required Change Control Level**
- **Full Engineering Change Request (ECR)**  
- **Formal risk assessment update (ISO 14971)**  
- **Re-validation testing required**, including:
  - Electrical safety review  
  - EMC pre-compliance (at minimum: ESD ±8 kV, Burst ±1 kV, Surge ±500 V per 60601 Class A environment)  
  - Power path verification (for F101, Q101, BQ21061 changes)  
- **Documentation updates**:
  - BoM  
  - Schematics  
  - Risk file  
  - IEC 60601-1 & 60601-1-2 rationale documents  

No substitution allowed without explicit technical review.

---

## **Class B — EMC-Critical**
**Examples**  
Ferrite beads (FB2, FB101), USB CMC (FL101), differential RF filter (FL2), shield bleed resistors (R101/R107), series resistors on USB/I²C (22 Ω), RF matching network (C14, C15, L1, L3).

**Required Change Control Level**
- **ECR required**  
- **Targeted EMC impact assessment**
  - Radiated emissions  
  - Conducted emissions  
  - RF tuning/harmonics  
  - ESD immunity  
- Re-validation (partial) recommended:
  - Radiated pre-scan  
  - RSSI/performance verification  

If RF π-match parts change value/tolerance, **new antenna tuning** is mandatory.

---

## **Class C — Function-Critical**
**Examples**  
MCU, sensors (TMP117, BMI270, SHTC3), decoupling capacitors, pull-up resistors, crystal components, LED driver resistor, logic biasing resistors.

**Required Change Control Level**
- Lightweight ECR or ECO  
- No risk file update typically required **unless**:
  - different tolerance affects timing  
  - crystal changes affect BLE frequency stability  
  - pull-up values affect boot or interrupt behaviour  

If replacing crystals or MCU:
- BLE frequency offset verification  
- Basic functional test  

---

## **Class D — Non-Critical**
**Examples**  
LED1, SW1, Tag-Connect (J3), mechanical connectors (J1, if not safety-sensitive), all test points TP1–TP17 (docs only).

**Required Change Control Level**
- Typical ECO only  
- No test re-validation required  
- No impact to risk file  
- No additional review unless form/fit to enclosure is impacted  

---

# 4. Summary Table

| Class | Impact | Requires Risk File Update | Requires EMC Testing | Requires Full ECR | Notes |
|-------|--------|---------------------------|-----------------------|--------------------|-------|
| **A** | Safety & essential performance | **Yes** | **Yes** | **Yes** | Highest control |
| **B** | EMC & essential performance | Maybe | **Recommended** | Yes | RF/EMC-sensitive |
| **C** | Functional | No (usually) | No | ECO/ECR | Check tolerances |
| **D** | Minimal | No | No | ECO | Test points, UI |

---

# 5. Guidelines for Substitution & Approved Vendor List (AVL)

### For Classes A & B:
- All alternates must be pre-qualified  
- Must match:  
  - voltage rating  
  - surge rating  
  - ESD performance  
  - impedance/frequency curves (for ferrites & RF)  
  - footprint  
  - tolerance  
- Requires **engineering approval** before placement on AVL.

### For Classes C & D:
- Alternate values may be allowed if tolerance and derating apply  
- Replacement must be FIT/FUNCTION equivalent  
- Document change in AVL log

---

# 6. Integration With ISO 13485 Design Controls

Changes to Class A or B components must be reviewed in Design Review (per 13485 7.3.7):

- Design input → output consistency  
- Verification/validation impact  
- Risk management update  
- Documentation traceability  
- Supplier evaluation if manufacturer changes  

---

# 7. Conclusion

This classification system ensures:

- Predictable change control  
- Full traceability under ISO 13485  
- Clear regulatory defensibility  
- Minimal EMC or safety regression risk  
- Fast decision making for lower-criticality parts  

This document is part of the BLE-Control **Design History File (DHF)** and must accompany any Engineering Change Request (ECR) relating to the BoM.

---

_End of Component_Criticality_ChangeControl.md_
