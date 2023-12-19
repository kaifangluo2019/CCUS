set maxvar 120000
set matsize 11000
forvalues n = 10(10)50{
use "TRANS_DIST_ASMT_all.dta", clear 

gen new = (retrofit == 0)
drop if dist>`n'
drop if operational <2000
drop if year < 1990

drop if community10 == 0

replace noofstories = round(noofstories)
replace building_area = . if building_area < 0

* repeated sales sample without remodel after 2000
tab state if yearremodeled > 2000 & yearremodeled != ., missing
drop if yearremodeled > 2000 & yearremodeled != .

bys importparcelid: gen repeatsale = _N
bys importparcelid: egen sumpost = sum(post)
order importparcelid repeatsale sumpost post
keep if repeatsale>1 & (repeatsale > sumpost)

replace geozip = 60002 if transid == 385058335
replace geozip = 60096 if transid == 453920792
replace geozip = 60096 if transid == 528902306
replace geozip = 62522 if transid == 416042855
replace geozip = 62521 if transid == 387687420
replace geozip = 62521 if transid == 378135437
replace geozip = 62521 if transid == 386380271
replace geozip = 62535 if transid == 426955552
replace geozip = 62526 if transid == 386380273
replace geozip = 53140 if transid == 538903672
drop zipcode
gen str5 zipcode = string(geozip,"%05.0f")

xtset importparcelid date
egen county_year = group(fips year)
egen month_year = group(month year)
gen dist_m = dist * 1000

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

xtreg lhprice vicinitypost* post buildingage popdens personincome i.month_year i.county_year, fe robust cluster(importparcelid)
est store distancebin
eststo, title(`n' km)

}

esttab using "DID_separate4200m_robustness_check.rtf", b se r2 star(* 0.05 ** 0.01 *** 0.001) replace b(%9.4f) se(%9.4f) long nogap noomit mtitles drop(*month_y* *county_y* *year*)
*esttab using "DID_separate4200m_40_50km.rtf", cells(b(star fmt(4)) p(fmt(3)) se(fmt(4)) ci_l(fmt(4)) ci_u(fmt(4))) starlevels(* 0.05 ** 0.01 *** 0.001) replace drop(*month_y* *county_y*) nogaps line wide r2 noomitted nonumbers noparentheses mtitles

*coefplot distancebin, xlabel(1 "0.8" 2 "1" 3 "1.2" 4 "1.4" 5 "1.6" 6 "1.8" 7 "2" 8 "2.2" 9 "2.4" 10 "2.6" 11 "2.8" 12 "3" 13 "3.2" 14 "3.4" 15 "3.6" 16 "3.8" 17 "4" 18 "4.2", labsize(small)) ylabel(, labsize(small)) vertical recast(scatter, msymbol(Oh) mcolor(dkorange) msize(large) mlwidth(thick)) cirecast(rcap, color(olive) lpattern(solid) lwidth(thick)) ytitle("Housing price %", size(medsmall)) xtitle("Distance bin (in kilometers)", size(medmall)) keep (vicinitypost*) yline(0, lpattern(shortdash) lcolor(gs10)) legend(size(vsmall) order(2 "Point estimates" 1 "90% CI")) scheme(s1mono) name(bin, replace)