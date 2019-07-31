#!/bin/sh

USER=user
PASS=pass
DB=`mysql -u $USER -p$PASS -e 'show databases;' | grep bitrix`
OPT="--quick --insert-ignore --skip-lock-tables --single-transaction=TRUE"
BMAIL=/tmp/mail
DEST=/backup
DATE=`date +%F`

for i in $DB;
do
    mysqldump -u $USER -p$PASS $OPT -B $DB | /bin/gzip -c > $DEST/$DATE-$DB.sql.gz;
done

if [ -e $DEST/$DATE-$DB.sql.gz ]; then
    echo "Backup $DEST/$DATE-$DB complete" >> $BMAIL
    cat $BMAIL | msmtp -a default user@mail.ru
else
    echo "Backup $DEST/$DATE-$DB FAIL!" >> $BMAIL
    cat $BMAIL | msmtp -a default user@mail.ru
fi


find /backup -maxdepth 1 -name "*sql.gz" -mtime +5 -exec rm -f {} \;

if [ $(cat $BMAIL | wc -l) > 9 ]; then
 sed -i '5d' $BMAIL
fi