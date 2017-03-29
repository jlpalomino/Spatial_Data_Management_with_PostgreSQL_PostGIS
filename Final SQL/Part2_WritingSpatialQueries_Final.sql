/* To run a query, highlight the line(s) to include the ; and click on the Executy Query icon above (looks like a Play button). */

/* Section 2 - Writing Spatial Queries */

/* First, let's do a quick review of the lessons learned for select by attributes */
/* It can be helpful to check what version of PostgreSQL and PostGIS you are using, so that you reference documentation */
select version();
select PostGIS_full_version();

/* Select first ten records from a table so you can see the table structure */
select * from cnty_Lyme_disease
limit 10; 

/* Select all records in the table and sort ASCENDING for 2005 values*/
select * from cnty_Lyme_disease
order by "2005"; 


/* */
/* Task #1 - repeat the query to sort DESCENDING for 2014 */
/* */ 
/* Hint - http://www.postgresqltutorial.com/postgresql-order-by */
select * from cnty_Lyme_disease
order by "2014" DESC; 


/* Select all records that have a 0 for year 2005 */
select * from cnty_Lyme_disease
where "2005" = 0
order by "2005"; 


/* */
/* Task #2 - Select all records that do NOT have a 0 for year 2014 */
/* */ 
/* Hint: https://www.postgresql.org/docs/9.5/static/functions-comparison.html*/
select * from cnty_Lyme_disease
where "2014" != 0
order by "2014"; 


/* Count how many counties have a 0 for 2008 */
select count(*) from cnty_Lyme_disease
where "2008" = 0; 

/* */
/* Task #3 - Count how many counties do NOT have a 0 for 2012 */
/* */ 
/* Hint: https://www.postgresql.org/docs/9.5/static/functions-comparison.html*/
select count(*) from cnty_Lyme_disease
where "2012" != 0; 


/* See which tables in database contain geometries */
select * from geometry_columns;
/* Note: rasters are not considered geometry */
/* 3310 is for the projection called California Teale Albers, NAD 83, which has units = meters */

/* See which tables are in raster format */
select * from raster_columns;


/* Now, the spatial fun can begin! */
/* Select by Location Queries */

/* Spatial Join */
/* Create one table that joins the county name from cnty_Lyme_disease to each tick location */
select cdph_ticks_albers.*, cnty_Lyme_disease.* 
from cnty_Lyme_disease
join cdph_ticks_albers 
on ST_Contains (cnty_Lyme_disease.geom, cdph_ticks_albers.geom)
order by cnty_Lyme_disease.county;


/* */
/* Task 4 - use the previous query to join the EPA ecoregion (epa_eco13_albers) to each tick location */
/* */
select cdph_ticks_albers.*, epa_eco13_albers.* 
from epa_eco13_albers 
join cdph_ticks_albers
on ST_Contains (epa_eco13_albers.geom, cdph_ticks_albers.geom)
order by epa_eco13_albers.us_l3name;


/* Spatial Join with Count */
/* Count the number of tick locations in each county, sorted in descending order by count */
select b.county, count(a.gid)
from cdph_ticks_albers AS a 
join cnty_Lyme_disease AS b 
on ST_Contains (b.geom, a.geom)
group by b.county
order by count(a.gid) DESC;


/* */
/* Task 5 - Order the previous query by county in ASCENDING order */
/* */
/* Hint - http://www.postgresqltutorial.com/postgresql-order-by */
select b.county, count(a.gid)
from cdph_ticks_albers AS a 
join cnty_Lyme_disease AS b 
on ST_Contains (b.geom, a.geom)
group by b.county
order by b.county;
/* Also, how many counties do NOT have any tick locations? */
/* Hint - there are 58 counties in California, but how many records do you get for the Spatial Join with Count? */
/* Answer - 58 counties minus 49 records, so 9 counties do NOT have any tick locations */


/* */
/* Task 6 - Count the number of tick locations in each EPA ecoregion (epa_eco13_albers), sorted in descending order by count */
/* */
/* Hint - you need to find a column in epa_eco13_albers that you can group the count by */
select b.us_l3name, count(a.gid)
from cdph_ticks_albers AS a 
join epa_eco13_albers AS b 
on ST_Contains (b.geom, a.geom)
group by b.us_l3name
order by count(a.gid) DESC;


/* Get the list of tick locations for Alameda county only */
select * from cdph_ticks_albers, cnty_Lyme_disease
where ST_INTERSECTS(cdph_ticks_albers.geom,
cnty_Lyme_disease.geom)
AND cnty_Lyme_disease.county = 'Alameda';


/* */
/* Task 7 - get the list of tick locations for EPA region called Central California Valley */ 
/* */
/* Hint - review the table epa_eco13_albers to see which columns contain the names of the regions */
select * from epa_eco13_albers;

select * from cdph_ticks_albers, epa_eco13_albers
where ST_INTERSECTS(cdph_ticks_albers.geom,
epa_eco13_albers.geom)
AND epa_eco13_albers.us_l3name = 'Central California Valley';


/*  We can also find all the CDPH tick locations within a certain distance of a point using ST_DWithin */
/* Again, the units are meters */
/* Berkeley (Long = -122.264653, Lat 37.872629) */
select a.* 
FROM cdph_ticks_albers as a 
where ST_DWithin(a.geom, ST_Transform(ST_SetSRID(ST_MakePoint(-122.264653, 37.872629), 4326), 3310), 10000);


/* Example of calculating area very quickly */
/* Returns in SRID units: for California Teale Albers (ESPG 3310), this is meters */
/* More info: http://postgis.net/docs/ST_Area.html */
select county, Sum(ST_Area(geom))
from cnty_Lyme_disease 
group by county;


/* We can also convert from sq meters to sq kilometers in the query 
/* 1 sq kilo =	1,000,000 sq meters */
/* ex: Alameda County where you are right now is 2,130 km2 according to Wikipedia */
select county, Sum(ST_Area(geom))/1000000
from cnty_Lyme_disease 
group by county;



/* Return to PDF instructions to move on to the next part of the exercise! */
/* Save these queries below in the QGIS SQL window in the next part of the exercise! */

/* We can dynamically buffer geometries with PostGIS using the ST_Buffer function */
/* Again, the units are meters */
select gid, ST_Buffer(geom, 5000) as geom FROM cdph_ticks_albers;

/*  We can also find all the CDPH tick locations within a certain distance of a point using ST_DWithin */
/* Berkeley (Long = -122.264653, Lat 37.872629) */
select a.* FROM cdph_ticks_albers as a 
where ST_DWithin(a.geom, ST_Transform(ST_SetSRID(ST_MakePoint(-122.264653, 37.872629), 4326), 3310), 10000);

/* Find all tick locations within 10km of the Alameda County boundary */
select a.* 
from cdph_ticks_albers as a 
where ST_DWithin(a.geom, (SELECT geom FROM cnty_lyme_disease WHERE county = 'Alameda'), 10000);

/* Combine Buffer and Intersection with our user defined point to retrieve the spatial intersection of a 10km buffer around the Berkeley point within the county of Alameda */
select a.gid, a.county, ST_Intersection(geom, ST_Buffer(ST_Transform(ST_SetSRID(ST_MakePoint(-122.264653, 37.872629), 4326), 3310), 10000)) as geom 
from cnty_lyme_disease as a 
where a.county = 'Alameda';


/* More spatial query examples */
/* http://postgis.net/docs/using_postgis_dbmanagement.html#examples_spatial_sql  */
/* https://2015.foss4g-na.org/session/advanced-spatial-analysis-postgis.html */
/* https://2015.foss4g-na.org/session/postgis-feature-frenzy.html */

/* General Useful PostGIS Resources */
/* Vector Data Management: http://postgis.net/docs/using_postgis_dbmanagement.html#idm2005 */
/* Raster Data Management: http://postgis.net/docs/using_raster_dataman.html#RT_Raster_Loader */
/* FAQ about rasters in PostGIS: http://postgis.net/docs/RT_FAQ.html */
     


