set maxvar 120000
set matsize 11000

use "TRANS_DIST_ASMT_without_remodel.dta", clear
set more off

sum dist
collapse (first)sitenum (mean)lhprice (mean)dist (mean)popdens (mean)realincomepc (mean)est (mean)white_share (mean)fed (mean)gas (mean)lngas (mean)elecp (mean)lnelecp (mean)happening (mean)worried (mean)fundre (mean)discuss (first)industry (first)status (first)category (first)operational, by(importparcelid year)

xtset importparcelid year
*tsfill, full
*bys importparcelid: fillmissing sitenum industry status category, with(any)
*order importparcelid year sitenum industry status category
gen post = 0
replace post = 1 if year >= operational 
gen treat =0
replace treat =1 if dist <= 4.2
gen D = treat * post    

keep sitenum lhprice dist popdens realincomepc est white_share fed gas lngas elecp lnelecp happening worried fundre discuss industry status category year treat post D importparcelid
tab year,gen(yr)
*tab month,gen(mth)
tab sitenum, gen(site)
encode industry, gen(idty)
encode status, gen(stts)
encode category, gen(ctry)

save "hetero_id_year.dta", replace

clear all
global path "C:/phd4/CCUS"
cd "$path/data"
use "hetero_id_year.dta", clear

sum worried
* mean: 61.80314
tsfill, full
xtplfc lhprice popdens realincomepc fed elecp gas yr1-site23, zvars(D) uvars(worried) gen(coef)

bysort worried:gen n=_n
keep if n==1
gen h95ci= coef_1 +1.96*coef_1_sd
gen l95ci= coef_1 -1.96*coef_1_sd
save worried.dta,replace

*keep if worried < 65 & worried > 50
twoway (rarea h95ci l95ci worried, sort color(gs15)) line coef_1 worried, lpattern(solid) lcolor(gray)  ///
ytitle("Housing price %") xtitle("Environmental awareness (%)") yline(0, lpattern(dash) lcolor(gray)) ///
xline(61.80, lpattern(dash) lcolor(gray)) ///
text(.1 65 "Sample mean: 61.80",size(VSmall)) ///
legend(size(vsmall) order(2 "Point estimates" 1 "95% CI")) ///
scheme(s1mono) name(worried, replace)
graph save "$path/results/worried.gph", replace
graph export "$path/results/worried.svg", as(svg) name("worried") replace

* industry:
clear all
global path "C:/phd4/CCUS"
cd "$path/data"
use "hetero_id_year.dta", clear

tab idty,m
tab industry, m
tsfill, full
xtplfc lhprice popdens realincomepc fed lnelecp lngas stts ctry yr1-yr32, zvars(D) uvars(idty) gen(coef)

bysort idty:gen n=_n
keep if n==1
gen h95ci= coef_1 +1.96*coef_1_sd
gen l95ci= coef_1 -1.96*coef_1_sd
save industry.dta,replace

twoway (rcap h95ci l95ci idty, sort color(olive) lpattern(solid) lwidth(thick)) scatter coef_1 idty, msymbol(Oh) mcolor(dkorange) msize(large) mlwidth(thick)  ///
ytitle("Housing price %") xtitle("") yline(0, lpattern(dash) lcolor(gray)) xscale(range(.5(.5)6.5)) ///
legend(size(vsmall) order(2 "Point estimates" 1 "95% CI")) ///
xlabel(1 "Ethanol Production" 2 "Fertiliser Production" 3 "Hydrogen Production" 4 "Natural Gas Processing" 5 "Power Generation" 6 "Various", labsize(vsmall) angle(vertical)) ///
scheme(s1mono) name(industry, replace)
graph save "$path/results/industry.gph", replace
graph export "$path/results/industry.svg", as(svg) name("industry") replace
