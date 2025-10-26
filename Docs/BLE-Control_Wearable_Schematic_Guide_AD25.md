
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

## Power_Batt_Charge_LDO.SchDoc
**Blocks:** LiPo charger **BQ24074**, load switch **TPS22910A** (sensors rail), LDO **TPS7A02‑3.3**, NTC, test pads.

**Charger (BQ24074):**
- `VBUS` from USB (through **polyfuse 0.5–1 A**), TVS to GND.
- `BAT` → net **VBAT**. Place **10 µF** right at BAT.
- **Charge current**: set **R_ICHG** for ~200–300 mA (use DS table). Fit footprint; tune in bring‑up.
- **Input current limit**: set **R_ILIM** (DS formula/table). Fit footprint.
- **TS pin**: use **10 k NTC** to GND (Beta≈3435) and bias per DS (or disable TS per DS if NTC not used).
- LEDs for CHG/PG good are optional; if used, limit to ~1–2 mA with >1 k resistors.

**3V3 LDO (TPS7A02‑3.3):**
- `IN` = VBAT; `OUT` = **3V3**; `EN` tied high (or MCU‑controlled if you want hard power‑down).
- Local caps: **1 µF + 0.1 µF** at IN/OUT close to pins.

**Sensor power gating (TPS22910A):**
- `IN` = **VBAT**, `OUT` = **VDD_SENS**, `EN` = **SENS_EN** (MCU).
- Add **0.1 µF** at IN/OUT + **1–4.7 µF** bulk on VDD_SENS.
- Optional 0 Ω link to bypass gate during debug.

**Test pads:** `TP_VBAT`, `TP_3V3`, `TP_VDD_SENS`, `TP_USB_5V`, `TP_GND` (Ø1.0 mm).


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

## Pin map (v1)
(Adjust later if routing demands; keep EXTI for INT lines.)

| Function | MCU Pin (STM32WB55) | Net |
|---|---|---|
| I²C1 SCL | PB6 | `I2C_SCL` |
| I²C1 SDA | PB7 | `I2C_SDA` |
| IMU INT1 | PA0 | `BMI270_INT1` |
| IMU INT2 | PA1 | `BMI270_INT2` |
| Gauge ALRT (opt) | PB2 | `GAUGE_INT` |
| Sensors rail enable | PA8 | `SENS_EN` |
| LED | PB0 | `GPIO_LED` |
| Button | PB1 | `BTN_IN` |
| USB FS DM (opt) | PA11 | `USB_DM` |
| USB FS DP (opt) | PA12 | `USB_DP` |
| SWDIO | PA13 | `SWDIO` |
| SWCLK | PA14 | `SWCLK` |
| SWO (opt) | PB3 | `SWO` |
| Reset | NRST | `NRST` |
| RF out | RF pin | `RF_OUT` |


---
## Pinout & Configuration — STM32WB55CG (UFQFPN-48)

> Single source of truth for firmware–schematic interface.  
> Net labels match the schematic; CubeIDE modes/pulls are implementation-ready.

| Function | MCU Pin | Net (User Label) | CubeIDE Mode / AF | Pull / Output | Speed | Notes |
|---|---|---|---|---|---|---|
| I²C1 SCL | **PB6** | **I2C_SCL** | I2C1_SCL (AF) | Open-Drain, No Pull | Very High | 2.2–4.7 kΩ external pull-up. |
| I²C1 SDA | **PB7** | **I2C_SDA** | I2C1_SDA (AF) | Open-Drain, No Pull | Very High | 2.2–4.7 kΩ external pull-up. |
| IMU INT1 | PA0 | **BMI270_INT1** | GPIO_Input + EXTI | No Pull (or Pull-Down) | — | EXTI **Rising** (BMI270 default active-high; adjust if needed). |
| IMU INT2 | PA1 | **BMI270_INT2** | GPIO_Input + EXTI | No Pull (or Pull-Down) | — | EXTI **Rising**. |
| Gauge ALERT (opt) | PB2 | **GAUGE_INT** | GPIO_Input + EXTI | **Pull-Up** (typ) | — | EXTI **Falling** if ALERT is active-low. |
| Sensors rail enable | PA8 | **SENS_EN** | GPIO_Output (Push-Pull) | No Pull (init **Low**) | Low | Drive **High** to power sensor rail. |
| LED | PB0 | **GPIO_LED** | GPIO_Output (Push-Pull) | No Pull | Low | Active-high. |
| Button | PB1 | **BTN_IN** | GPIO_Input + EXTI | **Pull-Up** | — | EXTI **Falling** (press → GND). |
| USB FS DM (opt) | PA11 | **USB_DM** | USB Device (FS) | — | — | Requires **HSI48 + CRS**; **LSE** recommended. Ensure **VDDUSB** powered. |
| USB FS DP (opt) | PA12 | **USB_DP** | USB Device (FS) | — | — | As above. |
| SWDIO | PA13 | **SWDIO** | Serial-Wire Debug | — | — | Keep dedicated to debug. |
| SWCLK | PA14 | **SWCLK** | Serial-Wire Debug | — | — | — |
| SWO (opt) | PB3 | **SWO** | Trace Async SW (SWO) | — | — | Enable **SWV** in Debug configuration. |
| Reset | NRST | **NRST** | Reset pin | — | — | Hardware line (no Cube config). |
| RF out | **RF1** | **RF_OUT** | RF pin (not GPIO) | — | — | **Single-ended** RF I/O → π-match → 50 Ω antenna. (UFQFPN-48 uses **RF1**, not RFP/RFN.) |

---

### CubeMX Setup (UFQFPN-48 specifics)

1. **Part selection**
   - Choose **STM32WB55CGUx** (UFQFPN-48) in CubeIDE.

2. **Pinout**
   - **PB6 → I2C1_SCL**, **PB7 → I2C1_SDA** (Open-Drain, no pull).
   - **PA0/PA1/PB2** as **GPIO Input + EXTI** (edges/pulls per table).
   - **PA8** as **GPIO Output (PP)**; initial state **Low** (you raise it when sensors should power).
   - Enable **USB Device (FS)**; Cube assigns **PA11/PA12**.
   - **Debug**: Serial Wire; optionally enable **Trace Async SW** for **PB3 (SWO)**.

3. **Clocks & Power**
   - **LSE 32.768 kHz** enabled (BLE timing) and **HSI48** for USB with **CRS** (best accuracy with LSE).
   - Enable **SMPS** if your BOM stuffs the SMPS network (lower current vs LDO).
   - Ensure **VDDUSB** domain is powered as per datasheet if USB is used.

4. **NVIC**
   - Enable EXTI IRQs for **PA0, PA1, PB1, PB2** with sensible priority (e.g., preempt 5).

5. **I²C1**
   - Timing for **100 kHz** or **400 kHz**; **Analog filter ON**, **Digital filter = 0** to start.

6. **Wireless (CPU2)**
   - Flash the appropriate **BLE wireless stack** to CPU2 using CubeProgrammer (Full/Light/Concurrent to suit app).
   - Build a BLE example (P2P Server / Heart Rate) to validate RF + clocks.

---

### (Copy-me) Short Pin List — for README quick reference (UFQFPN-48)

| Function | MCU Pin (STM32WB55CG) | Net |
|---|---|---|
| I²C1 SCL | PB6 | I2C_SCL |
| I²C1 SDA | PB7 | I2C_SDA |
| IMU INT1 | PA0 | BMI270_INT1 |
| IMU INT2 | PA1 | BMI270_INT2 |
| Gauge ALRT (opt) | PB2 | GAUGE_INT |
| Sensors rail enable | PA8 | SENS_EN |
| LED | PB0 | GPIO_LED |
| Button | PB1 | BTN_IN |
| USB FS DM (opt) | PA11 | USB_DM |
| USB FS DP (opt) | PA12 | USB_DP |
| SWDIO | PA13 | SWDIO |
| SWCLK | PA14 | SWCLK |
| SWO (opt) | PB3 | SWO |
| Reset | NRST | NRST |
| RF out | RF1 | RF_OUT |

---
### CubeIDE notes for UFQFPN48
- In **Pinout**, set **PB6 → I2C1_SCL** and **PB7 → I2C1_SDA**.  
- Keep USB on **PA11/PA12**, SWD on **PA13/PA14**, optional **SWO on PB3**.  
- RF path uses **RF1**: follow ST’s RF reference/matching network for WB55. :contentReference[oaicite:14]{index=14}
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

## EMC & layout rules (Capri‑Control style)
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

