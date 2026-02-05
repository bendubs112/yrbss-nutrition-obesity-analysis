# YRBSS Nutrition and Obesity Analysis

A statistical analysis of the Youth Risk Behavior Surveillance System (YRBSS) dataset examining the relationships between nutrition habits, physical activity, and obesity rates among high school students in the United States.

## Overview

This project analyzes trends in youth health behaviors from 2001-2023, investigating correlations between dietary habits (fruit/vegetable consumption, soda intake), physical activity levels, and obesity prevalence across different demographic groups.

## Dataset

**Source:** Youth Risk Behavior Surveillance System (YRBSS)  
**Variables analyzed:**
- Fruit consumption (less than 1 time daily)
- Vegetable consumption (less than 1 time daily)  
- Soda consumption (at least 1 time daily)
- Physical activity (≥1 hour daily)
- Physical education class participation
- Overweight classification
- Obesity rates

**Stratifications:** Grade level (9-12), sex, race/ethnicity

## Analysis Methods

### Data Cleaning
- Standardized race/ethnicity categorizations across variables
- Removed redundant and irrelevant variables
- Resolved inconsistencies in stratification labels
- Created simplified question identifiers for analysis

### Statistical Analysis
- **Descriptive statistics:** Distribution of health behaviors across demographics
- **Correlation analysis:** Relationships between nutrition/activity and obesity
- **Regression modeling:** Predicting obesity rates from vegetable consumption
- **Hypothesis testing:** Two-sided t-test comparing national obesity rates to benchmark values
- **Trend visualization:** Time series analysis of health behaviors (2001-2023)

### Data Transformation
- Collapsed data into yearly averages by demographic strata
- Reshaped from long to wide format for correlation analysis
- Generated overall national averages alongside stratified breakdowns

## Key Findings

The analysis reveals:
- Temporal trends in youth obesity and nutritional behaviors over two decades
- Correlations between low vegetable consumption and obesity prevalence
- Demographic variations in health behaviors and outcomes
- Regression coefficients quantifying the relationship between diet and obesity

## Technical Implementation

**Language:** Stata  
**Key techniques:**
- Data reshaping and collapsing
- Time series visualization
- Multivariate regression
- Stratified analysis by demographics

## File Structure

```
├── Full_Do_File_-_Nutrition.do                                                              # Main analysis script
├── Nutrition__Physical_Activity__and_Obesity_-_Youth_Risk_Behavior_Surveillance_System.csv  # YRBSS dataset
├── Full_Data_Log.txt                                                                        # Complete analysis output
└── README.md                                                                                # This file
```

## Usage

To replicate this analysis:

1. Clone this repository (includes the YRBSS dataset CSV)
2. Update the file paths in the .do file (lines 4-5) to match your local directory
3. Run the complete .do file in Stata

**Don't have Stata?** You can review the complete analysis output in the included log file (`Full_Data_Log.txt`), which contains all statistical results, summary tables, and test outputs, and review the graphs produced by the .do file, which are contained in this reposity.

**Note:** The script generates intermediate datasets (`Pre-collapsed Youth Nutrition Data.dta`, `Yearly Youth Nutrition Data.dta`) and can produce visualization outputs if graph export commands are uncommented.

## Output

The analysis produces:
- Summary statistics for all health behavior variables
- 2-dimensional graphs of dietary/acitvity variables and obesity (graphs available in repository)
- Correlation coefficients between dietary/activity variables and obesity
- Regression output with coefficients and residuals
- Hypothesis test results
- Log file with complete analysis output

## Academic Context

This project was completed as part of a data analysis course, demonstrating proficiency in:
- Large dataset manipulation and cleaning
- Regression analysis and interpretation
- Statistical hypothesis testing
- Simple data visualization and communication of results

---

**Author:** Ben Widgren  
**Tools:** Stata
