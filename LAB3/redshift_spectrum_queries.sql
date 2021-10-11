drop schema if exists spectrum;

create external schema spectrum
from data catalog
database 'default'
region 'us-east-1' 
iam_role 'arn:aws:iam::166573744155:role/DemoSpectrumRole';

select tripId, routeId, startTime, numOfFutureStops, 
currentStopSequence, currentStatus, stopId, currentTs
from spectrum.unknown limit 10;

--select all non-array fields 
select tripId, routeId, startTime, numOfFutureStops, 
currentStopSequence, currentStatus, stopId, currentTs
from spectrum.unknown limit 10;

--select future stop IDs for a trip  
select distinct f from spectrum.unknown t 
join t.futureStopIds f on true 
where tripId = '081100_FS..N'
order by currentTs;

--Total number of entries
select count (tripId) from spectrum.unknown

-- Number of trips started between two intervals 
select count(*) as numOfTrips, tripId, routeId, startTime from spectrum.unknown 
where startTime BETWEEN '2021-09-20 02:30:00' AND '2021-09-20 03:05:00'
group by tripId, routeId, startTime order by 4 desc;

-- Get future number of stops per trip and route at the moment 
select tripId, routeId, currentTs, sum(numOfFutureStops) from
(select tripId , routeId, currentTs, numOfFutureStops,
rank() over (order by currentTs) as rnk
from spectrum.unknown)
where rnk = 1
group by 1,2,3
order by 4 desc;
