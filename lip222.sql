Create database lipton2;
go
CREATE PROC createAllTables 
as 
BEGIN
CREATE TABLE SystemUser (username varchar(20) primary key ,password_ varchar(20));
CREATE TABLE Club(id int primary key IDENTITY, name_ varchar(20), location_ varchar(20));
CREATE TABLE Stadium(id int primary key IDENTITY, status_ bit, name_ varchar(20), capacity int, location_ varchar(20));
CREATE TABLE Club_Representative(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser,club_ID int, foreign key(club_id) references Club(id));
CREATE TABLE Stadium_Manager(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username),stadium_id int,foreign key(stadium_id)references Stadium(id));
CREATE TABLE Fan(national_id varcahr(20) primary key, phone_number int, name_ varchar(20), address_ varchar(20), status_ bit, birth_date date, username varchar(20), foreign key(username) references SystemUser(username));
CREATE TABLE Sports_Association_Manager(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username));
CREATE TABLE System_Admin(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username));
CREATE TABLE Match_(id int primary key IDENTITY, start_time datetime, end_time datetime,host_club_id int,guest_club_ID int,foreign key(host_club_id) references club(id),FOREIGN key(guest_club_ID) REFERENCES club(id),stadium_id int,FOREIGN key(stadium_id) REFERENCES stadium(id) );
CREATE TABLE Ticket(id int primary key IDENTITY, status_ bit,match_id int,foreign key (match_id) references Match(id));
CREATE TABLE Host_Request(id int primary key IDENTITY, status_ varchar(20), match_id int foreign key references match(id),manager_id int foreign key references Stadium_Manager(id),representative_id int foreign key references Club_Representative(id));
CREATE TABLE Ticket_Buying_Transactions(fan_national_Id int foreign key references fan(national_id),ticket_id int foreign key references Ticket(id));
end

EXEC createAllTables;
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

-- CREATE PROC dropAllProceduresFunctionsViews
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
go

Create VieW allTickets
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

GO

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
end
go

-- create function [return_g_name]
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



