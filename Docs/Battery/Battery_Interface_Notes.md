# Battery Interface Notes

- TS (BQ21061) wired to pack NTC via 0 Ω link; optional TS emulator pads (100 k/100 k) DNP.
- CE, LP, MR default pulls to +3V3_SYS (100 k).
- LSLDO remains a distinct output; ≥2.2 µF close to pin; not tied to +3V3_SYS.
- Test points: TP_VBAT, TP_BAT_NTC, TP_3V3, TP_CE, TP_INT.
