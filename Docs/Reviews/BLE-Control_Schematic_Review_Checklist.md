# BLE-Control Wearable: Schematic Review Checklist

Project: **BLE-Control Wearable**  
Classification: **Non-medical wearable / engineering prototype**  
Review Stage: **Schematic Freeze before PCB Layout**  
Tool: **Altium Designer AD25**  
Reviewer:  
Date:  
Revision:  

---

## Scope

BLE-Control is a **non-medical BLE wearable learning project**.

It demonstrates a small embedded wearable design using:

- STM32WB55 BLE microcontroller
- USB-C input and Li-Po charging
- 3.3 V system rail and switched sensor rail
- TMP117 temperature sensor
- BMI270 IMU
- Button and status LED
- SWD programming/debug
- BLE antenna / RF matching
- DFM, DFT and bring-up planning

This design is **not a medical device**, does **not claim clinical accuracy**, and is **not intended for diagnosis, treatment, therapy, or patient monitoring**.

IEC 60601 / IEC 61000 references, if used, are for **design-awareness only**: low-voltage safety thinking, ESD, EMC robustness, and documentation discipline. No compliance or certification claim is made.

---

## Review Decision

- [ ] Approved for PCB layout
- [ ] Approved with minor actions
- [ ] Rework required

---

# 1. Project Documentation

- [x] Project title is correct.
- [x] Sheet titles are correct.
- [x] Sheet numbers are correct.
- [x] Revision is correct.
- [x] Design is clearly described as a non-medical wearable prototype.
- [x] Updated schematic PDF has been exported.

---

# 2. Compile, Net Naming and Schematic Hygiene

- [x] Project compiles with no errors.
- [x] Remaining warnings are understood and documented.
- [x] No duplicate net names.
- [x] No off-grid ports.
- [x] No unintended one-pin nets.
- [x] Power rails use Power Ports.
- [x] Inter-sheet signals use Ports / Off-Sheet Connectors.
- [x] Main power nets are consistent: VIN_CHG, VBAT_PROT, VBATT_RAW, +3V3_SYS, 3V3_SENS.
- [x] Main signal nets are consistent: I2C_SENS_SCL, I2C_SENS_SDA, SENS_EN, BTN1, LED_STAT_N.
- [x] Removed/old nets are gone or clearly marked obsolete.

---

# 3. Power, USB-C and Charger

## Design snapshot

USB-C provides low-voltage input power. The MCP73833 charges a single-cell Li-Po battery. The TPS7A02 generates the always-on +3V3_SYS rail. The TPS22910A generates the switched 3V3_SENS rail.

## Checks

- [x] USB-C connector pinout is checked.
- [x] CC1 and CC2 have correct Rd pull-downs.
- [x] USB-C VBUS has input protection: TVS, PPTC/fuse, and filtering as required.
- [x] USB_VBUS and VIN_CHG are clearly separated.
- [x] MCP73833 input connects to VIN_CHG.
- [x] MCP73833 battery output connects to VBAT_PROT.
- [x] MCP73833 charge-current setting is documented.
- [x] MCP73833 THERM connection is defined.
- [x] MCP73833 STAT/PG outputs are test/debug only unless level-shifted.
- [x] Battery connector polarity and net naming are clear.
- [x] Reverse-protection PFET path is checked.
- [x] TPS7A02 input/output/enable connections are correct.
- [x] No unintended short exists between VIN_CHG, VBAT_PROT, and +3V3_SYS.
- [x] Power test points exist for bring-up.

---

# 4. MCU, Clocks and Debug

## Design snapshot

STM32WB55 provides BLE, USB FS, I2C sensor control, GPIO, debug and system control.

## Checks

- [x] All MCU power pins connect to the correct rail.
- [x] MCU decoupling is present on each supply domain.
- [x] Bulk capacitance is present near the MCU.
- [x] VBAT pin treatment is intentional and safe.
- [x] HSE/LSE crystal circuits are checked.
- [x] NRST circuit has defined reset behaviour.
- [x] BOOT0 has a defined default state.
- [x] SWDIO, SWCLK, NRST, VTREF and GND are connected to the debug connector.
- [x] SWD/Tag-Connect is documented as service/debug only.
- [x] Unused MCU pins are documented or handled in firmware.

---

# 5. Sensor Power and I2C Bus

## Design snapshot

Sensors are powered from a switched 3V3_SENS rail. The sensor rail is enabled by SENS_EN. TMP117 and BMI270 share the I2C_SENS_SCL / I2C_SENS_SDA bus.

## Checks

- [x] TPS22910A input is +3V3_SYS.
- [x] TPS22910A output is 3V3_SENS.
- [x] SENS_EN has a defined default state.
- [x] Sensors remain off during MCU reset unless intentionally enabled.
- [x] 3V3_SENS has suitable local capacitance.
- [x] I2C pull-ups connect to 3V3_SENS, not +3V3_SYS.
- [x] I2C sheet ports are bidirectional.
- [x] Series resistors are included near the MCU if used.
- [x] I2C bus can be verified with a firmware scan.

---

# 6. TMP117 Temperature Sensor

## Design snapshot

TMP117 is used as an engineering temperature sensor on the switched sensor rail.

## Checks

- [x] TMP117 V+ connects to 3V3_SENS.
- [x] TMP117 SCL/SDA connect to the sensor I2C bus.
- [x] TMP117 address strap is defined.
- [x] Decoupling capacitor is present.

---

# 7. BMI270 IMU

## Design snapshot

BMI270 is used as an engineering motion/IMU sensor on the switched sensor rail.

## Checks

- [x] BMI270 VDD and VDDIO connect to 3V3_SENS.
- [x] BMI270 SCL/SDA pins connect to the sensor I2C bus.
- [x] I2C mode strap pins are defined.
- [x] I2C address strap is defined.
- [x] Decoupling capacitors are present.
---

# 8. Button and LED

## Design snapshot

The board has one user button and one status LED for basic interaction and bring-up.

## Checks

- [x] Button net is clearly named.
- [x] Button has a defined default state.
- [x] Button pull-up/pull-down is on the correct rail.
- [x] Button has series resistance, filtering, and ESD protection if user-accessible.
- [x] LED net is clearly named.
- [x] LED current-limit resistor is fitted.
- [x] LED polarity and active state are documented.
- [x] Button and LED can be tested in firmware.

---

# 9. BLE RF Section

## Design snapshot

STM32WB55 RF output feeds an RF matching/filter/ESD path and 2.4 GHz BLE antenna.

## Checks

- [x] RF pin connects to the matching network.
- [x] Pi-match / tuning footprints are present.
- [x] RF filter footprint is correct.
- [x] RF ESD footprint is included.
- [x] Antenna part number and footprint are correct.
- [x] Antenna keepout is documented.
- [x] 50 ohm CPWG requirement is documented.
- [x] Solid L2 GND under RF path is planned.
- [x] RF via stitching / via fence is planned.
- [x] RF match parts are marked DNP/tuneable if required.
---

# 10. DFT / Bring-Up Access

- [x] GND test point exists.
- [x] VIN_CHG test point exists.
- [x] VBAT_PROT test point exists.
- [x] +3V3_SYS test point exists.
- [x] 3V3_SENS test point exists.
- [x] Charger status test points exist.
- [x] SWD programming access exists.
- [x] I2C bus can be probed or verified in firmware.
- [x] Button and LED can be tested in firmware.
- [x] BLE advertising can be tested after programming.
- [x] Test points are accessible and outside antenna keepout.

---

# 11. BOM, Libraries and Footprints

- [x] Every schematic symbol has a footprint.
- [x] Main IC footprints match exact packages.
- [x] USB-C connector footprint matches the selected part.
- [x] Battery connector footprint matches the selected part.
- [x] SWD/Tag-Connect footprint is correct.
- [x] Antenna footprint matches datasheet.
- [x] Passive package sizes are practical for assembly.
- [x] DNP/tuning parts are clearly marked.
- [x] Manufacturer part numbers are added where useful.
---
# 12. Ready for PCB Layout

- [x] Schematic compiles cleanly.
- [x] Schematic checklist is complete.
- [x] Updated schematic PDF is exported.
- [x] Placement strategy is defined.
- [x] RF keepout strategy is defined.
- [x] Test access strategy is defined.
- [x] Ready to update PCB from schematic.
- [x] Ready to begin placement review.
---

# Sign-Off

Reviewer:  Caoilte Donohoe

Decision:

- [x] Approved for PCB layout
- [ ] Approved with minor actions
- [ ] Rework required

