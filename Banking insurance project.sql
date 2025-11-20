create table customers (
    customerid int primary key auto_increment,
    name varchar(50) not null,
    phone varchar(15) unique,
    email varchar(50) unique,
    address varchar(100)
);

create table accounts (
    accountid int primary key auto_increment,
    customerid int,
    accounttype varchar(20) not null,
    balance decimal(12,2) default 0,
    foreign key (customerid) references customers(customerid)
);

create table insurancepolicies (
    policyid int primary key auto_increment,
    customerid int,
    policytype varchar(50),
    policyamount decimal(12,2),
    premium decimal(12,2),
    startdate date,
    enddate date,
    foreign key (customerid) references customers(customerid)
);

create table transactions (
    transactionid int primary key auto_increment,
    accountid int,
    transactiontype varchar(20), -- deposit/withdraw
    amount decimal(12,2),
    transactiondate timestamp,
    foreign key (accountid) references accounts(accountid)
);

create table claims (
    claimid int primary key auto_increment,
    policyid int,
    claimamount decimal(12,2),
    claimdate timestamp,
    status varchar(20) default 'pending',
    foreign key (policyid) references insurancepolicies(policyid)
);


insert into customers (name, phone, email, address) values
('ravi kumar','9876543210','ravi@mail.com','chennai'),
('anita raj','9876501234','anita@mail.com','coimbatore'),
('karthik s','9876512345','karthik@mail.com','madurai'),
('meena p','9876523456','meena@mail.com','trichy'),
('arjun k','9876534567','arjun@mail.com','salem'),
('deepa r','9876545678','deepa@mail.com','vellore'),
('vikram s','9876556789','vikram@mail.com','chennai'),
('priya l','9876567890','priya@mail.com','coimbatore'),
('santhosh m','9876578901','santhosh@mail.com','madurai'),
('latha k','9876589012','latha@mail.com','trichy');

insert into accounts (customerid, accounttype, balance) values
(1,'savings',50000),
(2,'savings',30000),
(3,'current',70000),
(4,'savings',40000),
(5,'current',60000),
(6,'savings',55000),
(7,'current',45000),
(8,'savings',35000),
(9,'current',65000),
(10,'savings',50000);

insert into insurancepolicies (customerid, policytype, policyamount, premium, startdate, enddate) values
(1,'life',1000000,5000,'2024-01-01','2034-01-01'),
(2,'vehicle',500000,3000,'2023-06-01','2024-06-01'),
(3,'health',2000000,7000,'2024-03-01','2025-03-01'),
(4,'life',1500000,5500,'2024-02-01','2034-02-01'),
(5,'vehicle',750000,4000,'2023-07-01','2024-07-01'),
(6,'health',1800000,6500,'2024-04-01','2025-04-01'),
(7,'life',1200000,5000,'2024-05-01','2034-05-01'),
(8,'vehicle',600000,3500,'2023-08-01','2024-08-01'),
(9,'health',2200000,7200,'2024-06-01','2025-06-01'),
(10,'life',1300000,5200,'2024-07-01','2034-07-01');

insert into transactions (accountid, transactiontype, amount, transactiondate) values
(1,'deposit',10000,'2025-01-10 10:00:00'),
(2,'withdraw',5000,'2025-01-12 11:00:00'),
(3,'deposit',20000,'2025-01-15 09:30:00'),
(4,'withdraw',10000,'2025-01-18 15:00:00'),
(5,'deposit',15000,'2025-01-20 14:00:00'),
(6,'withdraw',5000,'2025-01-22 13:00:00'),
(7,'deposit',10000,'2025-01-25 16:30:00'),
(8,'withdraw',7000,'2025-01-28 12:15:00'),
(9,'deposit',12000,'2025-01-30 10:45:00'),
(10,'withdraw',8000,'2025-02-02 11:30:00');

insert into claims (policyid, claimamount, claimdate, status) values
(1,500000,'2025-01-15','approved'),
(2,250000,'2025-01-18','pending'),
(3,1000000,'2025-01-20','approved'),
(4,750000,'2025-01-22','pending'),
(5,300000,'2025-01-25','approved'),
(6,900000,'2025-01-28','pending'),
(7,600000,'2025-02-01','approved'),
(8,200000,'2025-02-03','pending'),
(9,1200000,'2025-02-05','approved'),
(10,650000,'2025-02-07','pending');

-- to see the 5 table

select * from customers;
select * from accounts;
select * from insurancepolicies;
select * from transactions;
select * from claims;

-- create a procedure to deposit

DELIMITER //
CREATE PROCEDURE Deposit(IN acc_id INT, IN amt DECIMAL(12,2))
BEGIN
   -- Insert transaction
   INSERT INTO transactions (accountid, transactiontype, amount, transactiondate)
   VALUES (acc_id, 'Deposit', amt, NOW());

   -- Update account balance
   UPDATE accounts
   SET balance = balance + amt
   WHERE accountid = acc_id;
END //
DELIMITER ;

call Deposit(1,2200.00);

-- create a procedure for withdraw

DELIMITER //
CREATE PROCEDURE Withdraw(IN acc_id INT, IN amt DECIMAL(12,2))
BEGIN
   DECLARE current_balance DECIMAL(12,2);

   -- Get current balance
   SELECT balance INTO current_balance FROM accounts WHERE accountid = acc_id;

   -- Check balance
   IF current_balance >= amt THEN
      -- Insert transaction
      INSERT INTO transactions (accountid, transactiontype, amount, transactiondate)
      VALUES (acc_id, 'Withdraw', amt, NOW());

      -- Update balance
      UPDATE accounts
      SET balance = balance - amt
      WHERE accountid = acc_id;
   ELSE
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance';
   END IF;
END //
DELIMITER ;

call Withdraw(1,2200);

-- using joins to retrive data's

SELECT 
    c.customerId,
    c.name,
    c.phone,
    c.address,
    a.accountId,
    a.accounttype,
    a.balance,
    i.policyid,
    i.policytype,
    policyamount,
    cl.claimamount,
    cl.status
FROM
    customers c
        left JOIN
    accounts a ON c.customerId = a.customerId
        JOIN
    insurancepolicies i ON c.customerId = i.customerId
        JOIN
    claims cl ON i.policyid = cl.policyid;
    
SELECT 
    c.customerid,c.name, a.accountid, a.balance 
FROM
    customers c
        JOIN
    accounts a ON c.customerid = a.customerid
WHERE
    a.balance = (SELECT 
            MAX(balance) AS 'highest salary'
        FROM
            accounts a);
            
-- using joins to retrive data's

select 
    c.name, c.phone, cl.claimamount,(select avg(claimamount) from claims) as 'average of total account'
from customers c
join insurancepolicies i on c.customerid = i.customerid
join claims cl on i.policyid = cl.policyid
where cl.claimamount > (select avg(claimamount) from claims);

select name, phone
from customers
where customerid in (
    select customerid
    from insurancepolicies
    where policyid not in (select policyid from claims)
);
-- using care to process

select 
    c.customerid,
    c.name,
    i.policyid,
    i.policytype,
    cl.claimid,
    cl.claimamount,
    cl.status,
    
    -- total number of policies per customer
    count(i.policyid) over(partition by c.customerid) as total_policies,
    
    -- total claim amount per customer
    sum(cl.claimamount) over(partition by c.customerid) as total_claim_amount,
    
    -- count of pending claims per customer
    sum(case when cl.status = 'pending' then 1 else 0 end) over(partition by c.customerid) as pending_claims,
    
    -- count of approved claims per customer
    sum(case when cl.status = 'approved' then 1 else 0 end) over(partition by c.customerid) as approved_claims
    
from customers c
left join insurancepolicies i on c.customerid = i.customerid
left join claims cl on i.policyid = cl.policyid
order by c.customerid, i.policyid;

-- Triggers

DELIMITER //

CREATE TRIGGER check_claim_amount
BEFORE INSERT ON claims
FOR EACH ROW
BEGIN
    DECLARE policy_max DECIMAL(12,2);

    SELECT policyamount INTO policy_max 
    FROM insurancepolicies 
    WHERE policyid = NEW.policyid;

    IF NEW.claimamount > policy_max THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Claim amount exceeds policy amount';
    END IF;
END;
//

DELIMITER ;

-- for  check the trigger

INSERT INTO claims (policyid, claimamount, claimdate, status)
VALUES (1, 1500000, NOW(), 'pending');






    