# Project 2: Open Data App using RShiny - Where did our alumni go?
Term: Spring 2018

+ **Group 10 - team members:**
	+ Leo Lam (lkl2129)
	+ Yuhan Zha (yz3284)
	+ Yanjun Lin (yl3829)
	+ Ziyu Chen (zc2393)

	
+ **Link to deployed Shiny-App:**
https://leolam.shinyapps.io/Rshiny/

## Introduction:

In this project, we provided the job distribution, company name, and job location of the former M.A. students in Statistics at Columbia University as well as the average income and unemployment rate in each state aiming to provide current students more options in choosing their future career path. 


## What is the Business Problem Solved:

Career path is often the hardest decision to make as a student. In fact, many of us are having difficulties in finding our ideal jobs in New York City. Therefore, in this project, we provided the company name, job location, and job title of our alumni hoping to provide more options as we are planning our future career path. We found many of our alumni tend to stay in New York or work in the data related fields, but we found that in many other states, the unemployment rate is relatively lower while the average income is relatively higher, which can be the potential options for the students at the M.A. program in Statistics.


+ **Key Componant:**
	+ What field do our alumni tend to work in?
	+ What location do our alumni tend to work?
	+ What are the states with low unemployment rate and high average income?
	
+ **Our Finding:**
	+ **Job Type:  What field do our alumni tend to work in ?**
	The app displays the industries that our alumni are in:
	 	+ 23.2% work in the field of data science
		+ 14.1% work in the field of data analytics
	+ **Location: Where are our alumni ?** 	
	 	+ 56.3% work in NYC	
	+ **Unemployment Rate: Which state has the lowest unemployment rate ?** 
	 	+ Indiana
	+ **Average Income: Which state has the higher average income in statistics related field in 2016 ?**
	 	+ New Jersey
	 	+ Although New York average incomes are above 80% quintile, real average incomes are at the 60% quintile. Hence, New York may not have the highest income for statistics students!

	
+ **Our Method:**
	+ **Data Scrapping:  Data scrapping from Linkedin.**
		+ We used Linkedin to find the job profile of our alumni. 
		+ We first searched the links of linkedin profile on Google since we cannot directly search them through linkedin on python.
		+ We used the result links to connect the linkedin pages and scraped the educational and professional experience. 
		+ Our goal here is to provide the job location, job title, company name, and corresponding education.
	+ **Data Cleaning: Cleaning the data we collected.**
	    + We only focus on the first working experience after their graduation.
	    + We selected the alumni from MA program in Statistics at Columbia University.
	+ **Data Visualization:** 
	 	+ Unemployment: We implemented heat map to show the unemployment rate through out US.
	 	+ Average Income: Here, we applied both heat map and bar graph to visualize both the average income and the adjusted real income
	 		+ Real Personal Income: Refers to the income of an individual or group after taking into consideration the effects of inflation on purchasing power. Real personal income is personal income at RPPs divided by the national PCE chain-type price index. 
			+  Regional Price Parities (RPPs) are regional price levels expressed as a percentage of the overall national price level or a given year. The price level is determined by the average prices paid by consumers for the mix of goods and services consumed in each region. 
			+ Personal consumption expenditures price index (PCE) price index is a United States-wide indicator of the average increase in prices for all domestic personal consumption
		+ Job Distribution: We used pie chart and table to show the job title and location distribution of our alumni.
		+ 3D Connection Map: An earth that shows the job destination of alumni in both MA Statistics and MS Computer Science program, to show the difference between the two programs.
	+ **Privacy protection:**
		+ For privacy protection reason, we masked out the information like: linkedin profile url, names in our linkedin data set.

+ **Our App:**
	+ **Introduction: Project Goal**
![intro](lib/intro.png)
	+ **Unemployment Rate: Unemployment rate by states and years**
![unemploy](lib/unemploy.png)
	+ **Average Income: Average income by states**
![avg_income1](lib/avg_income1.png)
![avg_income2](lib/avg_income2.png)
	+ **Job Distribution: Job distribution by states and job titles**
![piechart](lib/piechart.png)
	+ **Connective Map: Map showing where our alumni in Statistics and Computer Science went from Columbia**
![connectivemap](lib/connectivemap.png)
	


## Data Sources:

+ Unemployment Rate Data from https://www.data.gov/
+ Average Income Date from 	https://www.bls.gov/oes/2014/may/oessrcst.htm
							https://www.bls.gov/oes/2015/may/oessrcst.htm
							https://www.bls.gov/oes/2016/may/oessrcst.htm
							https://bea.gov/iTable/
+ Student Data are scrapped by us using code in folder - [linkedin]()


## Contribution statement: 

Team members: Yanjun Lin, Ziyu Chen, Yuhan Zha, Leo Lam

All team members contributed equally in all stages of this project. All team members approve our work presented in this GitHub repository including this contributions statement. 
+ Yanjun Lin: Scraper development, scrapping data from linkedin, data preprocessing, R Shiny UI design;
+ Ziyu Chen: R Shiny 3D connection map, presentation, data preprocessing, scrapping data from linkedin, R Shiny UI design;
+ Yuhan Zha: R Shiny heat map, bar plot, data collection and data preprocessing for income, R Shiny UI design;
+ Leo Lam: R Shiny pie chart, data table, data preprocessing, R Shiny UI design.

Following [suggestions](https://github.com/TZstatsADS/Spring2018-Project2-Group10). This folder is orgarnized as follows.

```
proj/
├── app/
├── lib/
├── data/
├── doc/
├── output/
└── linkedin/


```

Please see each subfolder for a README file.

