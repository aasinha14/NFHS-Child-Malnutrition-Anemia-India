*==========================================================================
* Child Malnutrition & Anemia in India: Socio-Economic Determinants
* Across Uttar Pradesh, Bihar & West Bengal (NFHS-5, 2019-21)
*
* Authors: Abhishek Anand Sinha, Anoushka Purohit,
*          Chaitanya Dandale, Durga Sreedevi PR
* MA Public Policy & Governance, TISS Hyderabad
*==========================================================================

*Phase 1: Data Merging & Sample Selection
*****************************************

*1.Prepare KR File for Merge

gen hv001 = v001 //Cluster
gen hv002 = v002 //Household
gen hvidx = b16 //Child's line number
sort hv001 hv002 hvidx
*saved as KR_temp file


*2.Open PR File and Merge

sort hv001 hv002 hvidx
merge hv001 hv002 hvidx using "data/KR_Temp.dta" // update path to your local copy

*Keep only successful matches (children present in both files)
keep if _merge == 3
drop _merge

* 3. Filter Sample
keep if b5 == 1     // Keep only children who are alive
keep if hv103 == 1  // Keep only those who slept in the household last night
keep if hc1 < 60    // Restrict to children under 5 years (under 60 months)


*WEIGHT VARIABLE
gen wt = hv005/1000000


*Phase 2: Defining the Dependent Variables (Outcomes)
*****************************************************

*1.Stunting (Height-for-Age)
ta hc70 //height/age standard deviation
gen stunted = 0 if hc70 < 9996
replace stunted = 1 if hc70 < -200
label define stunted_lbl 0 "Not Stunted" 1 "Stunted"
label values stunted stunted_lbl
ta stunted [iw=wt]

*2.Wasting (Weight-for-Height)
gen wasted = 0 if hc72 < 9996
replace wasted = 1 if hc72 < -200
label define wasted_lbl 0 "Not Wasted" 1 "Wasted"
label values wasted wasted_lbl
ta wasted [iw=wt]

*3.Underweight (Weight-for-age)
gen underweight = 0 if hc71 < 9996               
replace underweight = 1 if hc71 < -200
label define underweight_lbl 0 "Not underweight" 1 "Underweight"
label values underweight underweight_lbl
ta underweight [iw=wt]

*4.Anemia (Children 6-59 months only) | hc57 codes: 1=Severe, 2=Moderate, 3=Mild, 4=Not anemic
gen child_anemic = 0 if hc1 > 5 & hc1 < 60 & hc57 != .
replace child_anemic = 1 if hc57 < 4 & hc1 > 5 & hc1 < 60
label define anemic_lbl 0 "Not Anemic" 1 "Anemic"
label values child_anemic anemic_lbl
ta child_anemic [iw=wt]

*v024 codes: 9=UP, 10=Bihar, 19=West Bengal
ta stunted if v024==9 [iw=wt] //UP
ta stunted if v024==10 [iw=wt] //Bihar
ta stunted if v024==19 [iw=wt] //WB
ta wasted if v024==9 [iw=wt] //UP
ta wasted if v024==10 [iw=wt] //Bihar
ta wasted if v024==19 [iw=wt] //WB
ta underweight if v024==9 [iw=wt] //UP
ta underweight if v024==10 [iw=wt] //Bihar
ta underweight if v024==19 [iw=wt] //WB
ta child_anemic if v024==9 [iw=wt] //UP
ta child_anemic if v024==10 [iw=wt] //Bihar
ta child_anemic if v024==19 [iw=wt] //WB


*Phase 3: Independent Variables (Socio-Economic Determinants)
*************************************************************

*1.Sector (Type of Residence)
recode v025 (1=1 "Urban") (2=2 "Rural"), g(residence)

*2.Religion
recode v130 (1=1 "Hindu") (2=2 "Muslim") (3=3 "Christian") (4/96=4 "Others"), g(religion_new)

*3.Social Group (Caste)
recode s116 (1=1 "SC") (2=2 "ST") (3=3 "OBC") (4 8 .=4 "Others/Missing"), g(caste_new)

*4.Wealth Index (v190: 1=Poorest to 5=Richest)

*5.Age of Mother (Grouped for non-linear effects)
recode v012 (15/24=1 "<25 years") (25/34=2 "25-34 years") (35/49=3 "35+ years"), g(age_mother_new)

*6. Mother's Education
recode v106 (0=0 "No Education") (1=1 "Primary") (2=2 "Secondary") (3=3 "Higher"), g(mother_edu)

*7. Mother's Anemic Status (v457: 4 is not anemic, 1-3 are anemic)
gen mother_anemic = 0 if v457 == 4
replace mother_anemic = 1 if v457 < 4
label define manem_lbl 0 "Not Anemic" 1 "Anemic"
label values mother_anemic manem_lbl

* 8. Child's Diarrhea (h11: 0=No, 1=Yes last 24h, 2=Yes last 2 weeks)
gen diarrhea = 0 if h11 == 0
replace diarrhea = 1 if h11 == 1 | h11 == 2
replace diarrhea = . if h11 == 8 | h11 == . // Drop "Don't know" or missing
label define dia_lbl 0 "No" 1 "Yes"
label values diarrhea dia_lbl

*9. Birth Weight (Low Birth Weight = <2500 grams)
* m19 codes weight in grams. 9996 = Not weighed at birth.
gen low_bw = 0 if m19 >= 2500 & m19 <= 9000
replace low_bw = 1 if m19 < 2500
replace low_bw = 2 if m19 >= 9996 | m19 == 9998
label define lbw_lbl 0 "Normal (>=2.5kg)" 1 "Low (<2.5kg)" 2 "Not Weighed/DK"
label values low_bw lbw_lbl

*10. Birth Order
recode bord (1=1 "1st Child") (2/3=2 "2nd or 3rd") (4/20=3 "4th or more"), g(birth_order_cat)

*11. Number of Children (Total Children Ever Born to Mother)
*Because birth order and total children are highly correlated, I am categorizing this as well.
recode v201 (1/2=1 "1-2 Children") (3/4=2 "3-4 Children") (5/20=3 "5+ Children"), g(total_children_cat)



*Phase 4: Independent Logit Regression by State
***********************************************

cd "outputs" // regression output tables (.xls) will be saved here

svyset [pw=wt] , psu(v021) strata(v023) single(centered)


*Outcome 1: Stunting
*===================

*Uttar Pradesh (v024 == 9)
svy: logit stunted i.residence i.religion_new i.caste_new i.v190 i.age_mother_new i.mother_edu i.mother_anemic i.diarrhea i.low_bw i.birth_order_cat i.total_children_cat if v024 == 9, or
outreg2 using Stunting_States.xls, replace excel ctitle(UP_OR) eform ci dec(3)

*Bihar (v024 == 10)
svy: logit stunted i.residence i.religion_new i.caste_new i.v190 i.age_mother_new i.mother_edu i.mother_anemic i.diarrhea i.low_bw i.birth_order_cat i.total_children_cat if v024 == 10, or
outreg2 using Stunting_States.xls, append excel ctitle(Bihar_OR) eform ci dec(3)

*West Bengal (v024 == 19)
svy: logit stunted i.residence i.religion_new i.caste_new i.v190 i.age_mother_new i.mother_edu i.mother_anemic i.diarrhea i.low_bw i.birth_order_cat i.total_children_cat if v024 == 19, or
outreg2 using Stunting_States.xls, append excel ctitle(WB_OR) eform ci dec(3)


* OUTCOME 2: Wasting
* ==================

*Uttar Pradesh
svy: logit wasted i.residence i.religion_new i.caste_new i.v190 i.age_mother_new i.mother_edu i.mother_anemic i.diarrhea i.low_bw i.birth_order_cat i.total_children_cat if v024 == 9, or
outreg2 using Wasting_States.xls, replace excel ctitle(UP_OR) eform ci dec(3)

*Bihar
svy: logit wasted i.residence i.religion_new i.caste_new i.v190 i.age_mother_new i.mother_edu i.mother_anemic i.diarrhea i.low_bw i.birth_order_cat i.total_children_cat if v024 == 10, or
outreg2 using Wasting_States.xls, append excel ctitle(Bihar_OR) eform ci dec(3)

*West Bengal
svy: logit wasted i.residence i.religion_new i.caste_new i.v190 i.age_mother_new i.mother_edu i.mother_anemic i.diarrhea i.low_bw i.birth_order_cat i.total_children_cat if v024 == 19, or
outreg2 using Wasting_States.xls, append excel ctitle(WB_OR) eform ci dec(3)


* OUTCOME 3: Underweight
* ======================

*Uttar Pradesh
svy: logit underweight i.residence i.religion_new i.caste_new i.v190 i.age_mother_new i.mother_edu i.mother_anemic i.diarrhea i.low_bw i.birth_order_cat i.total_children_cat if v024 == 9, or
outreg2 using Underweight_States.xls, replace excel ctitle(UP_OR) eform ci dec(3)

*Bihar
svy: logit underweight i.residence i.religion_new i.caste_new i.v190 i.age_mother_new i.mother_edu i.mother_anemic i.diarrhea i.low_bw i.birth_order_cat i.total_children_cat if v024 == 10, or
outreg2 using Underweight_States.xls, append excel ctitle(Bihar_OR) eform ci dec(3)

*West Bengal
svy: logit underweight i.residence i.religion_new i.caste_new i.v190 i.age_mother_new i.mother_edu i.mother_anemic i.diarrhea i.low_bw i.birth_order_cat i.total_children_cat if v024 == 19, or
outreg2 using Underweight_States.xls, append excel ctitle(WB_OR) eform ci dec(3)


* OUTCOME 4: Anemia
* =================

*Uttar Pradesh
svy: logit child_anemic i.residence i.religion_new i.caste_new i.v190 i.age_mother_new i.mother_edu i.mother_anemic i.diarrhea i.low_bw i.birth_order_cat i.total_children_cat if v024 == 9 & hc1 > 5, or
outreg2 using Anemia_States.xls, replace excel ctitle(UP_OR) eform ci dec(3)

*Bihar
svy: logit child_anemic i.residence i.religion_new i.caste_new i.v190 i.age_mother_new i.mother_edu i.mother_anemic i.diarrhea i.low_bw i.birth_order_cat i.total_children_cat if v024 == 10 & hc1 > 5, or
outreg2 using Anemia_States.xls, append excel ctitle(Bihar_OR) eform ci dec(3)

*West Bengal
svy: logit child_anemic i.residence i.religion_new i.caste_new i.v190 i.age_mother_new i.mother_edu i.mother_anemic i.diarrhea i.low_bw i.birth_order_cat i.total_children_cat if v024 == 19 & hc1 > 5, or
outreg2 using Anemia_States.xls, append excel ctitle(WB_OR) eform ci dec(3)
