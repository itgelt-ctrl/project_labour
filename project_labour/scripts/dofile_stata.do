// Set working directory, I forked it from my Git, because I used the python on my laptop first, and then now I am using Stata on virtual map. 

pwd
cd "C:/Users/Bat-Ochir_Itgelt/Desktop/project_labour/project_labour"

*Importing the data
import delimited "data/data_labour_mn.csv", clear 


* General summary 
list in 1/10
describe
summarize

* Check the variable types, important one here! 
describe

* It all seems in str type, which is not suitable. And the names of the variables must be translated into English. 

rename v1 agegr
rename v2 province
rename v3 gndr


*lets use loop to change var names. 

local val 1991
* Rename variables v4 to v35 to years 1992 to 2023
forvalues i = 4/35 {
    local val = `val' + 1 
	rename v`i' y`val'  
}

* Now I need to delete the first row. 
drop in 1 

* some more translations --> for gndr as 0 1, and all
replace gndr = "0" if gndr == "Эрэгтэй"
replace gndr = "1" if gndr == "Эмэгтэй"
replace agegr = "all" if agegr == "Бүгд"
destring gndr, replace

* Loop to convert y1992 to y2023 from string to numeric, but we have to remove commas in the values. 

forvalues year = 1992/2023 { 
   replace y`year' = subinstr(y`year', ",", "", .)
   destring y`year', replace
}


* Data is in a better shape now. Lets run into analysis now. 

misstable summarize

//There are quite a lot of missing values. This is a problem we can's address and some regions seems to have skipped years to collect data. We have to find a way to analyse our data. For this assignment, I will only concentrate on country level data conduct required analysis.  

* Some more translations 
replace province = "country" if province == "Улсын дүн"

* Check the unique values in the province variable
tabulate province


*lets save the data 
export delimited "data/data_labour_cleaner.csv", replace


** lets's filter the data to include only 'country' in the province variable
keep if province == "country" 

* Display the filtered dataset
list


* Like i did with python, we work on only observations in the specified age groups
keep if inlist(agegr, "Бүгд", "20-24", "25-29", "30-34", "35-39")


*lets save the data on more time, now its country level! 
export delimited "data/data_labour_country_only.csv", replace


// Now that the data seem fine, lets do some visualisations. we will start with reshaping the data. 

* we will need to reshape it
reshape long y, i(agegr province gndr) j(year)
keep if agegr == "all"

*Plots 
twoway (line y year if gndr == 0, color(blue) lwidth(medium) lpattern(solid)) ///
       (line y year if gndr == 1, color(red) lwidth(medium) lpattern(solid)), ///
       legend(label(1 "Male") label(2 "Female")) ///
       ytitle("Count") title("Male and Female Counts Over Time")

graph export "outputs\stata_male_female_counts_plot.png", replace



