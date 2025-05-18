
----SOLUTIONS----


1. Identify the longest movie for description 

SELECT * ,LEN(description) AS Length  
FROM   Media_Data
WHERE LEN(description) = (SELECT MAX(LEN(description)) FROM Media_Data)

2.Find content added in the last 5 years

SELECT COUNT(*) 
FROM Media_Data
WHERE DATEDIFF(year,date_added,GETDATE())>=5  

3. Find how many movies actor 'Salman Khan' appeared in last 10 years

SELECT C.cast_name , 
	   M.* 
FROM Media_Data M
JOIN Casts C ON C.show_id=M.show_id
WHERE C.cast_name='Salman Khan'
	  AND YEAR(GETDATE())-release_year<=10

4. Find the top 10 actors who have appeared in the highest number of movies produced in India. 

SELECT TOP 10 C.cast_name,
	    COUNT(*) AS Unity
FROM Casts C
JOIN Countries Cntry ON C.show_id=Cntry.show_id
JOIN Media_Data M ON M.show_id=Cntry.show_id
WHERE Cntry.country_name='India'
	  AND C.cast_name != ''
GROUP BY C.cast_name
ORDER BY Unity DESC

5. Find the total duration of content in the "Comedy" genre, rated "PG-13," and added in 2015. bitti

SELECT  type,
		SUM( CAST(LEFT(M.duration,3) as int)) AS Total_Time
FROM Media_Data M
JOIN Genre G ON G.show_id=M.show_id
WHERE G. genre_name LIKE '%comedies%'
	  AND M.rating='PG-13'
	  AND YEAR(M.date_added)=2015
GROUP BY M.type

6.Count the number of "United States" productions added between 2010-2020 that are categorized as both "Action" and "Drama." 

WITH New AS (SELECT COUNT(M.show_id) AS Total
				FROM Media_Data M
				JOIN Genre G ON M.show_id = G.show_id
				JOIN Countries C ON M.show_id = C.show_id
				WHERE C.country_name = 'United States'
				  AND YEAR(M.date_added) BETWEEN 2010 AND 2020
				  AND (G.genre_name LIKE '%Action%' OR G.genre_name LIKE '%Drama%')
				GROUP BY M.show_id
				HAVING COUNT(M.show_id)>=2
				)

SELECT COUNT(*) FROM New

7. Find the first and last years of content created by directors.  

SELECT D.director_name AS Name,
	   MIN(M.release_year) AS First_Year,
	   Max(M.release_year) AS Last_Year
FROM Media_Data M
JOIN Director D ON D.show_id=M.show_id
WHERE D.director_name!=''
GROUP BY D.director_name
ORDER BY Name

8. List the top 5 titles released in the most countries, along with the number of countries they were available in.

SELECT TOP 5 COUNT(DISTINCT C.country_name)AS Unity,
	   M.title 
FROM Countries C
JOIN Media_Data M ON M.show_id=C.show_id
WHERE C.country_name <>''
GROUP BY M.title
ORDER BY Unity DESC

9. Find the average release year of actors who have appeared in at least 10 different shows

SELECT C.cast_name, 
	   AVG(M.Release_year) AS Avg_Year 
FROM Casts C 
JOIN Media_Data M  ON M.show_id=C.show_id
GROUP BY C.cast_name
HAVING C.cast_name <> '' AND COUNT(DISTINCT M.title)>=10

10. Show how many different genres each actor has worked in. List actors who have worked in more than 10 genres.

SELECT c.cast_name,
	   COUNT(DISTINCT G.genre_name) as Unity
FROM Casts C
JOIN Genre G ON G.show_id=C.show_id
GROUP BY C.cast_name
HAVING C.cast_name <> '' AND COUNT(DISTINCT G.genre_name)>10
ORDER BY Unity DESC

11. How many different directors worked for each country?

SELECT  C.country_name,
		COUNT(DISTINCT D.director_name) AS Director_Count 
FROM Director D
JOIN Countries C ON C.show_id=D.show_id
WHERE C.country_name <>'' AND d.director_name <> ''
GROUP BY C.country_name
ORDER BY Director_Count DESC

 12. Find the most watched genres. Write a query showing how many different users watched each genre.

SELECT  G.genre_name,COUNT(DISTINCT N.c_id) AS Unity
FROM Genre G
JOIN N_Customers N ON N.Show_id=G.show_id
GROUP BY G.genre_name
ORDER BY Unity DESC

13. Create a table comparing the average points scored between male and female users.

SELECT gender, 
	   AVG (CAST( movie_point AS FLOAT)) AS Average_Point
FROM N_Customers 
WHERE movie_point IS NOT NULL
GROUP BY gender

 14.How many people log in to the platform on average every day? Which day of the week is the most busy day?

WITH NEW AS(SELECT Days,
	   COUNT(Show_id) AS Unity 
FROM N_Customers
GROUP BY Days)

SELECT Days,Unity 
FROM NEW
WHERE Unity=(SELECT MAX(Unity) FROM NEW)

15.Find the average age of viewers for each genre. List the genres where the average age is higher than overall average

SELECT G.genre_name,
	   COUNT(N.c_id) Unity,
	   AVG(N.age) AS Average_Age
FROM Genre G
JOIN N_Customers N ON N.Show_id=G.show_id
GROUP BY G.genre_name
HAVING AVG(N.age)>(SELECT AVG(AGE) FROM N_Customers)
ORDER BY Unity ASC

 16. Show movies with higher than average ratings and the actors in them.

SELECT M.title,
	   STRING_AGG(C.cast_name,',') AS Casts,
	   N.movie_point 
FROM N_Customers N
JOIN Media_Data M  ON M.show_id=N.Show_id
JOIN Casts C ON C.show_id=M.show_id
GROUP BY M.show_id,M.title,N.movie_point
HAVING AVG(N.movie_point)> (SELECT AVG(movie_point) FROM N_Customers)
ORDER BY M.title ASC

17.	Calculate the average duration for each type.

SELECT Type,
		ROUND(AVG(CAST(LEFT(duration,CHARINDEX(' ',duration)) as float)),0) as AVG
FROM Media_Data
GROUP BY Type



