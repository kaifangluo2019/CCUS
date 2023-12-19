set maxvar 120000
set matsize 11000
clear all
use "TRANS_DIST_ASMT_without_remodel.dta", clear
set more off

xtset importparcelid date
egen county_year = group(fips year)
egen month_year = group(month year)
gen dist_m = dist * 1000

* drop pandemic period
drop if date > mdy(3,11,2020)

forval i=200(200)4200 {
local j=`i'-200 
gen byte vicinity_`i'=1 if dist_m <= `i' & dist_m >`j'
replace vicinity_`i'=0 if missing(vicinity_`i')
}
drop post
gen post = 0
replace post = 1 if year >= operational 

forval i=200(200)4200 {
gen  vicinitypost`i'=vicinity_`i'*post 
}   

xtreg lhprice vicinitypost* post buildingage popdens realincomepc i.month_year i.county_year, fe robust cluster(importparcelid)
eststo, title(covid)

esttab using "DID_drop_pandemic.rtf", cells(b(star fmt(4)) p(fmt(4)) se(fmt(4)) ci_l(fmt(4)) ci_u(fmt(4))) starlevels(* 0.05 ** 0.01 *** 0.001) replace drop(*month_y* *county_y*) nogaps line wide r2 noomitted nonumbers noparentheses mtitles

