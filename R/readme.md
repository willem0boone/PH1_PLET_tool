## Data

### Required data format
CSV file:
- "Period": YYYY-MM (e.g. 2021-01)
- "lifeform": str name of lifeform (eg. diatom)
- "abundance": abundance data (using '.' as decimal), monthly averaged. 
- "num_samples": int, number of samples used in monthly aggregation.

Example records (note that the .txt file should not have a heading row).

| Period  		| lifeform		| abundance		| num_samples		|
| -------------   	|-------------	    	|-------------	  	|-------------	  	|
| 2017-05	  	| cilliate		| 0.4818		| 4			|
| 2017-06	  	| cilliate		| 4.2124		| 4			|
| 2017-07		| cilliate		| 3.5438		| 4			|
| ...			| ...			| ...			| ...			|
| 2017-05	  	| diatom		| 9659.75519878221	| 4			|
| 2017-06	  	| diatom		| 31736.4549733857	| 4			|
| 2017-07		| diatom		| 8265.58566611672	| 4			|


Example raw
```
"period","lifeform","abundance","num_samples"
"2017-05","cilliate",0.4818,4
"2017-06","cilliate",4.2124,4
"2017-07","cilliate",3.5438,4
...
"2017-05","diatom",9659.75519878221,4
"2017-06","diatom",31736.4549733857,4
"2017-07","diatom",8265.58566611672,4
```

### European Digital Twin of the Ocean (EDITO)
In the DTO-Bioflow project, a pipeline was tested to extract and prepare the data for PLET tool using EDITO. 
The output is stored at /data/PH1_edito_test.csv

## R
It is recomended to run the "R.proj" file (an R project file) before opening the R Notebooks script "PH1-FW5_indicator_script" within R-Studio.This ensures that the working directory will automatically be set appropriately.

### get_data.R
Extract and format data from EDITO data lake. Example of EurOBIS dataset 4687.

### lifeform lookup table
Supporting functions.

### search data lake
Supporting functions.

### PH1_edito.Rmd
This script uses the PLET export data to calculate the lifeform pairs indicator and to calculate the Kendall statistic for a 
user-specified range in the time-series for all lifeforms and relevant lifeform pairs contained in the dataset. It then outputs this information as a set
of figures to aid in understanding patterns and trends in plankton lifeform abundance.
The reference and comparison period of the assessment can also be modified in the first chunk of the script. These periods must be distinct (i.e. periods do not
contain any of the same years of data). The minimum and maximum years used to define these two distinct periods are also used to define the temporal limits for the
whole of the analysis. 
Output figures will be written to an "output" folder contained within the main directory.

### Supporting_scripts
Contains R files holding a set of functions necessary for running the indicator script.
It is recommended not to modify the files in this folder unless the user is experienced with writing functions in R.
