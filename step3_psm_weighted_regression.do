clear all
global path "C:\phd4\CCUS"
cd "$path\data"
adopath + "$path\"
use "TRANS_DIST_ASMT_without_remodel.dta", clear
set more off

drop treat
gen treat =0
replace treat =1 if dist <= 4.2
*psestimate treat, totry(yearbuilt buildingage noofstories totalrooms totalbedrooms building_area landassessedvalue est) noquad

foreach n in buildingage totalrooms totalbedrooms noofstories building_area{
drop if missing(`n')
}

bys fips year: gen n = _N
bys fips year: egen sumtreat = sum(treat)
tab sumtreat
keep if sumtreat > 1
tab n
drop if sumtreat > n/2
drop treat sumtreat n
egen county_year=group(fips year)
tab county_year

save "$path\results\psm_county_year_without_remodel.dta", replace

clear all
global path "C:\phd4\CCUS\results"
cd "$path"
adopath + "$path\"
use "psm_county_year_without_remodel.dta", clear
set more off

gen matched=.
gen newtreated = .
gen newsupport = .
gen newpscore = .
gen newweight = .

global ylist lhprice
global xlist buildingage totalrooms totalbedrooms noofstories building_area

forvalues f = 1/48{

gen treat =0
replace treat =1 if dist <= 4.2

psmatch2 treat $xlist if county_year == `f', neighbor(1) logit ate common out(lhprice)
*pstest $xlist if county_year == `f', both
replace matched=1 if _weight!=.
replace newtreated = _treated if newtreated == .
replace newsupport = _support if newsupport == .
replace newpscore = _pscore if newpscore == .
replace newweight = _weight if newweight == .
drop _pscore _treated _support _weight _lhprice _id _n1 _nn _pdif treat
}

tab stfips, missing
save psm_figure_without_remodel.dta, replace

use psm_figure_without_remodel.dta, clear
tabstat $xlist if matched != 1, stat(n mean sd min max) format(%9.1f) column(stat)
keep if matched == 1
tabstat $xlist, stat(n mean sd min max) format(%9.1f) column(stat)
save psm4DID_without_remodel.dta, replace

foreach f in 21 39 54{
use psm_figure_without_remodel.dta, clear
gen treat =0
replace treat =1 if dist <= 4.2

keep if stfips == `f'
psgraph, treated(newtreated) support(newsupport) pscore(newpscore) subtitle("`f'") name(matching_`f', replace) 

twoway(kdensity newpscore if treat==1, lp(solid) lw(*2.5))     ///
(kdensity newpscore if treat==0, lp(dash) lw(*2.5)),      ///
 ylabel(,angle(0))          ///
 ytitle("") xtitle("Before matching")          ///
 xscale(titlegap(2))               ///
 legend(order(1 "Treatment" 2 "Control"))                 ///
 scheme(s1mono) name(st`f'_1, replace)

 
replace treat=. if matched==.
* after matching
twoway(kdensity newpscore if treat==1, lp(solid) lw(*2.5))     ///
(kdensity newpscore if treat==0, lp(dash) lw(*2.5)),      ///
 ylabel(,angle(0))          ///
 ytitle("") xtitle("After matching")          ///
 xscale(titlegap(2))               ///
 legend(order(1 "Treatment" 2 "Control"))                 ///
 scheme(s1mono) name(st`f'_2, replace)

grc1leg st`f'_1 st`f'_2, cols(2) subtitle("`f'") legendfrom(st`f'_1) scheme(s1mono) name(compare`f', replace)
}

grc1leg matching_21 matching_39 matching_54, legendfrom(matching_21) note("Graph by State") 
graph save "psm_without_remodel.gph", replace

grc1leg compare21 compare39 compare54, cols(1) legendfrom(compare21) note("Graph by state") 
graph save "compare_without_remodel.gph", replace

clear all
global path "C:\phd4\CCUS\results"
cd "$path"
adopath + "$path\"
use psm4DID_without_remodel.dta, clear
set more off

global xlist buildingage totalrooms totalbedrooms noofstories building_area

drop county_year
encode sitenum, gen(siteno)
egen county_year = group(fips year)
egen month_year = group(month year)
drop post
gen post = 0
replace post = 1 if year >= operational 
gen treat =0
replace treat =1 if dist <= 4.2
gen D = treat * post    

* common support sample
reg lhprice D est $xlist i.siteno i.county_year i.month_year if newsupport ==1
eststo, title(All, support)
* use sampling weights
gen weight = newweight *2
replace weight =1 if treat==1 & newweight !=.
reg lhprice D est $xlist i.siteno i.county_year i.month_year [pweight = 1/weight] 
eststo, title(All)

foreach n in capture storage retrofit new{
reg lhprice D est $xlist i.siteno i.county_year i.month_year [pweight=1/weight] if `n' == 1
eststo, title(`n')
}

foreach r in retrofit new{
reg lhprice D est $xlist i.siteno i.county_year i.month_year [pweight=1/weight] if capture == 1 & `r' == 1
eststo, title(`r' capture)

reg lhprice D est $xlist i.siteno i.county_year i.month_year [pweight=1/weight] if storage == 1 & `r' == 1
eststo, title(`r' storage)
}

esttab using "$path\psm4weightedregre_4200m.rtf", cells(b(star fmt(4)) p(fmt(3)) se(fmt(4)) ci_l(fmt(4)) ci_u(fmt(4))) starlevels(* 0.05 ** 0.01 *** 0.001) replace drop(*month_y* *county_y*) nogaps line long r2 noomitted nonumbers noparentheses mtitles