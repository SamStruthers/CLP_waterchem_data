This folder contains metadata associated with the chemistry data in the raw and cleaned folders. Burn severity used in the files `sbs_buffer.csv` `sbs_watershed.csv`, was calculated using BAER derived soil burn severity available from <https://www.mtbs.gov/viewer/index.html>. Soil burn severity (sbs) buffer calculations were only preformed for reservoir sites while soil burn severity watershed calculations were preformed all sites in a reservoir system (inflow, outflow or reservoir).

Burn status in `location_metadata.csv` was done in a categorical manner with the following criteria:

-   Unburned: There was no burn in the watershed from the Cameron Peak Fire

-   Partially Burned: There was some portion of burn in the watershed from the Cameron Peak Fire but the majority of the watershed was unburned. All Cache la Poudre mainstem sites in this this dataset were categorized as partially burned.

-   Burned: The majority of the watershed burned in the Cameron Peak Fire.


Distance from the Canyon Mouth (PBD) site was calculated using NHDplusTools by Katie Willi and stored in `distance_from_pbd.csv`

RMRS procedures and units for water sample data are listed in `rmrs_procedures.png` and `water_chemistry_units.xlsx`