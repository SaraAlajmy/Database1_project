CREATE PROC createAllTables 
as 
BEGIN
CREATE TABLE SystemUser (username varchar(20) primary key ,password_ varchar(20));
CREATE TABLE Club(id int primary key IDENTITY, name_ varchar(20), location_ varchar(20));
CREATE TABLE Stadium(id int primary key IDENTITY, status_ bit, name_ varchar(20), capacity int, location_ varchar(20));
CREATE TABLE Club_Representative(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser,club_ID int, foreign key(club_id) references Club(id));
CREATE TABLE Stadium_Manager(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username),stadium_id int,foreign key(stadium_id)references Stadium(id));
CREATE TABLE Fan(national_id int primary key, phone_number int, name_ varchar(20), address_ varchar(20), status_ bit, birth_date date, username varchar(20), foreign key(username) references SystemUser(username));
CREATE TABLE Sports_Association_Manager(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username));
CREATE TABLE System_Admin(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username));
CREATE TABLE Match(id int primary key IDENTITY, start_time datetime, end_time datetime,host_club_id int,guest_club_ID int,foreign key(host_club_id) references club(id),FOREIGN key(guest_club_ID) REFERENCES club(id),stadium_id int,FOREIGN key(stadium_id) REFERENCES stadium(id) );
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
    DROP TABLE Match;
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
    TRUNCATE TABLE Match;
    TRUNCATE TABLE Stadium;
END

GO
CREATE VIEW allAssocManagers
AS
SELECT s.username, s.name_ 
FROM Sports_Association_Manager s;
go
CREATE VIEW allClubRepresentatives
AS
SELECT R.username, R.name_,C.name_
From  Club_Representative R INNER JOIN Club C ON R.club_id=C.id
go
Create VIEW allStadiumManagers
AS
SELECT M.username, M.name_, S.name_
From Stadium_Manager M INNER JOIN Stadium S ON M.stadium_id=S.id
go
Create VIEW allFans
As 
SELECT national_id, name_, status_, birthdate
From Fan
go


Create VIEW allMatches 
AS
SELECT c1.name_,c2.name_,c2.name_ as 'Host_Club' , m.start_time
from Club c1,club c2, match m WHERE m.guest_club_ID=c1.id and m.host_club_id=c2.id
go

Create VieW allTickets
As 
SELECT c1.name_,c2.name_,s.name_,m.start_time
from club c1 ,club c2,match m, stadium s
where m.guest_club_ID=c1.id and m.host_club_id=c2.id and m.stadium_id =s.id
go

create view allClubs
AS 
select name_,location_
from club
GO

CREATE view allStadiums
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
@club1_name varchar(20)

Go 

create procedure addStadium 
@nameV varchar(20),
@locationV varchar(20),
@capacityV int
As 
Begin
Insert into Stadium (name_, capacity, location_) values(nameV, capacityV, locationV);
End
Go;

create procedure deleteStadium
@nameV varchar(20)
As 
Begin
Delete From Stadium Where name_=nameV;
End
Go;

create procedure blockFan
@national_idV varchar(20)
As
Begin
Update Fan
Set status_bit = 1
Where national_id = national_idV;
End
Go;

create procedure unblockFan
@national_idV varchar(20)
As
Begin
Update Fan
Set status_bit = 0
Where national_id = national_idV;
End
Go;

create procedure addRepresentative 
@nameV varchar(20),
@club_nameV varchar(20),
@usernameV varchar(20),
@passwordV varchar(20)
As 
Begin
Insert into SystemUser values (usernameV, passwordV);
Insert into club_representative (name_, username, club_ID) values(nameV, usernameV, (Select id From Club where name_ = club_nameV));
End
Go;

create procedure addHostRequest 
@club_nameV varchar(20),
@stadium_nameV varchar(20),
@start_timeV datetime
As 
Begin
Insert into Host_Request (match_id, manager_id, representative_id) values 
((select id from Match where start_time = start_timeV and host_club_id = (Select id from Club where name_ = club_nameV)), (select Stadium_Manager.id from Stadium_Manager Inner Join Stadium ON Stadium_Manager.studium_id = Stadium.id where Stadium.name_ = stadium_nameV), (select Club_Representative.id from Club_Representative Inner Join Club ON Club_Representative.club_ID = Club.id where Club.name_ = club_nameV)); 
End
Go;
