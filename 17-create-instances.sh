#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
PACKAGES=("mysql" "python" "nginx" "httpd")

mkdir -p $LOGS_FOLDER
echo "Script Started Executing at:: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi #IF I am not root → show error and stop. Otherwise → continue.

VALIDATE(){
    if [ $1 -eq 0 ]
    then 
        echo -e "Installing $2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else 
        echo -e "Installing $2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

#for PACKAGE in ${PACKAGES[@]}
for PACKAGE in $@ #Here, $@ represents all the arguments passed to the shell script. The for loop takes each argument one by one and stores it in the PACKAGE variable. The commands inside the loop are then executed for each package.
do
    dnf list installed $PACKAGE &>>$LOG_FILE
    if [ $? -ne 0 ] #$? The exit status of the most recently executed command
    then
        echo -e "$R "$PACKAGE" is not installed $N ... $G going to install it $N" | tee -a $LOG_FILE
        dnf install $PACKAGE -y &>>$LOG_FILE
        VALIDATE $? "$PACKAGE"
    else
        echo -e "$Y "$PACKAGE" is already installed $N ... Nothing to do" | tee -a $LOG_FILE
        # exit 0
    fi
done
#Manikantha