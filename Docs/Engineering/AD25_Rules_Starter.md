# BLE‑Control — AD25 Rule‑Set (Starter)

This file mirrors the PDF and gives copy‑pasteable steps for Altium Designer 25.

## Stack Manager
* 4‑layer, 0.8 mm; L2 solid GND; outer 1 oz, inner 0.5 oz.
* Add Impedance Profile `RF_50R_CPWG` (Top over L2) with target Z=50 Ω.

## Net Classes
* **RF**: RF_OUT, RF1_FLT, RF1_ANT, π‑match nets.
* **SMPS_HOT**: VLXSMPS, VFBSMPS, VDDSMPS.
* **USB**: USB_DP, USB_DM, USB_VBUS, CC1, CC2.

## Clearances
* Default = 0.15 mm
* RF_Clear = 0.25 mm (assign to RF nets)
* SMPS_HOT → Sensitive (HSE/LSE/RF) = 0.20 mm

## Widths
* Default = 0.15 mm; Power = 0.30–0.50 mm; RF uses Impedance Profile (start W≈0.32 mm, G≈0.20 mm)

## Polygons
* L1 GND pour to CPWG gap 0.20 mm; L2 solid; avoid fills under antenna/crystal.

## Vias
* Min 0.45/0.20 mm; fence via every 1.5–2.0 mm; first near RF feed (<1 mm).

## USB (optional)
* If routed: 22 Ω series near MCU; short symmetric DP/DM; length‑match within 50 mil.

## DFM Checks
* π‑match close; charger caps at pins; EPAD via‑in‑pad; shield R//C near shell; VDDA=VDD with local caps; VDDUSB→VDD.
