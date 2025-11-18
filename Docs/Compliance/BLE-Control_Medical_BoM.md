# BLE-Control — Medical-Grade Bill of Materials (BoM)

**Document ID:** BLEC-BOM-A3  
**Revision:** A3  
**Device:** BLE-Control Wearable BLE Controller  
**Prepared by:** C. Donohoe  
**Standards:** IEC 60601-1, IEC 60601-1-2, ISO 13485, ISO 14971  

---

## 1. Criticality Classes

- **A — Safety-Critical** (electrical safety, battery, current limiting, surge/ESD)  
- **B — EMC-Critical** (RF match, CMC, ferrite, shield bleed)  
- **C — Function-Critical** (MCU, BLE, sensors, core passives)  
- **D — Non-Critical** (UI, indicators, documentation-only items, mechanical)

---

## 2. Full BoM (with MPNs, including passives)

> **Note:** For generic passives, MPNs are defined as **internal codes**  
> (e.g. `BLEC-R-0402-4K70-1%`), which can be mapped to a preferred vendor series  
> (Yageo RC0402FR-07…, Murata GRM155…, etc.) in your AVL.

| Cat. | Qty | Designator(s) | Function | Value / Part | Package | Manufacturer | MPN | Notes |
|------|-----|----------------|----------|--------------|---------|--------------|-----|-------|
| B | 1 | ANT1 | BLE antenna | 2450AT18A100E | 3.2×1.6 | Johanson | 2450AT18A100E | RF front-end |
| C | 6 | C1, C2, C24, C26, C103, C104 | Bulk/decoupling | 1 µF, 10 V, X5R | 0402 | Internal | **BLEC-C-0402-1u0-10V-X5R** | Pref: Murata GRM155R61A105K |
| C | 10 | C3, C9, C10, C11, C12, C13, C16, C17, C19, C23 | Local decoupling | 100 nF, 16 V, X7R | 0402 | Internal | **BLEC-C-0402-100n-16V-X7R** | Pref: Murata GRM155R71C104K |
| C | 3 | C8, C18, C20 | Bulk | 4.7 µF, 10 V, X5R | 0402 | Internal | **BLEC-C-0402-4u7-10V-X5R** | LDO/charger bulk |
| B | 1 | C14 | RF π-match | 0.8 pF | 0402 | Murata | GRM1555C1HR80BA01D | RF match C1 |
| B | 1 | C15 | RF π-match | 0.3 pF | 0402 | Murata | GRM1555C1HR30WA01D | RF match C2 |
| C | 1 | C21 | HSE load C | 10 pF | 0402 | Internal | **BLEC-C-0402-10p-25V-C0G** | Pref: GRM1555C1H100JA01 |
| C | 1 | C22 | LSE load C | 10 pF | 0402 | Internal | **BLEC-C-0402-10p-25V-C0G** | LSE crystal load |
| C | 4 | C25, C27, C28, C29 | RC/decoupling | 100 nF | 0402 | Internal | **BLEC-C-0402-100n-16V-X7R** | BTN RC, local decoupling |
| C | 2 | C101, C110 | Filter/snubber | 1 nF | 0402 | Internal | **BLEC-C-0402-1n0-50V-X7R** | Burst/EMC use |
| C | 1 | C102 | Bulk | 22 µF | 0402 | Internal | **BLEC-C-0402-22u-6V3-X5R** | Main 3V3 bulk |
| C | 2 | C105, C106 | LDO decoupling | 2.2 µF | 0402 | Internal | **BLEC-C-0402-2u2-10V-X5R** | TPS7A02/BQ support |
| A | 4 | D3, ESD_CC1, ESD_CC2, ESD_RF1 | ESD protection | PESD5V0S1UL,315 | SOD-323 | Nexperia | PESD5V0S1UL,315 | CC, BTN, RF ESD |
| A | 1 | D101 | VBUS TVS | SMF5.0AT1G | SOD-123FL | onsemi | SMF5.0AT1G | Surge/ESD on VBUS |
| A | 1 | D102 | USB ESD array | USBLC6-2SC6Y | SOT-23-6 | STMicro | USBLC6-2SC6Y | USB D+/D- ESD |
| A | 1 | F101 | PPTC fuse | MF-PSMF050X-2 | 0805 | Bourns | MF-PSMF050X-2 | 500 mA resettable |
| B | 2 | FB2, FB101 | Ferrite beads | 120 Ω @100 MHz | 0402 | Murata | BLM15AG121SN1D | Conducted RF filter |
| B | 1 | FL2 | RF filter | DLF162500LT-5028A1 | 1608 | TDK | DLF162500LT-5028A1 | Differential RF filter |
| B | 1 | FL101 | USB CMC | ACM2012D-900-2P-T00 | 0805 | TDK | ACM2012D-900-2P-T00 | USB CM choke |
| A | 1 | IC1 | Charger/PMIC | BQ21061YFPR | BGA20 | TI | BQ21061YFPR | Li-ion charger/safety |
| A | 1 | IC2 | 3.3V LDO | TPS7A0233PDBVR | SOT23-5 | TI | TPS7A0233PDBVR | 3V3 system rail |
| C | 1 | IC3 | MCU + BLE | STM32WB55CGU6 | QFN48 | STMicro | STM32WB55CGU6 | Core logic/radio |
| C | 1 | IC4 | Temp sensor | TMP117NAIDRVR | SON-6 | TI | TMP117NAIDRVR | Precision temperature |
| C | 1 | IC5 | IMU | BMI270 | QFN | Bosch | BMI270 | 6-axis IMU |
| C | 1 | IC6 | Humidity sensor | SHTC3 | QFN | Sensirion | SHTC3 | RH & temp |
| B | 1 | IC7 | Load switch | TPS22910AYZVR | BGA4 | TI | TPS22910AYZVR | Gated 3V3_SENS |
| D | 1 | J1 | Battery conn. | BM03B-GHS-TBT (LF)(SN)(N) | 3-pin | JST | BM03B-GHS-TBT | Li-Po connector |
| A | 1 | J2 | USB-C connector | USB4105-GF-A | - | GCT | USB4105-GF-A | Primary IEC 60601 port |
| D | 1 | J3 | SWD connector | TC2030-CTX-NL | - | Tag-Connect | TC2030-CTX-NL | Service-only debug |
| B | 1 | L1 | RF inductor | 2.7 nH | 0402 | Murata | (per LQW15 series) | RF π-match L |
| C | 1 | L2 | Power inductor | 10 µH | 0805 | Murata | (LQM21FN series) | LDO/charger inductor |
| B | 1 | L3 | RF inductor | 10 nH | 0402 | Murata | LQG15HS2N7S02 or equiv. | RF network |
| D | 1 | LED1 | Status LED | 19-217_GHC-YR1S2_3T | 0603 | Everlight | 19-217_GHC-YR1S2_3T | Indicator |
| A | 1 | Q101 | Reverse FET | SSM3J332R,LF | SOT-23 | Toshiba | SSM3J332R,LF | Battery reverse protection |
| D | 2 | R1, R104 | USB CC | 5.1 kΩ, 1% | 0402 | Internal | **BLEC-R-0402-5K10-1%** | Pref: Yageo RC0402FR-075K1L |
| C | 4 | R2, R9, R17, R18 | I2C pull-up | 4.7 kΩ, 1% | 0402 | Internal | **BLEC-R-0402-4K70-1%** | I2C SYS/SENS pulls |
| B | 8 | R3, R6, R22, R23, R25, R103, R109, R110 | Bias pulls | 100 kΩ, 1% | 0402 | Internal | **BLEC-R-0402-100K-1%** | Biasing GPIO/CE/etc. |
| C | 1 | R4 | BQ_INT pull-up | 47 kΩ, 1% | 0402 | Internal | **BLEC-R-0402-47K0-1%** | INT line pull |
| B | 4 | R10, R11, R12, R13 | Series resistors | 22 Ω, 1% | 0402 | Internal | **BLEC-R-0402-22R0-1%** | USB/signal damping |
| C | 3 | R14, R16, R19 | Reset/alert pulls | 10 kΩ, 1% | 0402 | Internal | **BLEC-R-0402-10K0-1%** | NRST/TMP/BQ pulls |
| D | 2 | R15, R105 | Zero-ohm links | 0 Ω | 0402 | Internal | **BLEC-R-0402-0R00** | Config links |
| C | 1 | R20 | LED resistor | 1 kΩ, 1% | 0402 | Internal | **BLEC-R-0402-1K00-1%** | LED current set |
| C | 1 | R21 | Button pull-up | 470 kΩ, 1% | 0402 | Internal | **BLEC-R-0402-470K-1%** | BTN bias |
| C | 1 | R24 | BTN series | 100 Ω, 1% | 0402 | Internal | **BLEC-R-0402-100R-1%** | EMC on button line |
| B | 2 | R101, R107 | Shield bleed | 1 MΩ, 1% | 0402 | Internal | **BLEC-R-0402-1M00-1%** | Shield R in R//C network |
| C | 1 | SW1 | Tactile switch | B3U-1000P | SMD | Omron | B3U-1000P | User pushbutton |
| D | 1 | TP1 | Electrical TP: USB_VBUS | N/A (net marker only) | N/A | N/A | N/A | Documentation-only |
| D | 2 | TP2, TP17 | Electrical TPs | N/A (TestPoint nets) | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP3 | Electrical TP: VIN_BQ | N/A | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP4 | Electrical TP: VBATT_RAW | N/A | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP5 | Electrical TP: VBAT_PROT | N/A | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP6 | Electrical TP: GND | N/A | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP7 | Electrical TP: +3V3_SYS | N/A | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP8 | Electrical TP: BQ_INT | N/A | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP9 | Electrical TP: LSLDO | N/A | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP10 | Electrical TP: CE_MCU | N/A | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP11 | Electrical TP: BAT_NTC_10K | N/A | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP12 | Electrical TP: 3V3_SENS | N/A | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP13 | Electrical TP: USB_FS_R_P | N/A | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP14 | Electrical TP: SENS_EN | N/A | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP15 | Electrical TP: USB_FS_R_N | N/A | N/A | N/A | N/A | Documentation-only |
| D | 1 | TP16 | Electrical TP: VDD | N/A | N/A | N/A | N/A | Documentation-only |
| C | 1 | Y1 | HSE crystal | 32 MHz | NX3225SA | NDK | NX3225SA-32MHZ-EXS00A-CS02368 | Main clock |
| C | 1 | Y2 | LSE crystal | 32.768 kHz | ABS07 | Abracon | ABS07-32.768KHZ-7-T | RTC clock |

---

_End of BLE-Control_Medical_BoM.md_
