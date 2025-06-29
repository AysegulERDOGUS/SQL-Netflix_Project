
----SOLUTIONS----


1. Identify the longest movie for description 

SELECT * ,LEN(description) AS Length  
FROM   Media_Data
WHERE LEN(description) = (SELECT MAX(LEN(description)) FROM Media_Data)

2. Average Content Ratings by Device Type: Do Mobile or Desktop Users Give Higher Scores?

SELECT device, 
	   AVG(CAST (movie_point AS Float)) AS Avg_Point, 
	      CASE WHEN AVG(CAST (movie_point AS Float))>3.11 THEN 'Happy with the contents'
	    	    ELSE 'Unhappy'
	      END as Reaction,
   COUNT(CASE WHEN movie_point IS NULL THEN 1 END) AS No_Points_Count,
   COUNT(*) as Total_Customers,
	     (COUNT(CASE WHEN movie_point IS NULL THEN 1.0 END)/cast(COUNT(*)as float))*100 AS 
Ratio_For_NoPoints
FROM N_Customers
GROUP BY device
ORDER BY Avg_Point DESC

3. Find how many movies actor 'Salman Khan' appeared in last 10 years

SELECT C.cast_name , 
	   M.* 
FROM Media_Data M
JOIN Casts C ON C.show_id=M.show_id
WHERE C.cast_name='Salman Khan'
	  AND YEAR(GETDATE())-release_year<=10

4.Write a query that shows the success level (successful, unsuccessful, etc.) based on the average rating of directors who have directed at least 3 different productions. The result should include the director’s name, average rating, and success level.

SELECT  D.director_name,
		AVG(N.movie_point) AS Avg_Point,
		CASE 
			WHEN AVG(N.movie_point)>= 4 THEN 'Success'
			WHEN AVG(N.movie_point) BETWEEN 2.5 AND  4 THEN 'Average'
			ELSE 'Failure'
		END AS Class FROM N_Customers N

JOIN Media_Data M ON M.show_id=N.Show_id
JOIN Director D ON D.show_id=M.show_id
WHERE N.movie_point IS NOT NULL AND D.director_name <>''
GROUP BY D.director_name
HAVING COUNT(DISTINCT D.show_id)>=3
ORDER BY D.director_name ASC

5.Count the number of "United States" productions added between 2010-2020 that are categorized as both "Action" and "Drama." 

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

6. Find the first and last years of content created by directors.  

SELECT D.director_name AS Name,
	   MIN(M.release_year) AS First_Year,
	   Max(M.release_year) AS Last_Year
FROM Media_Data M
JOIN Director D ON D.show_id=M.show_id
WHERE D.director_name!=''
GROUP BY D.director_name
ORDER BY Name

7. For each genre that an actor has appeared in, list the actors name, genre name, the number of productions in that genre, and the average rating. Compare this average rating with the actor’s overall average rating and indicate their success level (such as successful or unsuccessful). 
Include only actors who have appeared in at least 4 different productions

WITH Class AS (SELECT G.genre_name,
					AVG(N.movie_point) AS General_Avg
					FROM N_Customers N
					JOIN Genre G ON G.show_id=N.Show_id
					WHERE N.movie_point IS NOT NULL
					GROUP BY G.genre_name
				)
SELECT C.cast_name,G.genre_name,
		COUNT(DISTINCT C.show_id) AS Show_Count,
		AVG(N.movie_point) AS Avg_Point,
		CASE
WHEN AVG(N.movie_point)>=CL.General_Avg THEN ' More successful in this genre'
WHEN AVG(N.movie_point)<CL.General_Avg THEN ' Less successful in this genre'
			ELSE 'Stable Performance'
		END AS Scale
FROM N_Customers N
JOIN Genre G ON G.show_id=N.Show_id
JOIN Casts C ON C.show_id=G.show_id
JOIN Class CL ON CL.genre_name=G.genre_name
WHERE N.movie_point IS NOT NULL AND  C.cast_name <>''
GROUP BY C.cast_name,G.genre_name,CL.General_Avg
HAVING COUNT(DISTINCT G.show_id)>4
ORDER BY C.cast_name DESC

8. Find the average release year of actors who have appeared in at least 10 different shows

SELECT C.cast_name, 
	   AVG(M.Release_year) AS Avg_Year 
FROM Casts C 
JOIN Media_Data M  ON M.show_id=C.show_id
GROUP BY C.cast_name
HAVING C.cast_name <> '' AND COUNT(DISTINCT M.title)>=10

9. Show how many different genres each actor has worked in. List actors who have worked in more than 10 genres.

SELECT c.cast_name,
	   COUNT(DISTINCT G.genre_name) as Unity
FROM Casts C
JOIN Genre G ON G.show_id=C.show_id
GROUP BY C.cast_name
HAVING C.cast_name <> '' AND COUNT(DISTINCT G.genre_name)>10
ORDER BY Unity DESC

10. Show the total number of films watched by the first 10 users who joined the platform and the average age of these users.

WITH New AS (SELECT *, 
	    		DENSE_RANK() OVER (ORDER BY N.membership_date) AS Sorting
FROM N_Customers N
			)
SELECT COUNT(DISTINCT show_id) as Unity,
	         AVG(age) Avg_Age 
FROM New
WHERE Sorting <= 10

11. Find the most watched genres. Write a query showing how many different users watched each genre.

SELECT  G.genre_name,
          COUNT(DISTINCT N.c_id) AS Unity
FROM Genre G
JOIN N_Customers N ON N.Show_id=G.show_id
GROUP BY G.genre_name
ORDER BY Unity DESC

12. How Do Users Ratings Deviate from the Average Score of Their Device Group ?

WITH STD AS ( SELECT c_id,first_name,
				 movie_point,
				 AVG(movie_point*1.0) OVER(PARTITION BY device) AS Avg_Point, 
				 ROUND(STDEVP(movie_point) OVER(PARTITION BY device),2) AS Std
				 FROM N_Customers
			 )

SELECT * ,
	          (Avg_Point-movie_point) AS Distance_From_Avg 
FROM STD
ORDER BY Distance_From_Avg DESC


 13.How many people log in to the platform on average every day? Which day of the week is the most busy day?

WITH NEW AS(SELECT Days,
	   COUNT(Show_id) AS Unity 
FROM N_Customers
GROUP BY Days)

SELECT Days,Unity 
FROM NEW
WHERE Unity=(SELECT MAX(Unity) FROM NEW)

14.Find the average age of viewers for each genre. List the genres where the average age is higher than overall average

SELECT G.genre_name,
	   COUNT(N.c_id) Unity,
	   AVG(N.age) AS Average_Age
FROM Genre G
JOIN N_Customers N ON N.Show_id=G.show_id
GROUP BY G.genre_name
HAVING AVG(N.age)>(SELECT AVG(Age) FROM N_Customers)
ORDER BY Unity ASC

 15. Show movies with higher than average ratings and the actors in them.

SELECT M.title,
	   STRING_AGG(C.cast_name,',') AS Casts,
	   N.movie_point 
FROM N_Customers N
JOIN Media_Data M  ON M.show_id=N.Show_id
JOIN Casts C ON C.show_id=M.show_id
GROUP BY M.show_id,M.title,N.movie_point
HAVING AVG(N.movie_point)> (SELECT AVG(movie_point) FROM N_Customers)
ORDER BY M.title ASC

16.Calculate the average duration for each type.

SELECT Type,
		ROUND(AVG(CAST(LEFT(duration,CHARINDEX(' ',duration)) as float)),0) as AVG
FROM Media_Data
GROUP BY Type


