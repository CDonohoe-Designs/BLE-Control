
# BLE‑Control Wearable Schematic Guide 

Small wearable, EMC‑first, BLE on STM32WB55. This guide explains each schematic sheet and key design choices so layout and bring‑up are predictable. Target: **0402** passives (use **0603** only for bulk/ESD), **4‑layer 0.8 mm**, **TC2030‑NL** SWD, chip antenna with **DNP π‑match**.


## Table of contents
- TopLevel.SchDoc
- Power_Batt_Charge_LDO.SchDoc
- MCU_RF.SchDoc
- USB_Debug.SchDoc
- IO_Buttons_LEDs.SchDoc
- Sensors.SchDoc (BMI270, MAX17048, SHTC3)
- Testpoints_Assembly.SchDoc
- EMC & layout rules (wearable/Capri‑Control style)
- Values cheat‑sheet (start points)


---

## TopLevel.SchDoc
**Purpose:** hierarchy & net connectivity only (no real circuitry).  
**What to include:**
- Sheet symbols for: Power_Batt_Charge_LDO, MCU_RF, USB_Debug, IO_Buttons_LEDs, Sensors, Testpoints_Assembly.
- Global power/net flags: `VBAT`, `3V3`, `VDD_SENS`, `USB_5V`, `GND`.
- Bus labels: `I2C_SCL`, `I2C_SDA`, `BMI270_INT1`, `BMI270_INT2`, `GAUGE_INT` (optional), `SHTC3_INT` (optional), `SENS_EN`.
- RF net labels: `RF_OUT` (from MCU) → `ANT_IN` (to antenna).
- SWD bundle: `SWDIO`, `SWCLK`, `NRST`, `SWO`(opt), `VTREF`, `GND`.
- Order documents in **Project Options → Documents** so TopLevel is first (AD25 uses **Validate Project**).


---

## Power_Batt_Charge_LDO.SchDoc — **TI BQ21062** (USB-C, 1-cell Li-Po, ship-mode)

**Goal:** Replace external LDO (**TPS7A02-3V3**) and load-switch (**TPS22910A**) with **BQ21062**’s integrated **LDO / load-switch** and **power-path**. Keep USB-C sink-only, low quiescent current, and ship-mode for shelf life.

### Block overview
```
USB-C 5V  ── polyfuse ── TVS ──>  VIN     BQ21062     BAT  ──>  VBAT (to cell)
            CC1/CC2: 5.1k Rd          |             PMID  ──>  VSYS (system bus, optional)
                                       |             LDO_OUT/LS  ──>  either 3V3 (LDO) or VDD_SENS (LoadSwitch)
SCL/SDA ── I2C to MCU                  |             MR/INT/PG/TS  ──>  MCU GPIOs / NTC
```

---

### Pin → Net map (rename pins per symbol if different)
> Use this as your wiring checklist while editing the sheet.

| BQ21062 Pin | Net Name (proposed) | Notes |
|---|---|---|
| **VIN** | `USB_5V_PROT` | From USB-C VBUS via **polyfuse** & **TVS**. Short input loop. |
| **BAT** | `VBAT` | To cell (+). Place **10 µF** (min) close to BAT. |
| **PMID / SYS** | `VSYS` | Regulated system node (power-path). You can leave un-used if you power 3V3 only from LDO. |
| **LDO_OUT / LS_OUT** | `3V3` **or** `VDD_SENS` | Set **mode** below: LDO=3V3 rail, or LS=gated sensor rail. Input = `VINLS` (below). |
| **VINLS** | `VSYS` (preferred) | Feed LDO/LS from `VSYS` (or `VBAT` for lowest noise / lower headroom). Keep short. |
| **SDA / SCL** | `I2C_SDA` / `I2C_SCL` | I²C to MCU. **4.7 kΩ** pulls to 3V3 near MCU. |
| **/PG** | `CHG_PG` (opt.) | Power-good open-drain → pull-up to 3V3 (10–100 kΩ). |
| **/INT** | `CHG_INT` (opt.) | Interrupt open-drain → pull-up to 3V3 (10–100 kΩ). |
| **MR / QON** | `PWR_BTN` (opt.) | Momentary push-button input / ship-wake. Add **100 nF** to GND if you need debounce. |
| **TS** | `NTC_TS` | 10 k NTC to GND; bias per DS (or disable TS in I²C). Keep trace quiet/short. |
| **GND / EP** | `GND` | Solid ground. Exposed pad via-stitched to L2 GND. |

---

### Mode selection (pick **one** and annotate the sheet)

#### **Mode A — LDO = Main 3V3 rail (drop external TPS7A02)**
- `VINLS` = `VSYS`  
- `LDO_OUT` → **`3V3`** (feeds MCU + logic, ≤ **100 mA** total from LDO).  
- Optional: keep `VSYS` un-routed, or use as a test pad.

**Pros:** simple, quiet 3V3. **Cons:** 3V3 efficiency depends on battery voltage (linear).  
If 3V3 load peaks >100 mA, consider Mode B with an external buck (or use a PMIC).

#### **Mode B — Load-Switch = VDD_SENS (drop external TPS22910A)**
- Keep main 3V3 from an external regulator **or** from BQ21062 LDO at 3V3 (feeding only MCU).  
- Set internal block to **Load-Switch** and route **LS_OUT → `VDD_SENS`**, controlled via I²C.  
- Gate sensors off in standby for µA-level system sleep.

---

### USB-C (sink-only) front-end
- **CC1/CC2:** **5.1 kΩ Rd** to GND (advertises sink).  
- **VBUS:** **polyfuse 0.5–1 A** (low-R), **TVS** to GND close to connector.  
- **D+/D−:** not used? Leave NC, still place **ESD** footprints.  
- **GND shell**: multiple vias; stitch to L2 plane.

---

### Recommended passives (starting values)
- **BAT**: 10 µF (X5R/X7R, 6.3 V), + optional 0.1 µF.  
- **VIN**: 4.7–10 µF close to VIN, + 0.1 µF at pin.  
- **LDO/LS_OUT**: 1–4.7 µF at the output pin (check DS stability range).  
- **I²C pulls**: 4.7 kΩ to 3V3 (bus length-dependent).  
- **/PG, /INT pulls**: 10–100 kΩ to 3V3 (lower = faster edges).  
- **TS**: 10 k NTC (β≈3435), bias per DS (or disable via I²C).  
- **Test pads**: `TP_USB_5V`, `TP_VBAT`, `TP_VSYS`, `TP_3V3`, `TP_VDD_SENS`, `TP_SCL`, `TP_SDA`, `TP_GND`.

---

### Initial I²C bring-up (pseudo-regs — confirm with DS)
> Write these early in firmware init. Names are indicative; use the datasheet’s exact register map.

- **Charge Current (ICHG):** set ~**100–200 mA** (≈0.5 C for 200–400 mAh cells).  
- **Input Limit (ILIM):** set **500 mA** for USB bring-up; lower later if needed.  
- **LDO Voltage (Mode A):** set **3.3 V** (e.g., `VLDO = 3.3 V` code).  
- **LS Mode (Mode B):** set block to **Load-Switch** and default **OFF** on boot; MCU enables it when needed.  
- **TS behavior:** enable NTC or **disable TS** if no NTC fitted (development).  
- **Ship-mode:** verify **SHIP enable** bit/command works; confirm wake via **MR** or I²C as designed.

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

### Thermal sanity (linear charger rule-of-thumb)
Dissipation ≈ **(VUSB − VBAT) × ICHG**.  
- 5.0 V → 4.2 V @ **100 mA** → **0.08 W** (easy).  
- 5.0 V → 4.2 V @ **300 mA** → **0.24 W** (watch copper).  
Keep charger input/output loops tight; pour copper under the EP (to L2 GND) for spreading.

---

### Layout notes (wearable/EMC)
- L2 = **solid GND**; no ground splits.  
- Keep **VIN→IC→GND** and **BAT→IC→GND** loops **tight**; caps **at pins**.  
- Route **I²C** as a pair with a good return; place pulls near MCU.  
- Keep **TS** away from RF/high-dV/dt.  
- For **RF (2.4 GHz)**: respect antenna keepout; π-match DNP footprints in **MCU_RF.SchDoc**.

---

### What to remove from the old design
- **TPS7A02-3V3** (external LDO) — replaced by BQ21062 **LDO mode** (Mode A).  
- **TPS22910A** (sensor load switch) — replaced by BQ21062 **Load-Switch mode** (Mode B).  


---

### Bring-up checklist
- [ ] ST-LINK can flash; MCU boots on **3V3**.  
- [ ] I²C talks to **BQ21062**; reads **PG/INT** as expected.  
- [ ] **ICHG/ILIM** applied; battery charges from USB.  
- [ ] **Mode A:** 3V3 within spec; ripple OK. **Mode B:** `VDD_SENS` toggles under MCU control.  
- [ ] **Ship-mode** verified: battery drain in shelf is µA → nA class per DS; wake via **MR/I²C** confirmed.

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


## USB_Debug.SchDoc
**USB‑C (16‑pin) charge‑centric; optional USB‑FS data.**
- **CC1/CC2**: **5.1 kΩ Rd** to GND (sink‑only). Route only one CC if space; tie other via 5.1 kΩ as well.
- **VBUS** → BQ24074 `VBUS` via **polyfuse**; add **TVS** to GND.
- **D+ / D−**: to MCU USB‑FS if you need DFU/CDC; otherwise leave NC but keep ESD footprint.
- **ESD**: low‑cap arrays on D+/D−, CC pins; single‑line TVS on VBUS.
- Keep D+/D− short, matched, and away from RF; if routed, target ~90 Ω diff (FS tolerates laxity, but keep symmetry).

**Tag‑Connect (TC2030‑NL):**
- Place the **no‑legs** footprint; mark “DNL” in BOM. No solder paste; NPTH guide holes.


---

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
- **DNP jumpers** (0 Ω) where useful for bring‑up: in series with I²C lines, across TPS22910A (bypass), and current‑sense access in rails.
- **Assembly notes:** Mark **antenna keepout**, Tag‑Connect footprint **DNL**, RF π‑match **DNP** by default.


---

## EMC & layout rules
- **Stackup (4‑layer, 0.8 mm):** L1=signals+CPWG RF; L2=**solid GND plane**; L3=3V3/VBAT pours + slow signals; L4=signals/battery.
- **Grounding:** one continuous ground (no splits). Stitch vias around RF trace and board edges.
- **Loops:** keep charger input loop (VBUS→IC→GND) and LDO loops tight. Place caps **at the pins**.
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
- **TPS7A02 caps:** 1 µF + 0.1 µF at IN/OUT.
- **BQ24074 caps:** 10 µF at VBUS and BAT.
- **RF π‑match (0402):** C1/L1/C2 = **DNP** initially.
- **HSE/LSE loads:** 12 pF each (tune to crystal CL).
- **USB CC:** 5.1 kΩ on CC1/CC2 to GND (sink‑only).
- **Polyfuse (VBUS):** 0.5–1 A hold, low‑R.
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
- **Power_Batt_Charge_LDO.SchDoc**
  - **J_BATT (2‑pin)** → `VBAT` / `GND` (clear silk polarity). Place near board edge opposite antenna.
  - **BQ24074**: `VBUS` from USB via **polyfuse 0.5–1 A** + **TVS** to GND. `BAT` → `VBAT` with **10 µF** local cap.
  - **ICHG/ILIM:** fit **R_ICHG** for ~**0.5 C** of chosen cell; **R_ILIM** per DS (start ~500 mA input limit).
  - **TS (thermistor):** connect **10 k NTC** if the pack exposes it; otherwise configure per datasheet to disable or bias safely.
  - **TPS7A02‑3V3** from `VBAT`; **TPS22910A**: `IN=VBAT`, `OUT=VDD_SENS`, `EN=SENS_EN` (MCU).
  - **Test pads:** `TP_VBAT`, `TP_3V3`, `TP_VDD_SENS`, `TP_USB_5V`, `TP_GND`.
- **Sensors.SchDoc**
  - **MAX17048** (always‑on): **VDD = VBAT**, `SCL/SDA` on `I2C_SCL/SDA` (3V3 pull‑ups OK), `ALRT` → `GAUGE_INT` (optional), **0.1 µF** local.

### BOM call‑outs
- **Battery (placeholder):** `LiPo_Pouch_<capacity>mAh_<LxWxT>_PCM` (e.g., `LiPo_Pouch_200mAh_30x20x4mm_PCM`).
- **Connector:** `JST‑SH‑2` *or* `JST‑GH‑2` (match housing/crimp pins).
- **Protection:** **Polyfuse** 0.5–1 A (low‑R), **TVS** for `VBUS`, **10 k NTC** if used.

### Decisions to lock
1) **Connector**: JST‑SH (thinner) or JST‑GH (more secure).
2) **Battery envelope** (max L×W×T) and **target capacity** (e.g., 150–200 mAh).
3) **Charge current cap** (default **0.5 C**).

