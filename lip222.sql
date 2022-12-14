CREATE PROC createAllTables 
as 

CREATE TABLE SystemUser (username varchar(20) primary key ,password_ varchar(20))
CREATE TABLE Club(id int primary key IDENTITY, name_ varchar(20), location_ varchar(20))
CREATE TABLE Stadium(id int primary key IDENTITY, status_ bit, name_ varchar(20), capacity int, location_ varchar(20))
CREATE TABLE Club_Representative(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser,club_id int, foreign key(club_id) references Club(id))
CREATE TABLE Stadium_Manager(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username),stadium_id int,foreign key(stadium_id)references Stadium(id))
CREATE TABLE Fan(national_id int primary key, phone_number int, name_ varchar(20), address_ varchar(20), status_ bit, birth_date date, username varchar(20), foreign key(username) references SystemUser(username))
CREATE TABLE Sports_Association_Manager(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username))
CREATE TABLE System_Admin(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username))
CREATE TABLE Match_(id int primary key IDENTITY, start_time datetime, end_time datetime,host_club_id int,guest_club_id int,foreign key(host_club_id) references club(id),FOREIGN key(guest_club_id) REFERENCES club(id),stadium_id int,FOREIGN key(stadium_id) REFERENCES stadium(id) )
CREATE TABLE Ticket(id int primary key IDENTITY, status_ bit,match_id int,foreign key (match_id) references Match_(id))
CREATE TABLE Host_Request(id int primary key IDENTITY, status_ varchar(20), match_id int foreign key references match(id),manager_id int foreign key references Stadium_Manager(id),representative_id int foreign key references Club_Representative(id))
CREATE TABLE Ticket_Buying_Transactions(fan_national_Id int foreign key references fan(national_id),ticket_id int foreign key references Ticket(id))

--EXEC createAllTables;
GO
CREATE PROC dropAllTables 
as 
Begin
    DROP TABLE SystemUser;
    DROP TABLE Club_Representative;
    DROP TABLE Stadium_Manager;
    DROP TABLE Fan;
    DROP TABLE Sports_Association_Manager;
    DROP TABLE System_Admin;
    DROP TABLE Ticket;
    DROP TABLE Club;
    DROP TABLE Host_Request;
    DROP TABLE Match_;
    DROP TABLE Stadium;
    DROP table Ticket_Buying_Transactions
end

go
CREATE PROC clearAllTables 
as 
BEGIN
    Truncate TABLE SystemUser;
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
SELECT s.username, u.password,s.name_ 
FROM Sports_Association_Manager s ,SystemUser u
where s.username=u.username
go

CREATE VIEW allClubRepresentatives
AS
SELECT R.username, u.password_ ,R.name_,C.name_
From  Club_Representative R Inner join  SYSTEMUser u on r.username=u.username INNER JOIN Club C ON R.club_id=C.id
go

Create VIEW allStadiumManagers
AS
SELECT M.username,u.password_, M.name_, S.name_
From Stadium_Manager M inner join systemuser u on u.username=m.username INNER JOIN Stadium S ON M.stadium_id=S.id
go

Create VIEW allFans
As 
SELECT f.username ,u.password_,f.national_id, f.name_, f.status_, f.birthdate
From Fan f inner join systemuser u on f.username=u.username

go
Create VIEW allMatches 
AS
SELECT c2.name_,c1.name_ , m.start_time
from Club c1,club c2, match_ m WHERE m.guest_club_ID=c1.id and m.host_club_id=c2.id

Go

Create View allTickets
As 
SELECT c2.name_,c1.name_,s.name_,m.start_time
from club c1 ,club c2,match_ m, stadium s
where m.guest_club_ID=c1.id and m.host_club_id=c2.id and m.stadium_id =s.id
go

create view allClubs
AS 
select name_,location_
from club
GO

CREATE view allStadiums --AvailBLE WALA LAA
as
SELECT s.name_,s.location_,s.capacity,s.status
from Stadium

go

create view allRequests
as
select r.name_,s.name_,h.status_
from Club_Representative r,Stadium_Manager s,Host_Request h
where h.manager_id=s.id and h.representative_id=r.id
go

CREATE proc addAssociationManager 
@name_ varchar(20),
@username varchar(20),
@pass varchar(20)
as
begin
insert into SystemUser VALUES (@username,@pass)
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
SELECT @c1=c.id from club c where c.name_=@club1.name
DECLARE @c2 INT
SELECT @c2=c.id from club c where c.name_=@club2.name
insert into match_ values(start_time,end_time,@c1,@c2,null)
END
Go

-- create function return_g_name
-- (@club1_name varchar(20),@club2_name varchar(20),@host_name varchar(20))
-- RETURNS int
-- AS
-- Begin
-- DECLARE @res INT
-- if @club1_name=@host_name
-- SELECT @res= c.id FROM club c where c.name_=@club2_name
-- else select @res= c.id FROM club c where c.name_=@club1_name
-- return @res
-- end
-- GO


create view clubsWithNoMatches
AS SELECT c.id from club 
where 
not exists (select * from match_ m where m.host_club_id=c.id or m.guest_club_id=c.id )
GO
create proc deleteMatch
@club1 varcahr(20),
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
DELETE from club where name_=@name; --should i delete matches or add on delete cascade cons??
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
Go;

create procedure deleteStadium
@nameV varchar(20)
As 
Begin
Delete From Stadium Where name_= @nameV;
End
Go;

create procedure blockFan
@national_idV varchar(20)
As
Begin
Update Fan
Set status_bit = 1
Where national_id = @national_idV;
End
Go;

create procedure unblockFan
@national_idV varchar(20)
As
Begin
Update Fan
Set status_bit = 0
Where national_id = @national_idV;
End
Go;

create procedure addRepresentative 
@nameV varchar(20),
@club_nameV varchar(20),
@usernameV varchar(20),
@passwordV varchar(20)
As 
Begin
Insert into SystemUser values (@usernameV, @passwordV);
Insert into club_representative (name_, username, club_ID) values(@nameV, @usernameV, (Select id From Club where name_ = @club_nameV));
End
Go;

create procedure addHostRequest 
@club_nameV varchar(20),
@stadium_nameV varchar(20),
@start_timeV datetime
As 
Begin
Insert into Host_Request (status_, match_id, manager_id, representative_id) values 
('unhandled', (select id from Match_ where start_time = @start_timeV and host_club_id = (Select id from Club where name_ = @club_nameV)), (select Stadium_Manager.id from Stadium_Manager Inner Join Stadium ON Stadium_Manager.studium_id = Stadium.id where Stadium.name_ = @stadium_nameV), (select Club_Representative.id from Club_Representative Inner Join Club ON Club_Representative.club_ID = Club.id where Club.name_ = @club_nameV)); 
End
Go;


create procedure addStadiumManager
@nameV varchar(20),
@stadium_nameV varchar(20),
@usernameV varchar(20),
@passwordV varchar(20)
As 
Begin
insert into SystemUser values(@usernameV, @passwordV);
insert into Stadium_Manager values(@nameV, @usernameV, (select id from Stadium where name_ = @stadium_nameV));
End
Go;


create function viewAvailableStadiumsOn
(@dateV datetime)
Returns Table
As 
	Return (Select Stadium.name_, Stadium.location_, Stadium.capacity From (Stadium Left Outer Join Match_ ON Stadium.id = Match_.stadium_id) Where (status_ = 1) and ((Match_.start_time <> @dateV) or Match_.id IS NULL));
Go;

create function allUnassignedMatches
(@club_nameV varchar(20))
Returns Table
As
	Return (Select HC.name_, M.start_time From (Match_ M Inner Join Club HC ON M.host_club_id = HC.id Inner Join Club GC ON M.guest_club_id = GC.id) Where (HC.name_ = @club_nameV) and (M.stadium_id IS NULL));
Go;


create function allPendingRequests
(@stadium_manager_name varchar(20))
Returns table
As

return (select r.name_,g.name_,m.start_time from Stadium_Manager s
inner join Host_Request h on h.manager_id=s.id
inner join Club_Representative r on r.id=h.representative_id
inner join Match_ m on h.match_id=m.id
inner join club g on m.guest_club_id=g.id
where s.username=@stadium_manager_name and h.status_='unhandled')


Go
create proc acceptRequest
@stadium_manager_name varchar(20),
@hosting_club_name varchar(20),
@competing_club_name varchar(20),
@start_time datetime
As
Begin
Update Host_Request 
Set status_='accepted'
where id =
(select h.id from Host_Request h
inner join Stadium_Manager s  on s.id=h.manager_id
inner join Match_ m on h.match_id=m.id
inner join club as host on m.host_club_id=host.id
inner join club as competing on m.guest_club_id=competing.id
where s.username=@stadium_manager_name 
and host.name_=@hosting_club_name
and competing.name_=@competing_club_name
and m.start_time=@start_time)
End

Go
create proc rejectRequest 
@stadium_manager_name varchar(20),
@hosting_club_name varchar(20),
@competing_club_name varchar(20),
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
inner join club as competing on m.guest_club_id=competing.id
where s.username=@stadium_manager_name 
and host.name_=@hosting_club_name
and competing.name_=@competing_club_name
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
Insert into SystemUser values(@fan_username,@fan_pass)
Insert into Fan(name_,username,national_id,birth_date,address_,phone_number) values
(@fan_name,@fan_username,@fan_national_id ,@fan_birth_date,@fan_address,@fan_phone_number)
End

Go
create function upcomingMatchesOfClub
(@club_name varchar(20))
returns table
as

return(select c1.name_,c2.name_,m.start_time,s.name_ from Club c1
inner join Match_ m on c1.id=m.host_club_id or c1.id=m.guest_club_id
inner join Club c2 on c2.id=m.guest_club_id or c2.id=m.host_club_id
inner join Stadium s on s.id=m.stadium_id
where m.start_time>GETDATE() and c1.name_=@club_name)


Go
create function availableMatchesToAttend
(@date datetime)
returns table
as

return(select h.name_,g.name_,m.start_time,s.name_ from Match_ m
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
where @host_club_name = host.host_club_name and @guest_club_name = guest.guest_club_name and @match_start_time = m.start_time
 

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

 SELECT C.name_, count(*)
 FROM Match_ M INNER JOIN Club C1
 ON M.host_club_id = C1.club_id
 INNER JOIN Club C2
 ON M.guest_club_id = C2.club_id
 GROUP BY C.name_
 Go

 CREATE VIEW clubsNeverMatched
 AS
 SELECT C3.name_, C4.name_e
 FROM Club C3, Club C4
 WHERE C3.club_id <> C4.club_id
 EXCEPT(
 SELECT *
 FROM Match_ M 
 INNER JOIN Club C1 
 ON M.host_club_id = C1.club_id
 INNER JOIN Club C2 
 ON M.guest_club_id = C2.club_id
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
ON C.club_id = M.host_club_id
INNER JOIN CLUB C1
ON C1.club_id = M.guest_club_id
WHERE C1.name_ = @club_name)
AND
NOT EXISTS( SELECT *
FROM Match_ M
INNER JOIN CLUB C
ON C.club_id = M.guest_club_id
INNER JOIN CLUB C2 
ON C2.club_id = M.host_club_id
WHERE C2.name_ = @club_name)
)
Go

--helper function
CREATE FUNCTION RankMatches()
returns table
AS

return(
	SELECT C1.name_, C2.name_
	FROM Match_ M
	INNER JOIN Club C1 ON C1.club_id = M.host_club_id
	INNER JOIN Club C2 ON C2.club_id = M.guest_club_id
	INNER JOIN Ticket T ON M.match_id = T.match_id
	GROUP BY C1.name_, C2.name_
	ORDER BY count(T.id) desc
)
go

CREATE FUNCTION matchWithHighestAttendance()
returns table
AS

return(
	SELECT TOP 1 * FROM 
	RankMatches
)

Go

CREATE FUNCTION matchesRankedByAttendance()
returns table
AS
return(
SELECT C1.name_, C2.name_
FROM Match_ M
INNER JOIN Club C1 ON C1.club_id = M.host_club_id
INNER JOIN Club C2 ON C2.club_id = M.guest_club_id
INNER JOIN Ticket T ON M.match_id = T.match_id
WHERE M.end_time < CURRENT_TIMESTAMP
GROUP BY C1.name, C2.name
ORDER BY count(T.id) desc
)
GO
CREATE FUNCTION requestsFromClub
(@stadium_name Varchar(20), @club_name varchar(20))
returns table
AS
return(
SELECT C1.name_, C2.name_
FROM Match_ M INNER JOIN Club C1 ON C1.club_id = M.host_club_id
INNER JOIN Club C2 ON C2.club_id = M.guest_club_id
INNER JOIN Host_Request H ON H.match_id = M.id
INNER JOIN Stadium_Manager SM ON H.manager_id = SM.id
INNER JOIN Stadium S ON SM.stadium_id = S.id
INNER JOIN Club_Representative CR ON CR.id = H.representative_id
INNER JOIN Club C ON C.club_id = CR.club_id
WHERE S.name_ = @stadium_name and CR.name_ = @club_name
)
