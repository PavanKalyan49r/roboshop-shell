#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
    echo -e "$2 ...$R failed $N"
    exit 1
    else
    echo -e "$2 ...$G success $N"
    fi
}

if [ $ID -ne 0 ]
then
echo -e "$R ERROR:: please run this script with root access $N"
exit 1 #you can give other than 0
else
echo "you are root user"
fi # fi  means reverse of if, indicating condtion end

dnf install maven -y &>> $LOGFILE

id roboshop #if roboshop user does not exist , then it is failure
if [ $? -ne 0 ]
then
useradd roboshop
VALIDATE $? " roboshop user creation "
else
echo -e " roboshop user already exist $Y skipping $N"
fi

mkdir /app

VALIDATE $? " creating app directory "

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? " downloading shipping "

cd /app

VALIDATE $? " moving to app directory "

unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? " unzipping shipping "

mvn clean package &>> $LOGFILE

VALIDATE $? " installing dependencies "

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? " renaming jar file "

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? " copying shipping service "

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? " demon reload "

systemctl enable shipping &>> $LOGFILE

VALIDATE $? " enable shipping "

systemctl start shipping &>> $LOGFILE

VALIDATE $? " start shipping "

dnf install mysql -y &>> $LOGFILE

VALIDATE $? " install mysql client "

mysql -h mysql.pavanaws.online -uroot -pRoboShop@1 < /app/schema/shipping.sql 
VALIDATE $? " loading shipping data "

systemctl restart shipping &>> $LOGFILE

VALIDATE $? " retsart shipping"