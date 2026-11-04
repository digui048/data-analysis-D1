-- DAU
select date(SessionStart), count(distinct UserID) as "DAU"
from SessionTable
group by date(SessionStart);

-- MAU
select date(s1.SessionStart) as Day, count(distinct s2.UserID) as MAU
from SessionTable s1
left join SessionTable s2
on s2.SessionStart >= date(s1.SessionStart) - interval 29 DAY
and s2.SessionStart < date(s1.SessionStart) + interval 1 DAY
group by date(s1.SessionStart);

-- Stickiness
select date(s1.SessionStart) as Day, count(distinct s1.UserID) / count(distinct s2.UserID) * 100 as "Stickiness %"
from SessionTable s1
left join SessionTable s2
on s2.SessionStart >= date(s1.SessionStart) - interval 29 day
and s2.SessionStart < date(s1.SessionStart) + interval 1 day
group by date(s1.SessionStart);

-- D1
select count(distinct s.UserID) / count(distinct u.UserID) * 100 as "D1 retention %"
from UsersTable u
left join SessionTable s
on s.UserID = u.UserID and date(s.SessionStart - interval 1 day) = date(u.UserDate);

-- D3
select count(distinct s.UserID) / count(distinct u.UserID) * 100 as "D3 retention %"
from UsersTable u
left join SessionTable s
on s.UserID = u.UserID and date(s.SessionStart - interval 3 day) = date(u.UserDate);

-- D7
select count(distinct s.UserID) / count(distinct u.UserID) * 100 as "D7 retention %"
from UsersTable u
left join SessionTable s
on s.UserID = u.UserID and date(s.SessionStart - interval 7 day) = date(u.UserDate);

-- ARPU
select date(s.SessionStart) as Day, sum(i.ItemPrice) / count(distinct s.UserID) as "ARPU"
from SessionTable s
left join PurchaseTable p on p.SessionID = s.SessionID
left join ItemTable i on i.ItemID = p.ItemID
group by date(s.SessionStart);

-- ARPPU
select date(p.PurchaseDate) as Day, sum(i.ItemPrice) / count(distinct s.UserID) as "ARPPU"
from PurchaseTable p
join ItemTable i on i.ItemID = p.ItemID
join SessionTable s on s.SessionID = p.SessionID
group by date(p.PurchaseDate);

-- Sessions per player
select count(*) as "Total sessions", count(*) / count(distinct UserID) as "Sessions per player"
from SessionTable;

-- Number of sessions
select UserID, count(SessionID) as "n Sessions"
from SessionTable
group by UserID
order by 2 desc;

-- Average session time in minutes
select avg(timestampdiff(second, SessionStart, SessionEnd) / 60) as "Average session minutes"
from SessionTable;




-- KPI EXTRACTION BY GROUPS

-- Country 1
select u.UserCountry as "Group",
       count(distinct u.UserID) as "Players",
       count(distinct s.SessionID) / count(distinct u.UserID) as "Sessions per player",
       avg(timestampdiff(second, s.SessionStart, s.SessionEnd) / 60) as "Avg session minutes",
       sum(i.ItemPrice) / count(distinct u.UserID) as "ARPU"
from UsersTable u
left join SessionTable s on s.UserID = u.UserID
left join PurchaseTable p on p.SessionID = s.SessionID
left join ItemTable i on i.ItemID = p.ItemID
group by u.UserCountry;

-- Country 2
select u.UserCountry as "Group",
       count(distinct s1.UserID) / count(distinct u.UserID) * 100 as "D1 %",
       count(distinct s3.UserID) / count(distinct u.UserID) * 100 as "D3 %",
       count(distinct s7.UserID) / count(distinct u.UserID) * 100 as "D7 %"
from UsersTable u
left join SessionTable s1 on s1.UserID = u.UserID and date(s1.SessionStart - interval 1 day) = date(u.UserDate)
left join SessionTable s3 on s3.UserID = u.UserID and date(s3.SessionStart - interval 3 day) = date(u.UserDate)
left join SessionTable s7 on s7.UserID = u.UserID and date(s7.SessionStart - interval 7 day) = date(u.UserDate)
group by u.UserCountry;

-- Country 3
select u.UserCountry as "Group",
       sum(i.ItemPrice) / count(distinct s.UserID) as "ARPPU"
from PurchaseTable p
join ItemTable i on i.ItemID = p.ItemID
join SessionTable s on s.SessionID = p.SessionID
join UsersTable u on u.UserID = s.UserID
group by u.UserCountry;

-- Age 1
select floor(u.UserAge / 10) * 10 as "Group",
       count(distinct u.UserID) as "Players",
       count(distinct s.SessionID) / count(distinct u.UserID) as "Sessions per player",
       avg(timestampdiff(second, s.SessionStart, s.SessionEnd) / 60) as "Avg session minutes",
       sum(i.ItemPrice) / count(distinct u.UserID) as "ARPU"
from UsersTable u
left join SessionTable s on s.UserID = u.UserID
left join PurchaseTable p on p.SessionID = s.SessionID
left join ItemTable i on i.ItemID = p.ItemID
group by floor(u.UserAge / 10) * 10;

-- Age 2
select floor(u.UserAge / 10) * 10 as "Group",
       count(distinct s1.UserID) / count(distinct u.UserID) * 100 as "D1 %",
       count(distinct s3.UserID) / count(distinct u.UserID) * 100 as "D3 %",
       count(distinct s7.UserID) / count(distinct u.UserID) * 100 as "D7 %"
from UsersTable u
left join SessionTable s1 on s1.UserID = u.UserID and date(s1.SessionStart - interval 1 day) = date(u.UserDate)
left join SessionTable s3 on s3.UserID = u.UserID and date(s3.SessionStart - interval 3 day) = date(u.UserDate)
left join SessionTable s7 on s7.UserID = u.UserID and date(s7.SessionStart - interval 7 day) = date(u.UserDate)
group by floor(u.UserAge / 10) * 10;

-- Age 3
select floor(u.UserAge / 10) * 10 as "Group",
       sum(i.ItemPrice) / count(distinct s.UserID) as "ARPPU"
from PurchaseTable p
join ItemTable i on i.ItemID = p.ItemID
join SessionTable s on s.SessionID = p.SessionID
join UsersTable u on u.UserID = s.UserID
group by floor(u.UserAge / 10) * 10;

-- Gender 1
select u.UserGender >= 0.5 as "Group",
       count(distinct u.UserID) as "Players",
       count(distinct s.SessionID) / count(distinct u.UserID) as "Sessions per player",
       avg(timestampdiff(second, s.SessionStart, s.SessionEnd) / 60) as "Avg session minutes",
       sum(i.ItemPrice) / count(distinct u.UserID) as "ARPU"
from UsersTable u
left join SessionTable s on s.UserID = u.UserID
left join PurchaseTable p on p.SessionID = s.SessionID
left join ItemTable i on i.ItemID = p.ItemID
group by u.UserGender >= 0.5;

-- Gender 2
select u.UserGender >= 0.5 as "Group",
       count(distinct s1.UserID) / count(distinct u.UserID) * 100 as "D1 %",
       count(distinct s3.UserID) / count(distinct u.UserID) * 100 as "D3 %",
       count(distinct s7.UserID) / count(distinct u.UserID) * 100 as "D7 %"
from UsersTable u
left join SessionTable s1 on s1.UserID = u.UserID and date(s1.SessionStart - interval 1 day) = date(u.UserDate)
left join SessionTable s3 on s3.UserID = u.UserID and date(s3.SessionStart - interval 3 day) = date(u.UserDate)
left join SessionTable s7 on s7.UserID = u.UserID and date(s7.SessionStart - interval 7 day) = date(u.UserDate)
group by u.UserGender >= 0.5;

-- Gender 3
select u.UserGender >= 0.5 as "Group",
       sum(i.ItemPrice) / count(distinct s.UserID) as "ARPPU"
from PurchaseTable p
join ItemTable i on i.ItemID = p.ItemID
join SessionTable s on s.SessionID = p.SessionID
join UsersTable u on u.UserID = s.UserID
group by u.UserGender >= 0.5;

-- Time 1
select month(u.UserDate) as "Group",
       count(distinct u.UserID) as "Players",
       count(distinct s.SessionID) / count(distinct u.UserID) as "Sessions per player",
       avg(timestampdiff(second, s.SessionStart, s.SessionEnd) / 60) as "Avg session minutes",
       sum(i.ItemPrice) / count(distinct u.UserID) as "ARPU"
from UsersTable u
left join SessionTable s on s.UserID = u.UserID
left join PurchaseTable p on p.SessionID = s.SessionID
left join ItemTable i on i.ItemID = p.ItemID
group by month(u.UserDate);

-- Time 2
select month(u.UserDate) as "Group",
       count(distinct s1.UserID) / count(distinct u.UserID) * 100 as "D1 %",
       count(distinct s3.UserID) / count(distinct u.UserID) * 100 as "D3 %",
       count(distinct s7.UserID) / count(distinct u.UserID) * 100 as "D7 %"
from UsersTable u
left join SessionTable s1 on s1.UserID = u.UserID and date(s1.SessionStart - interval 1 day) = date(u.UserDate)
left join SessionTable s3 on s3.UserID = u.UserID and date(s3.SessionStart - interval 3 day) = date(u.UserDate)
left join SessionTable s7 on s7.UserID = u.UserID and date(s7.SessionStart - interval 7 day) = date(u.UserDate)
group by month(u.UserDate);

-- Time 3
select month(u.UserDate) as "Group",
       sum(i.ItemPrice) / count(distinct s.UserID) as "ARPPU"
from PurchaseTable p
join ItemTable i on i.ItemID = p.ItemID
join SessionTable s on s.SessionID = p.SessionID
join UsersTable u on u.UserID = s.UserID
group by month(u.UserDate);