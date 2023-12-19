set maxvar 120000
set matsize 11000

use "buffer30_01.dta", clear
foreach n in 08 12 17 18 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
append using buffer30_`n', force
}

save buffer30_all.dta, replace

use "buffer30_all.dta", clear
*Check to see if there are multiple transactions on the same day with different prices? And drop.
duplicates tag importparcelid date, gen(propdaytag)
tab propdaytag
gen okflag = (propdaytag==0)
egen stdprice = sd(salesprice), by(importparcelid date)
drop if stdprice > 0 & okflag == 0
duplicates drop importparcelid date, force
drop propdaytag okflag stdprice

*We don't want to include properties sold more than 1 time in a year
bysort importparcelid year: gen st=_N
drop if st>1
drop st

*Check if they are just land sales, and don't include: 
format yearbuilt %ty
gen land=(year < yearbuilt & yearbuilt!=.)
drop if land==1
drop land

gen buildingage = year - yearbuilt
gen sold_in_yr_blt = (buildingage == 0)

** merge with business establishments
merge m:1 zipcode year using business_establishments
drop if _merge == 2
drop _merge

tabstat dist, statistics(mean n sd min q p90 max)
save buffer30.dta, replace
