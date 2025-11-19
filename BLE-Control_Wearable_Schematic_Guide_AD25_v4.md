# BLE‑Control Wearable Schematic Guide 

Small wearable, EMC‑first, BLE on STM32WB55. This guide explains each schematic sheet and key design choices so layout and bring‑up are predictable. Target: **0402** passives (use **0603** only for bulk/ESD), **4‑layer 0.8 mm**, **TC2030‑NL** SWD, chip antenna with **DNP π‑match**.

> Update: **USB‑C VBUS protection now specifies a PPTC: _Bourns MF‑PSMF050X‑2 (0805), I_hold = 0.5 A_**, sized for **ILIM = 500 mA**. Keep a **0 Ω DNP bypass** pad in parallel for bring‑up.

## Table of contents

- **[Power_Charge_USB.SchDoc](#power_charge_usb)** — [`Hardware/Altium/Power_Charge_USB.SchDoc`](Hardware/Altium/Schematic/Power_Charge_USB.SchDoc)
- **[MCU_RF.SchDoc](#mcu_rf)** — [`Hardware/Altium/MCU_RF.SchDoc`](Hardware/Altium/MCU_RF.SchDoc)
- **[Sensor_IO_Buttons_LED.SchDoc](#sensor_io_buttons_led)** — [`Hardware/Altium/Sensor_IO_Buttons_LED.SchDoc`](Hardware/Altium/Schematic/Sensor_IO_Buttons_LED.SchDoc)
- **[Testpoints_Assembly.SchDoc](#testpoints_assembly)** — [`Hardware/Altium/Testpoints_Assembly.SchDoc`](Hardware/Altium/Schematic/Testpoints_Assembly.SchDoc)
- **[EMC & layout rules (wearable)](#emc_rules)**
- **[Values cheat-sheet (start points)](#values_cheatsheet)**
- **[Battery selection & connector](#battery)**
- **[TC2030 (SWD) hook table](#tc2030)**
- **[Bring-up checklist](#bringup_checklist)**


---

## <a id="toplevel"></a>TopLevel.SchDoc
**Purpose:** hierarchy & net connectivity only (no real circuitry).  
**What to include:**
- Sheet symbols for: `Power_Charge_USB`, `MCU_RF`, `Sensor_IO_Buttons_LED`, `Testpoints_Assembly`.
- Global power/net flags: `VBATT_RAW`, `VBAT_PROT`, `PMID`, `+3V3_SYS`, `VDD_SENS`, `USB_VBUS`, `GND`.
- Bus labels: `I2C_SCL`, `I2C_SDA`, `BMI270_INT1`, `BMI270_INT2`, `BTN_IN`, `GPIO_LED`, `SENS_EN`, `SKIN_ALERT`.
- RF net labels: `RF_OUT` (from MCU) → `ANT_IN` (to antenna).
- SWD bundle: `SWDIO`, `SWCLK`, `NRST`, `SWO` (opt), `VTREF`, `GND`.
- Order documents in **Project Options → Documents** so TopLevel is first (AD25 uses **Validate Project**).

---

## <a id="power_charge_usb"></a>Power_Charge_USB.SchDoc — TI BQ21061 (USB-C charge, 1-cell Li-Po, ship-mode)

## Power architecture

```
USB‑C VBUS
   │
 [PPTC]  — resettable fuse (0.5 A hold)
   │
 [TVS]   — SMF5.0A to GND at connector
   │
 [FB1]  — optional ferrite bead 
   │
  IN  →  BQ21061  →  PMID ──────────────┐
             │                          │
            BAT ↔ Li‑ion (NTC to TS)     ├─ VINLS = PMID
             │                          │
            VDD (decouple only)          │
            VIO → LS/LDO (= system 3V) ──┴─→ +3V3_SYS (MCU & sensors)
```

- **With USB present:** PMID is sourced from USB and the battery charges; **LS/LDO** drives +3V3_SYS.  
- **With USB removed:** PMID tracks **BAT** via the power‑path; **LS/LDO** continues to power +3V3_SYS from the battery.  
- **Ship/ship‑hold** (if used) disconnects BAT from PMID; wake via **MR** or USB.

> \*FB1 is optional; keep footprint and DNP by default. Fit if noise/EMI requires it.

---

## USB‑C (charge‑only) rules
- Receptacle: **GCT USB4105‑GF‑A** or similar.  
- **CC1/CC2:** 5.1 kΩ **Rd** to GND (advertise sink/UFP).  
- **D+ / D‑:** not connected (leave pads for ESD array if you want symmetry).  
- **Protection:**  
  - **TVS (SMF5.0A)** from **VBUS→GND**, placed at connector with short, wide trace and 2–3 GND vias.  
  - **PPTC** in series with VBUS (0.5 A hold typical).  
  - **ESD array** (**USBLC6‑2SC6**) protecting CC and (optionally) D± pads.  
- **Optional EMI bead:** **FB1 ~120 Ω @ 100 MHz** between protection and charger **IN** (DNP by default).

**Placement order (recommended):** `J1 VBUS → TVS → PPTC → (FB1 opt) → BQ21061 IN` with **CIN** close to IN.

---

## I/O & I²C logic domain
- **VIO:** tie to **LS/LDO** (your +3V3_SYS). **VIO max = 3.6 V**.  
- **LP:** **pull‑up to VIO (~100 kΩ)** → keeps **I²C accessible on battery‑only**.  
- **SCL/SDA pull‑ups:** **only on MCU board** (≈10 kΩ to VIO).  
- **PG/INT** (open‑drain): pull‑ups to **VIO** (≈100 kΩ).  
- **VDD:** **decouple only** (2.2–4.7 µF to GND). Do **not** power anything from VDD.

---

## Pin wiring summary (charger side)

| BQ21061 Pin | Connects to | Notes |
|---|---|---|
| **IN** | USB VBUS (after PPTC/TVS/FB1*) | Place **CIN 4.7–10 µF** close |
| **PMID** | System power‑path node | **22–47 µF** bulk near PMID |
| **BAT** | Li‑ion cell + | **1 µF** near BAT; **TS** to NTC |
| **VINLS** | **PMID** | Provide **≥1 µF** (match or exceed CLDO) |
| **LS/LDO** | **+3V3_SYS → MCU & sensors** | **2.2 µF** near pin (system rail) |
| **VIO** | **+3V3_SYS (LS/LDO)** | I/O reference for I²C/LP/CE/PG/INT |
| **LP** | **Pull‑up to VIO (~100 kΩ)** | I²C alive on battery |
| **SCL/SDA** | MCU I²C | **Pull‑ups on MCU only** (10 kΩ → VIO) |
| **PG/INT** | MCU GPIO (open‑drain) | Pull‑ups to VIO (~100 kΩ) |
| **MR** | Momentary NO to GND | Wakes from ship; ESD protect trace |
| **TS** | NTC divider | 10 kΩ NTC typical; see datasheet tables |
| **VDD** | Decouple to GND | 2.2–4.7 µF; don’t load |
| **CE** | MCU or default | Leave NC for charge‑enabled default, or drive from MCU |

\*FB1 is optional; keep footprint; DNP by default.

---

## Schematic checklist
- **Connector J1** (USB‑C, UFP) with **R1/R2 = 5.1 kΩ** to GND on CC1/CC2.  
- **Protection**: **TVS (SMF5.0A)** at VBUS, **PPTC** in series, **USBLC6‑2SC6** for ESD.  
- **CIN** at IN (**≥4.7–10 µF**), **CPMID** (**22–47 µF**), **CVDD** (**2.2–4.7 µF**), **CINLS** (**≥1 µF**), **CLDO** (**2.2 µF**).  
- **LP pull‑up** (100 kΩ → VIO), **PG/INT pull‑ups** (100 kΩ → VIO).  
- **I²C pull‑ups only on MCU** (10 kΩ → VIO).  
- **Test pads**: TP_VBUS, TP_PMID, TP_BAT, TP_3V3_SYS, TP_GND.

---

## Bring‑up plan
1. **No battery, no USB:** confirm no unintended rails.  
2. **Battery only:** verify **+3V3_SYS (LS/LDO)** comes up; **I²C responds** (LP high).  
3. **USB only (no batt):** PMID from USB, **+3V3_SYS present**, PG asserted.  
4. **Battery + USB:** charge current follows config; INT/PG behaviour as expected.  
5. **Glitch/EMI checks:** probe **VBUS/PMID/+3V3_SYS** during BLE TX; stuff **FB1** if needed.

---

## BOM highlights (key parts)
- **Charger:** TI **BQ21061** — 1‑cell Li‑ion, power‑path + LS/LDO  
- **USB‑C receptacle:** **GCT USB4105‑GF‑A**  
- **TVS (VBUS):** **Littelfuse SMF5.0A** (SOD‑123FL)  
- **ESD array (CC/D±):** **ST USBLC6‑2SC6**  
- **PPTC:** **Bourns MF‑PSMF050X‑2** (0805) or **MF‑MSMF050/16** (1206, alt)  
- **Ferrite bead (opt):** ~**120 Ω @ 100 MHz** (0402/0603), low RDC, ≥1 A

---

## Datasheets / refs
- TI **BQ21061** — 1‑cell charger w/ power‑path + LS/LDO: <https://www.ti.com/lit/gpn/BQ21061>  
- GCT **USB4105‑GF‑A** — USB‑C receptacle: <https://gct.co/connector/usb4105>  
- Littelfuse **SMF5.0A** — 5 V TVS (SMAF): <https://www.littelfuse.com/products/overvoltage-protection/tvs-diodes/surface-mount/smf/smf5-0a>  
- ST **USBLC6‑2SC6** — 2‑line ESD array: <https://www.st.com/resource/en/datasheet/usblc6-2.pdf>  
- Bourns **MF‑PSMF050X‑2** — PPTC 0805: <https://www.bourns.com/docs/product-datasheets/mfpsmf.pdf>  
- Bourns **MF‑MSMF050/16** — PPTC 1206: <https://www.bourns.com/docs/product-datasheets/mf-msmf.pdf>

---

### Initial I²C bring‑up (pseudo‑regs — confirm with DS)

- **Charge Current (ICHG):** set ~**100–200 mA** (≈0.5 C for 200–400 mAh cells).  
- **Input Limit (ILIM):** set **500 mA** for USB bring‑up; lower later if needed.  
- **LDO Voltage (Mode A):** set **3.3 V** (e.g., `VLDO = 3.3 V` code).  
- **LS Mode (Mode B):** set block to **Load‑Switch** and default **OFF** on boot; MCU enables it when needed.  
- **TS behavior:** enable NTC or **disable TS** if no NTC fitted (development).  
- **Ship‑mode:** verify **SHIP enable** bit/command works; confirm wake via **MR** or I²C as designed.

**Example (pseudocode):**
```c
// i2cWrite(addr, reg, val)
i2cWrite(BQ21061_ADDR, REG_ICHG,   ICHG_150mA);
i2cWrite(BQ21061_ADDR, REG_ILIM,   ILIM_500mA);

#if MODE_LDO_3V3
i2cWrite(BQ21061_ADDR, REG_LDOCTL, LDO_EN | LDO_V_3V3);
#else // MODE_LS_VDDSENS
i2cWrite(BQ21061_ADDR, REG_LSCTL,  LS_MODE | LS_DISABLE);  // start off
#endif

i2cWrite(BQ21061_ADDR, REG_TSCTL,  TS_ENABLE_OR_DISABLE);
i2cWrite(BQ21061_ADDR, REG_SHIP,   SHIP_CFG); // configure ship / long-press behavior
```

---

### Thermal sanity (linear charger rule‑of‑thumb)
Dissipation ≈ **(VUSB − VBAT_PROT) × ICHG**.  
- 5.0 V → 4.2 V @ **100 mA** → **0.08 W** (easy).  
- 5.0 V → 4.2 V @ **300 mA** → **0.24 W** (watch copper).  
Keep charger input/output loops tight; pour copper under the EP (to L2 GND) for spreading.

---

### Layout notes (wearable/EMC)
- L2 = **solid GND**; no ground splits.  
- Keep **VIN→PPTC→TVS→IC→GND** and **BAT→IC→GND** loops **tight**; caps **at pins**.
- Route **I²C** as a pair with a good return; place pulls near MCU.  
- Keep **TS** away from RF/high‑dV/dt.  
- For **RF (2.4 GHz)**: respect antenna keepout; π‑match DNP footprints in **MCU_RF.SchDoc**.

---

### What to remove from the old design
- **TPS7A02‑3V3** (external LDO) — replaced by BQ21061 **LDO mode** (Mode A).  
- **TPS22910A** (sensor load switch) — replaced by BQ21061 **Load‑Switch mode** (Mode B).  


---

## <a id="bringup_checklist"></a>Bring-up checklist
- ❑ ST‑LINK can flash; MCU boots on **3V3**.  
- ❑ I²C talks to **BQ21061**; reads **PG/INT** as expected.  
- ❑ **ICHG/ILIM** applied; battery charges from USB.  
- ❑ **Mode A:** 3V3 within spec; ripple OK. **Mode B:** `VDD_SENS` toggles under MCU control.  
- ❑ **VBUS drop** across PPTC at **500 mA** < **150 mV** (typical) — sanity check with load.  
- ❑ **Ship‑mode** verified: battery drain in shelf is µA → nA class per DS; wake via **MR/I²C** confirmed.

---

## <a id="mcu_rf"></a>MCU_RF.SchDoc

## Power & Ground — STM32WBxx (ties to `Power_Charge_USB.SchDoc`)

> **Purpose:** lock rail names and ground strategy before drawing `MCU_RF.SchDoc`. Main rail is **`+3V3_SYS`** from the charger/LDO sheet.

### Context from `Power_Charge_USB.SchDoc`
- USB-C (**USB4105-GF-A**), PPTC (**MF-PSMF050X-2**), TVS (**SMF5.0A**), ferrite (**BLM15AG121**), charger **BQ21061YFPR**.
- Nets exported: **`VBAT_PROT`**, **`PMID`**, **`+3V3_SYS`**.
- The charger has a local **VDD (IC1-D1)** pin. **Rename that local net to `BQ_VDD`** (or `CHG_VDD`) to avoid clashing with the MCU’s `VDD` rail name.

### VDDSMPS vs VDD — what & why
- **`VDD`** = MCU external 3.3 V rail (**`+3V3_SYS`**). Powers I/O and most internal domains.
- **`VDDSMPS`** = external 3.3 V **input to the on‑chip buck (SMPS)** that generates the core voltage. Separate pin → tight local decoupling and compact high‑di/dt loop.
- In this design: **`VDD`, `VDDRF`, `VDDSMPS` → `+3V3_SYS`** (same rail), with **different decoupling**.

### Rail map (what each pin wants)
- **`VDDx` → `+3V3_SYS`**: **0.1 µF per pin** at‑pin + **4.7–10 µF** bulk nearby.
- **`VDDRF` → `+3V3_SYS`**: tie direct; **0.1 µF** at pin.
- **`VDDSMPS` → `+3V3_SYS`**: **4.7 µF + 0.1 µF** at the pin to GND.
- **On‑chip SMPS**: `+3V3_SYS → L1 (2.2 µH @8 MHz or 10 µH @4 MHz, opt +10 nH series) → VLXSMPS`; **4.7 µF from VFBSMPS→GND** (not a system rail).
- **BYPASS option**: 0 Ω links to short `VDDSMPS/VLXSMPS/VFBSMPS → VDD` when not using SMPS (keep footprints).
- **`VDDA` / `VREF+`**: to `+3V3_ANA` (via bead) **or** `+3V3_SYS`; **0.1 µF + 1 µF** to **`VSSA`** at pins.
- **`VDDUSB`**: tie to `VDD` with 0.1 µF if USB FS unused; else 3.0–3.6 V with local caps.
- **`VBAT_PROT`**: **≤ 3.6 V**. Net‑tie to `VDD` + 0.1 µF **or** feed from 3.0–3.3 V backup.

### Ground strategy
- **Single solid GND plane** under MCU & RF (L2). Heavy stitching.
- **`VSSRF/EPAD`**: via‑in‑pad array to GND; via fence near RF pins/π‑match.
- **`VSSSMPS`**: keep the **SMPS loop** (`VLXSMPS → L1 → VFBSMPS → VSSSMPS`) **very tight**.
- **`VSSA`**: tie to plane beside MCU; **VDDA/VREF+** decouplers return to **VSSA** (no split planes needed).

### Power_Charge_USB ⇄ MCU_RF net mapping
| From `Power_Charge_USB` | Use in `MCU_RF`               | Notes |
|---|---|---|
| `+3V3_SYS`              | `VDDx`, `VDDRF`, `VDDSMPS`   | Same rail; per‑pin 0.1 µF on VDDx/VDDRF; **4.7 µF + 0.1 µF** on VDDSMPS. |
| `+3V3_SYS` via L1       | `VLXSMPS`                    | L1 = 2.2 µH (8 MHz) or 10 µH (4 MHz), optional +10 nH series. |
| —                       | `VFBSMPS`                    | **4.7 µF → GND**; **not** a system rail. |
| `+3V3_SYS` / `+3V3_ANA` | `VDDA`, `VREF+`              | 0.1 µF + 1 µF to VSSA; bead optional for `+3V3_ANA`. |
| `VBAT_PROT`                  | `VBAT_PROT` (MCU)                 | ≤ 3.6 V; tie to VDD (0.1 µF) **or** 3.0–3.3 V backup. |
| *(local)* `BQ_VDD`      | —                            | Charger‑IC local net only; don’t reuse as MCU `VDD`. |
| `GND`                   | `VSS`, `VSSRF/EPAD`, `VSSSMPS`, `VSSA` | One plane; EPAD via‑in‑pad; compact SMPS loop. |

## Schematic How-To (AD25)

1. **Power Ports:** Place global `+3V3_SYS`, `+3V3_ANA` (if used), and `GND` power ports.  
2. **SMPS Cell:** Draw the block with `L1`, optional `L2=10 nH` in series, `Cbulk 4.7 µF` on `VFBSMPS`, and `Cvdsmps 4.7 µF + 100 nF` on `VDDSMPS`.  
   - Add **0 Ω links** labelled “BYPASS” to short `VDDSMPS/VLXSMPS/VFBSMPS` to `VDD` when not using SMPS.  
3. **Decouplers:** One **100 nF per `VDDx`**, plus bulk **4.7–10 µF** per side of the MCU.  
4. **Analog Node:** `VDDA` to `+3V3_ANA` via bead **or** straight to `+3V3_SYS`; **`VREF+` → `VDDA`**. Place **100 nF + 1 µF** to `VSSA`.  
5. **USB Node:** `VDDUSB` → `VDD` (if unused) with 100 nF; otherwise to a 3.0–3.6 V rail with local caps.  
6. **VBAT_PROT:** Net-tie to `VDD` + 100 nF **or** bring in 3.0–3.3 V backup with 100 nF; label “Max 3.6 V”.  
7. **Ground Pins:** Expose **`VSSRF/EPAD`** pin on the symbol and annotate: “via array to GND, keepout under HSE/RF”.  
8. **Naming hygiene:** Keep the charger’s local **`BQ_VDD`** distinct from MCU **`VDD`** to avoid ERC/DRC confusion.

## <a id="tc2030"></a>TC2030 (SWD) hook table — STM32WB55

> Cable: **TC2030-CTX (Cortex/SWD)** style mapping  
> Grid (top view): top row **1-2-3**, bottom row **4-5-6**

| TC2030 Pad | Signal  | Altium Net (suggested) | STM32WB55 Signal Pin | Required? | Notes |
|---:|---|---|---|:---:|---|
| 1 | VTref (3V3 sense) | +3V3_SYS | — | ✅ | Sense only; **probe does not power target**. Tie to board 3V3 near MCU. |
| 2 | SWDIO | SWDIO | **PA13** | ✅ | Keep short; no series R. Testpoint optional. |
| 3 | GND | GND | — | ✅ | Solid plane; add a stitching via next to pad. |
| 4 | SWCLK | SWCLK | **PA14** | ✅ | Keep short; no series R. Testpoint optional. |
| 5 | nRESET | NRST | **NRST** | ✅ | Optional 10 kΩ → 3V3 + 100 nF → GND near pin. |
| 6 | SWO (trace) | SWO | **PB3 (TRACESWO)** | ◻️ | Optional but handy for SWV `printf`. Leave NC if unused. |

### Companion “bring-up” hooks
| Function | Altium Net | STM32WB55 Pin | Parts | Notes |
|---|---|---|---|---|
| Boot mode | BOOT0 | BOOT0 | 100 kΩ pulldown | Keep default low; add a pad to pull high for system bootloader if ever needed. |
| 3V3 rail sense | +3V3_SYS | — | — | Feed VTref from here (TC2030 pad 1). |
| Ground | GND | — | — | Add a nearby exposed GND pad if you like grabbing with a clip. |

### Layout quick-rules (AD25)
- Use the **TC2030-NL (no-legs)** footprint; **3 NPTH alignment holes**, **no paste** on the 6 pads.
- Place near a **board edge**; avoid the **antenna/RF keepout**.
- Keep **SWDIO/SWCLK/NRST** traces **short, direct, single-via** if possible.
- Do **not** route SWD under the crystal island or the RF feed/match.
- Power the board from its own rail; the probe reads **VTref** to know it’s a 3V3 target.

> If you’re ever forced to use a **10-pin Cortex** header instead, the relevant pins are: **1=VTref, 2=SWDIO, 3=GND, 4=SWCLK, 6=SWO, 10=NRST**. The TC2030-CTX cable maps these onto the 2×3 pad grid above.


### Quick ERC/DFM checks
- `VDD = VDDRF = VDDSMPS = +3V3_SYS` (ERC shows one source).
- BYPASS links in place (option to defer SMPS bring‑up).
- 0.1 µF at each VDDx; bulk near device.
- VDDA/VREF+ decouple to VSSA; short tie to plane.
- VBAT_PROT ≤ 3.6 V, labelled accordingly.
- EPAD note present; RF/SMPS loops compact.
- **Naming hygiene:** use `BQ_VDD` for the charger pin; reserve `VDD` for the MCU rail.


---

## <a id="sensor_io_buttons_led"></a>Sensor_IO_Buttons_LED.SchDoc — Sensors + User I/O (single sheet)

**Purpose:** Combine the sensors (BMI270, BME280 or SHTC3/LPS22HH option) with the user button and status LED, plus **skin temperature (digital)**.  
**Power domain:** `VDD_SENS` (switched) for sensors; LED may use `+3V3_SYS` (preferred, to avoid rail bounce).

### Rails & local decoupling
- **Rails on sheet:** `VDD_SENS`, `+3V3_SYS` (LED optional), `GND`.
- **Decoupling (at pins):**  
  - **BMI270:** 0.1 µF + 1 µF → GND  
  - **BME280 (or SHTC3/LPS22HH):** 0.1 µF (add 1 µF for LPS22HH) → GND  
- Add an extra **1 µF** near the sensor cluster entry point of `VDD_SENS`.

### I²C bus topology
- **Nets:** `I2C_SCL`, `I2C_SDA` (to MCU).  
- **Pull‑ups:** `2.2 kΩ` **to `VDD_SENS`** (`R_SCL_PU_SENS`, `R_SDA_PU_SENS`, 0402).  
- **Series dampers (DNP by default):** `33 Ω` near the MCU on SCL/SDA.  
- **Test pads:** `TP_I2C_SCL`, `TP_I2C_SDA`, `TP_VDD_SENS`, `TP_GND`.  
- Start @ 100 kHz; raise to 400 kHz after bring‑up.

### Sensors & addresses (no conflicts)
- **BMI270 (IMU):** I²C, **0x68** (`SDO → GND`) or 0x69 (`SDO → VDD_SENS`); `INT1→PA0`, `INT2→PA1`.  
- **BME280:** **0x76** (`SDO→GND`) or **0x77** (`SDO→VDDIO/VDD_SENS`).  
  *Alt:* **SHTC3** (0x70 fixed) + **LPS22HH** (0x5C/0x5D). Choose one path and annotate.
- Place SHTC3/LPS22HH/BME280 near a vent/slot; keep outside the antenna keepout.

### User I/O
**Button (SW1):**  
- `BTN_IN → PB1`, active‑low to **GND**.  
- Use MCU pull‑up; optional `100 nF` debounce to GND; `100 Ω` series to MCU; **SOD882 TVS** at the pad.  
- Test pad: `TP_BTN` optional.

**LED (LED1):** two options (pick one; DNP the other)  
- **A — Active‑low (preferred):** `+3V3_SYS → R_LED (1 kΩ) → LED1 → GPIO_LED (PB0)`; MCU drives **Low** = ON.  
- **B — Active‑high:** `GPIO_LED (PB0) → R_LED (1 kΩ) → LED1 → GND`.

### Skin Temperature (Digital) — TMP117 (default) + MAX30208 (rigid‑flex variant)

**Goal:** Accurate skin-contact temperature sensing with mechanical-first placement.

**Rails:** `VDD_SENS`, `GND`  
**I²C:** Shared `I2C_SCL`, `I2C_SDA` (2.2 kΩ pull-ups → `VDD_SENS`)  
**Nets:** `SKIN_ALERT` (optional), `TP_SKIN`

**TMP117 (default on rigid board)**  
- **VDD:** 3.0–3.6 V from `VDD_SENS`; **0.1 µF** at VDD.  
- **ADDR/ADR:** default **0x48** (strap per DS if multiple devices).  
- **ALERT:** open‑drain → `SKIN_ALERT` (optional) with **100 kΩ** PU → `VDD_SENS` or leave NC.  
- **Placement:** within **3–5 mm** of a **skin-contact copper pad** (ENIG), with **slot isolation** around the pad tongue; keep **>10 mm** from RF tip and away from charger heat; **TVS (SOD882)** at the pad entry; grounded guard ring.

**MAX30208 (variant for rigid‑flex tail)**  
- **VDD/VIO:** 1.7–3.6 V from `VDD_SENS`; **0.1 µF** at VDD.  
- **ADDR/SDO & CSB:** per DS (I²C mode).  
- **Use case:** mount on a **flex tail** with a coverlay opening over the package; add a small **stiffener** under IC for consistent pressure.  
- **Connector (optional, DNP):** `J_FLEX` 6‑pin FFC/FPC, 0.5 mm pitch, signals: `VDD_SENS, GND, SCL, SDA, SKIN_ALERT, NC`.

**Bring‑up (sheet‑level):** read TMP117 at **0.5–2 Hz**, average (IIR τ≈5–10 s). Log ambient (BME280/SHTC3) to correct for enclosure heating:  
`T_skin_corr = T_skin_raw − k · (T_board − T_amb)`; tune **k** empirically.

**ESD:** ground ring around the pad; **PESD5V0S1UL** or similar at pad entry on the rigid side.

### ERC/DRC notes
- No‑ERC on TVS‑to‑GND if flagged.  
- Mark environmental vent keepouts; button finger clearance.  
- Parameter Set on I²C nets if series‑R DNPs are used (to preserve width/clearance rules).

### Bring‑up (sheet‑level)
1) `SENS_EN=Low` → sensors off; 3V3 only.  
2) `SENS_EN=High` → `VDD_SENS≈3.3 V` at TP; I²C scan matches chosen devices.  
3) LED/SW sanity: blink LED; EXTI falling on button.  
4) Raise I²C to 400 kHz; enable BMI270 FIFO/DRDY; verify TMP117 reading and ambient correction path.

---

## <a id="testpoints_assembly"></a>Testpoints_Assembly.SchDoc
- **Test pads:** `TP_VBAT_PROT`, `TP_3V3_SYS`, `TP_VDD_SENS`, `TP_USB_VBUS`, `TP_SWDIO`, `TP_SWCLK`, `TP_GND`, `TP_SKIN`.
- **DNP jumpers** (0 Ω) where useful for bring‑up: in series with I²C lines, across the **PPTC** (bypass), and current‑sense access in rails.
- **Assembly notes:** Mark **antenna keepout**, Tag‑Connect footprint **DNP**, RF π‑match **DNP** by default.


---

## <a id="emc_rules"></a>EMC & layout rules (wearable)
- **Stackup (4‑layer, 0.8 mm):** L1=signals+CPWG RF; L2=**solid GND plane**; L3=+3V3/VBAT_PROT pours + slow signals; L4=signals/battery.
- **Grounding:** one continuous ground (no splits). Stitch vias around RF trace and board edges.
- **Loops:** keep **charger input loop (VBUS→PPTC→TVS→IC→GND)** and **LDO loops** tight. Place caps **at the pins**.
- **Decoupling order:** pad → 0.1 µF → via to GND (short); bulk cap slightly farther.
- **ESD/Surge:** TVS on `VBUS`; ESD arrays on CC and D+/D−; optional **CMC (DNP)** on D+/D− if data used.
- **RF:** antenna clearance per DS; 50 Ω CPWG; via fence 1.5–2 mm pitch; π‑match DNP until tuned.
- **Clocks:** shield/guard; avoid under antenna.
- **I²C:** route SCL/SDA together with a solid return path; place pull‑ups near bus center (`VDD_SENS` node).
- **LED current:** keep ≤2 mA to limit emissions & power.
- **Test pads:** isolate from antenna region.


---

## <a id="values_cheatsheet"></a>Values cheat-sheet (start points)
- **I²C pull‑ups:** **2.2 kΩ → VDD_SENS** (0402).  
- **I²C series (DNP):** **33 Ω** near MCU on SCL/SDA.  
- **LED series:** 1 kΩ (0402).  
- **Reset:** 10 kΩ to 3V3 + 100 nF to GND.  
- **BQ21061 caps:** 10 µF at `VIN` and `BAT` (check DS), plus local 0.1 µF at pins.  
- **RF π‑match (0402):** C1/L1/C2 = **DNP** initially.  
- **HSE/LSE loads:** 12 pF each (tune to crystal CL).  
- **USB CC:** 5.1 kΩ on CC1/CC2 to GND (sink‑only).  
- **PPTC (VBUS):** **Bourns MF‑PSMF050X‑2** (0805, **I_hold 0.5 A**), leave **0 Ω bypass DNP**.
- **Sensor decoupling:** BMI270 0.1 µF + 1 µF; **BME280 0.1 µF** (or SHTC3 0.1 µF; LPS22HH 0.1 µF + 1 µF).  
- **TMP117 (skin):** VDD 3.0–3.6 V, **0.1 µF** at VDD, I²C addr **0x48**, ALERT optional.  
- **MAX30208 (variant):** VDD/VIO 1.7–3.6 V, **0.1 µF**, mount on flex tail; connector `J_FLEX` DNP.
 

---

## <a id="battery"></a>Battery selection & connector (wearable)
**Goal:** thin, serviceable, EMC‑sane power input for a small wearable.

### Battery form factor
- **Type:** single‑cell **Li‑Po pouch** (3.7 V nom, 4.2 V charge), preferably with **PCM** (protection board).
- **Thickness target:** ≤ **3.5–4.0 mm**.
- **Typical sizes:**  
  • ~100 mAh → ~20×15×3.5 mm • ~150–200 mAh → ~30×20×3–4 mm • ~250–300 mAh → ~35×25×4–4.5 mm  
- **Charge‑current rule of thumb:** start at **0.5 C** (e.g., 200 mAh → 100 mA ICHG). Go higher only if the cell datasheet allows.
- **Runtime quick‑estimate:** `hours ≈ 0.8 × capacity_mAh / avg_current_mA` (0.8 derating for temp/aging).
- **EMC/placement:** keep **battery metal away from the antenna keepout**, add **foam+tape** strain relief, **twist VBAT_PROT/GND leads**, leave a **service loop**.

### Connector options (pick one)
- **Direct‑solder tabs** (thinnest): large pads + strain‑relief slot/adhesive. *Non‑serviceable.*
- **JST‑SH 1.0 mm** — PCB header **BM02B‑SRSS‑TB**, housing **SHR‑02V‑S‑B**.  
  *Very low profile; friction latch only.*
- **JST‑GH 1.25 mm** — PCB header **BM02B‑GHS‑TBT**, housing **GHR‑02V‑S**.  
  *Higher profile; positive lock; robust in labs.*
- (Alt.) **Molex PicoBlade 1.25 mm** if preferred.

### Schematic tie‑in (where to wire things)
- **Power_Charge_USB.SchDoc**
  - **J_BATT (2‑pin)** → `VBAT_PROT` / `GND` (clear silk polarity). Place near board edge opposite antenna.
  - **BQ21061**: `VIN` from USB via **PPTC 0.5 A (MF‑PSMF050X‑2)** + **TVS** to GND. `BAT` → `VBAT_PROT` with **10 µF** local cap.
  - **ICHG/ILIM:** program ~**0.5 C** of chosen cell; **ILIM = 500 mA** (USB cap).
  - **TS (thermistor):** connect **10 k NTC** if the pack exposes it; otherwise configure per datasheet to disable or bias safely.
  - **VDD_SENS**: use internal **Load‑Switch mode** if you choose to gate sensors from the charger.
  - **Test pads:** `TP_VBAT_PROT`, `TP_3V3_SYS`, `TP_VDD_SENS`, `TP_USB_VBUS`, `TP_GND`.
- **Sensor_IO_Buttons_LED.SchDoc**
  - `I2C_SCL/SDA` with **2.2 kΩ** to `VDD_SENS`; `33 Ω` DNP near MCU; decoupling at pins.
  - `BTN_IN → PB1` (to GND on press), `GPIO_LED → PB0` (choose active‑low/high option), `BMI270_INT1/2 → PA0/PA1`, `TMP117 addr=0x48`.

### BOM call‑outs
- **Battery (placeholder):** `LiPo_Pouch_<capacity>mAh_<LxWxT>_PCM` (e.g., `LiPo_Pouch_200mAh_30x20x4mm_PCM`).
- **Connector:** `JST‑SH‑2` *or* `JST‑GH‑2` (match housing/crimp pins).
- **Protection:** **PPTC** **MF‑PSMF050X‑2** (0805, 0.5 A hold), **TVS** for `VBUS`, **10 k NTC** if used.
- **EMI bead:** **Murata BLM15AG121SN1D** (0402, 120 Ω @ 100 MHz) — footprint present, **DNP** default.

### Decisions to lock
1) **Connector**: JST‑SH (thinner) or JST‑GH (more secure).
2) **Battery envelope** (max L×W×T) and **target capacity** (e.g., 150–200 mAh).
3) **Charge current cap** (default **0.5 C** of chosen cell).
