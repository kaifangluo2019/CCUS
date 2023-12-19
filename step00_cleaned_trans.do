set maxvar 120000
set matsize 11000

use price01, clear
foreach n in 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
append using price`n', force
}
save price, replace

use info01, clear
foreach n in 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
append using info`n',force

}
save info, replace

use price.dta, clear

merge 1:m transid using info
keep if _merge==3
drop _merge

* drop missing
drop if missing(salesprice)
drop if salesprice == 0
drop if missing(latitude)
drop if missing(importparcelid)

* date format
foreach m in signaturedate recordingdate{
replace documentdate = `m' if missing(documentdate)
}
gen date=date(documentdate, "YMD") 
format date %td
gen year=year(date)
gen month=month(date)
drop if missing(year)
drop if year < 1900

sort transid sequencenumber
* Keep only one record for each TransID and PropertySequenceNumber. 
* TransID is the unique identifier of a transaction, which could have multiple properties sequenced by PropertySequenceNumber. 
* Multiple entries for the same TransID and PropertySequenceNumber are due to updated records.
* Most TransID with multiple entries have only one nonmissing record. But nonmissing not always happens in the first sequence.
* So we first fillmissing from other sequence that have nonmissing data.
bys transid: fillmissing importparcelid infofips infozip latitude longitude, with(any)

* Drop transactions of multiple parcels (transIDs associated with PropertySequenceNumber > 1)
drop if sequencenumber>1
duplicates report transid

* drop duplicates transid
sort transid importparcelid
quietly by transid: gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup

save "trans.dta", replace
