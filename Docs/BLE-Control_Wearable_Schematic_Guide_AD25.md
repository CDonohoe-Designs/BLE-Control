# BLE‑Control Wearable Schematic Guide 

Small wearable, EMC‑first, BLE on STM32WB55. This guide explains each schematic sheet and key design choices so layout and bring‑up are predictable. Target: **0402** passives (use **0603** only for bulk/ESD), **4‑layer 0.8 mm**, **TC2030‑NL** SWD, chip antenna with **DNP π‑match**.

> Update: **USB‑C VBUS protection now specifies a PPTC: _Bourns MF‑PSMF050X‑2 (0805), I_hold = 0.5 A_**, sized for **ILIM = 500 mA**. Keep a **0 Ω DNP bypass** pad in parallel for bring‑up.


## Table of contents
- TopLevel.SchDoc
- Power_Charge_USB.SchDoc
- MCU_RF.SchDoc
- IO_Buttons_LEDs.SchDoc
- Sensors.SchDoc (BMI270, MAX17048, SHTC3)
- Testpoints_Assembly.SchDoc
- EMC & layout rules (wearable/Capri‑Control style)
- Values cheat‑sheet (start points)


---

## TopLevel.SchDoc
**Purpose:** hierarchy & net connectivity only (no real circuitry).  
**What to include:**
- Sheet symbols for: Power_Charge_USB, MCU_RF, IO_Buttons_LEDs, Sensors, Testpoints_Assembly.
- Global power/net flags: `VBAT`, `3V3`, `VDD_SENS`, `USB_5V`, `GND`.
- Bus labels: `I2C_SCL`, `I2C_SDA`, `BMI270_INT1`, `BMI270_INT2`, `GAUGE_INT` (optional), `SHTC3_INT` (optional), `SENS_EN`.
- RF net labels: `RF_OUT` (from MCU) → `ANT_IN` (to antenna).
- SWD bundle: `SWDIO`, `SWCLK`, `NRST`, `SWO`(opt), `VTREF`, `GND`.
- Order documents in **Project Options → Documents** so TopLevel is first (AD25 uses **Validate Project**).


---

## Power_Charge_USB.SchDoc — **TI BQ21062** (USB‑C charge, 1‑cell Li‑Po, ship‑mode)

## Power architecture

```
USB‑C VBUS
   │
 [PPTC]  — resettable fuse (0.5 A hold)
   │
 [TVS]   — SMF5.0A to GND at connector
   │
 [FB1]*  — optional ferrite bead (DNP default)
   │
  IN  →  BQ21061  →  PMID ──────────────┐
             │                          │
            BAT ↔ Li‑ion (NTC to TS)     ├─ VINLS = PMID
             │                          │
            VDD (decouple only)          │
            VIO → LS/LDO (= system 3V) ──┴─→ +3V_SYS (MCU & sensors)
```

- **With USB present:** PMID is sourced from USB and the battery charges; **LS/LDO** drives +3V_SYS.  
- **With USB removed:** PMID tracks **BAT** via the power‑path; **LS/LDO** continues to power +3V_SYS from the battery.  
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
- **VIO:** tie to **LS/LDO** (your +3V_SYS). **VIO max = 3.6 V**.  
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
| **LS/LDO** | **+3V_SYS → MCU & sensors** | **2.2 µF** near pin (system rail) |
| **VIO** | **+3V_SYS (LS/LDO)** | I/O reference for I²C/LP/CE/PG/INT |
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
- **Test pads**: TP_VBUS, TP_PMID, TP_BAT, TP_3V_SYS, TP_GND.

---

## Bring‑up plan
1. **No battery, no USB:** confirm no unintended rails.  
2. **Battery only:** verify **+3V_SYS (LS/LDO)** comes up; **I²C responds** (LP high).  
3. **USB only (no batt):** PMID from USB, **+3V_SYS present**, PG asserted.  
4. **Battery + USB:** charge current follows config; INT/PG behaviour as expected.  
5. **Glitch/EMI checks:** probe **VBUS/PMID/3V_SYS** during BLE TX; stuff **FB1** if needed.

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
i2cWrite(BQ21062_ADDR, REG_ICHG,   ICHG_150mA);
i2cWrite(BQ21062_ADDR, REG_ILIM,   ILIM_500mA);

#if MODE_LDO_3V3
i2cWrite(BQ21062_ADDR, REG_LDOCTL, LDO_EN | LDO_V_3V3);
#else // MODE_LS_VDDSENS
i2cWrite(BQ21062_ADDR, REG_LSCTL,  LS_MODE | LS_DISABLE);  // start off
#endif

i2cWrite(BQ21062_ADDR, REG_TSCTL,  TS_ENABLE_OR_DISABLE);
i2cWrite(BQ21062_ADDR, REG_SHIP,   SHIP_CFG); // configure ship / long-press behavior
```

---

### Thermal sanity (linear charger rule‑of‑thumb)
Dissipation ≈ **(VUSB − VBAT) × ICHG**.  
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
- **TPS7A02‑3V3** (external LDO) — replaced by BQ21062 **LDO mode** (Mode A).  
- **TPS22910A** (sensor load switch) — replaced by BQ21062 **Load‑Switch mode** (Mode B).  


---

### Bring‑up checklist
- ❑ ST‑LINK can flash; MCU boots on **3V3**.  
- ❑ I²C talks to **BQ21062**; reads **PG/INT** as expected.  
- ❑ **ICHG/ILIM** applied; battery charges from USB.  
- ❑ **Mode A:** 3V3 within spec; ripple OK. **Mode B:** `VDD_SENS` toggles under MCU control.  
- ❑ **VBUS drop** across PPTC at **500 mA** < **150 mV** (typical) — sanity check with load.  
- ❑ **Ship‑mode** verified: battery drain in shelf is µA → nA class per DS; wake via **MR/I²C** confirmed.

---

## MCU_RF.SchDoc
**MCU:** STM32WB55CGU6 (BLE5 + M4).

**Decoupling:** One **0.1 µF** per VDD pin placed at pad; plus **1–4.7 µF** bulk near MCU. Tie exposed pad to GND with vias.

**Reset:** `NRST` pull‑up **10 k** to 3V3 and **100 nF** to GND.

**Clocks:**
- **HSE 32 MHz** crystal + two load caps **(start 12 pF)** and a series **0 Ω** (tuning placeholder).
- **LSE 32.768 kHz** + two **12 pF** load caps.
- Keep crystals away from RF and high dV/dt nodes; short guard to GND.

**SWD (TC2030‑NL, 6‑pin, solderless footprint only):**
- 1: **VTREF** = 3V3
- 2: **SWDIO** → PA13
- 3: **NRST**
- 4: **SWCLK** → PA14
- 5: **GND**
- 6: **SWO** → PB3 (optional)
Reset series resistors (22–47 Ω) on SWDIO/SWCLK are optional if you see ringing.

**RF to chip antenna:**
- MCU `RF_OUT` → π‑match **C‑L‑C (0402, DNP)** → `ANT_IN` → chip antenna.
- Use **50 Ω CPWG** on Top; **ground fence vias** every ~2 mm; **no ground copper** under antenna per its datasheet.
- Place an **optional u.FL test pad** (DNP) inline for conducted tests.



## IO_Buttons_LEDs.SchDoc
- **User button** → GPIO (`BTN_IN`) to GND; use MCU pull‑up or fit **10 k** pull‑down + **RC 100 Ω/100 nF** if hardware debounce desired.
- **Status LED (green)**: `GPIO_LED` → **1 kΩ** → LED → GND (~1–2 mA typical).
- **Expansion pads** (optional): `I2C_SCL`, `I2C_SDA`, `3V3`, `GND`, `SENS_EN`.


---

## Sensors.SchDoc (BMI270, MAX17048, SHTC3)
**I²C bus:** `I2C_SCL`, `I2C_SDA` with **4.7 kΩ** pull‑ups to 3V3 placed near MCU. Keep bus <10 cm total run.

**BMI270 (6‑axis IMU):**
- VDD = **3V3** (or **VDD_SENS** if you want it power‑gated).
- I²C address: **0x68** (`SDO` = 0) or **0x69** (`SDO` = 1). Choose and annotate.
- Interrupts: `BMI270_INT1`, `BMI270_INT2` → EXTI‑capable pins.
- Local decoupling: **0.1 µF + 1 µF** close to VDD.

**MAX17048 (fuel gauge, always‑on):**
- **Power**: connect **VDD to VBAT** (device is powered by the cell).
- **I²C pull‑ups** to **3V3** as normal (open‑drain). *Check VIH vs. 3V3 in DS; commonly acceptable but verify thresholds.*
- `ALRT` (optional) → `GAUGE_INT` with 100 k pull‑up to 3V3 if used.
- **Sense**: connect the sense pin per DS to the battery positive; add **0.1 µF** local cap.
- Place short and direct to the battery net to reduce noise.

**SHTC3 (temp+RH, switched):**
- VDD = **VDD_SENS** (via load switch).
- Fixed I²C address **0x70**.
- Local **0.1 µF** cap. Place toward device edge/vent; add keepout copper below for thermal isolation.
- **INT** not required; optional pad `SHTC3_INT` (DNP).


---

## Testpoints_Assembly.SchDoc
- **Test pads:** `TP_VBAT`, `TP_3V3`, `TP_VDD_SENS`, `TP_USB_5V`, `TP_SWDIO`, `TP_SWCLK`, `TP_GND`.
- **DNP jumpers** (0 Ω) where useful for bring‑up: in series with I²C lines, across the **PPTC** (bypass), and current‑sense access in rails.
- **Assembly notes:** Mark **antenna keepout**, Tag‑Connect footprint **DNL**, RF π‑match **DNP** by default.


---

## EMC & layout rules
- **Stackup (4‑layer, 0.8 mm):** L1=signals+CPWG RF; L2=**solid GND plane**; L3=3V3/VBAT pours + slow signals; L4=signals/battery.
- **Grounding:** one continuous ground (no splits). Stitch vias around RF trace and board edges.
- **Loops:** keep **charger input loop (VBUS→PPTC→TVS→IC→GND)** and **LDO loops** tight. Place caps **at the pins**.
- **Decoupling order:** pad → 0.1 µF → via to GND (short); bulk cap slightly farther.
- **ESD/Surge:** TVS on `VBUS`; ESD arrays on CC and D+/D−; optional **CMC (DNP)** on D+/D− if data used.
- **RF:** antenna clearance per DS; 50 Ω CPWG; via fence 1.5–2 mm pitch; π‑match DNP until tuned.
- **Clocks:** shield/guard; avoid under antenna.
- **I²C:** route SCL/SDA together with a solid return path; place pull‑ups near MCU/bus center.
- **LED current:** keep ≤2 mA to limit emissions & power.
- **Test pads:** isolate from antenna region.


---

## Values cheat‑sheet (start points)
- **I²C pull‑ups:** 4.7 kΩ → 3V3 (0402).
- **LED series:** 1 kΩ (0402).
- **Reset:** 10 kΩ to 3V3 + 100 nF to GND.
- **BQ21062 caps:** 10 µF at `VIN` and `BAT` (check DS), plus local 0.1 µF at pins.
- **RF π‑match (0402):** C1/L1/C2 = **DNP** initially.
- **HSE/LSE loads:** 12 pF each (tune to crystal CL).
- **USB CC:** 5.1 kΩ on CC1/CC2 to GND (sink‑only).
- **PPTC (VBUS):** **Bourns MF‑PSMF050X‑2** (0805, **I_hold 0.5 A**), leave **0 Ω bypass DNP**.
- **Sensor decoupling:** BMI270 0.1 µF + 1 µF; SHTC3 0.1 µF; MAX17048 0.1 µF.
- **SWD series (optional):** 22–47 Ω at SWDIO/SWCLK if needed.


---

## Battery selection & connector (wearable)
**Goal:** thin, serviceable, EMC‑sane power input for a small wearable.

### Battery form factor
- **Type:** single‑cell **Li‑Po pouch** (3.7 V nom, 4.2 V charge), preferably with **PCM** (protection board).
- **Thickness target:** ≤ **3.5–4.0 mm**.
- **Typical sizes:**  
  • ~100 mAh → ~20×15×3.5 mm • ~150–200 mAh → ~30×20×3–4 mm • ~250–300 mAh → ~35×25×4–4.5 mm  
- **Charge‑current rule of thumb:** start at **0.5 C** (e.g., 200 mAh → 100 mA ICHG). Go higher only if the cell datasheet allows.
- **Runtime quick‑estimate:** `hours ≈ 0.8 × capacity_mAh / avg_current_mA` (0.8 derating for temp/aging).
- **EMC/placement:** keep **battery metal away from the antenna keepout**, add **foam+tape** strain relief, **twist VBAT/GND leads**, leave a **service loop**.

### Connector options (pick one)
- **Direct‑solder tabs** (thinnest): large pads + strain‑relief slot/adhesive. *Non‑serviceable.*
- **JST‑SH 1.0 mm** — PCB header **BM02B‑SRSS‑TB**, housing **SHR‑02V‑S‑B**.  
  *Very low profile; friction latch only.*
- **JST‑GH 1.25 mm** — PCB header **BM02B‑GHS‑TBT**, housing **GHR‑02V‑S**.  
  *Higher profile; positive lock; robust in labs.*
- (Alt.) **Molex PicoBlade 1.25 mm** if preferred.

### Schematic tie‑in (where to wire things)
- **Power_Charge_USB.SchDoc**
  - **J_BATT (2‑pin)** → `VBAT` / `GND` (clear silk polarity). Place near board edge opposite antenna.
  - **BQ21062**: `VIN` from USB via **PPTC 0.5 A (MF‑PSMF050X‑2)** + **TVS** to GND. `BAT` → `VBAT` with **10 µF** local cap.
  - **ICHG/ILIM:** program ~**0.5 C** of chosen cell; **ILIM = 500 mA** (USB cap).
  - **TS (thermistor):** connect **10 k NTC** if the pack exposes it; otherwise configure per datasheet to disable or bias safely.
  - **VDD_SENS** (if used): gate sensors with internal **LS_OUT**.
  - **Test pads:** `TP_VBAT`, `TP_3V3`, `TP_VDD_SENS`, `TP_USB_5V`, `TP_GND`.
- **Sensors.SchDoc**
  - **MAX17048** (always‑on): **VDD = VBAT**, `SCL/SDA` on `I2C_SCL/SDA` (3V3 pull‑ups OK), `ALRT` → `GAUGE_INT` (optional), **0.1 µF** local.

### BOM call‑outs
- **Battery (placeholder):** `LiPo_Pouch_<capacity>mAh_<LxWxT>_PCM` (e.g., `LiPo_Pouch_200mAh_30x20x4mm_PCM`).
- **Connector:** `JST‑SH‑2` *or* `JST‑GH‑2` (match housing/crimp pins).
- **Protection:** **PPTC** **MF‑PSMF050X‑2** (0805, 0.5 A hold), **TVS** for `VBUS`, **10 k NTC** if used.
- **EMI bead:** **Murata BLM15AG121SN1D** (0402, 120 Ω @ 100 MHz) — footprint present, **DNP** default.

### Decisions to lock
1) **Connector**: JST‑SH (thinner) or JST‑GH (more secure).
2) **Battery envelope** (max L×W×T) and **target capacity** (e.g., 150–200 mAh).
3) **Charge current cap** (default **0.5 C**).
