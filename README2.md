✅ BLE-Control — Wearable BLE Controller (STM32WB55 + Altium AD25)

BLE-Control is a compact, low-power wearable BLE controller built around the
STM32WB55 dual-core Bluetooth 5 SoC (Cortex-M4 + Cortex-M0+ RF core).

The project demonstrates:

Robust hardware design using Altium Designer 25 (AD25)

EMC-first design thinking (IEC 60601-1-2, Class A concepts)

Clear power architecture & protection (USB-C → Charger → System rails)

Professional documentation practices aligned with ISO 14971 (risk) and ISO 13485-style structure

BLE-centric bring-up, RF tuning, and test strategy

Firmware integration using STM32CubeIDE

⚠️ This is a design-for-compliance portfolio project — not a certified medical device.

🚀 Quick Navigation
📘 Full Documentation — Start Here

→ Docs/README.md

This is the central documentation hub (like a mini DHF):

Master schematic (SmartPDF)

Detailed schematic overview

Medical-style BoM

Component criticality & change control

Safety boundary & electrical safety notes

ISO 14971 risk register

EMC pre-compliance notes

Battery documents (spec, RFQ, incoming QC)

AD25 rules & bring-up guides

📐 Hardware (Altium AD25)

→ Hardware/Altium/

Contains:

Full AD25 design (.PrjPcb, .SchDoc, .PcbDoc)

Draftsman drawings

OutJobs (SmartPDF, fab, assembly outputs)

Custom component libraries

💻 Firmware (STM32WB55)

→ Firmware/

Includes:

STM32CubeIDE project

BLE stack integration (CPU2)

Startup, clocks, GPIO, I²C, and sensor bring-up

Power domain & SENS_EN logic support

🧩 System Overview

BLE-Control is divided into three electrical domains:

1. Power / Charging / USB-C

USB-C sink with CC resistors

Full front-end protection:

PPTC (500 mA)

VBUS TVS (SMF5.0A)

CC ESD diodes

USBLC6 for D+/D–

Common-mode choke

Shield bleed (1 MΩ // 1 nF C0G)

Power-Path IC: TI BQ21061

JEITA temperature profile

NTC (10 kΩ)

PMID → main system supply

Reverse-battery FET

Main Rail: TPS7A02-3.3V → +3V3_SYS

Sensor Rail: TPS22910A → 3V3_SENS (gated via SENS_EN)

2. MCU + RF (STM32WB55)

Dual-core BLE 5 MCU

HSE 32 MHz, LSE 32.768 kHz

USB FS with precision matched routing

On-chip SMPS (10 µH + optional 10 nH helper)

RF output:

π-match network (C-L-C)

Differential RF filter

Johanson 2.4 GHz antenna

RF ESD footprint

Controlled-impedance CPWG with via-fence

Debug: Tag-Connect TC2030-CTX-NL

Deterministic startup (BOOT0 pulldown, RC reset)

3. Sensors + I/O

All sensors run from 3V3_SENS, independently switchable:

TMP117 (precision temperature)

BMI270 (IMU)

SHTC3 (Humidity/Temp)

I²C pull-ups local to sensor domain

Button Input (BTN1):

SOD-882 TVS

100 Ω series resistor

RC debounce

Hard pull-up for EMC stability

Status LED: Active-low with series resistor.

🛡 Design-for-Compliance Highlights
IEC 60601-1 (Basic Safety & Essential Performance)

Entire system operates in SELV (<5 V)

Battery safety handled via charger + NTC

Essential performance defined as:
“Maintain BLE communication or fail safely with no unintended actions.”

IEC 60601-1-2 (EMC, Edition 4, Class A Concepts)

Surge/ESD/EFT hardened USB entry

Segmented power domains (3V3_SYS vs 3V3_SENS)

Shield bleed network

π-match and RF filtering

SMPS layout based on ST AN5165

All GPIO biased (no floating pins)

ISO 14971 (Risk)

Complete risk register included

Hazard → sequence → control → residual risk mapping

Controls include:

TVS

Series resistors

Shield bleed

Reverse FET

Watchdog (firmware)

Power-gated sensor domain

ISO 13485 (Documentation Style)

The /Docs tree mirrors a structured engineering documentation flow:

Docs/
  Schematic/
  BoM/
  Compliance/
  Risk/
  Battery/
  Reports/
  testing/

🧪 Bring-Up & Testing Summary
Recommended Bring-Up Order

Verify power rails and boot behaviour

Flash STM32WB55 (SMPS bypass mode)

Validate BQ21061 charging + BQ_INT interrupt

Enable sensor rail (SENS_EN → 3V3_SENS)

Enable SMPS and verify ripple

RF bring-up & π-match population

PER testing using STM32CubeMonitor-RF

EMC Pre-Compliance (Design Expectation)

ESD: ±8 kV contact / ±15 kV air

EFT/Burst: ±1 kV at VBUS

Radiated immunity: 10 V/m (80 MHz–2.7 GHz)

Conducted immunity: 3 Vrms (150 kHz–80 MHz)

Monitor:

BLE RSSI

Packet Error Rate (PER)

I²C stability

Reset events

False interrupts

Power rail droop

🔧 Tools Used

Altium Designer 25

STM32CubeIDE / CubeProgrammer

LTspice (power integrity + simulations)

STM32CubeMonitor-RF (PER, RSSI, RF sweep)

Python (data analysis, logs, FFT)

📂 Repository Structure Overview
```text
BLE-Control/
│
├── Docs/                ← Main documentation hub
│   ├── Schematic/
│   ├── BoM/
│   ├── Compliance/
│   ├── Battery/
│   ├── Risk/
│   ├── Reports/
│   └── testing/
│
├── Hardware/
│   └── Altium/          ← Full AD25 hardware project
│
├── Firmware/            ← STM32WB55 firmware (CubeIDE)
│
└── LICENSE_MIT
```

📬 Contact / Review Notes

If you're reviewing this repository for a hardware or embedded engineering position,
I'm happy to walk through:

The hardware architecture

Schematic/PCB design decisions

RF/EMC considerations

Power integrity

Risk, safety and compliance reasoning

Firmware bring-up sequence

✔ End of README