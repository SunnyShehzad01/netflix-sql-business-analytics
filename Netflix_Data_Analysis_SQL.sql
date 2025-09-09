-- create database netflix_db;
-- use netflix_db;

select count(*) as records from netflix;

# Business problems

# 1. Count the Number of Movies vs TV Shows
select type, count(*) as total_content from netflix group by 1;

# 2. Find the Most Common Rating for Movies and TV Shows
select * from netflix;

# 3. List All Movies Released in a Specific Year (e.g., 2020)
select type, title, release_year 
	from netflix 
		where release_year = 2020 and type = 'movie';
        
# 4. Find the Top 5 Countries with the Most Content on Netflix
select country, count(*) as content_count 
	from netflix 
		where country is not null and country <> ''
			group by country 
            having content_count is not null
				order by content_count desc limit 5;
-- Top 5 countries are US (2806), India (972), United kingdom (419), Japan (245), South korea (199)

# 5. Identify the Longest Movie
select type, title, duration, cast(SUBSTRING_INDEX(duration, ' ', 1) as unsigned) as duration_mins 
	from netflix 
		where type='movie' 
			order by duration_mins desc limit 1;
            
-- The longest movie is 'Black Mirror: Bandersnatch', '312 min'

# 6. Find Content Added in the Last 5 Years
    
SELECT 
    type,
    title,
    date_added,
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS Year_added
FROM
    netflix
WHERE
    STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
ORDER BY STR_TO_DATE(date_added, '%M %d, %Y') DESC;
        

# 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select * from netflix where director = 'rajiv chilaka';

# 8. List All TV Shows with More Than 5 Seasons
with netflix_tvshows as (
	select type, title, duration, cast(substring_index(duration, ' ', 1) as unsigned) as no_of_seasons
		from netflix 
			where type='tv show'
) select * from netflix_tvshows 
	where no_of_seasons >= 5;

# 9. Count the Number of Content Items in Each Genre
with recursive genre_split as (
	SELECT 
		show_id,
        TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) as genre,
        SUBSTRING(listed_in, length(substring_index(listed_in, ',', 1))+ 2) as rest
			FROM netflix
				WHERE listed_in is not null and listed_in <> ''
		union all
	SELECT
		show_id,
        TRIM(substring_index(rest, ',', 1)),
        substring(rest, length(substring_index(rest, ',', 1))+ 2)
			from genre_split
            where rest <> ''
) select genre, count(*) as total_count
	from genre_split
		where genre is not null and genre <> ''
        group by genre
		order by total_count desc;

# 10.Find each year and the average numbers of content release in India on netflix.
select 
	release_year, 
	count(*) as movies_released, 
    round(avg(count(*)) over(), 2) as avg_movies_per_year
	from netflix
		where country = 'india'
			group by release_year
				order by release_year;
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;
SELECT 
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT release_year), 2) AS avg_titles_per_year
FROM netflix
WHERE country LIKE '%India%';

# 11. List All Movies that are Documentaries
with recursive genre_list as (    
select
	show_id,
    type,
    title, 
    Trim(substring_index(listed_in, ',', 1)) as genre,
    substring(listed_in, length(substring_index(listed_in, ',', 1))+2) as rest
    from netflix
		where listed_in is not null and listed_in <> ''
    
    union all
select 
	show_id,
    type,
    title,
    trim(substring_index(rest, ',', 1)),
    substring(rest, length(substring_index(rest, ',', 1))+2) as rest
    from genre_list
    where rest <> ''
)
select show_id, type, title, genre
	from genre_list
		where type = 'movie'
			and genre = 'documentaries';

# 12. Find All Content Without a Director
-- update netflix set director = null where director = '';
-- update netflix set cast = null where cast = '';
-- update netflix set country = null where country = '';

select * from netflix 
	where director is null;
    
# 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
with recursive cast_list as (
	select 
		show_id, type, title, release_year,
        trim(substring_index(cast, ',', 1)) as actors,
        substring(cast, length(substring_index(cast, ',', 1))+2) as rest
		from netflix
			where cast is not null and cast <> ''
		
        union all
	select
		show_id, type, title, release_year,
        trim(substring_index(rest, ',', 1)),
        substring(rest, length(substring_index(rest, ',', 1))+2)
        from cast_list
			where rest <> ''
) select show_id, type, title, actors, release_year
	from cast_list
		where actors is not null and actors <> ''
			and type = 'movie'
            and actors = 'salman khan'
            order by release_year;

# 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
with recursive cast_list as (
	select
		type, title, country,
        trim(substring_index(cast, ',', 1)) as actors,
        substring(cast, length(substring_index(cast, ',', 1))+2) as rest
	from netflix
		where cast is not null and cast <> ''
        
	union all
    
    select
		type, title, country,
        trim(substring_index(rest, ',', 1)),
        substring(rest, length(substring_index(rest, ',', 1))+2)
	from cast_list
		where rest <> ''
) select actors, count(title) as total_count
	from cast_list
		where country = 'india'
		group by actors
        order by total_count desc limit 10;

# 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

with recursive keyword_list as (
	select 
		show_id, type, title, release_year,
        trim(substring_index(description, ' ', 1)) as keywords,
        substring(description, length(substring_index(description, ' ', 1))+2) as rest
		from netflix
			where description is not null and description <> ''
		
        union all
	select
		show_id, type, title, release_year,
        trim(substring_index(rest, ' ', 1)),
        substring(rest, length(substring_index(rest, ' ', 1))+2)
        from keyword_list
			where rest <> ''
) select show_id, type, title, keywords
	from keyword_list
		where keywords = 'kill' or keywords = 'violence';