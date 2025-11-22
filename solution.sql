-- Netflix project
create table netflix(
             show_id varchar(6),
			 type varchar(10),
			 title varchar(150),
			 director varchar(208),
			 casts varchar(1000),
			 country varchar(150),
			 date_added varchar(50),
			 release_year int,
			 rating	varchar(10),
			 duration varchar(15),
			 listed_in varchar(100),
			 description varchar(250)
);
select * from netflix;
-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows
	select count(*), type from netflix
	group by type;

-- 2. Find the most common rating for movies and TV shows
	select type, rating, total_rating, rnk from
	 (select netflix.type, 
	         rating, 
			 count(*) as total_rating ,
	         rank() over(partition by netflix.type order by count(*) desc) as rnk
     from netflix
	 group by type, rating
	 order by type, count(*) desc)
	where rnk = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
	select * from netflix;
	where type = 'Movie' and
	      release_year = 2020;
		  
-- 4. Find the top 5 countries with the most content on Netflix
	select distinct(country), count(show_id) from 
	(select trim(unnest(string_to_array(country,','))) as country, show_id from netflix)
	group by country
	order by count(show_id) desc;

-- 5. Identify the longest movie
	select title, type, duration from netflix
	where duration is not null
	order by split_part(duration, ' ', 1):: int  desc;

-- 6. Find content added in the last 5 years
	select title, to_date(date_added, 'Month dd, yyyy') as date from netflix
    where to_date(date_added, 'Month dd, yyyy') >=  (select current_date  - interval '5 years');
	 
	
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
	select type, director from netflix
	where director ilike '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
	select type, title, duration from netflix
	where type = 'TV Show' and split_part(duration, ' ', 1)::int > 5;


-- 9. Count the number of content items in each genre
	select genre, count(*) from
	(select type, trim(unnest(string_to_array(listed_in, ','))) as genre from Netflix)
	group by genre;

	
-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
	select extract(year from(to_date(date_added, 'Month dd,yyyy'))) as year, 
		   count(*) as total_count,
	       count(*)::numeric/(select count(*) as total_count from netflix where country = 'India')::numeric * 100 as avg_per_year
	from netflix
	where country = 'India'
	group by year

-- 11. List all movies that are documentaries
	select title from (select trim(unnest(string_to_array(listed_in, ','))) as genre, title, type from Netflix)
	where type = 'Movie' and genre = 'Documentaries'; 

-- 12. Find all content without a director
	select * from netflix
	where director is null;
	
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
	select count(*) as actual_date from Netflix
	where casts ilike '%Salman Khan%' and
 	                   to_date(date_added, 'Month dd,yyyy') >= (select current_date - interval '10 years');

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
	select actual_casts , count(*) from 
	(select trim(unnest(string_to_array(casts, ','))) as actual_casts,* from Netflix)
	where country ilike '%India%'
	group by actual_casts
	order by count(*) desc
	limit 10;
	
-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
	select label, count(*) from
	(select 
	(case 
	when description ilike '%kill%' or description ilike '%violence' then 'bad'
	else 'good'
	end) as label, *
	from Netflix)
	group by label
