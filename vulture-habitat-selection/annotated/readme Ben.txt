This annotated dataset comes from the Environmental Data Automated Track Annotation System (Env-DATA) on Movebank (movebank.org). The environmental data attributes are created and distributed by government and research organizations. For general information on the Env-DATA System, see Dodge et al. (2013) and movebank.org/node/6607.

Terms of Use: Verify the terms of use for relevant tracking data and environmental datasets prior to presenting or publishing these data. Terms of use for animal movement data in Movebank are defined by the study owners in the License Terms for the study. Terms of use for environmental datasets vary by provider; see below for details. When using these results in presentations or publications, acknowledge the use of Env-DATA and Movebank and cite Dodge et al. (2013). Sample acknowledgement: "[source product/variable] values were annotated using the Env-DATA System on Movebank (movebank.org)." Please send copies of published work to support@movebank.org.

Contact: support@movebank.org. Include the access key below with questions about this request.

---------------------------

Annotated data for the following Movebank entities are contained in this file:
Movebank study name: step selection ben
Annotated Animal IDs: CV6_44782, CV5__44780, CV4__53229, CV3__53230, CV1__44780
Requested on Thu Jan 31 18:06:54 CET 2019
Access key: 6364509529843526993
Requested by: Adam Kane

---------------------------

File attributes

Attributes from the Movebank database (see the Movebank Attribute Dictionary at http://www.movebank.org/node/2381):
Location Lat: latitude in decimal degrees, WGS84 reference system
Location Long: longitude in decimal degrees, WGS84 reference system
Timestamp: the time of the animal location estimates, in UTC
Update Ts

Locations are the the geographic coordinates of locations along an animal track as estimated by the processed sensor data.


---------------------------

Attributes from annotated environmental data:
Name: MODIS Land VCF 250m Yearly Terra Percent Non-Tree Vegetation
Description: Percent of land surface in pixel that is covered by non-tree vegetation. This is calculated as the percent tree cover minus the percent unvegetated.
Unit: percent
No data values: 200, 253 (provider), NaN (interpolated)
Interpolation: inverse-distance-weighted

Name: Movebank Orographic Uplift (from ASTER DEM and NARR)
Description: The velocity of upward air movement caused when rising terrain forces air to higher elevations. Calculated using elevations from the ASTER ASTGTM2 30-m DEM and weather data from the NCEP North American Regional Reanalysis.
Unit: m/s
No data values: NaN (interpolated)
Interpolation: nearest-neighbour

---------------------------

Environmental data services

Service: MODIS Land/Vegetation Continuous Fields 250-m Yearly Terra (MOD44B V6)
Provider: NASA Land Processes Distributed Active Archive Center
Datum: N/A
Projection: N/A
Spatial granularity: 250 m
Spatial range (long x lat): E: 180.0    W: -180.0 x N: 90    S: -90
Temporal granularity: yearly
Temporal range: 2000 – current
Source link: https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mod44b_v006
Terms of use: https://lpdaac.usgs.gov/citing_our_data
Related websites:
https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mod44b_v006
https://lpdaac.usgs.gov/sites/default/files/public/product_documentation/mod44b_user_guide_v6.pdf
https://lpdaac.usgs.gov/sites/default/files/public/product_documentation/mod44b_atbd.pdf
https://landval.gsfc.nasa.gov/ProductStatus.php?ProductID=MOD44
https://lpdaac.usgs.gov/sites/default/files/public/modis/docs/MODIS_LP_QA_Tutorial-1.pdf

Service: Movebank Derived Variables/derived from weather and elevation data
Provider: Movebank
Datum: N/A
Projection: N/A
Spatial granularity: 0.3 degrees
Spatial range (long x lat): W: -49.4    W: -152.9 x N: 57.3    N: 12.2
Temporal granularity: 3 hourly
Temporal range: 1979-01-01 to previous year
Source link: http://www.bioinfo.mpg.de/orn-gateway/variables.jsp?typeName=movebank-derived/orographic-uplift
Terms of use: https://www.movebank.org/node/8770#use
Related websites:
https://www.movebank.org/node/8770
http://www.ecmwf.int/en/research/climate-reanalysis/era-interim
https://lpdaac.usgs.gov/dataset_discovery/aster/aster_products_table/astgtm_v002
http://www.esrl.noaa.gov/psd/data/gridded/data.narr.html
http://srtm.csi.cgiar.org/

---------------------------

Dodge S, Bohrer G, Weinzierl R, Davidson SC, Kays R, Douglas D, Cruz S, Han J, Brandes D, Wikelski M (2013) The Environmental-Data Automated Track Annotation (Env-DATA) System: linking animal tracks with environmental data. Movement Ecology 1:3. doi:10.1186/2051-3933-1-3

Development and maintenance of Env-DATA is funded by the Max Planck Society, and has been supported by US National Science Foundation Biological Infrastructure award 1564380, NASA ABoVE project NNX15AT91A, and NASA Earth Science Division, Ecological Forecasting Program Project NNX11AP61G.