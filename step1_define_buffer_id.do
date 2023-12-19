set maxvar 120000
set matsize 11000
*buildingage totalrooms garage_area 
use "buffer30.dta", clear
set more off

drop if year < 1990
keep if dist<=30

egen county_year = group(fips year)
egen month_year = group(month year)

gen points = .
forvalues i =1/300000 {
	qui:replace points = `i'*0.0001 in `i'
}

* 1. buffer
** 1.1 30 km: buildingage totalrooms totalbedrooms noofstories building_area
quietly reg lhprice buildingage noofstories totalrooms totalbedrooms building_area i.month_year i.county_year, robust cluster(importparcelid) 
predict price_resid, residual 

qui lpoly price_resid dist if post == 0, generate(yhat_before) at(points) degree(1) kernal(gaussian) msymbol(oh) msize(small) mcolor(gs10) ciopts(lwidth(medium)) noscatter nograph

qui lpoly price_resid dist if post == 1, generate(yhat_after) at(points) degree(1) kernal(gaussian) msymbol(oh) msize(small) mcolor(gs10) ciopts(lwidth(medium)) noscatter nograph

twoway (line yhat_before points, lcolor(black) lpattern(solid))  (line yhat_after points, lcolor(black) lpattern(dash)), /*
*/ xtitle("Distance from CCUS facilities (in kilometers)", size(small)) ytitle("Log Price Residuals", size(small)) /*
*/ xline(4.2, lpattern(shortdash) lcolor(chocolate)) yline(0, lpattern(dot) lcolor(teal)) legend(order(1 "Before CCUS operation" 2 "After CCUS operation") size(small)) scheme(s1mono)  /*
*/ xlabel(, labsize(small)) ylabel(, labsize(small)) yscale(range(-1 1))  ylabel(-1(1)1)  name(buffer, replace)

graph save "buffer30.gph", replace
graph export "buffer_id.svg", as(svg) name("buffer_id") replace

* not generating buffer for different types of CCUS
set maxvar 120000
set matsize 11000
foreach n in capture storage retrofit new{
clear all 
use "buffer30.dta", clear
set more off

gen new = (retrofit == 0)
keep if `n' == 1
drop if operational < 2000
drop if year < 1990
drop if community10 == 0
keep if dist<=30

egen county_year = group(fips year)
egen month_year = group(month year)

gen points = .
forvalues i =1/3000 {
	qui:replace points = `i'*0.01 in `i'
}

* 1. buffer
** 1.1 30 km
quietly reg lhprice buildingage noofstories totalrooms totalbedrooms building_area i.month_year i.county_year, robust cluster(importparcelid) 
predict price_resid, residual 

qui lpoly price_resid dist if post == 0, generate(yhat_before) at(points) degree(1) kernal(gaussian) msymbol(oh) msize(small) mcolor(gs10) ciopts(lwidth(medium)) noscatter nograph

qui lpoly price_resid dist if post == 1, generate(yhat_after) at(points) degree(1) kernal(gaussian) msymbol(oh) msize(small) mcolor(gs10) ciopts(lwidth(medium)) noscatter nograph

twoway (line yhat_before points, lcolor(black) lpattern(solid))  (line yhat_after points, lcolor(black) lpattern(dash)), /*
*/ xtitle("Distance from CCUS facilities (in kilometers)", size(small)) ytitle("Log Price Residuals", size(small)) /*
*/ xline(4.2, lpattern(shortdash) lcolor(chocolate)) yline(0, lpattern(dot) lcolor(teal)) legend(order(1 "Before CCUS operation" 2 "After CCUS operation") size(small)) scheme(s1mono)  /*
*/ xlabel(, labsize(small)) ylabel(, labsize(small)) yscale(range(-1 1))  ylabel(-1(1)1)  name(`n'CCUS, replace)

graph save "buffer30_AER_`n'.gph", replace
}

*ssc install grc1leg
*grc1leg "buffer_capture_id" "buffer_storage_id" "buffer_retrofit_id" "buffer_new_id", rows(2) legendfrom(buffer_capture_id) scheme(s1mono) saving(buffer_type_id) 
*graph save "buffer_type_id.gph", replace
*graph export "buffer_type_id.svg", as(svg) name("buffer_type_id") replace
