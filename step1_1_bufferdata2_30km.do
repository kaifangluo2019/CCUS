set maxvar 100000
set matsize 11000
* We include 31 states that based on rough observation, possibly have houses locating within 30 km distance of a CCUS project. Their stfips are 01 04 05 08 12 13 16 17 18 19 20 21 22 26 28 29 30 31 35 38 39 40 42 46 47 48 49 51 54 55 56.

* It turns out 9 of them do not have any houses in a closer distance than 30 km from a CCUS project. Their stfips are 05 13 16 19 30 31 46 49 51.

* Listed below are 21 states that have and only have one CCUS project within 30 km. Actually four houses of stfips_04 also located within 30 km, but only one house is surrounded by only one CCUS (the other three are surrounded by three CCUS projects within 30 km distance). One obs is insufficient for analyzing, so, we exclude stips_04, leaving 21 states for buffer investigation. We will include stfips_04 when examining our main model.

foreach n in 01 08 12 17 18 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
*** 2.1.4 keep properties that have CCUS within 30 km
use "buffer_`n'.dta", clear
gen v30 = (dist <= 30)
bys transid: egen sum30 = sum(v30)  
keep if sum30>=1
drop v30 sum30 

** merge with site info
merge m:1 sitenum using site_info
keep if _merge == 3
drop _merge

** 2.2 properties with at least one sale after the operation of CCUS
gen post = 0
replace post = 1 if year >= operational 
bys importparcelid: egen sumpost = sum(post)
drop if sumpost < 1
drop sumpost

** 2.3 keep properties that have only one CCUS within 30 km after the operation of CCUS
gen v30 = (dist <= 30)
bys transid: egen sum30 = sum(v30)  
keep if sum30 == 1 & v30 == 1
drop v30 sum30

* merge TRANS-DIST data with ASMT data
merge m:m importparcelid using asmt`n'
keep if _merge == 3
drop _merge

destring infozip, replace
destring asmtzip, replace
gen geozip = infozip
replace geozip = asmtzip if infozip == .
gen str5 zipcode = string(geozip,"%05.0f")
tab state if missing(zipcode)

destring pricefips, replace
gen geofips = pricefips
foreach f in infofips asmtfips{
destring `f', replace
replace geofips = `f' if geofips == .
}
gen str5 fips = string(geofips,"%05.0f")
tab state if missing(fips)
drop infozip asmtzip pricefips infofips asmtfips

save buffer30_`n'.dta, replace
}

