# BLE-Control Battery Pack Specification

**Type:** Single-cell Li-ion polymer (3.7 V nom, 4.2 V max)  
**Capacity:** 300–500 mAh (target ~400 mAh)  
**Wires:** 3-wire (VBAT+, GND, 10 k NTC @25 °C, B≈3435)  
**Protection:** Integrated PCM (OVP/UVP/OCP/short)  
**Connector:** JST-GH, 3-pin (Board: BM03B-GHS-TBT; Cable: GHR-03V-S + SSHL-003GA-P0.2)

## Compliance & Documentation (Required)
- IEC 62133-2 certificate/report (cell or pack)
- UN 38.3 transport test report
- UL 2054 (or equivalent safety report) – preferred for pack
- MSDS, RoHS/REACH, CoC, traceability labels

## Electrical
- Max charge voltage: 4.2 V
- Recommended charge current: 0.2–0.5 C
- Discharge current: ≥0.2 A continuous, ≥0.5 A peak
- Operating temp (charge): 0…45 °C (JEITA via BQ21061 TS)
- Storage temp: –20…45 °C

## Pinout (J102 / JST-GH-3)
1: VBAT+ (red)  
2: GND (black)  
3: NTC 10 k (white)

## Notes
- Pack NTC is mandatory for medical-minded design; the charger TS pin reads pack temperature for JEITA-safe charging.
- Harness length: 50–150 mm, strain-relieved.
