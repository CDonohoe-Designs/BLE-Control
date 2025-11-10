# BLE-Control — BOM Datasheet Links (Major Components)

Below are manufacturer datasheets (and official product pages where helpful) grouped by schematic section.

---

## MCU-RF

- **MCU — STM32WB55CGU6 (ST)**  
  Datasheet: https://www.st.com/resource/en/datasheet/stm32wb55cc.pdf  
  Product page: https://www.st.com/en/microcontrollers-microprocessors/stm32wb55cg.html

- **On-chip SMPS Inductor — LQM21FN100M70L (Murata, 10 µH, 0805)**  
  Product page: https://www.murata.com/en-us/products/productdetail?partno=LQM21FN100M70L

- **SMPS helper inductor — LQW15AN10NG00D (Murata, 10 nH, 0402)**  
  Product page: https://www.murata.com/en-us/products/productdetail?partno=LQW15AN10NG00D

- **2.4 GHz Chip Antenna — 2450AT18A100 (Johanson Technology)**  
  Datasheet: https://www.johansontechnology.com/docs/1129/2450AT18A100E-AEC_tCZ7Fpd.pdf

- **u.FL RF test jack — U.FL-R-SMT-1(10) (Hirose)**  
  Series catalog: https://www.hirose.com/en/product/document?clcode=&documentid=ed_U.FL_CAT&documenttype=Catalog&lang=en&productname=&series=U.FL

- **RF ESD diode — PESD5V0S1UL (Nexperia, SOD882)**  
  Datasheet: https://assets.nexperia.com/documents/data-sheet/PESD5V0S1UL.pdf

- **HSE crystal — NX3225SA-32MHz-STD-CSR-3 (NDK 3.2×2.5 mm)**  
  Series datasheet: https://www.ndk.com/images/products/catalog/c_NX3225SA_e.pdf

- **LSE crystal — ABS07-32.768KHZ-7-T (Abracon 3.2×1.5 mm)**  
  Product page: https://abracon.com/parametric/crystals/ABS07-32.768KHZ-7-T  
  Datasheet: https://abracon.com/Resonators/ABS07.pdf

- **Tag-Connect SWD — TC2030-NL**  
  Product page: https://www.tag-connect.com/product/tc2030-nl

---

## Power_Charge_USB

- **1-cell Li-ion charger — BQ21062YFPR (TI)**  
  Product page / docs: https://www.ti.com/product/BQ21062

- **Reverse-battery P-MOSFET — SSM3J332R,LF (Toshiba) (alt: DMG2305UX-13, Diodes Inc.)**  
  Toshiba datasheet: https://toshiba.semicon-storage.com/info/docget.jsp?did=16305  
  Diodes Inc. datasheet (alt): https://www.diodes.com/assets/Datasheets/DMG2305UX.pdf

- **USB-C receptacle — USB4105-GF-A (GCT)**  
  Datasheet: https://gct.co/files/specs/usb4105-spec.pdf  
  Product page: https://gct.co/connector/usb4105

- **USB ESD array — USBLC6-2SC6 (ST)**  
  Datasheet: https://www.st.com/resource/en/datasheet/usblc6-2sc6y.pdf  
  Product page: https://estore.st.com/en/products/protections-and-emi-filters/esd-protection/general-purpose-esd-protection/usblc6-2.html

- **USB common-mode choke — ACM2012D-900-2P-T00 (TDK)**  
  Product page: https://product.tdk.com/en/search/emc/emc/cmf_cmc/info?part_no=ACM2012D-900-2P-T00

- **VBUS TVS — SMF5.0A (Littelfuse, SOD-123FL)**  
  Product page: https://www.littelfuse.com/products/overvoltage-protection/tvs-diodes/surface-mount/smf/smf5-0a

- **Polyfuse — MF-MSMF050/16 (Bourns, 1206)**  
  Series datasheet: https://www.bourns.com/docs/product-datasheets/mf-msmf.pdf

- **JST Li-Po connector — BM02B-GHS-TBT (GH series, 1.25 mm)**  
  GH series catalog: https://www.jst-mfg.com/product/pdf/eng/eGH.pdf

- **Charger NTC — NCP15XH103F03RC (Murata 10 k, 0402)**  
  Product page: https://www.murata.com/en-eu/products/productdetail?partno=NCP15XH103F03RC

---

## Sensor

- **6-axis IMU — BMI270 (Bosch Sensortec)**  
  Product page (docs): https://www.bosch-sensortec.com/products/motion-sensors/imus/bmi270/

- **Environmental sensor options**  
  – **BME280 (Bosch)** datasheet: https://www.bosch-sensortec.com/media/boschsensortec/downloads/datasheets/bst-bme280-ds002.pdf  
  – **SHTC3 (Sensirion)** datasheet: https://sensirion.com/media/documents/33C9B43E/637C3B76/Sensirion_Datasheet_SHTC3.pdf  
  – **LPS22HHTR (ST, barometer)** datasheet: https://www.st.com/resource/en/datasheet/lps22hh.pdf

---

## Sensor — Skin Temperature (Digital)

- **TMP117x (TI, ±0.1 °C)**  
  Product page / datasheet: https://www.ti.com/product/TMP117

- **Variant — MAX30208 (Analog Devices / Maxim, ±0.1 °C)**  
  Product page / datasheet: https://www.analog.com/en/products/max30208.html

---

## IO_Buttons_LED

- **Green LED — 19-217/GHC-YR1S2/3T (Everlight, 0603/1608)**  
  Datasheet: https://www.mouser.com/datasheet/2/143/19-217-GHC-YR1S2-3T-1663276.pdf

- **Tact switch — KMR221GLFS (C&K)**  
  Product page / datasheet: https://www.ckswitches.com/products/switches/product-details/Tactile/KMR/#

---

## Key Application Notes & Guides

- **ST AN6044 — Ultralow power system design guidelines & STEVAL-ASTRA1B power management characterization**  
  PDF: https://www.st.com/resource/en/application_note/an6044-ultralow-power-system-design-guidelines-and-stevalastra1b-power-management-characterization-stmicroelectronics.pdf

- **ST AN5156 — Introduction to security for STM32 MCUs**  
  PDF: https://www.st.com/resource/en/application_note/an5156-introduction-to-security-for-stm32-mcus-stmicroelectronics.pdf

- **BQ21061EVM — Evaluation Module User’s Guide (TI)**  
  Official PDF: https://www.ti.com/lit/ug/sluuc59/sluuc59.pdf  
  **Repo copy (your Docs/Datasheets):** https://github.com/CDonohoe-Designs/BLE-Control/blob/main/Docs/Datasheets/BQ21061EVM%20Evaluation%20Module%20User's%20Guide.pdf

