set maxvar 100000
set matsize 11000

foreach n in 01 04 08 12 17 18 20 21 22 26 28 29 35 38 39 40 42 47 48 54 55 56{

use TRANS_DIST`n'.dta, clear
merge m:m importparcelid using asmt`n'
keep if _merge == 3
drop _merge

destring infozip, replace
destring asmtzip, replace
gen geozip = infozip
tab state if missing(geozip)
replace geozip = asmtzip if infozip==.
tab state if missing(geozip)
gen str5 zipcode = string(geozip,"%05.0f")

destring pricefips, replace
gen geofips = pricefips
tab state if missing(geofips)
foreach f in infofips asmtfips{
destring `f', replace
replace geofips = `f' if geofips == .
}
tab state if missing(geofips)
gen str5 fips = string(geofips,"%05.0f")
drop infozip asmtzip pricefips infofips asmtfips

* some number of stories have digits
replace noofstories = round(noofstories)

save housing_site_dist_info_`n'.dta, replace
}
