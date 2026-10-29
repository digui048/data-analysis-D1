-- DAU
select count(distinct UserID, date(SessionStart)) / 365 as "Average DAU"
from SessionTable;

-- MAU
select count(distinct UserID, month(SessionStart)) / 12 as "Average MAU"
from SessionTable;

-- Stickiness
select (count(distinct UserID, date(SessionStart)) / 365) / (count(distinct UserID, month(SessionStart)) / 12) * 100 as "Stickiness %"
from SessionTable;

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
select sum(i.ItemPrice) / count(distinct u.UserID) as "ARPU"
from UsersTable u
left join SessionTable s on s.UserID = u.UserID
left join PurchaseTable p on p.SessionID = s.SessionID
left join ItemTable i on i.ItemID = p.ItemID;

-- ARPPU
select sum(i.ItemPrice) / count(distinct s.UserID) as "ARPPU"
from PurchaseTable p
join ItemTable i on i.ItemID = p.ItemID
join SessionTable s on s.SessionID = p.SessionID;

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