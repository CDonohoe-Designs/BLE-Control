
# Sensor_IO_Buttons_LED — Schematic Spec (AD25)

**MCU:** STM32WB55CGUx (UFQFPN-48)  
**Sheet name:** `Sensor_IO_Buttons_LED.SchDoc`  
**Purpose:** Consolidate sensors (BMI270, SHTC3, LPS22HH) and simple I/O (1×User Button, 1×User LED) on the *switched* sensor rail `VDD_SENS` (behind TPS22910A).

---

## 1) Rails & local decoupling

**Rails used on this sheet**
- `VDD_SENS` (3V3 switched via TPS22910A)
- `+3V3_SYS` (always on; for LED only if preferred — see Note)
- `GND`

**Decoupling per IC (place at pins)**  
- **BMI270:** `C1=0.1 µF (0402)`, `C2=1 µF (0402)` to GND.  
- **SHTC3:** `C3=0.1 µF (0402)` to GND.  
- **LPS22HH:** `C4=0.1 µF (0402)`, `C5=1 µF (0402)` to GND.  

> Keep `VDD_SENS` star-connected off the load switch flood; avoid long necks. If space allows, add a **local 1 µF** near the sensor cluster entry point.

---

## 2) I²C bus topology

**Nets**
- `I2C_SCL` (to PB6)
- `I2C_SDA` (to PB7)

**Pull-ups (to `VDD_SENS`)**
- `R_SCL_PU_SENS = 2.2 kΩ (0402)` → `I2C_SCL` to `VDD_SENS`
- `R_SDA_PU_SENS = 2.2 kΩ (0402)` → `I2C_SDA` to `VDD_SENS`

**Series dampers (DNP by default)**
- `R_SCL_SER = 33 Ω (0402, DNP)` in series with `I2C_SCL` (near MCU)
- `R_SDA_SER = 33 Ω (0402, DNP)` in series with `I2C_SDA` (near MCU)

**Test pads (Bottom side recommended)**
- `TP_I2C_SCL`, `TP_I2C_SDA` (1 mm pads), `TP_VDD_SENS`, `TP_GND`

**Bus policy**
- Start 100 kHz; enable analog filter; digital filter taps = 0.  
- Keep total bus length short; route SCL beside solid GND.

---

## 3) Sensors & addresses

### 3.1 BMI270 (U6) — 6‑axis IMU (I²C mode)
- **Power:** `VDD_SENS`
- **I²C:** `SDA=I2C_SDA`, `SCL=I2C_SCL`
- **Address select:** `SDO → GND` → I²C address **0x68**
- **Interrupts:**  
  - `INT1 → BMI270_INT1 (PA0)`
  - `INT2 → BMI270_INT2 (PA1)`
- **Pins not used:** Tie per datasheet (e.g., `CSB` pull to VDD_SENS for I²C; leave `ASDx/ASCx` N/C if not used).  
- **Decoupling:** 0.1 µF + 1 µF at `VDD/VDDIO`

> Place centrally; keep away from USB/charger heat and the antenna. Orientation silkscreen helpful (X/Y arrows).

### 3.2 SHTC3 (U8) — Temperature/Humidity
- **Power:** `VDD_SENS`
- **I²C:** `SDA=I2C_SDA`, `SCL=I2C_SCL`
- **Address:** fixed **0x70**
- **Decoupling:** 0.1 µF at VDD
- **Mechanical:** Vent/slot or breathable opening in enclosure path.

### 3.3 LPS22HH (U7) — Barometric Pressure
- **Power:** `VDD_SENS`
- **I²C:** `SDA=I2C_SDA`, `SCL=I2C_SCL`
- **Address select:** `SA0 → GND` → **0x5C** (or tie to `VDD_SENS` for **0x5D**; choose one and mark on schematic)
- **Decoupling:** 0.1 µF + 1 µF at VDD
- **Mechanical:** Place near vent; maintain keepout under the port; add “DO NOT COVER” note.

> With addresses **0x68 (BMI270)**, **0x5C (LPS22HH)**, **0x70 (SHTC3)** there are **no conflicts** on I²C1.

---

## 4) User I/O: Button + LED

### 4.1 User Button (SW1)
- **Net:** `BTN_IN` → **PB1**
- **Type:** Tactile switch (e.g., C&K KMR221GLFS), to **GND** on press.
- **Biasing:** Use **internal pull‑up** in firmware (or stuff `R_BTN_PU=100 kΩ` to `+3V3_SYS` if you want hardware bias).  
- **Debounce (optional):** `C_BTN=100 nF` from `BTN_IN` to `GND`.  
- **Series R (ESD tame):** `R_BTN_SER=100 Ω` between pad and PB1 (place close to MCU).  
- **ESD:** `D_BTN` (SOD882 TVS) at the button pad to GND.
- **Test pad:** `TP_BTN` optional.

> Configure EXTI **falling edge** (active‑low). Keep the button away from antenna edge.

### 4.2 User LED (LED1)
Two equivalent options—pick one and mark the other DNP:

**Option A (active‑low, preferred):**  
- `+3V3_SYS → R_LED (1 kΩ) → LED1 → GPIO_LED (PB0)` with LED cathode at PB0.  
- MCU drives **Low** to turn **ON**. (Lower EMI coupling into the sensor rail.)

**Option B (active‑high):**  
- `GPIO_LED (PB0) → R_LED (1 kΩ) → LED1 → GND`.  
- MCU drives **High** to turn **ON**.

> Keep series R near LED. 1–2 mA is fine for a wearable; you can use PWM for brightness.

---

## 5) Net labels (copy into AD25)

```text
# Rails
VDD_SENS, +3V3_SYS, GND

# I²C + INT
I2C_SCL, I2C_SDA
BMI270_INT1, BMI270_INT2

# User I/O
BTN_IN, GPIO_LED

# Test points
TP_I2C_SCL, TP_I2C_SDA, TP_VDD_SENS, TP_GND, TP_BTN
```

---

## 6) Footprints / packages

- **BMI270:** LGA‑16 (Bosch ref. footprint)  
- **SHTC3:** DFN‑4 1.3×0.8 mm  
- **LPS22HH:** HLGA‑10L 2.0×2.0 mm with central port (no copper under port)  
- **LED1:** 0402  
- **R/C:** 0402 (BOM uses Yageo RC0402 series)  
- **TVS (button):** SOD882 (PESD5V0S1UL or similar)

> Add 3D models if available; mark sensor orientations on silk.

---

## 7) ERC/DRC notes (AD25)

- Place **No ERC** on the TVS diode node if Altium flags the un-driven pad.  
- Add **Parameter Set** for I²C nets if you use series R DNP: keep diff‑like clearance consistent.  
- Mark **mechanical keepouts**: LPS22HH port area; SHTC3 vent window; button finger clearance.
- In **Project Options → Error Reporting**, set "Pin x-y Electrical Type Mismatch" to **No Report** for TVS-to-GND shunts if needed.

---

## 8) Placement guidance (mechanical)

- **IMU** toward the PCB center; avoid edges and high‑vibe zones (USB/connector).  
- **Baro + RH** near a **vent** with minimal internal heatwash; no copper under ports; avoid battery adjacency.  
- Keep all of this sheet **outside the antenna keepout** and at least **8–10 mm** from the RF tip if possible.

---

## 9) Bring‑up (sheet‑level)

1. Power `+3V3_SYS`; ensure `SENS_EN=Low` → sensors unpowered.  
2. Drive `SENS_EN=High`; verify `VDD_SENS≈3.3 V` at `TP_VDD_SENS`.  
3. I²C scan @100 kHz: expect **0x68**, **0x5C**, **0x70**.  
4. Toggle LED; confirm button EXTI falling edge.  
5. Raise bus to 400 kHz; run IMU FIFO / DRDY, baro ODR=25 Hz, RH 1 Hz. Check current delta with `VDD_SENS` on/off.

---

## 10) Schematic checklist (before layout)

- [ ] Pull‑ups are to `VDD_SENS` (not `+3V3_SYS`)  
- [ ] Series `33 Ω` on I²C marked **DNP**  
- [ ] Button ESD diode at pad; optional RC debounce placed  
- [ ] Test pads added (`TP_*`)  
- [ ] Address pins tied: `BMI270 SDO=GND`, `LPS22HH SA0=GND`  
- [ ] All decoupling stuffed and at pins
