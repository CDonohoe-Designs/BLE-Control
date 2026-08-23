# BLE-Control Battery Pack Specification

**Type:** Single-cell Li-ion polymer (3.7 V nominal, 4.2 V maximum)  
**Capacity:** 300–500 mAh (target ~400 mAh)  
**Wires:** 3-wire (VBAT+, GND, 10 kΩ NTC @25 °C, B≈3435)  
**Protection:** Integrated PCM (OVP/UVP/OCP/short-circuit protection)  
**Connector:** JST-GH, 3-pin (Board: BM03B-GHS-TBT; Cable: GHR-03V-S + SSHL-003GA-P0.2)

## Supplier documentation

For a future hardware build, request the applicable cell/pack safety and transport documentation from the battery supplier, together with RoHS/REACH and traceability information.

## Electrical requirements

- Maximum charge voltage: 4.2 V
- Recommended charge current: 0.2–0.5 C
- Discharge current: ≥0.2 A continuous, ≥0.5 A peak
- Operating temperature during charge: 0…45 °C
- Storage temperature: –20…45 °C

## Pinout (J102 / JST-GH-3)

1. VBAT+ (red)
2. GND (black)
3. NTC 10 kΩ (white)

## Notes

- The pack NTC is used by the charger temperature-monitoring input.
- Harness target: 50–150 mm with suitable strain relief.
- Final cell/pack selection, charge rate and protection thresholds must be verified against the chosen battery manufacturer's data.
