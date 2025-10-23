#!/usr/bin/env bash
set -e
echo "This script assumes you're in the repo root (BLE-Control)."
mkdir -p Hardware/Altium/{Schematic,PCB,Libraries/{Schematic,PCB,DBLib,Database,3D/Models,Rules},BOM,Draftsman,Outputs/{PDFs,Gerbers,Drill,ODB++,IPC-2581,PickPlace,Assembly},Releases,OutputJobs,Variants}
touch Hardware/Altium/Libraries/3D/Models/.gitkeep
