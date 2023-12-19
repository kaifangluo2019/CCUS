set maxvar 12000
set matsize 11000

global path "/a/ha-nfs-2-ib/export/data/bswift-1/kluo73/ccus"
set more off

*foreach n in 01 04 05 08 12 13 16 17 18 19 20 21 22 26 28 29 30 31 35 38 39 40 42 46 47 48 49 51 54 55 56{
foreach n in 01 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
clear all
import delimited "$path/`n'/ZTrans/Main.txt", delimiter("|") encoding(utf-8) clear

rename (v1-v131) (transid pricefips state county dataclassstndcode recordtypestndcode recordingdate recordingdocumentnumber recordingbooknumber recordingpagenumber rerecordedcorrectionstndcode priorrecordingdate priordocumentdate priordocumentnumber priorbooknumber priorpagenumber documenttypestndcode documentdate signaturedate effectivedate buyervestingstndcode buyermultivestingflag partialinteresttransferstndcode partialinteresttransferpercent salespriceamount salespriceamountstndcode citytransfertax countytransfertax statetransfertax totaltransfertax intrafamilytransferflag transfertaxexemptflag propertyusestndcode assessmentlandusestndcode occupancystatusstndcode legalstndcode borrowervestingstndcode lendername lendertypestndcode lenderidstndcode lenderdbaname dbalendertypestndcode dbalenderidstndcode lendermailcareofname lendermailhousenumber lendermailhousenumberext lendermailstreetpredirectional lendermailstreetname lendermailstreetsuffix lendermailstreetpostdirectional lendermailfullstreetaddress lendermailbuildingname lendermailbuildingnumber lendermailunitdesignator lendermailunit lendermailcity lendermailstate lendermailzip lendermailzip4 loanamount loanamountstndcode maximumloanamount loantypestndcode loantypeclosedopenendstndcode loantypefutureadvanceflag loantypeprogramstndcode loanratetypestndcode loanduedate loantermmonths loantermyears initialinterestrate armfirstadjustmentdate armfirstadjustmentmaxrate armfirstadjustmentminrate armindexstndcode armadjustmentfrequencystndcode armmargin arminitialcap armperiodiccap armlifetimecap armmaxinterestrate armmininterestrate interestonlyflag interestonlyterm prepaymentpenaltyflag prepaymentpenaltyterm biweeklypaymentflag assumabilityriderflag balloonriderflag condominiumriderflag plannedunitdevelopmentriderflag secondhomeriderflag onetofourfamilyriderflag concurrentmtgedocorbkpg loannumber mersminnumber casenumber mersflag titlecompanyname titlecompanyidstndcode accommodationrecordingflag unpaidbalance installmentamount installmentduedate totaldelinquentamount delinquentasofdate currentlender currentlendertypestndcode currentlenderidstndcode trusteesalenumber attorneyfilenumber auctiondate auctiontime auctionfullstreetaddress auctioncityname startingbid keyeddate keyerid subvendorstndcode imagefilename builderflag matchstndcode reostndcode updateownershipflag loadid statusind transactiontypestndcode batchid bkfspid zvendorstndcode sourcechksum)

keep transid state pricefips recordingdate documentdate signaturedate salespriceamount loadid dataclassstndcode

* Keep only one record for each TransID and LoadID. 
* TransID is the unique identifier of a transaction, which could have multiple properties sequenced by LoadID. 
* Multiple entries for the same TransID and LoadID are due to updated records.
* Most TransID with multiple entries have only one nonmissing record. But nonmissing not always happens in the largest LoadID.
* So we first fill missing from other LoadID that have nonmissing data.

*bys transid: fillmissing state pricefips recordingdate documentdate signaturedate salespriceamount loadid dataclassstndcode, with(any)
bys transid: gen n = _n
tab n,m
drop if n > 1
drop n
duplicates report transid

* Keep only events which are deed transfers (excludes mortgage records, foreclosures, etc. See documentation.) 
keep if dataclassstndcode == "D" | dataclassstndcode == "H"
save price`n'.dta, replace
}

foreach n in 01 08 17 18 19 20 21 22 26 28 35 38 39 40 42 48 54 55 56{
clear all
import delimited "$path/`n'/ZTrans/PropertyInfo.txt", delimiter("|") encoding(utf-8) clear

rename (v1-v68) (transid assessorparcelnumber apnindicatorstndcode taxidnumber taxidindicatorstndcode unformattedassessorparcelnumber alternateparcelnumber hawaiicondocprcode propertyhousenumber propertyhousenumberext streetpredirectional propertystreetname propertystreetsuffix propertystreetpostdirectional propertybuildingnumber fullstreetaddress propertycity propertystate infozip propertyzip4 originalfullstreetaddress originaladdresslastline addressstndcode legallot legalotherlot legallotcode legalblock legalsubdivisionname legalcondoprojectpuddevname legalbuildingnumber legalunit legalsection legalphase legaltract legaldistrict legalmunicipality legalcity legaltownship legalstrsection legalstrtownship legalstrrange legalstrmeridian legalsectwnrngmer legalrecordersmapreference legaldescription legallotsize sequencenumber propertyaddressmatchcode addressunitdesignator addressunitnumber addresscarrierroute addressgeocodematchcode latitude longitude addresscensustractandblock addressconfidencescore addresscbsacode addresscbsadivisioncode addressmatchtype propertyaddressdpv geocodequalitycode addressqualitycode infofips loadid importparcelid bkfspid assessmentmatchflag batchid)

keep transid importparcelid infofips infozip latitude longitude loadid sequencenumber
save info`n'.dta, replace
}

