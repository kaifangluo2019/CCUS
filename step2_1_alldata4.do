set maxvar 100000
set matsize 11000

use housing_site_dist_info_all.dta, clear

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
*order state import transid date year yearbuilt land
drop if land==1
drop land

*foreach n in yearbuilt totalrooms totalbedrooms buildingareasqft landassessedvalue lotsizesquarefeet{
*replace `n'=. if `n'==0
*}
gen buildingage = year - yearbuilt
gen sold_in_yr_blt = (buildingage == 0)


* merge control variables
merge m:1 fips year using demographic
drop if _merge == 2
drop _merge
rename realincome realincomepc
rename lnrealincome lnrealincomepc

merge m:1 fips year month using pm25_month
drop if _merge == 2
drop _merge

merge m:1 fips year month using pcp_tmp
drop if _merge == 2
drop _merge

merge m:1 fips using yale2020
drop if _merge == 2
drop _merge

drop statename
rename state statename
encode statename, gen(state)
merge m:1 state year using electricity_price
drop if _merge == 2
drop _merge

merge m:1 state year month using gas
drop if _merge == 2
drop _merge

merge m:1 state year using traffic
drop if _merge == 2
drop _merge

gen statefips = substr(fips, 1, 2)
merge m:1 statefips year using pop_white
drop if _merge == 2
drop _merge
rename white_share ws
gen white_share = ws*100

drop if zipcode == "00000" | zipcode == "."
merge m:1 zipcode year using business_establishments
drop if _merge == 2
drop _merge

merge m:1 year month using fed_fund_month
drop if _merge == 2
drop _merge

* drop outliers of price
bys state: egen meanhp=mean(salesprice)
bys state: egen sdhp=sd(salesprice)
gen hp1=meanhp-2*sdhp
gen hp2=meanhp+2*sdhp
drop if salesprice >hp2 | salesprice <hp1
drop meanhp sdhp hp1 hp2

merge m:1 year using adjusted
keep if _merge ==3
drop _merge
gen hp = salesprice/cpi*100
gen lhprice = ln(hp)

tabstat dist, statistics(mean n sd min q p90 max)
save TRANS_DIST_ASMT_all.dta, replace 
