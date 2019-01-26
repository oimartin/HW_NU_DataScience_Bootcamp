-- Use sakila database
use sakila;

-- 1a. Display first and last names of all actors
select first_name, last_name from actor;

-- 1b. Display actor name in one column
alter table actor
add Actor_Name varchar(40);

update actor 
set Actor_name = concat(first_name, ' ', last_name);

select * from actor;

-- 2a. Find info for actor named 'Joe'

select actor_id, Actor_Name
from actor
where first_name = 'Joe';

-- 2b. Fina all actors whose last name contains the letters GEN
select actor_id, Actor_Name
from actor
where first_name like '%G%E%N%';



