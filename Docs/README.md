# BLE-Control — Documentation Index (`/Docs`)

This folder is the **documentation hub** for the BLE-Control wearable controller.  
It’s structured to look and feel like a lightweight **Design History File / Technical File**:

- Schematic & architecture
- Medical-style BoM & change control
- IEC 60601-1 / 60601-1-2 alignment
- ISO 14971 risk artefacts
- Battery pack documentation
- Bring-up, test and EMC notes

> Design-for-compliance only — not a certified medical device.

---

## 1. Where to start

If you’re reviewing the hardware for the first time:

1. **Schematic (master view)**  
   → [`Schematic/BLE-Control_Schematic_Master.pdf`](Schematic/BLE-Control_Schematic_Master.pdf)  
   → [`Schematic/BLE-Control_Schematic_Overview.md`](Schematic/BLE-Control_Schematic_Overview.md)

2. **Medical BoM + component criticality**  
   → [`BoM/BLE-Control_Medical_BoM.md`](BoM/BLE-Control_Medical_BoM.md)  
   → [`BoM/Component_Criticality_ChangeControl.md`](BoM/Component_Criticality_ChangeControl.md)

3. **Compliance & risk cornerstones**  
   - IEC 60601 overview & port classification  
   - Safety boundary  
   - Risk register and ISO 14971 notes  

---

## 2. Folder map

```text
Docs/
  README.md                ← this file
  Battery/                 ← battery pack & supplier docs
  BoM/                     ← medical-style BoM & change control
  Compliance/              ← 60601 / 14971 / MCU safety notes
  Risk/                    ← risk register (if present)
  Schematic/               ← SmartPDF + schematic overview
  Reports/                 ← EMC & technical reports
  Datasheets/              ← key referenced datasheets/app notes
  testing/                 ← AD25 rules, bring-up & checklists
