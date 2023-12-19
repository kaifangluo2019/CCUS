set maxvar 120000
set matsize 11000

clear all
use TRANS_DIST_ASMT_without_remodel.dta, clear

xtset importparcelid date
egen zip_year = group(zipcode year)
egen county_year = group(fips year)
egen month_year = group(month year)
gen dist_m = dist * 1000

forval i=200(200)4200 {
local j=`i'-200 
gen byte vicinity_`i'=1 if dist_m <= `i' & dist_m >`j'
replace vicinity_`i'=0 if missing(vicinity_`i')
tab vicinity_`i'
}

forval i=200(200)4200 {
gen  vicinitypost`i'=vicinity_`i'*post 
}   


xtreg lhprice vicinitypost* post buildingage i.month i.year, fe robust cluster(importparcelid) 
eststo, title(year FE)

xtreg lhprice vicinitypost* post buildingage i.month_year i.county_year, fe robust cluster(importparcelid) 
eststo, title(county_year FE)

xtreg lhprice vicinitypost* post buildingage popdens personincome i.month_year i.county_year, fe robust cluster(importparcelid) 
eststo, title(covariates)

xtreg lhprice vicinitypost* post buildingage popdens personincome pm25 est i.month_year i.county_year, fe robust cluster(importparcelid) 
eststo, title(covariates)

*esttab using "DID30_200m_county_y_newrepeat.rtf" , b se r2 star(* 0.05 ** 0.01 *** 0.001) replace b(%9.4f) se(%9.4f) long nogap noomit mtitles drop(*month* *county_y* *year*) 

esttab using "DID_200m_county_y_newrepeat_detail.rtf", cells(b(star fmt(4)) p(fmt(3)) se(fmt(4)) ci_l(fmt(4)) ci_u(fmt(4))) starlevels(* 0.05 ** 0.01 *** 0.001) replace drop(*month_y* *county_y*) nogaps line wide r2 noomitted nonumbers noparentheses mtitles

