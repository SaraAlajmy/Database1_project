CREATE PROC createAllTables 
as 
begin
CREATE TABLE System_User_ (username varchar(20) primary key ,password_ varchar(20))
CREATE TABLE Club(id int primary key IDENTITY, name_ varchar(20), location_ varchar(20))
CREATE TABLE Stadium(id int primary key IDENTITY, status_ bit, name_ varchar(20), capacity int, location_ varchar(20))
CREATE TABLE Club_Representative(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references System_User_,club_id int, foreign key(club_id) references Club(id) on delete SET NULL ON UPDATE CASCADE)
CREATE TABLE Stadium_Manager(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references System_User_(username),stadium_id int,foreign key(stadium_id)references Stadium(id) on delete SET NULL ON UPDATE CASCADE)
CREATE TABLE Fan(national_id int primary key, phone_number int, name_ varchar(20), address_ varchar(20), status_ bit, birth_date date, username varchar(20), foreign key(username) references System_User_(username) ON DELETE CASCADE ON UPDATE CASCADE)
CREATE TABLE Sports_Association_Manager(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references System_User_(username) ON DELETE CASCADE ON UPDATE CASCADE)
CREATE TABLE System_Admin(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references System_User_(username) ON DELETE CASCADE ON UPDATE CASCADE)
CREATE TABLE Match_(id int primary key IDENTITY, start_time datetime, end_time datetime,host_club_id int,guest_club_id int,foreign key(host_club_id) references club(id) ON DELETE no action ON UPDATE no action,FOREIGN key(guest_club_id) REFERENCES club(id)  ON DELETE no action ON UPDATE no action,stadium_id int,FOREIGN key(stadium_id) REFERENCES stadium(id) ON DELETE SET NULL ON UPDATE CASCADE)
CREATE TABLE Ticket(id int primary key IDENTITY, status_ bit,match_id int,foreign key (match_id) references Match_(id) on delete cascade)
CREATE TABLE Host_Request(id int primary key IDENTITY, status_ varchar(20), match_id int foreign key references match_(id)  ON DELETE CASCADE ON UPDATE CASCADE,manager_id int foreign key references Stadium_Manager(id) on delete NO ACTION on update NO ACTION ,representative_id int foreign key references Club_Representative(id) on delete cascade on update cascade)
CREATE TABLE Ticket_Buying_Transactions(fan_national_Id int foreign key references fan(national_id) ON DELETE SET NULL ON UPDATE CASCADE,ticket_id int foreign key references Ticket(id) ON DELETE CASCADE ON UPDATE CASCADE)
end

--EXEC createAllTables


    
GO
CREATE PROC dropAllTables 
as 
Begin
DROP TABLE Ticket_Buying_Transactions
DROP TABLE Host_Request
DROP TABLE Ticket
DROP TABLE Match_
DROP TABLE System_Admin
DROP TABLE Sports_Association_Manager
DROP TABLE Fan
DROP TABLE Stadium_Manager
DROP TABLE Club_Representative
DROP TABLE Stadium
DROP TABLE Club
DROP TABLE System_User_
end

GO
CREATE PROC dropAllProceduresFunctionsViews
AS
DROP PROC createAllTables
DROP PROC dropAllTables
DROP PROC clearAllTables
DROP VIEW allAssocManagers
DROP VIEW allClubRepresentatives
DROP VIEW allStadiumManagers
DROP VIEW allFans
DROP VIEW allMatches
DROP VIEW allTickets
DROP VIEW allClubs
DROP VIEW allStadiums
DROP VIEW allRequests
DROP PROC addAssociationManager
DROP PROC addNewMatch
DROP VIEW clubsWithNoMatches
DROP PROC deleteMatch
DROP PROC deleteMatchesOnStadium
DROP PROC addClub
DROP PROC addTicket
DROP PROC deleteClub
DROP PROC addStadium
DROP PROC deleteStadium
DROP PROC blockFan
DROP PROC unblockFan
DROP PROC addRepresentative
DROP FUNCTION viewAvailableStadiumsOn
DROP PROC addHostRequest
DROP FUNCTION allUnassignedMatches
DROP PROC addStadiumManager
DROP FUNCTION allPendingRequests
DROP PROC acceptRequest
DROP PROC rejectRequest
DROP PROC addFan
DROP FUNCTION upcomingMatchesOfClub
DROP FUNCTION availableMatchesToAttend
DROP PROC purchaseTicket
DROP PROC updateMatchHost
DROP VIEW matchesPerTeam
DROP VIEW clubsNeverMatched
DROP FUNCTION clubsNeverPlayed
DROP FUNCTION NumberOfTicketsForEachMatch --helper
DROP FUNCTION pastMatches --helper
DROP FUNCTION matchWithHighestAttendance
DROP FUNCTION matchesRankedByAttendance
DROP FUNCTION requestsFromClub


go
CREATE PROC clearAllTables 
as 
BEGIN
    Truncate TABLE System_User_;
    TRUNCATE TABLE Club_Representitave;
    TRUNCATE TABLE Stadium_Manager;
    TRUNCATE TABLE Fan;
    TRUNCATE TABLE Sports_Association_Manager;
    TRUNCATE TABLE System_Admin;
    TRUNCATE TABLE Ticket;
    TRUNCATE TABLE Club;
    TRUNCATE TABLE Host_Request;
    TRUNCATE TABLE Match_;
    TRUNCATE TABLE Stadium;
    truncate table Ticket_Buying_Transactions
END

GO
CREATE VIEW allAssocManagers
AS
SELECT s.username, u.password_,s.name_ 
FROM Sports_Association_Manager s ,System_User_ u
where s.username=u.username
go

CREATE VIEW allClubRepresentatives
AS
SELECT R.username, u.password_ ,R.name_ as Club_Rep_Name,C.name_ as Club_Name
From  Club_Representative R Inner join  System_User_ u on r.username=u.username INNER JOIN Club C ON R.club_id=C.id
go

Create VIEW allStadiumManagers
AS
SELECT M.username,u.password_, M.name_ as Stadium_Manager_Name, S.name_ as Stadium_Name
From Stadium_Manager M inner join System_User_ u on u.username=m.username INNER JOIN Stadium S ON M.stadium_id=S.id
go

Create VIEW allFans
As 
SELECT f.username ,u.password_,f.national_id, f.name_, f.status_, f.birth_date
From Fan f inner join System_User_ u on f.username=u.username

go
Create VIEW allMatches 
AS
SELECT c2.name_ as host_name,c1.name_ as guest_name , m.start_time
from Club c1,club c2, match_ m WHERE m.guest_club_ID=c1.id and m.host_club_id=c2.id

Go

Create View allTickets
As 
SELECT c2.name_ as host_name,c1.name_ as guest_name,s.name_,m.start_time
from club c1 ,club c2,match_ m, stadium s
where m.guest_club_ID=c1.id and m.host_club_id=c2.id and m.stadium_id =s.id
go

create view allClubs
AS 
select name_,location_
from club
GO

CREATE view allStadiums 
as
SELECT name_,location_, capacity,status_
from Stadium

go

create view allRequests
as
select r.name_ as Club_rep_name,s.name_ as Stadium_Manager_name,h.status_
from Club_Representative r,Stadium_Manager s,Host_Request h
where h.manager_id=s.id and h.representative_id=r.id
go

CREATE proc addAssociationManager 
@name_ varchar(20),
@username varchar(20),
@pass varchar(20)
as
begin
insert into System_User_ VALUES (@username,@pass)
insert into Sports_Association_Manager values (@name_,@username)
END
Go

create proc addNewMatch
@club1_name varchar(20),
@club2_name varchar(20),
@start_time DATETIME,
@end_time DATETIME
as 
BEGIN
DECLARE @c1 int
SELECT @c1=c.id from club c where c.name_=@club1_name
DECLARE @c2 INT
SELECT @c2=c.id from club c where c.name_=@club2_name
insert into match_ values(@start_time,@end_time,@c1,@c2,null)
END
Go

create view clubsWithNoMatches
AS SELECT c.name_ from club c
where 
not exists (select * from match_ m where m.host_club_id=c.id or m.guest_club_id=c.id )
GO
create proc deleteMatch
@club1 varchar(20),
@club2 varchar(20)
as begin 
declare @host_id INT 
SELECT @host_id=c.id from club c where c.name_=@club1 
declare @guest_id INT 
SELECT @guest_id=c.id from club c where c.name_=@club2 
DELETE from match_ where host_club_id=@host_id and guest_club_id=@guest_id
END
GO

create proc deleteMatchesOnStadium
@stad varchar(20)
as BEGIN
declare @stad_id int
select @stad_id=id from Stadium where name_=@stad
DELETE from match_  where stadium_id=@stad_id and start_time < CURRENT_TIMESTAMP
END
GO

create proc addClub
@name varchar(20),
@location varchar(20)
as begin
INSERT into club values (@name,@location);
END
GO

create proc addTicket 
@host varchar(20),
@guest varchar(20),
@time DATETIME
as BEGIN
declare @hid INT
SELECT @hid=id from club where name_=@host
declare @gid INT
select @gid=id from club where name_=@guest
declare @mid INT
select @mid=id from match_ where host_club_id=@hid and guest_club_id=@gid and start_time=@time
insert into ticket values (1,@mid);
END
GO

create proc deleteClub
@name varchar(20)
as BEGIN
DELETE from Match_ where id IN (Select t.id From Match_ t INNER JOIN Club g ON t.guest_club_id=g.id INNER JOIN Club h ON t.host_club_id=h.id  where (g.name_ = @name) or (h.name_ = @name))
DELETE from club where name_=@name;
END

GO

create procedure addStadium 
@nameV varchar(20),
@locationV varchar(20),
@capacityV int
As 
Begin
Insert into Stadium (status_, name_, capacity, location_) values(1, @nameV, @capacityV, @locationV);
End
Go

create procedure deleteStadium
@nameV varchar(20)
As 
Begin
Delete From Stadium Where name_= @nameV;
End
go

create procedure blockFan
@national_idV varchar(20)
As
Begin
Update Fan
Set status_ = 1
Where national_id = @national_idV;
End
go

create procedure unblockFan
@national_idV varchar(20)
As
Begin
Update Fan
Set status_ = 0
Where national_id = @national_idV;
End
go

create procedure addRepresentative 
@nameV varchar(20),
@club_nameV varchar(20),
@usernameV varchar(20),
@passwordV varchar(20)
As 
Begin
Insert into System_User_ values (@usernameV, @passwordV);
Insert into club_representative (name_, username, club_ID) values(@nameV, @usernameV, (Select id From Club where name_ = @club_nameV));
End
go

create function viewAvailableStadiumsOn
(@dateV datetime)
Returns Table
As 
	Return (Select Stadium.name_, Stadium.location_, Stadium.capacity From (Stadium Left Outer Join Match_ ON Stadium.id = Match_.stadium_id) Where (status_ = 1) and ((Match_.start_time <> @dateV) or Match_.id IS NULL));
go

create procedure addHostRequest 
@club_nameV varchar(20),
@stadium_nameV varchar(20),
@start_timeV datetime
As 
Begin
Insert into Host_Request (status_, match_id, manager_id, representative_id) values 
('unhandled', (select id from Match_ where start_time = @start_timeV and host_club_id = (Select id from Club where name_ = @club_nameV)), (select Stadium_Manager.id from Stadium_Manager Inner Join Stadium ON Stadium_Manager.stadium_id = Stadium.id where Stadium.name_ = @stadium_nameV), (select Club_Representative.id from Club_Representative Inner Join Club ON Club_Representative.club_ID = Club.id where Club.name_ = @club_nameV)); 
End
go

create function allUnassignedMatches
(@club_nameV varchar(20))
Returns Table
As
	Return (Select HC.name_, M.start_time From (Match_ M Inner Join Club HC ON M.host_club_id = HC.id Inner Join Club GC ON M.guest_club_id = GC.id) Where (HC.name_ = @club_nameV) and (M.stadium_id IS NULL));
go

create procedure addStadiumManager
@nameV varchar(20),
@stadium_nameV varchar(20),
@usernameV varchar(20),
@passwordV varchar(20)
As 
Begin
insert into System_User_ values(@usernameV, @passwordV);
insert into Stadium_Manager values(@nameV, @usernameV, (select id from Stadium where name_ = @stadium_nameV));
End
go


create function allPendingRequests
(@stadium_manager_name varchar(20))
Returns table
As

return (select r.name_ as Club_Rep_Name,g.name_ as Club_Name,m.start_time from Stadium_Manager s
inner join Host_Request h on h.manager_id=s.id
inner join Club_Representative r on r.id=h.representative_id
inner join Match_ m on h.match_id=m.id
inner join club g on m.guest_club_id=g.id
where s.username=@stadium_manager_name and h.status_='unhandled')


Go
create proc acceptRequest
@stadium_manager_username varchar(20),
@hosting_club_name varchar(20),
@guest_club_name varchar(20),
@start_time datetime
As
Begin 
UPDATE Host_Request
Set status_='accepted'
where id =
(select h.id from Host_Request h
inner join Stadium_Manager s  on s.id=h.manager_id
inner join Match_ m on h.match_id=m.id
inner join club as host on m.host_club_id=host.id
inner join club as guest on m.guest_club_id=guest.id
where s.username=@stadium_manager_username 
and host.name_=@hosting_club_name
and guest.name_=@guest_club_name
and m.start_time=@start_time);
UPDATE Match_
Set stadium_id = (Select s.stadium_id From Host_Request h
inner join Stadium_Manager s  on s.id=h.manager_id
inner join Match_ m on h.match_id=m.id
inner join club as host on m.host_club_id=host.id
inner join club as guest on m.guest_club_id=guest.id
where s.username=@stadium_manager_username 
and host.name_=@hosting_club_name
and guest.name_=@guest_club_name
and m.start_time=@start_time)
declare @i int =0
while @i< (Select capacity From Stadium Inner Join Stadium_Manager ON Stadium.id = Stadium_Manager.stadium_id Where @stadium_manager_username = username)
Begin
EXEC addTicket @host = @hosting_club_name , @guest = @guest_club_name, @time = @start_time;
SET @i = @i+1
End
End

Go
create proc rejectRequest 
@stadium_manager_username varchar(20),
@hosting_club_name varchar(20),
@guest_club_name varchar(20),
@start_time datetime
As
Begin
Update Host_Request 
Set status_='rejected'
where id =
(select h.id from Host_Request h
inner join Stadium_Manager s  on s.id=h.manager_id
inner join Match_ m on h.match_id=m.id
inner join club as host on m.host_club_id=host.id
inner join club as guest on m.guest_club_id=guest.id
where s.username=@stadium_manager_username 
and host.name_=@hosting_club_name
and guest.name_=@guest_club_name
and m.start_time=@start_time)
End

Go
create proc addFan
@fan_name varchar(20),
@fan_username varchar(20),
@fan_pass varchar(20),
@fan_national_id varchar(20),
@fan_birth_date datetime,
@fan_address varchar(20),
@fan_phone_number int
As
Begin
Insert into System_User_ values(@fan_username,@fan_pass)
Insert into Fan(name_,username,national_id,birth_date,address_,phone_number) values
(@fan_name,@fan_username,@fan_national_id ,@fan_birth_date,@fan_address,@fan_phone_number)
End

Go
create function upcomingMatchesOfClub
(@club_name varchar(20))
returns table
as

return(select c1.name_ as host_name ,c2.name_ as guest_name ,m.start_time,s.name_ as Stadium_name from Club c1
inner join Match_ m on c1.id=m.host_club_id or c1.id=m.guest_club_id
inner join Club c2 on c2.id=m.guest_club_id or c2.id=m.host_club_id
inner join Stadium s on s.id=m.stadium_id
where m.start_time> CURRENT_TIMESTAMP and c1.name_=@club_name)


Go
create function availableMatchesToAttend
(@date datetime)
returns table
as

return(select h.name_ as host_name ,g.name_ as guest_name,m.start_time,s.name_ as Stadium_name from Match_ m
inner join Club h on h.id=m.host_club_id
inner join Club g on g.id=m.guest_club_id
inner join Stadium s on s.id=m.stadium_id
where m.start_time>=@date and m.id in
(select m1.id from Ticket t 
inner join Match_ m1 on t.match_id=m.id
where t.status_=1
Group by m1.id
having count(t.id)<>0))


Go
create proc purchaseTicket
@fan_national_id varchar(20) ,
@hosting_club_name varchar(20),
@competing_club_name varchar(20),
@match_start_time datetime
as
Begin
DECLARE @ticket_id varchar(20)
select @ticket_id = min(t.id) from Ticket t 
inner join Match_ m on t.match_id=m.id
inner join Club as host on host.id=m.host_club_id
inner join Club as guest on guest.id=m.guest_club_id
where t.status_=1 
and host.name_=@hosting_club_name 
and guest.name_=@competing_club_name 
and m.start_time =@match_start_time 

insert into Ticket_Buying_Transactions values (@fan_national_id,@ticket_id)

update Ticket 
Set status_=0
where id=@ticket_id
End

Go
CREATE PROC updateMatchHost
@host_club_name varchar(20),
@guest_club_name varchar(20),
@match_start_time datetime
AS
Begin
DECLARE @match_id varchar(20)
DECLARE @host_club_id varchar(20)
DECLARE @guest_club_id varchar(20)
SELECT @match_id = m.id, @host_club_id = m.host_club_id,@guest_club_id = m.guest_club_id 
FROM Match_ as m
inner join Club as host on host.id=m.host_club_id
inner join Club as guest on guest.id=m.guest_club_id
where @host_club_name = host.name_ and @guest_club_name = guest.name_ and @match_start_time = m.start_time
 

 update Match_
 Set host_club_id = @guest_club_id 
 where id = @match_id 

 update Match_
 Set guest_club_id = @host_club_id 
 where id = @match_id
 End

 Go
 CREATE VIEW matchesPerTeam
 AS

 SELECT C.name_, count(*) as count_matches
 FROM Match_ M INNER JOIN Club C
 ON M.host_club_id = C.id OR M.guest_club_id = C.id
 GROUP BY C.name_
 Go

 CREATE VIEW clubsNeverMatched
 AS
 SELECT C3.name_ as first_, C4.name_ as second_
 FROM Club C3, Club C4
 WHERE C3.id <> C4.id
 EXCEPT( 
 SELECT C1.name_ as first_, C2.name_ as second_
 FROM Match_ M 
 INNER JOIN Club C1 
 ON M.host_club_id = C1.id
 INNER JOIN Club C2 
 ON M.guest_club_id = C2.id
 )
 Go

 create function clubsNeverPlayed
(@club_name varchar(20))
returns table
AS

return(
SELECT C.name_
FROM Club C 
WHERE NOT EXISTS( SELECT *
FROM Match_ M
INNER JOIN CLUB C
ON C.id = M.host_club_id
INNER JOIN CLUB C1
ON C1.id = M.guest_club_id
WHERE C1.name_ = @club_name)
AND
NOT EXISTS( SELECT *
FROM Match_ M
INNER JOIN CLUB C
ON C.id = M.guest_club_id
INNER JOIN CLUB C2 
ON C2.id = M.host_club_id
WHERE C2.name_ = @club_name)
)   
Go

--helper function
CREATE FUNCTION NumberOfTicketsForEachMatch()
returns table
AS

return(
	SELECT C1.name_ as host_name, C2.name_ as guest_name, count(T.id) as count_tickets 
	FROM Match_ M
	INNER JOIN Club C1 ON C1.id = M.host_club_id
	INNER JOIN Club C2 ON C2.id = M.guest_club_id
	INNER JOIN Ticket T ON M.id = T.match_id
    GROUP BY  C1.name_, C2.name_
)
go


go
CREATE FUNCTION matchWithHighestAttendance()
returns table
AS

return(
	SELECT TOP 1 host_name, guest_name FROM 
	NumberOfTicketsForEachMatch()
    ORDER BY count_tickets desc
    
)

Go
CREATE FUNCTION pastMatches()
returns table
AS
return (
SELECT C1.name_ as guest_name, C2.name_ as host_name, count(T.id) as count_tickets
FROM Match_ M
INNER JOIN Club C1 ON C1.id = M.host_club_id
INNER JOIN Club C2 ON C2.id = M.guest_club_id
INNER JOIN Ticket T ON M.id = T.match_id
WHERE M.end_time < CURRENT_TIMESTAMP
GROUP BY C1.name_, C2.name_
)


go
CREATE FUNCTION matchesRankedByAttendance()
returns table
AS
return(
SELECT TOP 100 PERCENT host_name, guest_name 
FROM
pastMatches()
ORDER BY count_tickets desc
)
    
GO
CREATE FUNCTION requestsFromClub
(@stadium_name Varchar(20), @club_name varchar(20))
returns table
AS
return(
SELECT C1.name_ as host_name, C2.name_ as guest_name
FROM Match_ M INNER JOIN Club C1 ON C1.id = M.host_club_id
INNER JOIN Club C2 ON C2.id = M.guest_club_id
INNER JOIN Host_Request H ON H.match_id = M.id
INNER JOIN Stadium_Manager SM ON H.manager_id = SM.id
INNER JOIN Stadium S ON SM.stadium_id = S.id
INNER JOIN Club_Representative CR ON CR.id = H.representative_id
INNER JOIN Club C ON C.id = CR.club_id
WHERE S.name_ = @stadium_name and CR.name_ = @club_name
)
