#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script Started Executing at:: $(date)" | tee -a $LOG_FILE

#Check whether the user has root privileges or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi #IF I am not root → show error and stop. Otherwise → continue.

#Validate the function inputs: exit status and the command used for installation.
VALIDATE(){
    if [ $1 -eq 0 ]
    then 
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else 
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling the Redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling the Redis version 7"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing the Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Edited redis.conf to accept remote connections"

# sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
# VALIDATE $? "Editing Redis conf file for remote connection"

# sed -i 's/yes/no/g' /etc/redis/redis.conf
# VALIDATE $? "Editing Redis conf file for remote connection"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabled the Redis services"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Started the Redis services"
