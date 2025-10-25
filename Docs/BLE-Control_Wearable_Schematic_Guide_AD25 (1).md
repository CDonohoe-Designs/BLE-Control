
# BLE‑Control Wearable Schematic Guide (AD25)

Small wearable, EMC‑first, BLE on STM32WB55. Target: **0402** passives (0603 only bulk/ESD), **4‑layer 0.8 mm**, **TC2030‑NL** SWD, chip antenna with **DNP π‑match**.

## Table of contents
- TopLevel.SchDoc
- Power_Batt_Charge_LDO.SchDoc
- MCU_RF.SchDoc
- USB_Debug.SchDoc
- IO_Buttons_LEDs.SchDoc
- Sensors.SchDoc (BMI270, MAX17048, SHTC3)
- Testpoints_Assembly.SchDoc
- Battery selection & connector (wearable)
- EMC & layout rules
- Values cheat‑sheet

---
## TopLevel.SchDoc
Sheet symbols for: Power_Batt_Charge_LDO, MCU_RF, USB_Debug, IO_Buttons_LEDs, Sensors, Testpoints_Assembly.  
Global flags: `VBAT`, `3V3`, `VDD_SENS`, `USB_5V`, `GND`.  
Nets across sheets: `I2C_SCL`, `I2C_SDA`, `BMI270_INT1/2`, `GAUGE_INT`(opt), `SHTC3_INT`(opt), `SENS_EN`, `RF_OUT→ANT_IN`, `SWDIO/SWCLK/NRST/SWO`.

---
## Power_Batt_Charge_LDO.SchDoc
- **BQ24074**: `VBUS` from USB (polyfuse 0.5–1 A + TVS) → charge Li‑Po; `BAT`→`VBAT` (10 µF at BAT). `R_ICHG`≈0.5 C, `R_ILIM` per DS. `TS` → 10 k NTC (or disable per DS).  
- **TPS7A02‑3.3**: `VBAT`→`3V3`; caps **1 µF+0.1 µF** in/out.  
- **TPS22910A**: `IN=VBAT`, `OUT=VDD_SENS`, `EN=SENS_EN`; **0.1 µF** both sides + **1–4.7 µF** on `VDD_SENS`.  
- Test pads: `TP_VBAT`, `TP_3V3`, `TP_VDD_SENS`, `TP_USB_5V`, `TP_GND`.

---
## MCU_RF.SchDoc
- **STM32WB55CGU6** with 0.1 µF per VDD at pins + 1–4.7 µF bulk; `NRST` 10 k→3V3 + 100 nF→GND.  
- **Crystals:** HSE 32 MHz (2×~12 pF + series 0 Ω), LSE 32.768 kHz (2×~12 pF).  
- **SWD (TC2030‑NL)**: 1=3V3, 2=SWDIO(PA13), 3=NRST, 4=SWCLK(PA14), 5=GND, 6=SWO(PB3 opt).  
- **RF:** `RF_OUT` → π‑match **C‑L‑C (0402, DNP)** → `ANT_IN` → chip antenna (edge, keepout, via‑fence, CPWG 50 Ω). Optional u.FL pad (DNP).

---
## USB_Debug.SchDoc
- **USB‑C (16‑pin)**: `CC1/CC2` = **5.1 kΩ Rd** to GND (sink‑only), ESD on CC/D+/D−, TVS on VBUS.  
- Route `D+`/`D−` to MCU only if DFU/CDC needed; otherwise NC (keep ESD pads).  
- **Tag‑Connect TC2030‑NL** footprint only (DNL, no paste; NPTH guides).

---
## IO_Buttons_LEDs.SchDoc
- **Button** `BTN_IN` to GND (use MCU PU or 10 k PD + 100 Ω/100 nF).  
- **LED** `GPIO_LED` → 1 k → LED → GND (~1–2 mA).  
- **Expansion pads** (opt): `I2C_SCL`, `I2C_SDA`, `3V3`, `GND`, `SENS_EN`.

---
## Sensors.SchDoc (BMI270, MAX17048, SHTC3)
- **Bus:** `I2C_SCL/SDA` with **4.7 kΩ** pull‑ups to 3V3 near MCU.  
- **BMI270**: VDD=3V3 or `VDD_SENS`; addr **0x68/0x69**; `INT1/INT2` to EXTI; decoupling **0.1 µF + 1 µF**.  
- **MAX17048 (always‑on)**: VDD=**VBAT**; I²C open‑drain to 3V3 pull‑ups OK; `ALRT`→`GAUGE_INT`(opt); **0.1 µF** local.  
- **SHTC3 (switched)**: VDD=`VDD_SENS`; addr **0x70**; **0.1 µF**; place near vent/edge; thermal isolation slot ideal.

---
## Testpoints_Assembly.SchDoc
- Pads: `TP_VBAT`, `TP_3V3`, `TP_VDD_SENS`, `TP_USB_5V`, `TP_SWDIO`, `TP_SWCLK`, `TP_GND`.  
- DNP 0 Ω jumpers: I²C series (debug), TPS22910A bypass, rail current‑sense links.  
- Notes: antenna keepout, Tag‑Connect DNL, RF π‑match DNP.

---
## Battery selection & connector (wearable)
**Li‑Po pouch** (3.7 V nom, 4.2 V charge) with **PCM** preferred. Thickness ≤ **3.5–4.0 mm**.  
Sizes: ~100 mAh≈20×15×3.5; 150–200 mAh≈30×20×3–4; 250–300 mAh≈35×25×4–4.5 mm.  
**Charge current:** start **0.5 C** (200 mAh→100 mA). Runtime ≈ `0.8×mAh/mA`.  
**EMC:** keep battery metal out of antenna keepout; twist VBAT/GND leads; service loop + strain relief.

**Connector options**
- Tabs direct‑solder (thinnest; non‑serviceable).
- **JST‑SH 1.0 mm** (BM02B‑SRSS‑TB + SHR‑02V‑S‑B): very low profile, friction latch.  
- **JST‑GH 1.25 mm** (BM02B‑GHS‑TBT + GHR‑02V‑S): positive lock, slightly taller.

**Schematic tie‑in**
- **Power_Batt_Charge_LDO**: `J_BATT(2p)`→`VBAT/GND`; BQ24074 `VBUS` from USB via polyfuse + TVS; `BAT`→`VBAT` (10 µF). Set `R_ICHG≈0.5 C`, `R_ILIM` per DS. `TS` to 10 k NTC if present.  
- **Sensors**: **MAX17048** VDD=VBAT; I²C to 3V3 pull‑ups OK; `ALRT` optional.

---
## EMC & layout rules
- **Stackup (4‑layer, 0.8 mm):** L1=signals+CPWG RF; L2=solid GND; L3=3V3/VBAT pours + slow signals; L4=signals/battery.  
- Tight loops at charger & LDO; caps **at pins**. One continuous GND (no splits).  
- RF: edge antenna keepout; 50 Ω CPWG; via‑fence 1.5–2 mm; π‑match DNP initially.  
- Clocks guarded/short; avoid under antenna. I²C paired with short return; pull‑ups near MCU/bus center.  
- LED ≤2 mA; keep test pads away from antenna region.

---
## Values cheat‑sheet
- I²C pull‑ups: **4.7 kΩ** → 3V3.  
- LED: **1 kΩ**. Reset: **10 kΩ**→3V3 + **100 nF**→GND.  
- TPS7A02 caps: **1 µF + 0.1 µF** in/out. BQ24074 caps: **10 µF** VBUS & BAT.  
- RF π‑match: **C/L/C = DNP** initially. HSE/LSE loads: start **12 pF**.  
- USB CC: **5.1 kΩ** each to GND. Polyfuse: **0.5–1 A** hold.  
- Sensor decoupling: BMI270 **0.1 µF + 1 µF**; SHTC3 **0.1 µF**; MAX17048 **0.1 µF**.  
- SWD series (opt): **22–47 Ω** at SWDIO/SWCLK if needed.
