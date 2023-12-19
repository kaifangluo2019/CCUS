set maxvar 120000
set matsize 11000

foreach n in 01 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
use "trans`n'.dta", clear

* obtain coordinates of CCUS facilities
merge m:1 state using site_coor
keep if _merge ==3
drop _merge
drop facility_latitudesite18 facility_longitudesite18 facility_latitudesite25 facility_longitudesite25

* convert to desired data pattern--one transid with all sites coor
reshape long facility_latitude facility_longitude, i(transid) j(sitenum) string

* calculate distance between houses and each CCUS facilities
geodist latitude longitude facility_latitude facility_longitude, gen(dist)

merge m:1 sitenum using site_info
keep if _merge == 3
drop _merge
replace industry = "" if industry == "N/A"

gen post = 0
replace post = 1 if year >= operational 

save trans_dist_info_`n'.dta, replace

* for each house, keep the minimum distance
collapse (min)dist, by(transid) 

* merge house pricing data with the minimum distance data
merge 1:m transid dist using trans_dist_info_`n'
keep if _merge == 3
drop _merge
save TRANS_DIST`n'.dta, replace
}


