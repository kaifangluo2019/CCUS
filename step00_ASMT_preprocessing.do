set maxvar 120000
set matsize 11000
global path "/a/ha-nfs-2-ib/export/data/bswift-1/kluo73/ccus"
set more off

foreach n in 01 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
clear all
import delimited "$path/`n'/ZAsmt/Main.txt", delimiter("|") encoding(utf-8) clear

rename (v1-v95) (rowid importparcelid asmtfips state county valuecertdate extractdate edition zvendorstndcode assessorparcelnumber dupapn unformattedassessorparcelnumber parcelsequencenumber alternateparcelnumber oldparcelnumber parcelnumbertypestndcode recordsourcestndcode recordtypestndcode confidentialrecordflag propertyaddresssourcestndcode propertyhousenumber propertyhousenumberext propertystreetpredirectional propertystreetname propertystreetsuffix propertystreetpostdirectional propertyfullstreetaddress propertycity propertystate asmtzip propertyzip4 originalpropertyfulladdress originalpropertyaddresslastline propertybuildingnumber propertyzoningdescription propertyzoningsourcecode censustract taxidnumber taxamount taxyear taxdelinquencyflag taxdelinquencyamount taxdelinquencyyear taxratecodearea legallot legallotstndcode legalotherlot legalblock legalsubdivisioncode legalsubdivisionname legalcondoprojectpuddevname legalbuildingnumber legalunit legalsection legalphase legaltract legaldistrict legalmunicipality legalcity legaltownship legalstrsection legalstrtownship legalstrrange legalstrmeridian legalsectwnrngmer legalrecordersmapreference legaldescription legalneighborhoodsourcecode noofbuildings lotsizeacres lotsizesquarefeet lotsizefrontagefeet lotsizedepthfeet lotsizeirr lotsitetopographystndcode loadid propertyaddressmatchcode propertyaddressunitdesignator propertyaddressunitnumber propertyaddresscarrierroute propertyaddressgeocode latitude longitude censustractandblock confidencescore cbsacode cbsadivisioncode matchtype propertyaddressdpv geocodequalitycode propertyaddressqualitycode subedition batchid bkfspid sourcechksum)

keep rowid importparcelid asmtfips state asmtzip lotsizeacres lotsizesquarefeet batchid
save main`n'.dta, replace
}

foreach n in 01 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
clear all
import delimited "$path/`n'/ZAsmt/Value.txt", delimiter("|") encoding(utf-8) clear

rename (v1-v15) (rowid landassessedvalue improvementassessedvalue totalassessedvalue assessmentyear landmarketvalue improvementmarketvalue totalmarketvalue marketvalueyear landappraisalvalue improvementappraisalvalue totalappraisalvalue appraisalvalueyear fips batchid)

keep rowid landassessedvalue landmarketvalue batchid
save value`n'.dta, replace
}

foreach n in 01 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
clear all
import delimited "$path/`n'/ZAsmt/Building.txt", delimiter("|") encoding(utf-8) clear

rename (v1-v47) (rowid noofunits occupancystatusstndcode propertycountylandusedescription propertycountylandusecode propertylandusestndcode propertystatelandusedescription propertystatelandusecode buildingorimprovementnumber buildingclassstndcode buildingqualitystndcode buildingqualitystndcodeoriginal buildingconditionstndcode architecturalstylestndcode yearbuilt effectiveyearbuilt yearremodeled noofstories totalrooms totalbedrooms totalkitchens fullbath threequarterbath halfbath quarterbath totalcalculatedbathcount totalactualbathcount bathsourcestndcode totalbathplumbingfixtures roofcoverstndcode roofstructuretypecode heatingtypeorsystemcode airconditioningtypecode foundationtypecode elevatorcode fireplaceflag fireplacetypecode fireplacenumber waterstndcode sewerstndcode mortgagelendername timesharestndcode comments loadid storytypestndcode fips batchid)

keep rowid buildingorimprovementnumber yearbuilt yearremodeled noofstories totalrooms totalbedrooms fips propertylandusestndcode batchid
* Reduce bldg dataset to Single-Family Residence, Condo's, Co-opts (or similar)
* 'RR101', SFR; 'RR999', Inferred SFR; 'RR104', Townhouse; 'RR105', Cluster Home;
* 'RR106', Condominium; 'RR107', Cooperative; 'RR108', Row House; 'RR109', Planned Unit Development;
* 'RR113', Bungalow; 'RR116', Patio Home; 'RR119', Garden Home; 'RR120', Landominium
keep if propertylandusestndcode == "RR101" | propertylandusestndcode == "RR999" | propertylandusestndcode == "RR104" | propertylandusestndcode == "RR105" | propertylandusestndcode == "RR106" | propertylandusestndcode == "RR107" | propertylandusestndcode == "RR108" | propertylandusestndcode == "RR109" | propertylandusestndcode == "RR113" | propertylandusestndcode == "RR116" | propertylandusestndcode == "RR119" | propertylandusestndcode == "RR120" 
save building`n'.dta, replace
}

foreach n in 01 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
clear all
import delimited "$path/`n'/ZAsmt/BuildingAreas.txt", delimiter("|") encoding(utf-8) clear

rename (v1-v7) (rowid buildingorimprovementnumber buildingareasequencenumber buildingareastndcode buildingareasqft fips batchid)

bysort rowid buildingorimprovementnumber: egen building_area=total(buildingareasqft)
keep if buildingareasequencenumber==1
keep rowid buildingorimprovementnumber building_area batchid
* some building areas are negative
replace building_area = . if building_area < 0
save area`n'.dta, replace
}

foreach n in 01 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
clear all
import delimited "$path/`n'/ZAsmt/Garage.txt", delimiter("|") encoding(utf-8) clear

rename (v1-v8) (rowid buildingorimprovementnumber garagesequencenumber garagestndcode garageareasqft garagenoofcars fips batchid)

bysort rowid buildingorimprovementnumber: egen garage_area=total(garageareasqft)
keep if garagesequencenumber==1
keep rowid buildingorimprovementnumber garage_area
save garage`n'.dta, replace
}

foreach n in 01 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
clear all
import delimited "$path/`n'/ZAsmt/Pool.txt", delimiter("|") encoding(utf-8) clear

rename (v1-v6) (rowid buildingorimprovementnumber poolstndcode poolsize fips batchid)

keep rowid buildingorimprovementnumber poolsize
save pool`n'.dta, replace
}

* 04 05 no observation
foreach n in 01 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
clear all
import delimited "$path/`n'/ZAsmt/LotSiteAppeal.txt", delimiter("|") encoding(utf-8) clear

rename (v1-v4) (rowid lotsiteappealstndcode fips batchid)

keep rowid lotsiteappealstndcode
gen goodview=1 if lotsiteappealstndcode=="AIR"|lotsiteappealstndcode=="FWY"|lotsiteappealstndcode=="GBL"|lotsiteappealstndcode=="GLF"|lotsiteappealstndcode=="HST"|lotsiteappealstndcode=="OMS"|lotsiteappealstndcode=="SCH"|lotsiteappealstndcode=="VWL"|lotsiteappealstndcode=="VWM"|lotsiteappealstndcode=="VWO"|lotsiteappealstndcode=="VWR"|lotsiteappealstndcode=="WFB"|lotsiteappealstndcode=="WFC"|lotsiteappealstndcode=="WFS"

save lotsiteappeal`n'.dta, replace
}

foreach n in 01 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
use "main`n'.dta", clear

merge 1:m rowid using value`n'
drop _merge

merge 1:m rowid using building`n'
drop _merge

merge 1:m rowid buildingorimprovementnumber using area`n'
drop _merge

merge 1:m rowid buildingorimprovementnumber using garage`n'
drop _merge

merge 1:m rowid buildingorimprovementnumber using pool`n'
drop _merge

save asmt`n'.dta, replace
}

use asmt01, clear
foreach n in 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
append using asmt`n', force
}
save asmt, replace