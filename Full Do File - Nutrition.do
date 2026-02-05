*** Ben Widgren's Data Project .do File***

* open data + log file
cd "C:\Users\ebw26\Box\Data Project Stata Files\"
import delimited "C:\Users\ebw26\Box\Data Project Stata Files\Nutrition__Physical_Activity__and_Obesity_-_Youth_Risk_Behavior_Surveillance_System.csv", clear
log using Full_Data_Log.txt, text replace

*** Data Cleaning ***
* drop redundant/irrelevant variables
drop geolocation data_value_alt data_value_type datavaluetypeid data_value_unit data_value_footnote_symbol data_value_footnote datasource class topic yearend classid topicid

* drop redundant year variable and rename to "year"
rename yearstart year

* make raceethnicty variable and race stratification variable consistent in their naming, and correct mismatched American Indian/Alaska Natives observations
replace raceethnicity = "Black" if raceethnicity == "Non-Hispanic Black"
replace raceethnicity = "White" if raceethnicity == "Non-Hispanic White"
replace raceethnicity = "Black" if raceethnicity == "non-Hispanic black"
replace raceethnicity = "White" if raceethnicity == "non-Hispanic white"
replace raceethnicity = "American Indian/Alaska Native" if raceethnicity == "American Indian/Alaska Na"
replace stratification1 = "Black" if stratification1 == "Non-Hispanic Black"
replace stratification1 = "White" if stratification1 == "Non-Hispanic White"

* drop the 3 mismatched observations
drop if stratificationcategoryid1 == "RACE" & raceethnicity == "Hawaiian/Pacific Islander" & stratification1 == "Hispanic"

* now the command assert raceethnicity == stratification1 if stratificationcategoryid1 == "RACE" is true for all observations
* and now drop the stratificationcategoryid1 and stratificationid1 because they are redundant with stratificationcategory1 and stratification1 respectively

drop stratificationcategoryid1 stratificationid1

* to double check, the command assert raceethnicity == stratification1 if stratificationcategory1 == "Race/Ethnicity" is now true, good to check because we are now using stratificationcategory1 == "Race/Ethnicity" instead of stratificationcategoryid1 == "RACE" because we dropped stratificationcategoryid1


*** clean up questionid variable to make collapsing the data later on easier ***
replace questionid = "fruit" if questionid == "Q020"
replace questionid = "veg" if questionid == "Q021"
replace questionid = "soda" if questionid == "Q058"
replace questionid = "exercise" if questionid == "Q048"
replace questionid = "pe" if questionid == "Q049"
replace questionid = "overweight" if questionid == "Q039"
replace questionid = "obese" if questionid == "Q038"


*** reviewing date, tabulate variables to find frequencies ***
tabulate stratificationcategory1
// shows how the surveys were stratified, the choices being Grade, Race/Ethnicity, Sex, or Total (no stratification)
tab stratification1
// shows sub-stratifications, Grade being 9-12, Sex being male or female, etc


*** summarize data_value variable according to question ***
summarize data_value if question == "Percent of students in grades 9-12 who consume fruit less than 1 time daily", detail
sum data_value if question == "Percent of students in grades 9-12 who consume vegetables less than 1 time daily", detail
sum data_value if question == "Percent of students in grades 9-12 who drank regular soda/pop at least one time per day", detail
sum data_value if question == "Percent of students in grades 9-12 who achieve 1 hour or more of moderate-and/or vigorous-intensity physical activity daily", detail
sum data_value if question == "Percent of students in grades 9-12 who participate in daily physical education", detail
sum data_value if question == "Percent of students in grades 9-12 who have an overweight classification", detail
sum data_value if question == "Percent of students in grades 9-12 who have obesity", detail


*** summarize conditional data, summarize obesity percentages conditional on being male ***
summarize data_value if question == "Percent of students in grades 9-12 who have obesity" & stratification1 == "Male"

/*
*** histogram of obesity among all students ***
histogram data_value if question == "Percent of students in grades 9-12 who have obesity", ///
	title("Distribution of Obesity Rate Among High School Students") ///
	xtitle("% of Students in a given High School with Obesity")
graph export "obesity_allstudents.png", replace width(1800) height(1200)
*/

* save pre-collapsed dataset *
save "Pre-collapsed Youth Nutrition Data.dta", replace


*** collapse data into yearly averages so we can correlate and regress data ***
* first collapse by year, questionid, and stratification1, save as separate dataset
collapse (mean) data_value, by(year questionid stratification1)
save "temp_stratified.dta", replace

* second, collapse again only by year and questionid, ignoring stratification1, and label as "overall" for each year
collapse (mean) data_value, by(year questionid)
gen stratification1 = "Yearly Overall"
save "temp_overall.dta", replace

* append overall to stratified *
use "temp_stratified.dta", clear
append using "temp_overall.dta"

* reshape so we can now correlate data
reshape wide data_value, i(year stratification1) j(questionid) string
rename data_value* *
order year stratification1 fruit veg soda exercise pe overweight obese
* get the rows sorted nicely by stratum *
replace stratification1 = "Total Student Population" if stratification1 == "Total"
gen stratum_order = .
replace stratum_order = 1  if stratification1 == "Yearly Overall"
replace stratum_order = 2  if stratification1 == "Male"
replace stratum_order = 3  if stratification1 == "Female"
replace stratum_order = 4  if stratification1 == "9th"
replace stratum_order = 5  if stratification1 == "10th"
replace stratum_order = 6  if stratification1 == "11th"
replace stratum_order = 7  if stratification1 == "12th"
replace stratum_order = 8  if stratification1 == "White"
replace stratum_order = 9  if stratification1 == "Black"
replace stratum_order = 10 if stratification1 == "Hispanic"
replace stratum_order = 11 if stratification1 == "Asian"
replace stratum_order = 12 if stratification1 == "American Indian/Alaska Native"
replace stratum_order = 13 if stratification1 == "Hawaiian/Pacific Islander"
replace stratum_order = 14 if stratification1 == "2 or more races"
replace stratum_order = 15 if stratification1 == "Total Student Population"
sort year stratum_order
drop stratum_order


*** time to correlate! ***
* correlate "Yearly Overall veg and obese variables"
correlate veg obese if stratification1 == "Yearly Overall"

/* make line graph, combining graphs
line veg year if stratification1 == "Yearly Overall", ///
    title("% of High School Students Who Eat Vegetables Less than Once per Day", size(small)) ///
	xlabel(2001(3)2023) ///
    ylabel(0(10)50) ///
    ytitle("% of Students") ///
    xtitle("Year") ///
    lcolor(green) ///
    lwidth(medium)
graph save veg_graph.gph, replace
	
	
line obese year if stratification1 == "Yearly Overall", ///
    title("% of High School Students with Obesity", size(small)) ///
    xlabel(2001(3)2023) ///
    ylabel(0(10)50) ///
    ytitle("% of Students") ///
    xtitle("Year") ///
    lcolor(red) ///
    lwidth(medium)
graph save obese_graph.gph, replace

graph combine veg_graph.gph obese_graph.gph, ///
    title("Low Vegetable Consumption and Obesity Trends") ///
    col(2)
*/

/*
* graph both lines on the same graph	
twoway (line veg year if stratification1 == "Yearly Overall", ///
            lcolor(green) lwidth(medium) ///
            lpattern(solid) ///
            mcolor(green) msize(medium)) ///
       (line obese year if stratification1 == "Yearly Overall", ///
            lcolor(red) lwidth(medium) ///
            lpattern(solid) ///
            mcolor(red) msize(medium)), ///
       title("Low Vegetable Consumption and Obesity Rates Over Time", size(small)) ///
       xtitle("Year") ytitle("% of Students") ///
       xlabel(2001(3)2023) ylabel(0(5)50) ///
       legend(order(1 "Low Veg. Consumption" 2 "Obesity") size(small))	
graph export "veg_obese_graph.png", replace width(1800) height(1200)
*/

/* to paste into console and make twoway graphs for the other variables
twoway (line fruit year if stratification1 == "Yearly Overall", lcolor(orange) lwidth(medium) lpattern(solid) mcolor(green) msize(medium)) (line obese year if stratification1 == "Yearly Overall", lcolor(red) lwidth(medium) lpattern(solid) mcolor(red) msize(medium)), title("Low Fruit Consumption and Obesity Rates Over Time", size(small)) xtitle("Year") ytitle("% of Students") xlabel(2001(3)2023) ylabel(0(5)50) legend(off)

graph save fruit_obese.gph, replace

twoway (line pe year if stratification1 == "Yearly Overall", lcolor(black) lwidth(medium) lpattern(solid) mcolor(black) msize(medium)) (line obese year if stratification1 == "Yearly Overall", lcolor(red) lwidth(medium) lpattern(solid) mcolor(red) msize(medium)), title("Daily PE Class and Obesity Rates Over Time", size(small)) xtitle("Year") ytitle("% of Students") xlabel(2001(3)2023) ylabel(0(5)50) legend(off)

graph save pe_obese.gph, replace

graph combine fruit_obese.gph pe_obese.gph, title("Fruit Consumption, Exercise, and Obesity Trends") col(2)

graph export "combined_fruit_pe_obese_graph.png", replace width(2400) height(1200)

twoway (line soda year if stratification1 == "Yearly Overall" & year > 2006, lcolor(blue) lwidth(medium) lpattern(solid) mcolor(blue) msize(medium)) (line obese year if stratification1 == "Yearly Overall" & year > 2006, lcolor(red) lwidth(medium) lpattern(solid) mcolor(red) msize(medium)), title("High Soda Consumption and Obesity Rates Over Time", size(small)) xtitle("Year") ytitle("% of Students") xlabel(2007(3)2023) ylabel(0(5)40) legend(order(1 "High Soda Consumption" 2 "Obesity") size(small))

graph export "soda_obese_graph.png", replace width(1800) height(1200)
*/

*** regress y = obese and x = veg for "Yearly Overall"
regress obese veg if stratification1 == "Yearly Overall"
display _b[veg]
display _b[_cons]

predict pred_obese if stratification1 == "Yearly Overall", xb
predict obese_resid if stratification1 == "Yearly Overall", residual

* find highest and lowest residuals
summarize obese_resid if stratification1 == "Yearly Overall"
list year veg obese pred_obese obese_resid if stratification1 == "Yearly Overall"

* make own prediction
display _b[_cons] + _b[veg]*20

** Data Project part 4 commands **
* question 1a and 1b
sum obese if stratification1 == "Yearly Overall" // mean, st.dev.
ttest obese == 15 if stratification1 == "Yearly Overall" // hypothesis test, two-sided, see if the true national obesity average is different than 15%


*** Save data ***
log close
save "Yearly Youth Nutrition Data.dta", replace
