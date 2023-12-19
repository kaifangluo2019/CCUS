clear all
global path "C:\phd4\CCUS\data"
cd $path
use "TRANS_DIST_ASMT_without_remodel.dta", clear
set more off

bys sitenum: gen n = _n
keep if n == 1
tab sitenum, m
tab operational, m
keep sitenum facility_lat facility_lon
export delimited using $path\site4mapping, delimiter(",") replace

clear all
global path "C:\phd4\CCUS\data"
cd $path
use "TRANS_DIST_ASMT_without_remodel.dta", clear
set more off

sum dist
sort importparcelid transid
duplicates drop importparcelid, force
keep if dist <= 4.2
keep importparcelid latitude longitude

export delimited using $path\treatment, delimiter(",") replace

clear all
global path "C:\phd4\CCUS\data"
cd $path
use "TRANS_DIST_ASMT_without_remodel.dta", clear
set more off

sum dist
sort importparcelid transid
duplicates drop importparcelid, force
keep if dist > 4.2
keep importparcelid latitude longitude

export delimited using $path\control, delimiter(",") replace

* mapping for DDD
clear all
global path "C:\phd4\CCUS\data"
cd $path
use basin_houses_repeated.dta, clear
set more off

keep if statename == "IL" | statename == "KY" | statename == "WI"
gen housetype = "unselected" if _ID == .
replace housetype = "basin_c" if km_to_fakeid <= 50 
replace housetype = "basin_t" if _ID != .
replace housetype = "ccus_c" if dist <= 30
replace housetype = "ccus_t" if dist <= 4.2
drop if housetype == "unselected"
tab statename housetype

export delimited using basin_control_repeated_map if housetype == "basin_c", delimiter(",") replace
export delimited using basin_treat_repeated_map if housetype == "basin_t", delimiter(",") replace
export delimited using ccus_control_repeated_map if housetype == "ccus_c", delimiter(",") replace
export delimited using ccus_treat_repeated_map if housetype == "ccus_t", delimiter(",") replace
