#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)
R="\e[31m" #colors
G="\e[32m"
Y="\e[33m"
N="\e[0m"

CHECKROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Please run this script with root priveleges $N" | tee -a $LOG_FILE
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R FAILURE $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

echo "Script start executed at: $(date) " | tee -a $LOG_FILE
CHECK_ROOT

dnf install mysql -y
VALIDATE $? "Installing mysql"

systemctl enable mysqld -y
VALIDATE $? "Enabling mysql"

systemctl start mysqld -y
VALIDATE $? "Starting mysql"

mysql -h mysql.daws81s.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo "MySQL root password is not setup, setting now" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting UP root password"
else
    echo -e "MySQL root password is already setup...$Y SKIPPING $N" | tee -a $LOG_FILE
fi