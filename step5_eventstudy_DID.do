clear all
global path "C:\phd4\CCUS"
cd "$path"
adopath + "$path\"
use "TRANS_DIST_ASMT_without_remodel.dta", clear
set more off

sum dist
global building buildingage noofstories totalbedrooms building_area  
global demographic realincome popdens 
global control fed elecp gas pm25 happening

xtset importparcelid date
gen treat =0
replace treat =1 if dist <= 4.2
gen D = treat * post    
tab treat

* event study (IW estimator)
gen ry = year - operational
gen never_op = (treat==0)
tab ry
drop if ry>5 | ry<-5

forvalues k = 5(-1)2 {
gen pre_`k' = ry == -`k'
}
gen current = ry == 0

forvalues k = 1/5 {
gen post_`k' = ry == `k'
}

egen county_year = group(fips year)

eventstudyinteract lhprice pre_* current post_*, cohort(operational) control_cohort(never_op) covariates(est $building $demographic $control) absorb(i.importparcelid i.county_year) vce(cluster importparcelid)


matrix C = e(b_iw)
mata st_matrix("A",sqrt(st_matrix("e(V_iw)")))
matrix C = C \ A
matrix list C

matrix input CC = (-1.2161427  -.23887332  -.06731889  -.00009982   0   .01237839  .24213384  .12074427  -.01533733  .03236618  .19208505 \ .74517015   .25026866   .07645373   .07375022   0   .11288019   .12038265   .07249949   .10097634   .11563226   .07205371)

matrix list CC

coefplot matrix(CC[1]), se(CC[2]) baselevels ///
vertical ///转置图形
yline(0,lcolor(olive)) ///include line y=0
ylabel(-2(1)1) ///
xline(5, lwidth(vthin) lpattern(shortdash) lcolor(teal)) ///
ylabel(,labsize(vsmall)) xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "1" 8 "2" 9 "3" 10 "4" 11 "5", labsize(vsmall)) ///
ytitle("Impact of CCUS Projects put into operation", size(small)) ///
xtitle("Relative Year between housing transaction and CCUS put into operation", size(small)) ///
addplot(line @b @at, color(maroon)) ///add line
ciopts(recast(rarea) color(gs5%80*.2) lwidth(none)) ///
msymbol(diamond_hollow) mlcolor(maroon) msize(medium) ///
scheme(s1mono) legend(size(vsmall) order(2 "Point Estimate" 1 "95% CI"))

graph save "$path\results\event.gph", replace
