use User_Actions_2;

create partition function pf_UserLogsPartititon_By_Month (DATE)
as range right for values (
    '2025-02-01', '2025-03-01', '2025-04-01', '2025-05-01',
    '2025-06-01', '2025-07-01', '2025-08-01', '2025-09-01',
    '2025-10-01', '2025-11-01', '2025-12-01'
);

create partition scheme ps_UserLogsPartition_By_Month
as partition pf_UserLogsPartititon_By_Month
all to ([PRIMARY]);

create table User_Logs_Partitioned (
    id uniqueidentifier DEFAULT NEWID(),
    username varchar(255) NOT NULL,
    user_action varchar(50) NOT NULL,
    action_date date NOT NULL,
    action_time time NOT NULL,
    action_result varchar(50) NOT NULL,
    constraint PK_User_Logs_Partitioned primary key nonclustered (id, action_date)
) 
on ps_UserLogsPartition_By_Month(action_date);

create clustered index IX_User_Logs_Partitioned_ActionDate 
on User_Logs_Partitioned (action_date, id)
on ps_UserLogsPartition_By_Month(action_date);

set nocount on;

insert into User_Logs_Partitioned with (tablock) 
    (id, username, user_action, action_date, action_time, action_result)
select 
    id, username, user_action, action_date, action_time, action_result
from User_Logs;

select 
    $partition.pf_UserLogsPartititon_By_Month(action_date) as PartitionNumber,
    year(action_date) as [Year],
    month(action_date) as [Month],
    count(*) as [RowCount],
    min(action_date) as MinDate,
    max(action_date) as MaxDate
from User_Logs_Partitioned
group by 
    $partition.pf_UserLogsPartititon_By_Month(action_date),
    year(action_date),
    month(action_date)
order by PartitionNumber;