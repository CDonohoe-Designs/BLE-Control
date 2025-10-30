# BLE-Control — Bill of Materials (BOM)

Small wearable, EMC-first, BLE on STM32WB55. Passives default to **0402** (use **0603** for bulk caps / ESD arrays if needed), **4-layer 0.8 mm**, **TC2030-NL** SWD, chip antenna with **DNP π-match**.  
**VBUS protection:** **PPTC Bourns MF-PSMF050X-2 (0805), I_hold = 0.5 A** for **ILIM = 500 mA**, with **0 Ω DNP bypass** footprint.

_Last updated: 2025-10-30_

## Legend
- **DNP** — Do Not Populate (fit footprint for tuning/bring-up only)  
- **DNL** — Do Not Load (mechanical/footprint only; never fitted)

---

## Table of Contents
- [TopLevel.SchDoc](#toplevelschdoc)
- [Power_Batt_Charge_LDO.SchDoc — BQ21062](#power_batt_charge_ldoschdoc--bq21062)
- [MCU_RF.SchDoc — STM32WB55 + RF/Clocks](#mcu_rfschdoc--stm32wb55--rfclocks)
- [USB_Debug.SchDoc — USB-C (sink-only), ESD, PPTC](#usb_debugschdoc--usb-c-sink-only-esd-pptc)
- [IO_Buttons_LEDs.SchDoc — User IO](#io_buttons_ledsschdoc--user-io)
- [Sensors.SchDoc — BMI270, MAX17048, SHTC3](#sensorsschdoc--bmi270-max17048-shtc3)
- [Testpoints_Assembly.SchDoc — Test & Bring-Up](#testpoints_assemblyschdoc--test--bring-up)
- [Optional / Shared Items](#optional--shared-items)
- [Quick Checks](#quick-checks)

---

## TopLevel.SchDoc
*(Hierarchy & nets only — no fitted components on this sheet)*

- **No BOM items**

---

## Power_Batt_Charge_LDO.SchDoc — BQ21062

| Item | RefDes           | Qty | Value / Rating                         | Package        | Manufacturer | MPN                 | Notes |
|----:|-------------------|----:|----------------------------------------|----------------|--------------|---------------------|------|
| 1   | U1                | 1   | Li-ion Charger + LDO/LS, I²C           | WCSP (YFP-15)  | TI           | **BQ21062YFPR**     | EP to GND, via-stitched |
| 2   | F1                | 1   | **PPTC 0.5 A I_hold**                  | 0805           | Bourns       | **MF-PSMF050X-2**   | VBUS protection |
| 3   | R_BYP             | 1   | **0 Ω (DNP)**                          | 0402           | Generic      | —                   | **Bypass across PPTC** (bring-up) |
| 4   | D1                | 1   | **TVS 5.0 V uni (SMF)**                | SOD-123FL      | Many         | **SMF5.0A**         | Near USB-C VBUS |
| 5   | C_VIN1            | 1   | 10 µF, 10 V, X5R/X7R                   | 0603           | Murata/etc   | e.g. GRM188R61A106KA| Close to VIN |
| 6   | C_VIN2            | 1   | 0.1 µF, 16 V, X7R                      | 0402           | Generic      | —                   | At VIN pin |
| 7   | C_BAT1            | 1   | 10 µF, 6.3 V, X5R/X7R                  | 0603           | Murata/etc   | e.g. GRM188R60J106M | Close to BAT |
| 8   | C_BAT2            | 1   | 0.1 µF, 16 V, X7R                      | 0402           | Generic      | —                   | At BAT node |
| 9   | C_LDO             | 1   | 2.2 µF (1–4.7 µF ok), 6.3 V, X5R/X7R   | 0402           | Generic      | —                   | LDO/LS_OUT cap (per DS) |
| 10  | R_SCL, R_SDA      | 2   | **4.7 kΩ, 1%**                         | 0402           | Generic      | —                   | I²C pull-ups to 3V3 (place near MCU) |
| 11  | R_PG, R_INT       | 2   | 100 kΩ, 1%                             | 0402           | Generic      | —                   | Pull-ups for /PG and /INT (opt.) |
| 12  | C_MR              | 1   | 100 nF                                 | 0402           | Generic      | —                   | MR/QON debounce (opt.) |
| 13  | TH_TS             | 1   | **NTC 10 kΩ @25 °C, β≈3435**           | 0402           | Generic      | —                   | Battery TS (or disable in FW) |
| 14  | J_BATT (pick 1)   | 1   | **2-pin Li-Po connector**              | JST-SH-2/GH-2  | JST          | **BM02B-SRSS-TB** / **BM02B-GHS-TBT** | Choose one; mate accordingly |
| 15  | —                 | —   | Test pads: TP_USB_5V, TP_VBAT, TP_VSYS, TP_3V3, TP_GND | — | — | — | Fabrication test pads (no BOM) |

> **Mode A:** LDO → **3V3** ≤100 mA total.  
> **Mode B:** Internal **Load-Switch** → **VDD_SENS** (main 3V3 from LDO or ext. reg).

---

## MCU_RF.SchDoc — STM32WB55 + RF/Clocks

| Item | RefDes                        | Qty | Value / Rating                            | Package       | Manufacturer | MPN                             | Notes |
|----:|--------------------------------|----:|--------------------------------------------|---------------|--------------|----------------------------------|------|
| 1   | U2                             | 1   | BLE MCU                                    | UFQFPN-48     | ST           | **STM32WB55CGU6**                | EP to GND |
| 2   | C_VDDx (per VDD)               | 6–10| 0.1 µF, 16 V, X7R                          | 0402          | Generic      | —                                | One per VDD pin |
| 3   | C_VDD_BULK                     | 1–2 | 2.2 µF, 6.3 V, X5R/X7R                     | 0402          | Generic      | —                                | Near MCU power entry |
| 4   | R_NRST                         | 1   | 10 kΩ, 1%                                  | 0402          | Generic      | —                                | Pull-up to 3V3 |
| 5   | C_NRST                         | 1   | 100 nF                                     | 0402          | Generic      | —                                | To GND |
| 6   | X1 (HSE)                       | 1   | **32 MHz crystal**                         | 3.2×2.5 mm    | NDK          | **NX3225SA-32MHz-STD-CSR-3**     | Check CL |
| 7   | C_X1A, C_X1B                   | 2   | **12 pF** (tune to CL)                     | 0402          | Murata       | **GRM1555C1H120JA01**            | HSE load caps |
| 8   | R_X1_SER                       | 1   | **0 Ω (DNP)**                              | 0402          | Generic      | —                                | HSE series placeholder |
| 9   | X2 (LSE)                       | 1   | **32.768 kHz crystal**                     | 3.2×1.5 mm    | Abracon      | **ABS07-32.768KHZ-7-T**          | — |
| 10  | C_X2A, C_X2B                   | 2   | **12 pF**                                  | 0402          | Murata       | **GRM1555C1H120JA01**            | LSE load caps |
| 11  | R_SWDIO, R_SWCLK (optional)    | 2   | 22–47 Ω                                    | 0402          | Generic      | —                                | Series dampers |
| 12  | C1, L1, C2 (RF π-match)        | 3   | **DNP**                                    | 0402          | Generic      | —                                | Between RF_OUT ↔ ANT_IN |
| 13  | J3 (u.FL test)                 | 1   | **u.FL jack (DNP)**                         | u.FL          | Hirose       | **U.FL-R-SMT-1(10)**             | Inline or pad |
| 14  | ANT1                            | 1   | **2.4 GHz chip antenna**                   | Per DS        | TBD          | TBD                               | Keepout & via fence |

---

## USB_Debug.SchDoc — USB-C (sink-only), ESD, PPTC

| Item | RefDes               | Qty | Value / Rating                       | Package     | Manufacturer | MPN                | Notes |
|----:|-----------------------|----:|---------------------------------------|-------------|--------------|--------------------|------|
| 1   | J1                    | 1   | USB-C Receptacle (16-pin)            | Receptacle  | GCT          | **USB4105-GF-A**   | Mid/Top mount per DS |
| 2   | R_CC1, R_CC2          | 2   | **5.1 kΩ, 1%** (USB-C Rd)            | 0402        | Yageo        | **RC0402FR-075K1L**| Sink-only |
| 3   | U_ESD_DPDM            | 1   | **USB ESD array, low-C** (D+/D−)     | SOT-23-6    | ST           | **USBLC6-2SC6**    | Place near J1 |
| 4   | U_ESD_CC1, U_ESD_CC2  | 2   | **ESD, single-line** (CC1/CC2)       | SOD-923/0402| OnSemi/TI    | e.g. ESD9L5.0ST5G  | Low-C |
| 5   | F1                    | 1   | **PPTC 0.5 A I_hold**                | 0805        | Bourns       | **MF-PSMF050X-2**  | VBUS → charger VIN |
| 6   | R_BYP                 | 1   | **0 Ω (DNP)**                         | 0402        | Generic      | —                  | **Bypass across PPTC** |
| 7   | D1                    | 1   | **TVS 5.0 V uni (SMF)**              | SOD-123FL   | Many         | **SMF5.0A**        | Close to J1 |
| 8   | —                     | —   | Tag-Connect **TC2030-NL** (**DNL**)  | —           | Tag-Connect  | **TC2030-NL**      | Footprint only |
| 9   | C_USBin               | 1   | 4.7–10 µF, 10 V, X5R/X7R             | 0603        | Murata/etc   | —                  | Bulk near J1 |

---

## IO_Buttons_LEDs.SchDoc — User IO

| Item | RefDes      | Qty | Value / Rating            | Package | Manufacturer | MPN | Notes |
|----:|--------------|----:|---------------------------|---------|--------------|-----|------|
| 1   | SW1          | 1   | Tactile momentary switch  | SMD     | C&K/ALPS/etc | TBD | User button to GND |
| 2   | R_BTN_PD     | 1   | 10 kΩ, 1% (optional)      | 0402    | Generic      | —   | Ext pull-down if not using MCU PU |
| 3   | R_BTN_RC     | 1   | 100 Ω (optional)          | 0402    | Generic      | —   | Series (debounce) |
| 4   | C_BTN_RC     | 1   | 100 nF (optional)         | 0402    | Generic      | —   | To GND (debounce) |
| 5   | LED1 (green) | 1   | LED, green                | 0402    | Rohm/etc     | TBD | Status |
| 6   | R_LED        | 1   | **1 kΩ, 1%**              | 0402    | Generic      | —   | ~1–2 mA |

---

## Sensors.SchDoc — BMI270, MAX17048, SHTC3

| Item | RefDes              | Qty | Value / Rating              | Package   | Manufacturer | MPN               | Notes |
|----:|----------------------|----:|-----------------------------|-----------|--------------|-------------------|------|
| 1   | U3                   | 1   | **BMI270 IMU**              | LGA       | Bosch        | **BMI270**        | I²C |
| 2   | C_IMU1, C_IMU2      | 2   | 0.1 µF + **1 µF**           | 0402      | Generic      | —                 | Local decoupling |
| 3   | U4                   | 1   | **Fuel Gauge**              | TDFN/WLP  | Maxim/ADI    | **MAX17048G+T**   | **VDD = VBAT** |
| 4   | C_GAUGE             | 1   | 0.1 µF                      | 0402      | Generic      | —                 | Near VDD |
| 5   | R_GAUGE_INT         | 1   | 100 kΩ (optional)           | 0402      | Generic      | —                 | Pull-up for ALRT |
| 6   | U5                   | 1   | **SHTC3 Temp/RH**           | DFN 2×2   | Sensirion    | **SHTC3**         | **VDD = VDD_SENS** |
| 7   | C_SHTC3             | 1   | 0.1 µF                      | 0402      | Generic      | —                 | Local decoupling |
| 8   | R_SCL, R_SDA (bus)  | 2   | **4.7 kΩ, 1%**              | 0402      | Generic      | —                 | I²C pull-ups to **3V3** *(or place on MCU sheet)* |

---

## Testpoints_Assembly.SchDoc — Test & Bring-Up

| Item | RefDes                 | Qty | Value / Rating | Package | Manufacturer | MPN | Notes |
|----:|-------------------------|----:|----------------|---------|--------------|-----|------|
| 1   | TP_*                    | —   | Test pads      | —       | —            | —   | TP_USB_5V, TP_VBAT, TP_VSYS, TP_3V3, TP_VDD_SENS, TP_SCL, TP_SDA, TP_GND |
| 2   | JP_I2C_SCL, JP_I2C_SDA  | 2   | **0 Ω (DNP)**  | 0402    | Generic      | —   | Series jumpers (isolation/debug) |
| 3   | JP_PPTC_BYP             | 1   | **0 Ω (DNP)**  | 0402    | Generic      | —   | Parallel to PPTC (if placed here) |
| 4   | —                       | —   | Tag-Connect pads (**DNL**) | — | Tag-Connect | — | **TC2030-NL** footprint only |
| 5   | —                       | —   | RF π-match **DNP** | —   | —            | —   | Ensure **C-L-C** footprints exist |

---

## Optional / Shared Items

| Item | Use-case                          | Suggested Part(s)                                   | Notes |
|----:|------------------------------------|-----------------------------------------------------|------|
| A   | Battery placeholder                | `LiPo_Pouch_<capacity>mAh_<LxWxT>_PCM`              | e.g., 150–200 mAh, ≤4 mm thick |
| B   | Battery connector (pick one)       | **JST-SH-2** (BM02B-SRSS-TB) / **JST-GH-2** (BM02B-GHS-TBT) | Match housings/crimps |
| C   | 0.1 µF general decoupling          | Murata **GRM155R71C104KA88** (0402, 16 V, X7R)      | Common stock item |
| D   | 12 pF crystal loads                | Murata **GRM1555C1H120JA01** (0402, C0G)            | HSE/LSE load caps |
| E   | USB-C Rd 5.1 kΩ                    | Yageo **RC0402FR-075K1L**                           | CC1/CC2 |
| F   | I²C pull-ups 4.7 kΩ                | RC0402 **4.7 kΩ 1%** (generic)                      | Place near MCU |
| G   | LED (green)                        | Any 0402 green LED                                  | ~1–2 mA with 1 kΩ |
| H   | u.FL jack (DNP)                    | Hirose **U.FL-R-SMT-1(10)**                         | Conducted RF test |

---

## Quick Checks
- **0402** for most passives; **0603** for 10 µF bulk; **0805** for **PPTC**.  
- **DNP**: RF π-match C-L-C, HSE 0 Ω series, PPTC bypass, I²C series jumpers.  
- **DNL**: **TC2030-NL** Tag-Connect footprint.  
- **VBUS** chain: **USB-C → PPTC (0.5 A) → TVS (SMF5.0A) → BQ21062 VIN**, tight loop.  
- **I²C pulls** to **3V3**, placed near MCU or Sensors as chosen.  
- **MAX17048 VDD = VBAT**; verify I²C VIH vs. 3V3 levels.  
- **SHTC3** powered from **VDD_SENS** if using internal load-switch mode.

---

## Consolidated BOM (Procurement-Ready)
> **Deduping rules applied:** Single **PPTC**, **TVS**, and **0 Ω PPTC bypass** (placed near USB-C); **I²C pull-ups (2× 4.7 kΩ)** counted once (fit either on MCU or Sensors); test pads excluded; **DNP/DNL** called out.

| Cat. | MPN / Part                           | Description                                                | Package        | Qty | DNP/DNL | Notes |
|-----:|--------------------------------------|------------------------------------------------------------|----------------|----:|:------:|-------|
| IC   | **STM32WB55CGU6**                    | BLE MCU SoC                                                | UFQFPN-48      | 1  |        | Exposed pad to GND |
| IC   | **BQ21062YFPR**                      | Li-ion charger + LDO/Load-Switch (I²C)                     | WCSP (YFP-15)  | 1  |        | VIN from USB via PPTC + TVS |
| IC   | **BMI270**                           | 6-axis IMU                                                 | LGA            | 1  |        | I²C |
| IC   | **MAX17048G+T**                      | Fuel gauge (always-on, VDD=VBAT)                           | WLP/TDFN       | 1  |        | ALRT optional |
| IC   | **SHTC3**                            | Temp/RH sensor (switched VDD_SENS)                         | DFN 2×2        | 1  |        | — |
| CLK  | **NX3225SA-32MHz-STD-CSR-3**         | HSE 32 MHz crystal                                         | 3.2×2.5 mm     | 1  |        | — |
| CLK  | **ABS07-32.768KHZ-7-T**              | LSE 32.768 kHz crystal                                     | 3.2×1.5 mm     | 1  |        | — |
| USB  | **USB4105-GF-A**                     | USB-C receptacle (16-pin)                                  | Receptacle     | 1  |        | — |
| ESD  | **USBLC6-2SC6**                      | ESD array, low-C (D+/D−)                                   | SOT-23-6       | 1  |        | Place near J1 |
| ESD  | *ESD9L5.0ST5G* (or equiv.)           | Single-line ESD (CC1/CC2)                                  | SOD-923/0402   | 2  |        | 5 V low-C |
| PROT | **MF-PSMF050X-2**                    | PPTC resettable fuse, **I_hold 0.5 A**                     | 0805           | 1  |        | VBUS front-end |
| PROT | **SMF5.0A**                          | TVS diode, 5.0 V, uni                                      | SOD-123FL      | 1  |        | Next to USB-C |
| R    | **RC0402FR-075K1L**                  | 5.1 kΩ (USB-C Rd, CC1/CC2)                                 | 0402           | 2  |        | Sink-only |
| CONN | **TC2030-NL**                        | Tag-Connect (no-legs) footprint                            | —              | 1  |  DNL   | Footprint only |
| RF   | **U.FL-R-SMT-1(10)**                 | u.FL coax jack                                             | u.FL           | 1  |  DNP   | Conducted RF test (optional) |
| ANT  | **TBD (2.4 GHz chip antenna)**       | 2.4 GHz antenna                                            | Per DS         | 1  |        | Keepout & via fence |
| BAT  | **BM02B-SRSS-TB** *or* **BM02B-GHS-TBT** | 2-pin Li-Po connector (pick one: JST-SH-2 / JST-GH-2)   | JST SH-2 / GH-2| 1  |        | Choose family before PO |

### Resistors (general)
| Value         | Package | Qty | DNP | Notes |
|---------------|---------|----:|:---:|------|
| **4.7 kΩ, 1%**| 0402    | 2   |     | I²C pull-ups to 3V3 (fit once, near MCU or bus center) |
| **100 kΩ, 1%**| 0402    | 3   |     | /PG, /INT (2×) + MAX17048 ALRT (1×, optional) |
| **10 kΩ, 1%** | 0402    | 2   |     | NRST pull-up (1×), button pull-down (1×, optional) |
| **1 kΩ, 1%**  | 0402    | 1   |     | LED series |
| **22–47 Ω**   | 0402    | 2   |     | SWDIO/SWCLK series (optional) |
| **0 Ω**       | 0402    | 1   | DNP | HSE crystal series placeholder |
| **0 Ω**       | 0402    | 1   | DNP | PPTC bypass across MF-PSMF050X-2 |
| **0 Ω**       | 0402    | 2   | DNP | I²C series jumpers (debug isolation) |

### Capacitors (initial planning)
| Value / Dielectric             | Package | Qty | DNP | Notes |
|--------------------------------|---------|----:|:---:|------|
| **0.1 µF, 16 V, X7R**          | 0402    | 14* |     | MCU VDD (≈8), IMU (1), Gauge (1), SHTC3 (1), VIN (1), BAT (1), misc (1). *Verify per VDD count.* |
| **1.0 µF, 6.3 V, X5R/X7R**     | 0402    | 1   |     | IMU bulk |
| **2.2 µF, 6.3 V, X5R/X7R**     | 0402    | 2   |     | MCU bulk (1), LDO/LS_OUT (1) |
| **10 µF, 6.3–10 V, X5R/X7R**   | 0603    | 3   |     | VIN (1), BAT (1), USB-C bulk (1) |
| **12 pF, C0G**                 | 0402    | 4   |     | Crystal loads: HSE (2), LSE (2) |

### RF Match Network (fit after tuning)
| Part | Value     | Package | Qty | DNP | Notes |
|------|-----------|---------|----:|:---:|------|
| C1   | TBD (RF)  | 0402    | 1   | DNP | π-match (MCU RF_OUT → ANT_IN) |
| L1   | TBD (RF)  | 0402    | 1   | DNP | π-match |
| C2   | TBD (RF)  | 0402    | 1   | DNP | π-match |

> **Procurement notes:**  
> • Choose **one** battery connector family (JST-SH or JST-GH) before ordering.  
> • Confirm **0.1 µF** and **2.2 µF** counts after schematic annotation & ERC.  
> • Keep the **PPTC/TVS** near the USB-C; only **one** of each per board.  
> • Fit **I²C pull-ups** in **one place only** (MCU sheet recommended).


