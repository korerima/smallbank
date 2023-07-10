create database bankmg
go
use bankmg
go
-------------------------------
--- Microsoft SQL
-----------TABLES-------------- 

------ branch table
create table branch(
	branch_id int primary key identity,
	branch_name varchar(20) UNIQUE NOT NULL,
	branch_city varchar(20) NOT NULL,
	branch_contact varchar(20) UNIQUE NOT NULL CHECK(LEN(branch_contact)=10)
	)
go

-- customer table
create table customer(
	cust_id int primary key identity, 
	f_name varchar(20) NOT NULL,
	l_name varchar(20) NOT NULL,
	city varchar(20) NOT NULL,
	street varchar(20) NOT NULL,
	house_no int,
	dob date NOT NULL CHECK(DATEDIFF(YEAR,dob,GETDATE())>15),
	gender varchar(10) NOT NULL CHECK(gender ='female' OR gender= 'male'),
	email varchar(25) UNIQUE CHECK(CHARINDEX('@',email)!=0 AND CHARINDEX('.com',email)!=0),
	contact varchar(20) NOT NULL UNIQUE CHECK(LEN(contact)=10)
	)
go

--teller table
create table teller(
	tel_id int primary key identity, 
	branch_id int foreign key references branch(branch_id),
	f_name varchar(20) NOT NULL,
	l_name varchar(20) NOT NULL,
	city varchar(20) NOT NULL,
	street varchar(20) NOT NULL,
	house_no int,
	dob date NOT NULL CHECK(DATEDIFF(YEAR,dob,GETDATE())>21),
	gender varchar(10) NOT NULL check(gender ='female' OR gender= 'male'),
	email varchar(25) UNIQUE CHECK(CHARINDEX('@',email)!=0 AND CHARINDEX('.com',email)!=0),
	contact varchar(20) NOT NULL UNIQUE check(len(contact)=10),
	salary money NOT NULL CHECK(salary > 7000),
	username varchar(30) NOT NULL UNIQUE,
	password varchar(100) NOT NULL
	)
go

--manager table
create table manager(
	man_id int primary key identity, 
	branch_id int foreign key references branch(branch_id) UNIQUE,
	f_name varchar(20) NOT NULL,
	l_name varchar(20) NOT NULL,
	city varchar(20) NOT NULL,
	street varchar(20) NOT NULL,
	house_no int,
	dob date NOT NULL CHECK(DATEDIFF(YEAR,dob,GETDATE())>21),
	gender varchar(10) NOT NULL check(gender ='female' OR gender= 'male'),
	email varchar(25) UNIQUE CHECK(CHARINDEX('@',email)!=0 AND CHARINDEX('.com',email)!=0),
	contact varchar(20) NOT NULL UNIQUE check(len(contact)=10),
	salary money NOT NULL CHECK(salary > 20000),
	username varchar(30) NOT NULL UNIQUE,
	password varchar(100) NOT NULL
	)
go

-- interest table
create table interest(
	int_id int primary key identity,
	int_type varchar(20) NOT NULL,
	int_rate float NOT NULL
	)
go

-- account table
create table account(
	acc_no int primary key identity(10000,1),
	acc_type varchar(20) NOT NULL,
	balance money,
	cust_id int foreign key references customer(cust_id) UNIQUE,
	acc_status date NOT NULL,
	int_id int foreign key references interest(int_id),
	branch_id int foreign key references branch(branch_id),
	tel_id int foreign key references teller(tel_id)
	)
go

-- transaction table
create table transact(
	trans_id int primary key identity,
	acc_no int foreign key references account(acc_no),
	tel_id int foreign key references teller(tel_id),
	cust_id int foreign key references customer(cust_id),
	trans_type varchar(20) NOT NULL,
	amount money NOT NULL,
	trans_date date NOT NULL,
	balance money NOT NULL
	)
go

-- deposit table
create table deposit( 
	dep_id int primary key identity,
	acc_no int foreign key references account(acc_no),
	tel_id int foreign key references teller(tel_id),
	cust_id int foreign key references customer(cust_id),
	amount money NOT NULL,
	d_date date NOT NULL,
	)
go

-- withdraw table
create table withdraw(
	with_id int primary key identity,
	acc_no int foreign key references account(acc_no),
	tel_id int foreign key references teller(tel_id),
	cust_id int foreign key references customer(cust_id),
	amount money NOT NULL,
	w_date date NOT NULL
	)
go


-------------procedures------------------

----------------------------------------------------------insert/create procedures
-------------------------------------------------------

--------------------- procedure to create a branch
alter proc [create branch](
	@branch_name varchar(20),
	@branch_city varchar(20),
	@branch_contact varchar(20)
	)
as
begin
	declare @c_contact varchar(20), @t_contact varchar(20), @m_contact varchar(20)
	
	---------------- check if the branch phone is found on the other tables
	exec [customer phone]@branch_contact,@c_contact output
	exec [teller phone]@branch_contact,@t_contact output
	exec [manager phone]@branch_contact,@m_contact output

	if (@c_contact != 'found' AND @t_contact != 'found' AND @m_contact != 'found')
	begin
		insert into branch values
		(@branch_name,@branch_city,@branch_contact)
	end
	else
		print 'this contact is already registered'
end
go
------------------------------------------- procedure to create a customer
alter proc [create customer]( 
	@f_name varchar(20),
	@l_name varchar(20),
	@city varchar(20),
	@street varchar(20),
	@house_no int,
	@dob date,
	@gender varchar(10),
	@email varchar(25),
	@contact varchar(20)  
	)
as
begin
	declare @b_contact varchar(20), @t_contact varchar(20), @m_contact varchar(20), @t_email varchar(25), @m_email varchar(25)
	
	--search other tables to check if the customer phone and email is already registered
	exec [branch phone]@contact,@b_contact output
	exec [teller phone]@contact,@t_contact output
	exec [manager phone]@contact,@m_contact output
	exec [teller email]@email,@t_email output
	exec [manager email]@email,@m_email output
	
	if (@b_contact != 'found' AND @t_contact != 'found' AND @m_contact != 'found')
	begin
		if (@t_email != 'found' AND @m_email != 'found')
		begin
			insert into customer values
			(@f_name, @l_name, @city, @street, @house_no, @dob, @gender, @email, @contact)
		end
		else
			print 'this email is already registered'
	end
	else
		print 'this contact is already registered'
	
end
go

-------------------------------------------------- procedure to create a teller
alter proc [create teller](  
	@branch_id int,
	@f_name varchar(20),
	@l_name varchar(20),
	@city varchar(20),
	@street varchar(20),
	@house_no int,
	@dob date,
	@gender varchar(10),
	@email varchar(25),
	@contact varchar(20),
	@salary money,
	@username varchar(30),
	@password varchar(100)
	)
as
begin
	declare @b_contact varchar(20),@c_contact varchar(20), @m_contact varchar(20), @c_email varchar(25), @m_email varchar(25), @m_user varchar(30)
	
		--search other tables to check if the teller phone, email and username is already registered
	exec [branch phone]@contact,@b_contact output
	exec [customer phone]@contact,@c_contact output
	exec [manager phone]@contact,@m_contact output
	exec [customer email]@email,@c_email output
	exec [manager email]@email,@m_email output
	exec [manager username]@username,@m_user output
	
	if (@b_contact != 'found' AND @c_contact != 'found' AND @m_contact != 'found')
	begin
		if (@c_email != 'found' AND @m_email != 'found')
		begin
			if (@m_user != 'found')
			begin
				insert into teller values
				(@branch_id,@f_name, @l_name, @city, @street, @house_no, @dob, @gender, @email, @contact, @salary, @username, EncryptByPassPhrase(@username, @password))
			end
			else
				print 'this username is already registered'
		end
		else
			print 'this email is already registered'
	end
	else
		print 'this contact is already registered'
end
go

---------------------------------------------------- procedure to create a manager
alter proc [create manager](  
	@branch_id int,
	@f_name varchar(20),
	@l_name varchar(20),
	@city varchar(20),
	@street varchar(20),
	@house_no int,
	@dob date,
	@gender varchar(10),
	@email varchar(25),
	@contact varchar(20),
	@salary money,
	@username varchar(30),
	@password varchar(100)
	)
as
begin
	declare @b_contact varchar(20),@c_contact varchar(20), @t_contact varchar(20), @c_email varchar(25), @t_email varchar(25), @t_user varchar(30)
	
	--search other tables to check if the manager phone, email and username is already registered
	exec [branch phone]@contact,@b_contact output
	exec [customer phone]@contact,@c_contact output
	exec [teller phone]@contact,@t_contact output
	exec [customer email]@email,@c_email output
	exec [teller email]@email,@t_email output
	exec [teller username]@username,@t_user output
	
	if (@b_contact != 'found' AND @c_contact != 'found' AND @t_contact != 'found')
	begin
		if (@c_email != 'found' AND @t_email != 'found')
		begin
			if (@t_user != 'found')
			begin
				insert into manager values
				(@branch_id,@f_name, @l_name, @city, @street, @house_no, @dob, @gender, @email, @contact, @salary, @username, EncryptByPassPhrase(@username, @password))
			end
			else
				print 'this username is already registered'
		end
		else
			print 'this email is already registered'
	end
	else
		print 'this contact is already registered'
end
go

--------------------------------------------------procedure to create interest
create proc [create interest](
	@int_type varchar(20),
	@int_rate float
	)
as
begin
	insert into interest values
	(@int_type,@int_rate)
end
go

-----------------------------------------------------procedure to create account
alter proc [create account](
	@acc_type varchar(20),
	@balance money,
	@cust_id int,
	@acc_status date,
	@branch_id int,
	@tel_id int
	)
as
begin
	declare @int_id int
	
	--the following statments is to set the interest rate of the account and filter not valid inputs
	if(@acc_type= 'saving')
	begin
		if(@balance<50)
			print 'mminimum deposit is 50 ETB'
		else if(@balance>50)
			begin
				set @int_id= 2
				insert into account values
				(@acc_type,@balance,@cust_id,@acc_status,@int_id,@branch_id,@tel_id)
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'current')
	begin
		if(@balance<15000.00)
			print 'mminimum deposit is 15,000.00 ETB'
		else if(@balance>15000.00)
			begin
				set @int_id= 1
				insert into account values
				(@acc_type,@balance,@cust_id,@acc_status,@int_id,@branch_id,@tel_id)
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'sheria')
	begin
		if(@balance<50.00)
			print 'mminimum deposit is 50.00 ETB'
		else if(@balance>50.00)
			begin
				set @int_id= 1
				insert into account values
				(@acc_type,@balance,@cust_id,@acc_status,@int_id,@branch_id,@tel_id)
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'fixed0')
	begin
		if(@balance<50000.00 OR @balance>150000.00)
			print 'mminimum deposit is 50,000.00 ETB and 150000 ETB is maximum'
		else if (@balance>50000.00 AND @balance<150000.00)
			begin
				set @int_id= 3
				insert into account values
				(@acc_type,@balance,@cust_id,@acc_status,@int_id,@branch_id,@tel_id)
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'fixed1')
	begin
		if(@balance<150000.00)
			print 'mminimum deposit is 150,000.00 ETB'
		else if(@balance>150000.00)
			begin
				set @int_id= 4
				insert into account values
				(@acc_type,@balance,@cust_id,@acc_status,@int_id,@branch_id,@tel_id)
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'fixed2')
	begin
		if(@balance<300000.00)
			print 'mminimum deposit is 300,000.00 ETB'
		else if(@balance>300000.00)
			begin
				set @int_id= 5
				insert into account values
				(@acc_type,@balance,@cust_id,@acc_status,@int_id,@branch_id,@tel_id)
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'vip0')
	begin
		if(@balance<1000000.00)
			print 'mminimum deposit is 1,000,000.00 ETB'
		else if(@balance>1000000.00)
			begin
				set @int_id= 6
				insert into account values
				(@acc_type,@balance,@cust_id,@acc_status,@int_id,@branch_id,@tel_id)
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'vip1')
	begin
		if(@balance<10000000.00)
			print 'mminimum deposit is 10,000,000.00 ETB'
		else if(@balance>10000000.00)
			begin
				set @int_id= 7
				insert into account values
				(@acc_type,@balance,@cust_id,@acc_status,@int_id,@branch_id,@tel_id)
			end
		else
			print 'something went wrong'
	end
	else
		print 'invalid account type'
end
go

------------------------------------------------------procedure to deposit
alter proc [create deposit](
	@acc_no int,
	@tel_id int,
	@cust_id int,
	@amount money,
	@d_date date	
	)
as
begin
	declare @time int, @status varchar(10)= 'notfound', @cust int,@balance money,@int_id int, @interest money
	
	--to get the year to check if the account has expires or still open
	set @time= datediff(year, (select acc_status from account where acc_no=@acc_no), @d_date)
	
	------ cursor to check if the customer have an account number
	declare search_name cursor scroll
	for select account.cust_id from account 
	open search_name
	fetch next from search_name
	into @cust
	while @@FETCH_STATUS=0
	begin
		if (@cust_id = @cust )
			set @status= 'found'
		fetch next from search_name
		into @cust
	end
	close search_name
	deallocate search_name	
	
	if (@time>10 and @time !< 0)
		Print 'sorry the account number has expired'
	else if((@status != 'found') and (@amount>5000.00))	
		Print 'sorry the customer does not have an account number'
	else
	begin
		declare @c1 int,@c2 int
 		set @c1= (select count (*) from deposit)
		
		--- transaction to rollback if something went wrong with the deposit
		begin transaction s
			insert into deposit values
			(@acc_no, @tel_id ,@cust_id ,@amount ,@d_date)

			set @balance= (select balance from account where acc_no= @acc_no)
			set @int_id= (select int_id from account where acc_no= @acc_no)
			set @interest= dbo.[calculate interest](@acc_no,@balance,@int_id)
		
			set @c2= (select count (*) from deposit)
			if (@c1 = @c2)
				rollback transaction s
			else
			begin
				commit transaction s
				update account set balance= (balance+@interest) where acc_no= @acc_no
				update account set balance= (balance+@amount) where acc_no = @acc_no
				update account set acc_status= @d_date where acc_no= @acc_no
			end
	end
end
go

--------------------------------------------------------------------procedure to withdraw
alter proc [create withdraw](
	@acc_no int,
	@tel_id int,
	@cust_id int,
	@amount money,
	@d_date date	
	)
as
begin
	declare @time int, @status money, @cust int, @balance money, @int_id int, @interest money, @low_balance varchar(10)= 'updated'
	
	set @time= datediff(year, (select acc_status from account where acc_no=@acc_no), @d_date)
	set @cust= (select cust_id from account where acc_no= @acc_no)
	set @status= (select balance from account where acc_no= @acc_no)

	-- to get the interest of the account in a given year
	set @balance= (select balance from account where acc_no= @acc_no)
	set @int_id= (select int_id from account where acc_no= @acc_no)
	set @interest= dbo.[calculate interest](@acc_no,@balance,@int_id)
	
	if (@status< @amount)
	begin	
		update account set balance= (balance+@interest) where acc_no= @acc_no
		set @status= (select balance from account where acc_no= @acc_no)
		if (@status<@amount)
			set @low_balance= 'short'
		else
			set @low_balance='long'
	end
	
	if (@time>10 and @time !< 0)
		Print 'sorry the account number has expired'
	else if (@low_balance = 'short')
		print 'insufficiet balance'
	else if(@cust != @cust_id)
		Print 'sorry wrong account or customer'
	else
	begin
		declare @c1 int,@c2 int
 		set @c1= (select count (*) from withdraw)
		
		--- transaction to rollback if something went wrong with the withdraw
		begin transaction s
			insert into withdraw values
			(@acc_no, @tel_id ,@cust_id ,@amount ,@d_date)
			set @c2= (select count (*) from withdraw)
			if (@c1 = @c2)
				rollback transaction s
			else
			begin
				commit transaction s
				update account set balance= (balance-@amount) where acc_no = @acc_no
				update account set acc_status= @d_date where acc_no= @acc_no
			end
	end
end
go

----------------------------------insert into transact table
create proc [create transact]
(
	@acc_no int,
	@tel_id int,
	@cust_id int,
	@trans_type varchar(20),
	@amount money,
	@trans_date date,
	@balance money
)
as
begin
	insert into transact values
	(@acc_no, @tel_id, @cust_id, @trans_type, @amount, @trans_date, @balance)
end
go

-----------------------------------------------------------search procedures
--------------------------------------------
--------------------------------------------

------------------------------------ search branch phone
alter proc [branch phone]
(
	@contact varchar(20),
	@status varchar(20) output
)
as
begin
	declare @temp1 varchar(20)
	set @status ='notfound'
	declare search_branchphone cursor scroll
	for select branch_contact from branch 
	open search_branchphone
	fetch first from search_branchphone
	into @temp1
	while @@FETCH_STATUS=0
	begin
		if (charindex(@contact,@temp1)!= 0)
		begin
			set @status= 'found'
			break
		end
		fetch next from search_branchphone
		into @temp1
	end
	close search_branchphone
	deallocate search_branchphone
end
go

------------------------------------ search customer phone
alter proc [customer phone]
(
	@contact varchar(20),
	@status varchar(20) output
)
as
begin
	declare @temp1 varchar(20) 
	set @status ='notfound'
	declare search_customerphone cursor scroll
	for select contact from customer 
	open search_customerphone
	fetch first from search_customerphone
	into @temp1
	while @@FETCH_STATUS=0
	begin
		if (charindex(@contact,@temp1)!= 0)
		begin
			set @status= 'found'
			break
		end
		fetch next from search_customerphone
		into @temp1
	end
	close search_customerphone
	deallocate search_customerphone
end
go

----------------------------------- search teller phone
alter proc [teller phone]
(
	@contact varchar(20),
	@status varchar(20) output
)
as
begin
	declare @temp1 varchar(20)
	set @status='notfound'
	declare search_tellerphone cursor scroll
	for select contact from teller 
	open search_tellerphone
	fetch first from search_tellerphone
	into @temp1
	while @@FETCH_STATUS=0
	begin
		if (charindex(@contact,@temp1)!= 0)
		begin
			set @status= 'found'
			break
		end
		fetch next from search_tellerphone
		into @temp1
	end
	close search_tellerphone
	deallocate search_tellerphone
end
go

------------------------------------- search manager phone
alter proc [manager phone]
(
	@contact varchar(20),
	@status varchar(20) output
)
as
begin
	declare @temp1 varchar(20)
	set @status= 'notfound'
	declare search_managerphone cursor scroll
	for select contact from manager 
	open search_managerphone
	fetch first from search_managerphone
	into @temp1
	while @@FETCH_STATUS=0
	begin
		if (charindex(@contact,@temp1)!= 0)
		begin
			set @status= 'found'
			break
		end
		fetch next from search_managerphone
		into @temp1
	end
	close search_managerphone
	deallocate search_managerphone
end
go

------------------------------------- search customer email
alter proc [customer email]
(
	@email varchar(25),
	@status varchar(20) output
)
as
begin
	declare @temp1 varchar(25)
	set @status= 'notfound'
	declare search_customeremail cursor scroll
	for select email from customer
	open search_customeremail
	fetch first from search_customeremail
	into @temp1
	while @@FETCH_STATUS=0
	begin
		if (charindex(@email,@temp1)!= 0)
		begin
			set @status= 'found'
			break
		end
		fetch next from search_customeremail
		into @temp1
	end
	close search_customeremail
	deallocate search_customeremail
end
go

----------------------------------------search teller email
alter proc [teller email]
(
	@email varchar(25),
	@status varchar(20) output
)
as
begin
	declare @temp1 varchar(25)
	set @status= 'notfound'
	declare search_telleremail cursor scroll
	for select email from teller
	open search_telleremail
	fetch first from search_telleremail
	into @temp1
	while @@FETCH_STATUS=0
	begin
		if (charindex(@email,@temp1)!= 0)
		begin
			set @status= 'found'
			break
		end
		fetch next from search_telleremail
		into @temp1
	end
	close search_telleremail
	deallocate search_telleremail
end
go

---------------------------------------------search manager email
alter proc [manager email]
(
	@email varchar(25),
	@status varchar(20) output
)
as
begin
	declare @temp1 varchar(25)
	set @status= 'notfound'
	declare search_manageremail cursor scroll
	for select email from manager
	open search_manageremail
	fetch first from search_manageremail
	into @temp1
	while @@FETCH_STATUS=0
	begin
		if (charindex(@email,@temp1)!= 0)
		begin
			set @status= 'found'
			break
		end
		fetch next from search_manageremail
		into @temp1
	end
	close search_manageremail
	deallocate search_manageremail
end
go

-----------------------------------------search teller username
alter proc [teller username]
(
	@username varchar(25),
	@status varchar(20) output
)
as
begin
	declare @temp1 varchar(25)
	set @status= 'notfound'
	declare search_tellerusername cursor scroll
	for select username from teller
	open search_tellerusername
	fetch first from search_tellerusername
	into @temp1
	while @@FETCH_STATUS=0
	begin
		if (charindex(@username,@temp1)!= 0)
		begin
			set @status= 'found'
			break
		end
		fetch next from search_tellerusername
		into @temp1
	end
	close search_tellerusername
	deallocate search_tellerusername
end
go

-------------------------------------------search manager username
alter proc [manager username]
(
	@username varchar(25),
	@status varchar(20) output
)
as
begin
	declare @temp1 varchar(25)
	set @status ='notfound'
	declare search_managerusername cursor scroll
	for select username from manager
	open search_managerusername
	fetch first from search_managerusername
	into @temp1
	while @@FETCH_STATUS=0
	begin
		if (charindex(@username,@temp1)!= 0)
		begin
			set @status= 'found'
			break
		end
		fetch next from search_managerusername
		into @temp1
	end
	close search_managerusername
	deallocate search_managerusername
end
go

-----------------------------------------------delete procedures
----------------------------------------------------------------

------------------------------------- delete branch
create proc [delete branch]
(
	@branch_id int
)
as
begin
	delete branch where branch_id=@branch_id
end
go

---------------------------------------delete customer
create proc [delete customer]
(
	@cust_id int
)
as
begin
	delete customer where cust_id=@cust_id
end
go

----------------------------------------delete teller
create proc [delete teller]
(
	@tel_id int
)
as
begin
	delete teller where tel_id=@tel_id
end
go

---------------------------------------delete manager
create proc [delete manager]
(
	@man_id int
)
as
begin
	delete manager where man_id=@man_id
end
go

-----------------------------------------delete interest
create proc [delete interest]
(
	@int_id int
)
as
begin
	delete interest where int_id=@int_id
end
go

-------------------------------------delete account
create proc [delete account]
(
	@acc_no int
)
as
begin
	delete account where acc_no=@acc_no
end
go

--------------------------------------delete transact
create proc [delete transact]
(
	@trans_id int
)
as
begin
	delete transact where trans_id=@trans_id
end
go

-----------------------------------delete deposit
alter proc [delete deposit]
(
	@dep_id int
)
as
begin
	delete deposit where dep_id = @dep_id
end
go

-----------------------------------------delete withdraw
alter proc [delete withdraw]
(
	@with_id int
)
as
begin
	delete withdraw where with_id = @with_id 
end
go


-------------------------------------search tables
---------------------------------------

------------------------- search branch
alter proc [search branch]
(
	@branch_id int
)
as
begin
	select * from branch where branch_id=@branch_id
end
go

--------------------------------search customer
alter proc [search customer]
(
	@cust_id int
)
as
begin
	select * from customer where cust_id=@cust_id
end
go

---------------------------------search teller
alter proc [search teller]
(
	@tel_id int
)
as
begin
	select * from teller where tel_id=@tel_id
end
go

--------------------------------search manager
alter proc [search manager]
(
	@man_id int
)
as
begin
	select * from manager where man_id=@man_id
end
go

-----------------------------------search interest
alter proc [search interest]
(
	@int_id int
)
as
begin
	select * from interest where int_id=@int_id
end
go

-------------------------------------search account
alter proc [search account]
(
	@acc_no int
)
as
begin
	declare @time int, @balance money,@int_id int, @interest money
	
	set @time= datediff(month, (select acc_status from account where acc_no=@acc_no), getdate())
	set @balance= (select balance from account where acc_no= @acc_no)
	set @int_id= (select int_id from account where acc_no= @acc_no)
	set @interest= dbo.[account interest](@acc_no,@balance,@int_id, @time)

	select acc_no, acc_type, balance+@interest as 'balance', cust_id, acc_status, int_id, branch_id, tel_id from account where acc_no=@acc_no

end
go

--------------------------------------search deposit
alter proc [search deposit]
(
	@dep_id int
)
as
begin
	select * from deposit where dep_id = @dep_id
end
go

--------------------------------search withdraw
alter proc [search withdraw]
(
	@with_id int
)
as
begin
	select * from withdraw where with_id = @with_id 
end
go

-------------------------------------search transact
alter proc [search transact]
(
	@trans_id int
)
as
begin
	select * from transact where trans_id= @trans_id 
end
go


-------------------------------------------------update procedures
--------------------------------------------------

----------------------------------------update branch 
alter proc [update branch]
(
	@branch_id int,
	@branch_name varchar(20),
	@branch_city varchar(20),
	@branch_contact varchar(20)
)
as
begin
	declare @c_contact varchar(20), @t_contact varchar(20), @m_contact varchar(20)

	exec [customer phone]@branch_contact,@c_contact output
	exec [teller phone]@branch_contact,@t_contact output
	exec [manager phone]@branch_contact,@m_contact output

	if (@c_contact != 'found' AND @t_contact != 'found' AND @m_contact != 'found')
	begin
		update branch set 
		branch_name= @branch_name, 
		branch_city= @branch_city, 
		branch_contact=@branch_contact 
		where branch_id=@branch_id
	end
	else
		print 'this contact is already registered'

end
go

-----------------------------------------update customer
alter proc [update customer]
(
	@cust_id int,
	@f_name varchar(20),
	@l_name varchar(20),
	@city varchar(20),
	@street varchar(20),
	@house_no int,
	@dob date,
	@gender varchar(10),
	@email varchar(25),
	@contact varchar(20)
)
as
begin
	declare @b_contact varchar(20), @t_contact varchar(20), @m_contact varchar(20), @t_email varchar(25), @m_email varchar(25)
	
	exec [branch phone]@contact,@b_contact output
	exec [teller phone]@contact,@t_contact output
	exec [manager phone]@contact,@m_contact output
	exec [teller email]@email,@t_email output
	exec [manager email]@email,@m_email output
	
	if (@b_contact != 'found' AND @t_contact != 'found' AND @m_contact != 'found')
	begin
		if (@t_email != 'found' AND @m_email != 'found')
		begin
			update contact set
			f_name= @f_name, 
			l_name= @l_name, 
			city= @city, 
			street= @street, 
			house_no= @house_no, 
			dob= @dob, 
			gender= @gender, 
			email= @email, 
			contact= @contact 
			where cust_id= @cust_id
		end
		else
			print 'this email is already registered'
	end
	else
		print 'this contact is already registered'

end
go

-------------------------------------update teller
create proc [update teller]
(
	@tel_id int,
	@branch_id int,
	@f_name varchar(20),
	@l_name varchar(20),
	@city varchar(20),
	@street varchar(20),
	@house_no int,
	@dob date,
	@gender varchar(10),
	@email varchar(25),
	@contact varchar(20),
	@salary money,
	@username varchar(30),
	@password varchar(100)
)
as
begin
	declare @b_contact varchar(20),@c_contact varchar(20), @m_contact varchar(20), @c_email varchar(25), @m_email varchar(25), @m_user varchar(30)
	
	exec [branch phone]@contact,@b_contact output
	exec [customer phone]@contact,@c_contact output
	exec [manager phone]@contact,@m_contact output
	exec [customer email]@email,@c_email output
	exec [manager email]@email,@m_email output
	exec [manager username]@username,@m_user output
	
	if (@b_contact != 'found' AND @c_contact != 'found' AND @m_contact != 'found')
	begin
		if (@c_email != 'found' AND @m_email != 'found')
		begin
			if (@m_user != 'found')
			begin
				update teller set 
				branch_id= @branch_id,
				f_name= @f_name,
				l_name= @l_name,
				city= @city,
				street= @street,
				house_no= @house_no,
				dob= @dob,
				gender= @gender,
				email= @email,
				contact= @contact,
				salary= @salary,
				username= @username,
				password= EncryptByPassPhrase(@username, @password)
				where tel_id= @tel_id
			end
			else
				print 'this username is already registered'
		end
		else
			print 'this email is already registered'
	end
	else
		print 'this contact is already registered'

end
go

-------------------------------------update manager
create proc [update manager]
(
	@man_id int,
	@branch_id int,
	@f_name varchar(20),
	@l_name varchar(20),
	@city varchar(20),
	@street varchar(20),
	@house_no int,
	@dob date,
	@gender varchar(10),
	@email varchar(25),
	@contact varchar(20),
	@salary money,
	@username varchar(30),
	@password varchar(100)
)
as
begin
	declare @b_contact varchar(20),@c_contact varchar(20), @t_contact varchar(20), @c_email varchar(25), @t_email varchar(25), @t_user varchar(30)
	
	exec [branch phone]@contact,@b_contact output
	exec [customer phone]@contact,@c_contact output
	exec [teller phone]@contact,@t_contact output
	exec [customer email]@email,@c_email output
	exec [teller email]@email,@t_email output
	exec [teller username]@username,@t_user output
	
	if (@b_contact != 'found' AND @c_contact != 'found' AND @t_contact != 'found')
	begin
		if (@c_email != 'found' AND @t_email != 'found')
		begin
			if (@t_user != 'found')
			begin
				update manager set
				f_name= @f_name,
				l_name= @l_name,
				city= @city,
				street= @street,
				house_no= @house_no,
				dob= @dob,
				gender= @gender,
				email= @email,
				contact= @contact,
				salary= @salary,
				username= @username,
				password= EncryptByPassPhrase(@username, @password)
				where man_id= @man_id
			end
			else
				print 'this username is already registered'
		end
		else
			print 'this email is already registered'
	end
	else
		print 'this contact is already registered'
	
end
go

-----------------------------------------update interest
create proc [update interest]
(
	@int_id int,
	@int_type varchar(20),
	@int_rate float
)
as
begin
	update interest set int_type= @int_type, int_rate= @int_rate where int_id=@int_id
end
go

-----------------------------------------update account
create proc [update account]
(
	@acc_no int,
	@acc_type varchar(20),
	@balance money,
	@cust_id int,
	@acc_status date,
	@branch_id int,
	@tel_id int
)
as
begin
	declare @int_id int
	
	if(@acc_type= 'saving')
	begin
		if(@balance<50)
			print 'mminimum deposit is 50 ETB'
		else if(@balance>50)
			begin
				set @int_id= 2
				update account set 
				acc_type= @acc_type, 
				balance= @balance, 
				cust_id= @cust_id, 
				acc_status= @acc_status, 
				branch_id= @branch_id, 
				tel_id= @tel_id
				where acc_no= @acc_no
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'current')
	begin
		if(@balance<15000.00)
			print 'mminimum deposit is 15,000.00 ETB'
		else if(@balance>15000.00)
			begin
				set @int_id= 1
				update account set acc_type= @acc_type, balance= @balance, cust_id= @cust_id, acc_status= @acc_status, branch_id= @branch_id, tel_id= @tel_id
				where acc_no= @acc_no
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'sheria')
	begin
		if(@balance<50.00)
			print 'mminimum deposit is 50.00 ETB'
		else if(@balance>50.00)
			begin
				set @int_id= 1
				update account set acc_type= @acc_type, balance= @balance, cust_id= @cust_id, acc_status= @acc_status, branch_id= @branch_id, tel_id= @tel_id
				where acc_no= @acc_no
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'fixed0')
	begin
		if(@balance<50000.00 OR @balance>150000.00)
			print 'mminimum deposit is 50,000.00 ETB and 150000 ETB is maximum'
		else if (@balance>50000.00 AND @balance<150000.00)
			begin
				set @int_id= 3
				update account set acc_type= @acc_type, balance= @balance, cust_id= @cust_id, acc_status= @acc_status, branch_id= @branch_id, tel_id= @tel_id
				where acc_no= @acc_no
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'fixed1')
	begin
		if(@balance<150000.00)
			print 'mminimum deposit is 150,000.00 ETB'
		else if(@balance>150000.00)
			begin
				set @int_id= 4
				update account set acc_type= @acc_type, balance= @balance, cust_id= @cust_id, acc_status= @acc_status, branch_id= @branch_id, tel_id= @tel_id
				where acc_no= @acc_no
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'fixed2')
	begin
		if(@balance<300000.00)
			print 'mminimum deposit is 300,000.00 ETB'
		else if(@balance>300000.00)
			begin
				set @int_id= 5
				update account set acc_type= @acc_type, balance= @balance, cust_id= @cust_id, acc_status= @acc_status, branch_id= @branch_id, tel_id= @tel_id
				where acc_no= @acc_no
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'vip0')
	begin
		if(@balance<1000000.00)
			print 'mminimum deposit is 1,000,000.00 ETB'
		else if(@balance>1000000.00)
			begin
				set @int_id= 6
				update account set acc_type= @acc_type, balance= @balance, cust_id= @cust_id, acc_status= @acc_status, branch_id= @branch_id, tel_id= @tel_id
				where acc_no= @acc_no
			end
		else
			print 'something went wrong'
	end
	else if (@acc_type= 'vip1')
	begin
		if(@balance<10000000.00)
			print 'mminimum deposit is 10,000,000.00 ETB'
		else if(@balance>10000000.00)
			begin
				set @int_id= 7
				update account set acc_type= @acc_type, balance= @balance, cust_id= @cust_id, acc_status= @acc_status, branch_id= @branch_id, tel_id= @tel_id
				where acc_no= @acc_no
			end
		else
			print 'something went wrong'
	end
	else
		print 'invalid account type'
end
go

-------------------------------------------update deposit
create proc [update deposit]
(
	@dep_id int,
	@acc_no int,
	@tel_id int,
	@cust_id int,
	@amount money,
	@d_date date		
)
as
begin
	declare @time int
	set @time= datediff(year, @d_date, (select acc_status from account where acc_no=@acc_no))
	
	if (@time>10 and @time !< 0)
		Print 'sorry the account number has expired'
	else
	begin
		update deposit set acc_no= @acc_no, tel_id= @tel_id, cust_id= @cust_id, amount= @amount, d_date= @d_date	
		where dep_id= @dep_id
	end
end
go

---------------------------------------update withdraw
create proc [update withdraw]
(
	@with_id int,
	@acc_no int,
	@tel_id int,
	@cust_id int,
	@amount money,
	@w_date date
)
as
begin
	declare @time int
	set @time= datediff(year, @w_date, (select acc_status from account where acc_no=@acc_no))
	
	if (@time>10 and @time !< 0)
		Print 'sorry the account number has expired'
	else
	begin
		update withdraw set 
		acc_no= @acc_no, 
		tel_id= @tel_id, 
		cust_id= @cust_id, 
		amount= @amount, 
		w_date= @w_date	
		where with_id= @with_id
	end
end
go

--------------------------------------------update 
create proc [update transact]
(
	@trans_id int,
	@acc_no int,
	@tel_id int,
	@cust_id int,
	@trans_type varchar(20),
	@amount money,
	@trans_date date,
	@balance money
)
as
begin
	update transact set 
	acc_no= @acc_no,
	tel_id= @tel_id,
	cust_id= @cust_id,
	trans_type= @trans_type,
	amount= @amount,
	trans_date= @trans_date,
	balance= @balance
	where trans_id= @trans_id
end
go

----------------------------view interest rate
create proc [view interest]
(
	@int_type varchar(20) 
)
as
begin
	select int_rate as interest_rate from interest where int_type= @int_type
end
go

-----------------------------------check the account status
create proc [account status]
(
	@acc_no int
)
as
begin
	declare @time int
	set @time= datediff(year,(select acc_status from account where acc_no=@acc_no),getdate())
	if (@time>10 and @time !< 0)
		Print 'the account '+ convert(varchar, @acc_no) + ' is expired'
	else	
		print 'the account '+ convert(varchar, @acc_no) + ' is active'
end
go

----------------------------------------------------- view all deposits of a certain account
create proc [view deposit]
(
	@acc_no int
)
as
begin
	select * from deposit where acc_no= @acc_no
end
go

----------------------------------------------------- view all withdraws of a certain account
create proc [view withdraw]
(
	@acc_no int
)
as
begin
	select * from withdraw where acc_no= @acc_no
end
go

--------------------------------------------------- view which teller did the most transactions
create proc [employee of the month]
(
	@tel_id int,
	@start_date date, 
	@end_date date,
	@result int out
)
as
begin
	declare @temp1 date
	
	declare search_employee cursor scroll
	for select trans_date from transact where tel_id= @tel_id 
	open search_employee
	fetch first from search_employee
	into @temp1
	while @@FETCH_STATUS=0
	begin
		if (@temp1 > @start_date AND @temp1 < @end_date)
			set @result= @result + 1
		fetch next from search_employee
		into @temp1
	end
	close search_employee
	deallocate search_employee
end
go



---------FUNCTIONS-----------------

---------function to check the password
alter function [check password] 
(
	@password varchar(20)
)
	returns varchar(7)
as
begin
	declare @result varchar(7), @len int, @count int=1, @upp int=0, @low int=0, @num int=0, @temp int=0;
	set @len= len(@password)

	if (@len>7 and @len<20)
	begin
		while(@count<=@len)
		begin
			set @temp= ascii(substring(@password,@count,1))
			if(@temp >= 65 and @temp <= 90)	
				 set @upp= @upp + 1
			else if(@temp >= 97 and @temp <= 122)
				set @low = @low + 1
			else if(@temp >= 48 and @temp <= 57)
				set @num = @num + 1
			else
			begin
				set @result = 'invalid'
				break
			end
			set @count= @count + 1
		end	
		if ((@upp+@low)<3 or @upp<1 or @low<1 or @num<3)
			set @result= 'invalid'
		else
			set @result= 'valid'
	end
	else 
		set @result= 'invalid'
	
	return @result
end
go

------ function to calculate the interest
alter function [calculate interest]
(
	@acc_no int,
	@balance money,
	@int_id int
)
	returns money
as
begin
	declare @p float, @r float, @n float, @t float, @interest float
	set @p= convert(float,@balance)
	set @r= (select int_rate from interest where int_id= @int_id)/100
	set @n= dbo.[calculate idate](@acc_no)
	if (@n<1)
		set @p= 0
	set @t=@n/12
	set @t=@t*@n
	set @interest= @p*(power((1+(@r/@n)),@t))
	return convert(money,@interest)
end
go

------ to find the last deposit
alter function [last deposit]
(
	@acc_no int
)
	returns date
as
begin
	declare @lastd date ='0000-00-00', @temp1 int, @temp2 date
	
	declare search_lastdeposit cursor scroll
	for select acc_no,d_date from deposit 
	open search_lastdeposit
	fetch last from search_lastdeposit
	into @temp1,@temp2
	while @@FETCH_STATUS=0
	begin
		if (@temp1 = @acc_no)
		begin
			set @lastd= @temp2
			break
		end
		fetch prior from search_lastdeposit
		into @temp1,@temp2
	end
	close search_lastdeposit
	deallocate search_lastdeposit

	return @lastd
end
go

------------to find the last withdraw
alter function [last withdraw]
(
	@acc_no int
)
	returns date
as
begin
	declare @lastw date ='0000-00-00', @temp1 int, @temp2 date
	
	declare search_lastwithdraw cursor scroll
	for select acc_no,w_date from withdraw 
	open search_lastwithdraw
	fetch last from search_lastwithdraw
	into @temp1,@temp2
	while @@FETCH_STATUS=0
	begin
		if (@temp1 = @acc_no)
		begin
			set @lastw= @temp2
			break
		end
		fetch prior from search_lastwithdraw
		into @temp1,@temp2
	end
	close search_lastwithdraw
	deallocate search_lastwithdraw

	return @lastw
end
go

-----------calculate the total interest date
alter function [calculate idate]
(
	@acc_no int
)
	returns int
as
begin
	declare @ret int, @temp1 int, @temp2 date, @last date

	declare search_lasttrans cursor scroll
	for select acc_no,trans_date from transact 
	open search_lasttrans
	fetch last from search_lasttrans
	into @temp1,@temp2
	while @@FETCH_STATUS=0
	begin
		if (@temp1 = @acc_no)
		begin
			set @last= @temp2
			break
		end
		fetch prior from search_lasttrans
		into @temp1,@temp2
	end
	close search_lasttrans
	deallocate search_lasttrans

	set @ret= datediff(MONTH,@last,getdate())	
	return @ret
end
go

------------------------------calculate the interest of any given account
create function [account interest]
(
	@acc_no int,
	@balance money,
	@int_id int,
	@l_date int
)
	returns money
as
begin
	declare @p float, @r float, @n float, @t float, @interest float
	
	set @p= convert(float,@balance)
	set @r= (select int_rate from interest where int_id= @int_id)/100
	set @n= @l_date
	if (@n<1)
		set @p= 0
	set @t=@n/12
	set @t=@t*@n
	set @interest= @p*(power((1+(@r/@n)),@t))
	return convert(money,@interest)
end
go



---------------------------------------
-------------triggers------------------
---------------------------------------


--------- trigger to check passwords for teller
create trigger [check password1]
on teller
after update, insert
as
begin
	declare @result varchar(7), @pass varchar(20), @username varchar(30), @pass2 varchar(100)
	set @pass2= (select password from inserted)
	set @username= (select username from inserted)
	set @pass=  convert(varchar(100),DECRYPTBYPASSPHRASE(@username,@pass2))
	set @result= dbo.[check password](@pass)
	if (@result = 'invalid')
	begin
		print 'password not valid'
		rollback transaction
	end
	else
		print 'successful'
		
end
go

--------- trigger to check passwords for manager
create trigger [check password2]
on manager
after update, insert
as
begin
	declare @result varchar(7), @pass varchar(20), @username varchar(30), @pass2 varchar(100)
	set @pass2= (select password from inserted)
	set @username= (select username from inserted)
	set @pass=  convert(varchar(100),DECRYPTBYPASSPHRASE(@username,@pass2))
	set @result= dbo.[check password](@pass)
	if (@result = 'invalid')
	begin
		print 'password not valid'
		rollback transaction
	end
	else
		print 'successful'
		
end
go

-----------trigger for deposit
create trigger [craate deposit]
on deposit
after insert
as
begin
	declare @acc_no int, @tel_id int, @cust_id int, @trans_type varchar(20), @amount money, @trans_date date, @balance money
	
	set @acc_no= (select acc_no from inserted)
	set @tel_id= (select tel_id from inserted)
	set @cust_id= (select cust_id from inserted)
	set @trans_type= 'deposit'
	set @amount= (select amount from inserted)
	set @trans_date= (select d_date from inserted)
	set @balance= (select balance from account where acc_no= @acc_no) + @amount

	exec [create transact]@acc_no,@tel_id,@cust_id,@trans_type,@amount,@trans_date,@balance
end
go

-----------trigger for withdraw
create trigger [craate withdraw]
on withdraw
after insert
as
begin
	declare @acc_no int, @tel_id int, @cust_id int, @trans_type varchar(20), @amount money, @trans_date date, @balance money 
	
	set @acc_no= (select acc_no from inserted)
	set @tel_id= (select tel_id from inserted)
	set @cust_id= (select cust_id from inserted)
	set @trans_type= 'withdraw'
	set @amount= (select amount from inserted)
	set @trans_date= (select w_date from inserted)
	set @balance= (select balance from account where acc_no= @acc_no) - @amount

	exec [create transact]@acc_no,@tel_id,@cust_id,@trans_type,@amount,@trans_date,@balance
end
go

--------trigger for new accounts(to deposit)
create trigger [new account]
on account
after insert
as
begin
	declare @acc_no int, @tel_id int, @cust_id int, @amount money, @d_date date
	set @acc_no= (select acc_no from inserted)
	set @tel_id= (select tel_id from inserted)
	set @cust_id= (select cust_id from inserted)
	set @amount= (select balance from inserted)
	update account set balance= 0 where acc_no=@acc_no
	set @d_date= (select acc_status from inserted)

	exec [create deposit]@acc_no,@tel_id,@cust_id,@amount,@d_date
end
go

------------------trigger to downgrade account interest rate if it doesnt qualify
create trigger [downgrade]
on transact
after insert
as
begin
	declare @balance money, @int_id int,@acc_no int
	set @balance= (select balance from inserted)
	set @acc_no= (select acc_no from inserted)
	set @int_id= (select int_id from account where acc_no= @acc_no)

	if (@int_id=3 AND @balance<50000)
		update account set int_id=8 where acc_no= @acc_no 
	if (@int_id=4 AND @balance<150000)
		update account set int_id=9 where acc_no= @acc_no
	if (@int_id=5 AND @balance<300000)
		update account set int_id=10 where acc_no= @acc_no
	if (@int_id=6 AND @balance<1000000)
		update account set int_id=10 where acc_no= @acc_no
	if (@int_id=7 AND @balance<10000000)
		update account set int_id=6 where acc_no= @acc_no
end
go

-----------------------------------------------------------------
--------------------------------backup database
backup database bankmg
to disk = 'D:\sqlbackups\bankbackup.bkp'
go

------------------------------------------------------------------



------------------------------------------------------------------

exec [create branch]'kera','addis ababa','0911040404'
select * from branch

exec [create customer]'cf4','cl4','addis ababa','nifas silk','1856','1998-01-01','male','c4@gmail.com','0910040404'
select * from customer

exec [create interest]'fixed2_penality','5.5'
select * from interest
update interest set int_id=1 where int_type= 'current'

exec [create account]'saving','5000','10','2013-11-11','3','7'
select * from account
delete account


exec [create deposit]'10002','7','8','5000','2021-6-2'
select * from deposit

exec [create withdraw]'10002','9','8','2000','2021-6-2'
select * from withdraw

exec [create teller]'3','tf3','tl3','addisababa','nifas silk','1856','1998-01-01','female','te3@gmail.com','0912030303','10000','username3','Pass1000'
select * from teller

exec [create manager]'5','mf1','ml1','addisababa','nifas silk','1856','1998-08-08','male','me1@gmail.com','0914010101','21000','musername1','Pass1000'
select * from manager

select * from transact

----------------------------------------------------

exec [branch phone]
exec [customer phone]
exec [teller phone]
exec [manager phone]
exec [customer email]
exec [teller email]
exec [manager email]
exec [teller username]
exec [manager username]

-----------------------------------------------------

exec [delete branch]
exec [delete customer]
exec [delete teller]
exec [delete manager]
exec [delete interest]
exec [delete account]
exec [delete deposit]
exec [delete withdraw]
exec [delete transact]

-----------------------------------------------------

exec [search branch]
exec [search customer]
exec [search teller]
exec [search manager]
exec [search interest]
exec [search account]
exec [search deposit]
exec [search withdraw]
exec [search transact]

----------------------------------------------------

exec [update branch]
exec [update customer]
exec [update teller]
exec [update manager]
exec [update interest]
exec [update account]
exec [update deposit]
exec [update withdraw]
exec [update transact]

---------------------------------------------------

exec [view interest]
exec [account status]
exec [view deposit]
exec [view withdraw]
exec [employee of the month]

----------------------------------------------------

delete account
delete interest
delete branch
delete customer
delete teller
delete manager
delete transact
delete deposit
delete withdraw

-------------------------------------

drop table branch
drop table customer
drop table interest
drop table teller
drop table account
drop table transact
drop table deposit
drop table withdraw
drop table manager
