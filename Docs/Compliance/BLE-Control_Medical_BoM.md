# BLE-Control — Medical-Grade Bill of Materials (BoM)

**Document ID:** BLEC-BOM-A2  
**Revision:** A2  
**Device:** BLE-Control Wearable BLE Controller  
**Prepared by:** Caoilte Donohoe  
**Standards:** IEC 60601-1, IEC 60601-1-2, ISO 13485, ISO 14971  
**Date: 17/11/2025**

---

# 1. Component Criticality Classification

All components are classified as follows:

**A — Safety-Critical:**  
Necessary for electrical safety, EMC protection, current limiting, surge protection, battery protection.

**B — EMC-Critical:**  
Affects EMI/EMC performance, RF tuning, emissions, susceptibility.

**C — Function-Critical:**  
Microcontroller, RF, sensors, passives that affect core operation.

**D — Non-Critical:**  
UI elements, passives, test points (documentation only), general mechanical/connectors.

This is required for ISO 14971 traceability and FDA/ISO 13485 Design History Files.

---

# 2. Full BoM Table (All Components Included)

| Cat. | Qty | Designator(s) | Comment / MPN | Description | Footprint | Manufacturer | Notes |
|------|-----|----------------|----------------|-------------|-----------|--------------|-------|
| **B** | 1 | ANT1 | 2450AT18A100E | BLE Antenna 2.4 GHz | ANTC3216X140N | Johanson | RF emissions & sensitivity |
| **C** | 6 | C1, C2, C24, C26, C103, C104 | 1uF | 1uF 0402 MLCC | CAP_0402 | Yageo/Murata | Decoupling |
| **C** | 10 | C3, C9, C10, C11, C12, C13, C16, C17, C19, C23 | 100nF | 100nF 0402 MLCC | CAP_0402 | Yageo/Murata | Decoupling |
| **C** | 3 | C8, C18, C20 | 4.7uF | 4.7uF 0402 | CAP_0402 | Murata | Bulk |
| **B** | 1 | C14 | GRM1555C1HR80BA01D | 0.8pF RF Match | CAP_0402 | Murata | RF tuning |
| **B** | 1 | C15 | GRM1555C1HR30WA01D | 0.3pF RF Match | CAP_0402 | Murata | RF tuning |
| **C** | 1 | C21 | 10pF | Crystal load cap | CAP_0402 | Murata | Clock stability |
| **C** | 1 | C22 | 10pF | Crystal load cap | CAP_0402 | Murata | Clock stability |
| **C** | 4 | C25, C27, C28, C29 | 100nF | BTN RC & decoupling | CAP_0402 | Yageo/Murata | Filtering |
| **C** | 2 | C101, C110 | 1nF | Filtering | CAP_0402 | Murata | Burst suppression |
| **C** | 1 | C102 | 22uF | Bulk | CAP_0402 | Murata | System stability |
| **C** | 2 | C105, C106 | 2.2uF | LDO decoupling | CAP_0402 | Murata | Filtering |
| **A** | 4 | D3, ESD_CC1, ESD_CC2, ESD_RF1 | PESD5V0S1UL,315 | ESD diode | PESD5V0S1BL315 | Nexperia | ESD safety |
| **A** | 1 | D101 | SMF5.0AT1G | VBUS TVS | SOD-123FL | OnSemi | Surge/Burst safety |
| **A** | 1 | D102 | USBLC6-2SC6Y | USB ESD array | SOT95P280X145-6 | STMicro | USB ESD protection |
| **A** | 1 | F101 | MF-PSMF050X-2 | PPTC 500mA | FP-MF-PSMF | Bourns | Overcurrent safety |
| **B** | 2 | FB2, FB101 | BLM15AG121SN1D | Ferrite Bead 120R | 0402 | Murata | Conducted RF immunity |
| **B** | 1 | FL2 | DLF162500LT-5028A1 | Differential filter | - | TDK | RF filtering |
| **B** | 1 | FL101 | ACM2012D-900-2P-T00 | USB CMC | 0805 | TDK | USB emissions |
| **A** | 1 | IC1 | BQ21061YFPR | Charger/Power-path | BGA20 | Texas Instruments | Battery safety |
| **A** | 1 | IC2 | TPS7A0233PDBVR | 3.3V LDO | SOT23-5 | Texas Instruments | Power rail |
| **C** | 1 | IC3 | STM32WB55CGU6 | BLE MCU | QFN48 | STMicro | Core logic |
| **C** | 1 | IC4 | TMP117NAIDRVR | Temp Sensor | SON6 | TI | Sensor |
| **C** | 1 | IC5 | BMI270 | IMU | QFN | Bosch | Sensor |
| **C** | 1 | IC6 | SHTC3 | Humidity Sensor | QFN | Sensirion | Sensor |
| **B** | 1 | IC7 | TPS22910AYZVR | Load Switch | BGA4 | TI | EMC recovery |
| **D** | 1 | J1 | BM03B-GHS-TBT | Battery conn. | - | JST | Mechanical |
| **A** | 1 | J2 | USB4105-GF-A | USB-C Port | - | GCT | Primary EMC entry point |
| **D** | 1 | J3 | TC2030-CTX-NL | Tag-Connect Header | - | Tag-Connect | Service port |
| **B** | 1 | L1 | 2.7nH | RF inductor (match) | 0402 | Murata | RF tuning |
| **C** | 1 | L2 | 10uH | Power inductor | 0805 | Murata | Regulator stability |
| **B** | 1 | L3 | 10nH | RF inductor (match) | 0402 | Murata | RF tuning |
| **D** | 1 | LED1 | 19-217_GHC-YR1S2_3T | Status LED | LEDC1608 | Everlight | Indicator |
| **A** | 1 | Q101 | SSM3J332R | Reverse protection FET | SOT-23 | Toshiba | Battery safety |
| **D** | 2 | R1, R104 | 5k1 | USB CC resistors | 0402 | Yageo | USB config |
| **C** | 4 | R2, R9, R17, R18 | 4k7 | I²C pull-up | 0402 | Yageo | Bus integrity |
| **B** | 8 | R3, R6, R22, R23, R25, R103, R109, R110 | 100k | Biasing pulls | 0402 | Yageo | Stable states |
| **C** | 1 | R4 | 47k | BQ_INT pull-up | 0402 | Yageo | IRQ behaviour |
| **B** | 4 | R10, R11, R12, R13 | 22R | Series resistors | 0402 | Yageo | Edge-rate control |
| **C** | 3 | R14, R16, R19 | 10k | Reset/Alert pull-ups | 0402 | Yageo | Boot stability |
| **D** | 2 | R15, R105 | 0R | Links | 0402 | Yageo | Routing flexibility |
| **C** | 1 | R20 | 1k | LED resistor | 0402 | Yageo | UI |
| **C** | 1 | R21 | 470k | BTN pull-up | 0402 | Yageo | Input bias |
| **C** | 1 | R24 | 100R | BTN series | 0402 | Yageo | EMC filtering |
| **B** | 2 | R101, R107 | 1M | Shield bleed resistors | 0402 | Yageo | ESD charge bleed |
| **C** | 1 | SW1 | B3U-1000P | Tactile switch | - | Omron | UI |
| **D** | 17 | TP1–TP17 | N/A | Electrical test markers (no physical part) | N/A | N/A | Documentation-only |
| **C** | 1 | Y1 | NX3225SA-32MHz | 32MHz Crystal | - | NDK | HSE |
| **C** | 1 | Y2 | ABS07-32.768KHZ-7-T | 32.768kHz Crystal | - | Abracon | RTC |

---

# 3. Safety-Critical Components (ISO 14971 Link)

| Component | Why Safety-Critical | Standard |
|-----------|----------------------|----------|
| F101 | Prevents overcurrent/overheating | IEC 60601-1 |
| D101 | Surge/ESD protection on primary port | IEC 60601-1-2 |
| USBLC6 | USB ESD protection | IEC 61000-4-2 |
| PESD diodes | Button/CC/Antenna ESD protection | IEC 61000-4-2 |
| Q101 | Battery reverse-protection | ISO 14971 |
| BQ21061 | Battery charge safety | IEC 60601-1 |
| TPS22910 | EMC recovery on sensors | IEC 60601-1-2 |
| RF π-match | Controls radiated emissions | IEC 60601-1-2 |

---

# 4. Notes on Test Points (Your Selected Option B)

The design uses **non-procured test points**.  
These are **logical/electrical net markers only**, with **no physical component** placed.

This classification is acceptable under:

- ISO 13485 (BoM completeness) **if marked N/A**  
- FDA QSR 820 (DMR/BOM) **as documentation-only items**  
- IEC 60601 audits (no operator-accessible conductive part introduced)

---

# End of BLE-Control_Medical_BoM.md
