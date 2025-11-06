# BLE-Control — Build Plan (Altium AD25)

This is a concise plan to finish the first schematic set, wire consistently, and be ready for PCB layout. It mirrors the repository structure and keeps all paths relative.

---

## 1) Create schematic sheets
Create these under `Hardware/Altium/Schematic/` (names matter):
- `TopLevel.SchDoc`
- `Power_Charge_USB.SchDoc`
- `MCU_RF.SchDoc`
- `IO_Buttons_LEDs.SchDoc`
- `Sensors.SchDoc`
- `Testpoints_Assembly.SchDoc`

---

## 2) Pin map (v1)
(Adjust later if routing demands; keep EXTI for INT lines.)

| Function | MCU Pin (STM32WB55) | Net |
|---|---|---|
| I²C1 SCL | PB8 | `I2C_SCL` |
| I²C1 SDA | PB9 | `I2C_SDA` |
| IMU INT1 | PA0 | `BMI270_INT1` |
| IMU INT2 | PA1 | `BMI270_INT2` |
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

## 3) Per-sheet implementation (minimum viable)

### Power_Charge_USB
- **Battery connector** `J3` (JST-GH-2): `+BATT_RAW`, `GND` (silk polarity, strain-relief).
- **Reverse battery protection**: P-MOS **ideal diode**  
  `D (from +BATT_RAW) → S (to VBAT_PROT)`; **R_G = 100 kΩ** gate→GND; **R_GS = 1 MΩ (DNP)**.
- **Charger** **BQ21062** (`U2`):  
  - `IN` from `USB_5V` via **polyfuse 0.5 A** (`F1`) and **VBUS TVS** (`D1`).  
  - **ESD**: `CC1/CC2` each with **5.1 kΩ Rd → GND** + **PESD5V0S1UL** to GND close to the connector.  
  - **D+/D− ESD array** (`USBLC6-2SC6`) placed at the receptacle even if data is NC; **CMC (ACM2012… DNP)** footprints after ESD.  
  - **Shield bleed**: `1 MΩ // 1 nF C0G` from shell→GND near the connector.  
  - **Caps** per your latest spec: `C_PMID = 22 µF`, `C_BAT = 22 µF`, `C_VDD = 2.2 µF`, `C_IN = 2.2 µF` (place **tight to pins**).  
  - **System rail**: use **LSLDO → `+3V3_SYS`** (configure VSET per BQ21062 method).  
- **Test pads**: `TP_USB_5V`, `TP_VBAT_RAW`, `TP_VBAT_PROT`, `TP_PMID`, `TP_3V3_SYS`, `TP_GND`.

### MCU_RF
- **STM32WB55CGU6** + **decoupling**: `0.1 µF at every VDD` (pin-proximate) + **1–4.7 µF bulk** per side.  
- **VDDA/VSSA**: **VDDA tied to `+3V3_SYS` (no bead)**; keep **0.1 µF + 1 µF** from **VDDA→GND** close to pins.  
- **VBAT_MCU**: **do not** connect to Li-ion; tie **`VBAT_MCU` → `+3V3_SYS`** (net-tie) with **100 nF** for backup retention.  
- **Reset**: NRST has **internal pull-up**; keep **external RC optional** (`10 kΩ→3V3` + `100 nF→GND`) for noise immunity.  
- **Crystals**:  
  - **HSE 32 MHz**: use internal load-cap bank → **external load caps DNP** (keep pads).  
  - **LSE 32.768 kHz**: **12 pF** each to GND; symmetric, short, guarded.  
- **On-chip SMPS cell** (plan for BYPASS first):  
  - Route **`+3V3_SYS → L1 (10 µH) → [L1A 10 nH DNP] → VLXSMPS`**,  
  - **`VFBSMPS → 4.7 µF → GND`** and **`VDDSMPS → (4.7 µF + 0.1 µF) → GND`** at pins.  
  - Provide **0 Ω links** to short `VDDSMPS/VLXSMPS/VFBSMPS` to `VDD` for LDO/BYPASS bring-up.  
- **RF**: `RF_OUT → π-match (C-L-C DNP) → ANT1 (chip antenna)` at edge; strict keepout, CPWG, via-fence; **RF ESD (PESD5V0S1UL DNP)** pad to GND at the feed.  
- **SWD (TC2030-NL footprint)**: Pads: 1=VTREF(3V3), 2=SWDIO, 3=GND, 4=SWCLK, 5=NRST, 6=SWO(opt). No paste, add 3×NPTH tooling.

### USB_Debug
- **USB-C**: `CC1/CC2 → 5.1 kΩ Rd → GND` plus **PESD5V0S1UL** on each. **D+/D− ESD array** fitted; **CMC DNP** footprints present.  
- **Data lines**: If showing DFU capability, route `D+/D−` to MCU with **22 Ω series** near MCU; otherwise leave NC but keep the protection footprints.  
- **Tag-Connect TC2030-NL**: Cortex/SWD pinout; place close to MCU pins.

### IO_Buttons_LEDs
- **Button** `BTN_IN` → GND (use MCU pull-up). Optionally fit **100 Ω series + 100 nF to GND** at the MCU pin for debounce/ESD.  
  Add **button ESD TVS** (SOD882) close to the switch.  
- **LED**: `GPIO_LED → 1 kΩ → LED → GND` (~1–2 mA).  
- **Expansion pads**: `I2C_SCL`, `I2C_SDA`, `3V3`, `GND`, `SENS_EN`.

### Sensors
- **Fuel gauge**: **removed** (no MAX17048).  
- **I²C pull-ups**: **2× 2.2 kΩ to `VDD_SENS`** (switched rail) for `I2C_SCL/SDA`.  
  Optional **33 Ω series DNP** footprints (`R_SCL_SER/R_SDA_SER`) at the MCU side.  
- **BMI270**: decoupling **0.1 µF + 1 µF**; `INT1/INT2` to EXTI pins; address pin per 0x68/0x69 choice.  
- **SHTC3**: on `VDD_SENS`; **0.1 µF** at VDD; fixed addr 0x70.  
- **Baro (LPS22HH)**: **0.1 µF** at VDD; vent/keepout window.

### Testpoints_Assembly
- **Test pads**: `TP_SWDIO`, `TP_SWCLK`, `TP_NRST`, `TP_I2C_SCL`, `TP_I2C_SDA`, `TP_RF_FEED` (coax probe option), `TP_VLXSMPS` (debug), `TP_VFBSMPS`.  
- **DNP jumpers**: π-match (C/L/C), `L1A 10 nH`, CMC on USB, USB 22 Ω series, I²C 33 Ω series, RF ESD.  
- **Notes**: antenna keepout, via-fence, Tag-Connect **DNL** assembly note, Class-A EMC intent.

---

## 4) Libraries
- **Acquire** real parts via **Manufacturer Part Search → Acquire** into `BLE_Control.SchLib` / `BLE_Control.PcbLib`.  
- **Compile** an **Integrated Library (.IntLib)** and install it in Components.  
- (Optional) enable **DBLib** when symbols/footprints exist to drive BOM parameters.

---

## 5) Validate & rules
- **Project → Validate Project** until ERC is clean.  
- PCB rules: **4-layer / 0.8 mm**, **L2 = solid GND**, RF as **CPWG**, **0402** passives (0603 only for bulk/ESD).  
- Keep **SMPS loop tiny**, no under-routes beneath crystals/RF, and **stitch ground** around the antenna feed.

---

## 6) Values cheat-sheet (Rev-A targets)
- **I²C pull-ups**: **2.2 kΩ** → `VDD_SENS` (switched).  
- **I²C series (opt)**: **33 Ω DNP** at SCL/SDA (near MCU).  
- **LED**: **1 kΩ** series.  
- **Reset**: internal pull-up present; **10 kΩ→3V3 + 100 nF→GND (opt)**.  
- **BQ21062 caps**: `C_PMID = 22 µF`, `C_BAT = 22 µF`, `C_VDD = 2.2 µF`, `C_IN = 2.2 µF`.  
- **USB-C**: `CC1/CC2 = 5.1 kΩ Rd` to GND; **PESD5V0S1UL** on CC; **USBLC6-2SC6** on `D+/D−`; **Shield 1 MΩ // 1 nF C0G**; **CMC DNP**.  
- **RF π-match**: **C/L/C = DNP** initially; **RF ESD DNP** pad fitted only if needed.  
- **SMPS**: `L1 = 10 µH`; `L1A = 10 nH (DNP)`; BYPASS via 0 Ω shorts on SMPS nets for first power-up.  
- **Crystals**: HSE **ext caps DNP** (use internal bank); LSE **12 pF** each.  
- **Polyfuse**: **0.5 A** hold at VBUS.  
- **VDDA**: tied to `+3V3_SYS`; still fit **0.1 µF + 1 µF** local to the MCU pins.  
- **VBAT_MCU**: **net-tie to +3V3_SYS** with **100 nF** (no Li-ion).

---

## Naming hygiene (nets)
- **Rails**: `+BATT_RAW`, `VBAT_PROT`, `USB_5V`, `PMID`, `+3V3_SYS`, `VDD_SENS`.  
- **Analog**: `VDDA` (to +3V3_SYS), `VSSA` (to GND).  
- **USB**: `CC1`, `CC2`, `USB_DP`, `USB_DM`.  
- **RF**: `RF_OUT`, `ANT_IN`.  
- **Debug**: `SWDIO`, `SWCLK`, `SWO`, `NRST`.

---

## 7) Test / Bring-Up Checklist (bench)

### A. Pre-power checks (DMM only)
- Continuity: **GND plane** integrity, no shorts to rails.
- Resistance to ground: `+3V3_SYS`, `VBAT_PROT`, `PMID` should read **kΩ–MΩ** (caps charging slowly).
- Orientation & polarity: TVS, polyfuse, PMOS, USB-C, JST-GH, crystals, antenna.

**Acceptance:** No shorts; rails show expected RC charge curve with DMM beeper fading.

### B. First power (USB in, no MCU SMPS)
- Populate **0 Ω bypass** links to tie `VDDSMPS/VLXSMPS/VFBSMPS` to `VDD` (LDO/BYPASS mode).
- Plug USB; measure `USB_5V`, `PMID`, `VBAT_PROT`, `+3V3_SYS`.
- Check **charger** behavior (no cell, then with a known-good cell). Verify **TS network** and termination.
- Scope **+3V3_SYS** for ripple/overshoot at plug-in.

**Acceptance:** `+3V3_SYS` within spec; ripple < ~20–30 mVpp at light load; charger enters expected state.

### C. MCU bring-up (SWD only)
- Connect **TC2030-NL**; power target from board (VTref sense only).
- Flash minimal FW: toggle LED, SWV printf on **PB3**.
- Verify **NRST** behavior; optional RC improves noise immunity.

**Acceptance:** Stable SWD connect; LED blinks; SWV prints reliably.

### D. Peripherals (I²C rail switched)
- Assert `SENS_EN` → `VDD_SENS` rises cleanly.
- Run **I²C scan**; confirm **BMI270 / SHTC3 / LPS22HH** respond.
- Check **IMU INT1/INT2** edges to EXTI.
- Verify **button** interrupt through 100 Ω/ESD path; LED current as designed (~1–2 mA).

**Acceptance:** All devices ACK at expected addresses; interrupts functional.

### E. Enable SMPS (efficiency check)
- Remove bypass shorts; populate **L1 = 10 µH** (keep **10 nH L1A DNP** initially).
- Measure current draw vs LDO/BYPASS; scope `VLXSMPS`, `VFBSMPS`, `+3V3_SYS` ripple.
- If RF desense suspected later, try **L1A 10 nH** series and re-check.

**Acceptance:** Current reduces in SMPS mode; ripple stays acceptable; no instability bursts.

### F. RF bring-up & PER
- Leave π-match **DNP** initially; verify CW return loss w/ VNA if available.
- Run **STM32CubeMonitor-RF** PER test; note channel sensitivity, TX power steps.
- Populate π-match parts to center match across BLE channels; lock values into BOM.

**Acceptance:** PER meets expectations; antenna efficiency adequate; documented match values.

### G. ESD / EMC spot checks (pre-compliance mindset)
- ESD gun (if available): **±8 kV contact / ±15 kV air** at USB shell, button, test pads. Observe recovery (no latch-up).  
- Sniff or spectrum check for **SMPS spur coupling** into 2.4 GHz region; tweak 10 nH series if needed.
- Confirm **shield bleed R//C** path and CC/D+/D− ESD clamp locations are as-built.

**Acceptance:** No unrecoverable failures; emissions profile reasonable for Class A intent.

### H. Revision close-out
- Update **risk log** with observed issues/controls/verification.
- Freeze **RF keepout & π-match**; update **Grouped BOM** and **OutJob**.
- Generate **Releases** package (PDF schematics, fab/assy, XY, BOM).

---

*End of build plan.*
