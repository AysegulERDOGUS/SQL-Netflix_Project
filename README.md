## Netflix Data Analysis with SQL

- In this project, we analyze Netflix data using SQL and thoroughly examine the database to answer questions about newly added content, the most popular actors, and more

## Goals

- The main objective is to use SQL to analyze the data and answer key questions.

## Database Manipulations with SQL
In this project, several database modifications have been made to analyze the Netflix dataset.

    ## Data Update (UPDATE)
    To make it easier to process the date column with different formats, the format and data type have been changed:
      SELECT CONVERT(DATE, date_added, 104) 
      FROM Netflix_table;
  
      UPDATE Netflix_table
      SET date_added= CONVERT(DATE, date_added, 104) 
      
      ALTER TABLE  Netflix_table 
      ALTER COLUMN date_added date

    Data Cleaning (TRIM)
    The TRIM function was used to remove leading spaces from records in the dataset.
      UPDATE Netflix_table
      SET type =TRIM(type),
      title =TRIM(title),
      director =TRIM(director),
      casts =TRIM(casts),
      country = TRIM(country),
      rating =TRIM(rating),
      duration =TRIM(duration),

## Key Questions & Approach

- What new content has been added recently? The release dates were analyzed to identify newly added films and TV series.
- How many films and TV shows are there in each category? The number of titles in each genre was analyzed.






