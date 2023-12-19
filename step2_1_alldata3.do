set maxvar 100000
set matsize 11000

use housing_site_dist_info_01.dta, clear
foreach n in 04 08 12 17 18 20 21 22 26 28 29 35 38 39 40 42 47 48 54 55 56{
append using housing_site_dist_info_`n', force
}
save housing_site_dist_info_all.dta, replace

