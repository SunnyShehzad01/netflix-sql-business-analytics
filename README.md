# NETFLIX-SQL-ANALYTICS

**Author:** Shehzad Khan

**Project:** Netflix SQL Analytics — Business Questions & Solutions

---

## Project Overview

This repository contains a complete SQL-based analysis of a Netflix-style dataset. The project demonstrates data cleaning, transformation, exploratory analysis, and business-focused SQL queries using **MySQL** (primary) and notes for **PostgreSQL** where relevant. The goal is to solve real analytical and business questions using SQL only — showcasing strong skills with **subqueries, joins, window functions, CTEs (including recursive CTEs), aggregation, and string/date manipulation**.

## Why this project?
* Apply advanced SQL techniques to a real-world entertainment dataset.
* Convert messy CSV fields into actionable analytics (split multi-value columns, parse dates and durations, handle missing values).
* Produce business insights that are easy to reproduce and share (CSV + `.sql` scripts).

## Dataset(s)
The data for this project is sourced from the Kaggle dataset:
- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

* **netflix.csv** (primary) — contains metadata for titles added to a streaming platform (movies & TV shows). Typical columns:

  * `show_id`, `title`, `type`, `director`, `cast`, `country`, `date_added`, `release_year`, `rating`, `duration`, `listed_in`

> Note: In this project some columns contain multi-values (comma-separated lists) and inconsistent formats (e.g., `date_added` like "September 25, 2021" and `duration` like "90 min"). The queries demonstrate practical ways to normalize and analyze this data in MySQL.

## What you'll find in this repo

* `schema.sql` — CREATE TABLE statements for the Netflix tables used in the analysis (MySQL-compatible).\\
* `load_data.sql` / `load_data_instructions.txt` — steps & commands to import `netflix.csv` into MySQL Workbench or `mysql` client.\\
* `Netflix_sql_business_analysis/` — organized SQL files grouped by queries:
* `README.md` — this file (detailed explanation and reproducible steps).

## Key Business Questions Solved (examples)

* Count by country and top countries by content.\\
* Top 5 countries with the most content (handles multi-valued `country` values).\\
* Longest movie (cleaning `duration` string to numeric minutes).\\
* Content added in the last 5 years (parse `date_added` text to DATE).\\
* Genre breakdown: splitting `listed_in` into individual genres and counting per genre.\\
* Average titles per year for a country.\\
* Replace empty director fields with `NULL` and display counts by director.\\
* Recursive CTE examples to normalize multi-value columns.

* **Type casting**

  * PostgreSQL: `value::numeric` or `::type`.\\
  * MySQL: `CAST(value AS SIGNED)` or `CAST(value AS DECIMAL(10,2))`.

## Reproducible Steps (MySQL Workbench / mysql CLI)

1. **Create database**

```sql
CREATE DATABASE netflix_analytics;
USE netflix_analytics;
```

2. **Create table**

* Use `schema.sql` included here. Example simplified table:

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

3. **Load CSV** (if `netflix.csv` is present and allowed to be added)

* If using `mysql` CLI and server allows `LOCAL` loads:

* import via MySQL Workbench: Table Data Import Wizard → select CSV.

4. **Run queries**


## Example Useful Queries (snippets)

**Replace empty directors with NULL**

```sql
UPDATE netflix
SET director = NULL
WHERE director = '';
```

**Longest movie (extract minutes)**

```sql
SELECT title, duration,
  CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS duration_minutes
FROM netflix
WHERE type = 'Movie'
ORDER BY duration_minutes DESC
LIMIT 1;
```

**Split `listed_in` into genres (recursive CTE)**

```sql
WITH RECURSIVE genre_split AS (
  SELECT id,
         TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
         TRIM(SUBSTRING(listed_in, LENGTH(SUBSTRING_INDEX(listed_in, ',', 1)) + 2)) AS rest
  FROM netflix
  WHERE listed_in IS NOT NULL AND listed_in <> ''

  UNION ALL

  SELECT id,
         TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS genre,
         TRIM(SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)) AS rest
  FROM genre_split
  WHERE rest <> ''
)
SELECT genre, COUNT(*) AS total_content
FROM genre_split
WHERE genre <> ''
GROUP BY genre
ORDER BY total_content DESC;
```

**Average titles per year in India (overall average)**

```sql
SELECT ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT release_year), 2) AS avg_titles_per_year
FROM netflix
WHERE country LIKE '%India%';
```

**Top 3 titles per country by editor\_rating**

```sql
WITH ranked AS (
  SELECT title, country, editor_rating,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY editor_rating DESC) AS rn
  FROM netflix
)
SELECT title, country, editor_rating
FROM ranked
WHERE rn <= 3;
```

## Insights & Conclusions

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

## License: **MIT License**

### Author:
**Shehzad Khan** — shehzad.khan0796@gmail.com

---
