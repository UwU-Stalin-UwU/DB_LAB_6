create database User_Actions_2;

use User_Actions_2;

create table User_Logs(
    id uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
    username varchar(255) NOT NULL,
    user_action varchar(50) NOT NULL,
    action_date date NOT NULL,
    action_time time NOT NULL,
    action_result varchar(50) NOT NULL
);

set nocount on;

with Tally as (
    select top 1000000
        rn = row_number() over (order by (select null))
    from (values (1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) v1(n)
    cross join (values (1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) v2(n)
    cross join (values (1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) v3(n)
    cross join (values (1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) v4(n)
    cross join (values (1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) v5(n)
    cross join (values (1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) v6(n)
),
Randomized as (
    select
        rn,
        rand_val = abs(checksum(newid()))
    from Tally
)
insert into User_Logs with (tablock) (username, user_action, action_date, action_time, action_result)
select
    'user_' + right('00000' + cast(rand_val % 99999 as varchar(5)), 5),
    
    case rand_val % 8
        when 0 then 'LOGIN'      when 1 then 'LOGOUT'
        when 2 then 'UPDATE'     when 3 then 'DELETE'
        when 4 then 'VIEW'       when 5 then 'CREATE'
        when 6 then 'EXPORT'     when 7 then 'IMPORT'
        else 'UNKNOWN'
    end,
    
    dateadd(day, rand_val % 365, '2025-01-01'),
    
    dateadd(second, rand_val % 86400, CAST('00:00:00' AS time)),
    
    case rand_val % 5
        when 0 then 'SUCCESS'        when 1 then 'FAILED'
        when 2 then 'PENDING'        when 3 then 'TIMEOUT'
        when 4 then 'ACCESS_DENIED'
        else 'ERROR'
    end
from Randomized;

select * from User_Logs order by action_date;