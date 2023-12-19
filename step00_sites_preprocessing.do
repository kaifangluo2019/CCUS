clear all
global path "C:\phd4\CCUS\data"
cd "$path"
adopath + "$path\"
insheet using site_info.csv, clear
set more off

rename community_within_10 community10
drop community_within_20
gen new = (retrofit == 0)
order sitenum retrofit new capture storage
drop if operational <2000
keep if community10 == 1
save site_info.dta, replace

clear all
global path "C:\phd4\CCUS\data"
cd "$path"
adopath + "$path\"
insheet using site_info_all.csv, clear
set more off

rename communitywithin10 community10
drop communitywithin20
gen new = (retrofit == 0)
order sitenum retrofit new capture storage
drop if operational <2000
keep if community10 == 1
keep sitenum facility_latitude facility_longitude
gen state = "AL"
reshape wide facility_latitude facility_longitude, i(state) j(sitenum) string
outsheet state facility_latitude* facility_longitude* using site_coor_wide.csv, comma replace
* here I copied all the coordinates to all states

*keep if  stfips ==1| stfips ==8| stfips ==17| stfips ==18| stfips ==19| stfips ==20| stfips ==21| stfips ==22| stfips ==26| stfips ==28| stfips ==35| stfips ==38| stfips ==39| stfips ==40| stfips ==42| stfips ==48| stfips ==54| stfips ==55| stfips ==56

clear all
global path "C:\phd4\CCUS\data"
cd "$path"
adopath + "$path\"
insheet using site_coor_wide.csv, clear
set more off

save site_coor.dta, replace
