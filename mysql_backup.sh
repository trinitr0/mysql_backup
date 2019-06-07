#!/bin/sh

USER=user
PASS=pass
DB=`mysql -u $USER -p$PASS -e 'show databases;' | grep bitrix`
OPT="--quick --insert-ignore --skip-lock-tables --single-transaction=TRUE"
DEST=/backup
DATE=`date +%Y-%m-%d-%H-%M`

for i in $DB;
do
    mysqldump -u $USER -p$PASS $OPT -B $DB | /bin/gzip -c > $DEST/$DATE-$DB.sql.gz;
done

if [ -e $DEST/$DATE-$DB.sql.gz ]; then
    echo "Backup $DEST/$DATE-$DB complete" >> /tmp/mail
    cat /tmp/mail | msmtp -a default user@mail.ru
else
    echo "Backup $DEST/$DATE-$DB FAIL!" >> /tmp/mail
    cat /tmp/mail | msmtp -a default user@mail.ru
fi


find /backup -maxdepth 1 -name "*sql.gz" -mtime +5 -exec rm -f {} \;
