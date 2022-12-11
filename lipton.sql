CREATE PROC createAllTables 
as 
BEGIN
CREATE TABLE SystemUser (username varchar(20) primary key ,password_ varchar(20))
CREATE TABLE Club(id int primary key IDENTITY, name_ varchar(20), location_ varchar(20))
CREATE TABLE Stadium(id int primary key IDENTITY, status_ bit, name_ varchar(20), capacity int, location_ varchar(20))
CREATE TABLE Club_Representative(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser,club_ID int, foreign key(club_id) references Club(id))
CREATE TABLE Stadium_Manager(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username),stadium_id int,foreign key(stadium_id)references Stadium(id))
CREATE TABLE Fan(national_id int primary key, phone_number int, name_ varchar(20), address_ varchar(20), status_ bit, birth_date date, username varchar(20), foreign key(username) references SystemUser(username))
CREATE TABLE Sports_Association_Manager(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username))
CREATE TABLE System_Admin(id int primary key IDENTITY, name_ varchar(20), username varchar(20), foreign key(username) references SystemUser(username))
CREATE TABLE Match(id int primary key IDENTITY, start_time datetime, end_time datetime,host_club_id int,guest_club_ID int,foreign key(host_club_id) references club(id),FOREIGN key(guest_club_ID) REFERENCES club(id),stadium_id int,FOREIGN key(stadium_id) REFERENCES stadium(id) )
CREATE TABLE Ticket(id int primary key IDENTITY, status_ bit,match_id int,foreign key (match_id) references Match(id))
CREATE TABLE Host_Request(id int primary key IDENTITY, status_ varchar(20), match_id int foreign key references match(id),manager_id int foreign key references Stadium_Manager(id),representative_id int foreign key references Club_Representative(id))
CREATE TABLE Ticket_Buying_Transactions(fan_national_Id int foreign key references fan(national_id),ticket_id int foreign key references Ticket(id))
end
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
