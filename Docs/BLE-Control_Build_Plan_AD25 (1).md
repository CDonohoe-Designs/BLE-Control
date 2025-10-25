
# BLE‑Control — Build Plan (Altium AD25)

This is a concise plan to finish the first schematic set, wire consistently, and be ready for PCB layout. It mirrors the repository structure and keeps all paths relative.

> *Documentation map:* For EMC rules and starting values, use **Wearable Schematic Guide** (`docs/BLE-Control_Wearable_Schematic_Guide_AD25.md`). For quick wiring, use the **One‑Page Connection Checklist** (`docs/BLE-Control_Connection_Checklist_OnePage.md`).

---

## 1) Create schematic sheets
Create these under `Hardware/Altium/Schematic/` (names matter):
- `TopLevel.SchDoc`
- `Power_Batt_Charge_LDO.SchDoc`
- `MCU_RF.SchDoc`
- `USB_Debug.SchDoc`
- `IO_Buttons_LEDs.SchDoc`
- `Sensors.SchDoc`
- `Testpoints_Assembly.SchDoc`

In **TopLevel**, place **Sheet Symbols** for each child sheet and route ports with these nets:
- **Power:** `VBAT`, `3V3`, `VDD_SENS`, `USB_5V`, `GND`
- **I²C:** `I2C_SCL`, `I2C_SDA`
- **Control/IRQs:** `SENS_EN`, `BMI270_INT1`, `BMI270_INT2`, `GAUGE_INT`(opt), `SHTC3_INT`(opt)
- **RF:** `RF_OUT` → `ANT_IN`
- **SWD:** `SWDIO`, `SWCLK`, `NRST`, `SWO`(opt), `VTREF`, `GND`

---

## 2) Pin map (v1)
(Adjust later if routing demands; keep EXTI for INT lines.)

| Function | MCU Pin (STM32WB55) | Net |
|---|---|---|
| I²C1 SCL | PB8 | `I2C_SCL` |
| I²C1 SDA | PB9 | `I2C_SDA` |
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

## 3) Per‑sheet implementation (minimum viable)
### Power_Batt_Charge_LDO
- **Battery connector** `J_BATT` (2‑pin JST‑SH‑2 or JST‑GH‑2) → `VBAT`, `GND` (mark polarity).  
- **BQ24074**: `VBUS` from `USB_5V` via **polyfuse 0.5–1 A** + **TVS**; `BAT` → `VBAT` with **10 µF** local.  
  `R_ICHG` ≈ 0.5 C of selected cell; `R_ILIM` per DS. `TS` → **10 k NTC** if available (else configure per DS).  
- **TPS7A02‑3.3**: `VBAT` → `3V3`; caps **1 µF + 0.1 µF** in/out.  
- **TPS22910A**: `IN=VBAT`, `OUT=VDD_SENS`, `EN=SENS_EN`; caps **0.1 µF** both sides + **1–4.7 µF** on `VDD_SENS`.  
- **Test pads:** `TP_VBAT`, `TP_3V3`, `TP_VDD_SENS`, `TP_USB_5V`, `TP_GND`.

### MCU_RF
- **STM32WB55CGU6** + decoupling (**0.1 µF per VDD** at pins + **1–4.7 µF** bulk). `NRST` **10 k→3V3 + 100 nF→GND**.  
- **Crystals:** HSE **32 MHz** (2× ~**12 pF** loads + series **0 Ω**) and LSE **32.768 kHz** (2× ~**12 pF**).  
- **RF:** `RF_OUT` → **π‑match C‑L‑C** (**DNP**) → `ANT_IN` → **chip antenna** (edge, keepout, via fence).  
- **SWD (TC2030‑NL footprint only)**: 1=`VTREF(3V3)`, 2=`SWDIO`, 3=`NRST`, 4=`SWCLK`, 5=`GND`, 6=`SWO`(opt).

### USB_Debug
- **USB‑C (16‑pin)**: `CC1/CC2` each **5.1 kΩ Rd** → GND; TVS on VBUS; ESD arrays on CC + D+/D−.  
- `VBUS` → charger `VBUS` via polyfuse. Wire `D+`/`D−` to MCU only if you want DFU/CDC; otherwise leave NC (keep ESD footprints).  
- **Tag‑Connect TC2030‑NL** footprint (DNL).

### IO_Buttons_LEDs
- **Button** `BTN_IN` to GND (use MCU pull‑up or fit 10 k pull‑down + 100 Ω/100 nF RC).  
- **LED**: `GPIO_LED` → **1 kΩ** → LED → GND (~1–2 mA).  
- **Expansion pads** (opt): `I2C_SCL`, `I2C_SDA`, `3V3`, `GND`, `SENS_EN`.

### Sensors
- **Pull‑ups:** 2× **4.7 kΩ** to 3V3 for `I2C_SCL/SDA`.  
- **BMI270** (3V3 or `VDD_SENS`): address **0x68** (`SDO=0`) or **0x69** (`SDO=1`); `INT1/INT2` wired. Decoupling **0.1 µF + 1 µF**.  
- **MAX17048** (always‑on): **VDD=VBAT**; I²C to 3V3 pull‑ups OK (open‑drain); `ALRT→GAUGE_INT` (opt); **0.1 µF** local.  
- **SHTC3** (on `VDD_SENS`): fixed addr **0x70**; **0.1 µF** local; `SHTC3_INT` optional.

### Testpoints_Assembly
- Add `TP_SWDIO`, `TP_SWCLK`, and DNP 0 Ω jumpers (I²C series, TPS22910A bypass).  
- Assembly notes: antenna keepout, π‑match **DNP**, Tag‑Connect **DNL**.

---

## 4) Libraries
- **Acquire** real parts via **Manufacturer Part Search → Acquire** into `BLE_Control.SchLib` / `BLE_Control.PcbLib`.  
- **Compile** an **Integrated Library (.IntLib)** and install it in Components.  
- (Optional) enable **DBLib** when symbols/footprints exist to drive BOM parameters.

---

## 5) Validate & rules
- **Project → Validate Project** until ERC is clean.  
- PCB rules: 4‑layer/0.8 mm, L2 = solid GND, CPWG for RF, 0402 passives, 0603 only bulk/ESD.

---

## 6) Values cheat‑sheet
See **Wearable Schematic Guide → Values cheat‑sheet** (`docs/BLE-Control_Wearable_Schematic_Guide_AD25.md`).

