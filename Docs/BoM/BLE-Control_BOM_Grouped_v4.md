# BLE-Control — BOM (Grouped)

**ToDo** Change the ref designators on the Schematic to reflect my current ones as shown below

- [MCU-RF](#mcu-rf)
- [Power_Charge_USB](#power_charge_usb)
- [Sensor](#sensor)
- [Sensor — Skin Temperature (Digital)](#sensor--skin-temperature-digital)
- [IO_Buttons_LED](#io_buttons_led)
- [Variant / DNP policy](#variant--dnp-policy-for-bom-export)

---

## MCU-RF

| Designators | Qty | Value/Function | Description | Manufacturer | MPN | Package | DNP | Placement_Criticality | Notes_Wearable |
|---|---:|---|---|---|---|---|:---:|---|---|
| U1 | 1 | STM32WB55CGUx | MCU, BLE5 dual-core | STMicroelectronics | STM32WB55CGU6 | UFQFPN-48 |  | Core | Keep RF feed short; LSE close |
| C_VDDA_0u1, C_VDDA_1u0 | 2 | 0.1 µF; 1 µF | VDDA decoupling → GND | Murata | GRM155R71C104KA88; GRM155R61A105KE15 | 0402 |  | Core | **VDDA tied to +3V3_SYS** (no bead) |
| L1 | 1 | 10 µH | On-chip SMPS inductor (4 MHz mode) | Murata | LQM21FN100M70L | 0805 |  | Core | Close to VLX/VDDSMPS |
| L1A | 1 | 10 nH | SMPS helper (series) | Murata | LQW15AN10NG00D | 0402 | **Yes** | Core | Fit only if RX de-sens seen |
| ANT1 | 1 | 2.4 GHz Chip Antenna | RF antenna | Johanson | 2450AT18A100 | SMD |  | RF critical | Keepout per DS; π-match nearby |
| J2 | 1 | u.FL test (inline) | Coax test connector | Hirose | U.FL-R-SMT-1(10) | UFL | **Yes** | RF region | Bring-up only; DNP for prod |
| D_RF | 1 | RF ESD (ultra-low-C) | TVS to GND at RF feed | Nexperia | PESD5V0S1UL,315 | SOD882 | **Yes** | RF critical | Stuff only if needed |
| C_RF*, L_RF* | 3 | π-match | C-L-C footprints | — | — | 0402 | **Yes** | RF critical | Populate after tune |
| Y1 | 1 | 32 MHz (HSE) | Crystal 3.2×2.5 mm | NDK | NX3225SA-32MHz-STD-CSR-3 | 3.2×2.5 |  | Clock island | Uses **internal** load caps |
| C_Y1* | 2 | — | HSE load capacitors | — | — | 0402 | **Yes** | Clock island | **DNP** (WB55 cap-bank) |
| Y2 | 1 | 32.768 kHz (LSE) | Crystal 3.2×1.5 mm | Abracon | ABS07-32.768KHZ-7-T | 3.2×1.5 |  | Clock island | Keep away from RF area |
| C_Y2* | 2 | 12 pF | LSE load capacitors | Murata | GRM1555C1H120JA01 | 0402 |  | Clock island | Symmetric, short |
| Cdecoupling | 20 | 0.1 µF | Local decoupling | Murata | GRM155R71C104KA88 | 0402 |  | General | At each VDD; short GND via |
| Cbulk | 10 | 1 µF | Bulk bypass | Murata | GRM155R61A105KE15 | 0402 |  | General | Cluster near ICs |
| J4 | 1 | Tag-Connect TC2030 | 6-pin SWD footprint | Tag-Connect | TC2030-NL | TC2030 |  | General | No paste; 3×NPTH tooling |
| R_USB_DP, R_USB_DM | 2 | 22 Ω | USB series (near MCU) | Yageo | RC0402FR-0722RL | 0402 | **Yes** | General | Keep DNP for Rev-A |

---

## Power_Charge_USB

| Designators | Qty | Value/Function | Description | Manufacturer | MPN | Package | DNP | Placement_Criticality | Notes_Wearable |
|---|---:|---|---|---|---|---|:---:|---|---|
| U2 | 1 | BQ21062 | 1-cell Li-ion charger w/ LS/LDO | Texas Instruments | BQ21062YFPR | X2SON-6 |  | Edge (USB) | VINLS=PMID; LSLDO → **+3V3_SYS** |
| Q_REV | 1 | P-MOSFET | Reverse-battery protector | Toshiba | SSM3J332R,LF *(alt: DMG2305UX-13)* | SOT-23 |  | Battery edge | D=+BATT_RAW → S=VBAT_PROT |
| R_G | 1 | 100 kΩ | Gate pull-down | Yageo | RC0402FR-07100KL | 0402 |  | Battery edge | Gate→GND |
| R_GS | 1 | 1 MΩ | Gate-source bleed | Yageo | RC0402FR-071ML | 0402 | **Yes** | Battery edge | Optional |
| J1 | 1 | USB-C Receptacle | USB4105 mid-mount | GCT | USB4105-GF-A | — |  | Edge (USB) | Sink-only |
| D_USB | 1 | USB ESD array | D+/D− protector | ST | USBLC6-2SC6 | SOT23-6 |  | Edge (USB) | Place closest to pins |
| FL_USB | 1 | 2-line CMC | Common-mode choke | TDK | ACM2012D-900-2P-T00 | 0805 | **Yes** | Edge (USB) | After ESD; DNP Rev-A |
| R_CC1, R_CC2 | 2 | 5.1 kΩ | CC Rd pull-downs | Yageo | RC0402FR-075K1L | 0402 |  | Edge (USB) | Sink/UFP advert |
| D_CC1, D_CC2 | 2 | CC TVS | CC ESD to GND | Nexperia | PESD5V0S1UL,315 | SOD882 |  | Edge (USB) | Within a few mm |
| D1 | 1 | SMF5.0A | VBUS TVS | Littelfuse | SMF5.0A | SOD-123FL |  | Edge (USB) | Short GND return |
| F1 | 1 | 0.5 A hold | Polyfuse | Bourns | MF-MSMF050/16 | 1206 |  | Edge (USB) | Inrush check |
| R_SHIELD, C_SHIELD | 2 | 1 MΩ; 1 nF C0G | Shield bleed R//C | Yageo; Murata | RC0402FR-071ML; GCM1555C1H102JA16 | 0402 |  | Edge (USB) | Shell→GND near conn |
| C_IN | 1 | 2.2 µF / ≥6.3 V | IN pin bypass | Murata | GRM188R60J225KE21 | 0603 |  | Power | Near IN pin |
| C_PMID | 1 | **22 µF / ≥6.3 V** | PMID bulk | Murata | **GRM21BR60J226ME39** | 0805 |  | Power | Near PMID |
| C_BAT | 1 | **22 µF / ≥6.3 V** | BAT bulk | Murata | **GRM21BR60J226ME39** | 0805 |  | Power | Near BAT pins |
| C_VDD | 1 | **2.2 µF / ≥6.3 V** | VDD cap (BQ) | Murata | **GRM188R60J225KE21** | 0603 |  | Power | VDD→GND at pin |
| J3 | 1 | JST-GH-2 | Li-Po connector | JST | BM02B-GHS-TBT | JST-GH-2 |  | Battery edge | Strain-relief, polarity silk |
| NTC1 | 1 | 10 k NTC | Charger TS thermistor | Murata | NCP15XH103F03RC | 0402 |  | Power | Bias per DS |
| R_CC_Spare* | 2 | — | Spare CC footprints | — | — | 0402 | **Yes** | Edge (USB) | Optional spares |

---

## Sensor

| Designators | Qty | Value/Function | Description | Manufacturer | MPN | Package | DNP | Placement_Criticality | Notes_Wearable |
|---|---:|---|---|---|---|---|:---:|---|---|
| U6 | 1 | BMI270 | 6-axis IMU | Bosch Sensortec | BMI270 | LGA-16 |  | Center | INT1/2 → EXTI |
| U7 | 1 | BME280 *(alt: SHTC3+LPS22HH)* | Env sensor | Bosch / Sensirion / ST | BME280 / SHTC3 / LPS22HHTR | LGA/DFN/HLGA |  | Edge (vent) | Choose one path |
| R_SCL_PU_SENS, R_SDA_PU_SENS | 2 | **2.2 kΩ** | I²C pull-ups (SENS) | Yageo | RC0402FR-072K2L | 0402 |  | Sensors | To **VDD_SENS** (switched) |
| R_SCL_SER, R_SDA_SER | 2 | 33 Ω | I²C series (edge-tame) | Yageo | RC0402FR-0733RL | 0402 | **Yes** | Sensors | DNP unless needed |

---

## Sensor — Skin Temperature (Digital)

| Designators | Qty | Value/Function | Description | Manufacturer | MPN | Package | DNP | Placement_Criticality | Notes |
|---|---:|---|---|---|---|---|:---:|---|---|
| U9 | 1 | **TMP117** | ±0.1 °C digital skin-temp | Texas Instruments | TMP117x | DFN/WSON‑6 |  | Skin contact | Default; rigid board |
| C_U9 | 1 | 0.1 µF | VDD decoupling | Murata | GRM155R71C104KA88 | 0402 |  | Core | Place at pin |
| D_SKIN | 1 | TVS, 5 V | ESD at skin pad | Nexperia | PESD5V0S1UL,315 | SOD882 |  | Edge | At pad entry |
| R_SCL_SER, R_SDA_SER | 2 | 33 Ω | I²C series (tail/edge‑rate) | Yageo | RC0402FR-0733RL | 0402 | **Yes** | General | DNP unless needed |
| U9_ALT* | 1 | **MAX30208** | ±0.1 °C temp (flex) | Analog Devices | MAX30208 | WLP/TDFN | **Yes** | Flex tail | Variant for rigid‑flex |
| J_FLEX* | 1 | 6‑pin 0.5 mm | FFC/FPC connector | Generic | FPC_6P_0.5mm | — | **Yes** | Flex tail | DNP; demo option |

---

## IO_Buttons_LED

| Designators | Qty | Value/Function | Description | Manufacturer | MPN | Package | DNP | Placement_Criticality | Notes_Wearable |
|---|---:|---|---|---|---|---|:---:|---|---|
| LED1 | 1 | Green LED | Indicator | Everlight | 19-217/GHC-YR1S2/3T | 0402 |  | General | Low current |
| R_LED | 1 | 1 kΩ | LED series | Yageo | RC0402FR-071KL | 0402 |  | General | 1–2 mA drive |
| SW1 | 1 | Tactile switch | Low-profile button | C&K | KMR221GLFS | SMT |  | Edge (user) | Keep away from RF |
| D_BTN | 1 | ESD (button) | TVS to GND at pad | Nexperia | PESD5V0S1UL,315 | SOD882 |  | User I/O | Optional but recommended |

---

## Variant / DNP policy (for BOM export)
- Create **Variant `Proto_A`** and set **Not Fitted**: `L1A (10 nH)`, `D_RF`, `C_RF*/L_RF*`, `J2`, `FL_USB`, `R_USB_DP/DM`, `R_SCL_SER/R_SDA_SER`, `R_GS`, `R_CC_Spare*`, `C_Y1*`, `U9_ALT*`, `J_FLEX*`.
- In your OutJob BOM, select **Variant = Proto_A** and **Exclude Not Fitted**.

**Additional Variants**
- **Flex_Demo:** Fit `U9_ALT* (MAX30208)` + `J_FLEX*`; DNP `U9 (TMP117)` on rigid.

**Notes**
- With **VDDA tied to +3V3_SYS**, keep **C_VDDA_0u1/1u0** at the MCU pins (they still help).
- HSE relies on the **internal load-cap bank**; keep **C_Y1* DNP** but leave pads for contingency.
- If you later enable USB-FS, stuff `FL_USB` and `R_USB_DP/DM` (22 Ω near MCU).
