Create database lipton2;
go
CREATE PROC createAllTables 
as 
begin
CREATE TABLE SystemUser (username varchar(20) primary key ,password_ varchar(20))
CREATE TABLE Club(id int primary key IDENTITY, name_ varchar(20), location_ varchar(20))
CREATE TABLE Stadium(id int primary key IDENTITY, status_ bit, name_ varchar(20), capacity int, location_ varchar(20))
CREATE TABLE Club_Representative(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser,club_id int, foreign key(club_id) references Club(id))
CREATE TABLE Stadium_Manager(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username),stadium_id int,foreign key(stadium_id)references Stadium(id))
CREATE TABLE Fan(national_id int primary key, phone_number int, name_ varchar(20), address_ varchar(20), status_ bit, birth_date date, username varchar(20), foreign key(username) references SystemUser(username))
CREATE TABLE Sports_Association_Manager(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username))
CREATE TABLE System_Admin(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username))
CREATE TABLE Match_(id int primary key IDENTITY, start_time datetime, _time datetime,host_club_id int,guest_club_id int,foreign key(host_club_id) references club(id),FOREIGN key(guest_club_id) REFERENCES club(id),stadium_id int,FOREIGN key(stadium_id) REFERENCES stadium(id) )
CREATE TABLE Ticket(id int primary key IDENTITY, status_ bit,match_id int,foreign key (match_id) references Match_(id))
CREATE TABLE Host_Request(id int primary key IDENTITY, status_ varchar(20), match_id int foreign key references match(id),manager_id int foreign key references Stadium_Manager(id),representative_id int foreign key references Club_Representative(id))
CREATE TABLE Ticket_Buying_Transactions(fan_national_Id int foreign key references fan(national_id),ticket_id int foreign key references Ticket(id))
end

Go
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



