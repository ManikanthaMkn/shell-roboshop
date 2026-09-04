#!/bin/bash/

START_TIME=$(date +%s)
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

nf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabled the current Nodejs version"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling the Nodejs version 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing the enabled Nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating Roboshop systyem for Cart"
else
    echo -e "System User Roboshop is already created ... $Y Skipping $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Cart Files"

rm -rf /app/*
cd /app 
unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "Move to the application directory and extract the downloaded files"

npm install &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copying Cart service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading systemd unit files after configuration changes"

systemctl enable cart &>>$LOG_FILE
VALIDATE $? "Enabled the Cart services"

systemctl start cart &>>$LOG_FILE
VALIDATE $? "Started the Cart services"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE