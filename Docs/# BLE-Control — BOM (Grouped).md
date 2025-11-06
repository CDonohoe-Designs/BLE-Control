# BLE-Control — BOM (Grouped)

- [MCU-RF](#mcu-rf)
- [Power_Charger_USB](#power_charger_usb)
- [Sensor](#sensor)
- [IO_Buttons_LED](#io_buttons_led)

---

## MCU-RF

| Designators         | Qty | Value/Function       | Description                                  | Manufacturer         | MPN                         | Package        | DNP | Placement_Criticality | Notes_Wearable |
|---|---:|---|---|---|---|---|:---:|---|---|
| U1                  | 1   | STM32WB55CGUx        | MCU, BLE5 dual-core, UFQFPN-48               | STMicroelectronics    | STM32WB55CGU6               | UFQFPN-48      | No  | Core                  | Keep RF feed short; decouple at pins; LSE near MCU |
| ANT1                | 1   | 2.4 GHz Chip Antenna | Johanson 2.4 GHz antenna                      | Johanson Technology   | 2450AT18A100 (TBD)          | SMD            | No  | RF critical           | Antenna keepout & GND clearance; tune π-match |
| J2                  | 1   | u.FL test (DNP)      | U.FL coax connector                           | Hirose                | U.FL-R-SMT-1(10)            | UFL            | **Yes** | RF region          | Inline for conducted tests; omit in production |
| C_RF*, L_RF*        | 3   | π-match placeholders | C-L-C 0402 (DNP)                              | —                     | —                            | 0402           | **Yes** | RF critical        | Leave DNP until tuning; footprints mandatory |
| **L1**              | 1   | **10 µH**            | **Main inductor for on-chip SMPS**            | **Murata**            | **LQM21FN100M70L**          | **0805**       | No  | **SMPS loop**         | Place within 2–3 mm of VLXSMPS; tight loop. *(Alt: Coilcraft XFL2010-103MEC)* |
| **L1A**             | 1   | **10 nH (series)**   | **HF helper (optional) for RX spur reduction**| **Murata**            | **LQW15AN10NG00D**          | **0402**       | **Yes** | **SMPS loop**      | Inline with L1 on VLXSMPS side; un-DNP if needed. *(Alt: TDK MLG1005S10NHT000)* |
| Y1                  | 1   | 32 MHz (HSE)         | Crystal 3.2×2.5 mm                            | NDK (placeholder)     | NX3225SA-32MHz-STD-CSR-3    | 3.2×2.5        | No  | Clock island          | Match CL with load caps; short guarded traces |
| C_Y1*               | 2   | 12 pF                | HSE load capacitors                           | Murata                | GRM1555C1H120JA01           | 0402           | No  | Clock island          | Tune per crystal CL; start 12 pF |
| Y2                  | 1   | 32.768 kHz (LSE)     | Crystal 3.2×1.5 mm                            | Abracon               | ABS07-32.768KHZ-7-T         | 3.2×1.5        | No  | Clock island          | Keep away from RF; guard to GND |
| C_Y2*               | 2   | 12 pF                | LSE load capacitors                           | Murata                | GRM1555C1H120JA01           | 0402           | No  | Clock island          | As per CL; symmetric routing |
| Cdecoupling         | 20  | 0.1 µF               | Decoupling capacitors                         | Murata                | GRM155R71C104KA88           | 0402           | No  | General               | At each VDD; via to GND very close |
| Cbulk               | 10  | 1 µF                 | Bulk bypass capacitors                        | Murata                | GRM155R61A105KE15           | 0402           | No  | General               | Group near IC clusters |
| J4                  | 1   | Tag-Connect TC2030   | 6-pin pogo SWD footprint                      | Tag-Connect           | TC2030-NL                    | TC2030         | No  | General               | No-legs footprint; no paste; NPTH tooling holes |
| JP_RF, JP_SENS      | 2   | 0 Ω (DNP)            | DNP jumpers for debug                         | Yageo                 | RC0402JR-070RL              | 0402           | **Yes** | General            | Bring-up flexibility; remove in production |

**Placement notes (L1/L1A):**  
- Route **+3V3_SYS → L1 (10 µH) → L1A (10 nH, DNP by default) → VLXSMPS (MCU)**.  
- Place **Cbulk 4.7 µF** at **VFBSMPS→GND** and **4.7 µF + 0.1 µF** at **VDDSMPS→GND**, all **right at pins**.  
- If starting in **BYPASS/LDO**, set **L1/L1A = DNP** and add 0 Ω links to short `VDDSMPS/VLXSMPS/VFBSMPS → VDD`.  
- If you test **8 MHz SMPS mode**, swap **L1 to 2.2 µH** (e.g., Würth 74479774222) and keep the 10 nH option inline.

**Section total:** *(original total) + 2 components (L1, L1A)*

---

## Power_Charger_USB

| Designators        | Qty | Value/Function         | Description                              | Manufacturer        | MPN                 | Package             | DNP | Placement_Criticality | Notes_Wearable |
|---|---:|---|---|---|---|---|:---:|---|---|
| U2                 | 1   | BQ24074                | Li-ion charger, 1S, power-path           | Texas Instruments   | BQ24074RGTR         | VQFN-16 (RGT)      | No  | Edge (USB)           | Place close to USB/VBAT; tight input/output loops; thermals |
| U3                 | 1   | TPS7A02-3.3            | LDO 3.3 V, low IQ                        | Texas Instruments   | TPS7A0233DBVR       | SOT-23-5           | No  | General              | Shortest decoupling; low-IQ suits wearable standby |
| U4                 | 1   | TPS22910A              | Load switch for sensors rail             | Texas Instruments   | TPS22910A-TBD       | X2SON/TSSOP (TBD)  | No  | General              | Gate sensors (VDD_SENS) to cut idle current; pick exact suffix |
| J1                 | 1   | USB Type-C Receptacle  | USB2.0, 16-pin, mid-mount                | GCT                 | USB4105-GF-A        | USB-C              | No  | Edge (USB)           | Sink-only design; robust shell grounding |
| ESD1               | 1   | USB ESD array          | Low-cap ESD for D+/D−                    | STMicroelectronics  | USBLC6-2SC6         | SOT23-6            | No  | Edge (USB)           | Low Cj to preserve signal quality |
| D1                 | 1   | VBUS TVS               | TVS diode 5 V line                       | Littelfuse          | SMF5.0A             | SMF (SOD-123FL)    | No  | Edge (USB)           | Near connector; short return to ground |
| F1                 | 1   | Polyfuse 0.5 A hold    | Resettable fuse for VBUS                 | Bourns              | MF-MSMF050/16       | 1206               | No  | Edge (USB)           | Low R preferred; verify inrush |
| R_CC1, R_CC2       | 2   | 5.1 kΩ                 | USB-C Rd resistors                       | Yageo               | RC0402FR-075K1L     | 0402               | No  | Edge (USB)           | To GND from CC1/CC2 |
| C10u               | 4   | 10 µF                  | Bulk caps for rails                      | Murata              | GRM188R60J106ME47   | 0603               | No  | Power                | VBUS/BAT/LDO bulk near sources |
| J3                 | 1   | JST-GH-2               | 2-pin battery connector, 1.25 mm         | JST                 | BM02B-GHS-TBT       | JST-GH-2           | No  | Battery edge         | Strain relief; polarity silk; away from antenna |
| NTC1               | 1   | 10 k NTC               | Thermistor for charger TS                | Murata              | NCP15XH103F03RC     | 0402               | No  | Power                | Match bias per BQ24074 TS recommendations |

**Section total:** 15 designators

---

## Sensor

| Designators | Qty | Value/Function | Description                    | Manufacturer         | MPN             | Package   | DNP | Placement_Criticality | Notes_Wearable |
|---|---:|---|---|---|---|---|:---:|---|---|
| U5        | 1   | MAX17048      | ModelGauge m5, I²C (fuel gauge)| Analog Devices (Maxim)| MAX17048G+T     | TDFN-6 2×2 | No  | Battery side          | VDD=VBAT; keep sense & bypass short |
| U6        | 1   | BMI270        | 6-axis IMU, I²C/SPI            | Bosch Sensortec      | BMI270          | LGA-16    | No  | Center                | INT1/INT2 to EXTI; underfill keepout optional |
| U7        | 1   | LPS22HH       | Barometric pressure sensor     | STMicroelectronics   | LPS22HHTR       | HLGA-10L  | No  | Edge (vent)           | Vent hole/keepout; avoid airflow from hand heat |
| U8        | 1   | SHTC3         | Temp/RH sensor                 | Sensirion            | SHTC3           | DFN-4     | No  | Edge (vent)           | On VDD_SENS; near board edge/vent holes |
| U9        | 1   | OPT3001       | Ambient light sensor           | Texas Instruments    | OPT3001DNPT     | DFN-6     | No  | Edge (window)         | Small window; shield from LED light leak |

**Section total:** 5 designators

---

## IO_Buttons_LED

| Designators | Qty | Value/Function | Description           | Manufacturer | MPN                     | Package | DNP | Placement_Criticality | Notes_Wearable |
|---|---:|---|---|---|---|---|:---:|---|---|
| LED1      | 1   | Green LED      | SMD indicator LED     | Everlight    | 19-217/GHC-YR1S2/3T     | 0402    | No  | General               | Low-current indicator |
| R_LED     | 1   | 1 kΩ           | LED series resistor   | Yageo        | RC0402FR-071KL          | 0402    | No  | General               | LED ~1–2 mA for low EMI/power |
| SW1       | 1   | Tactile switch | Low-profile tactile   | C&K          | KMR221GLFS              | SMT     | No  | Edge (user)           | Keep away from antenna region (metal) |

**Section total:** 3 designators
