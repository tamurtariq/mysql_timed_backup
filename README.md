# mysql_timed_backup
Mysql backup and deletion of old backup
1. install aws cli for secured connection to s3 
    run script aws_cli_install.sh
2. configure aws cli with the user credentials
    once aws cli is installed configure the aws cli for login with following command
     > aws configure
     # it will ask for the following

    Secret key:    dMS+0HVK4jqpIZ3iAbbEBbql/XZH7ThxUA7G/zpd <br />
    Access key:     AKIAQWYXJZ3LWHFRKGVJ  <br />
    Default region name [None]: us-east-2  <br />
    Default output format [None]: json  <br />

3. add cronjob in system for timed backup process
    run command as root # crontab -e    <br />
    a. add the following at the end of the file <br />
   >  * * * * * bash /path-to-script/mysql_backup_script.sh
