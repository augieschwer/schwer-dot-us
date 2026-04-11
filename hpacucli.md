# HPACUCLI

HPACUCLI stands for HP Array Configuration Utility CLI.

[Download](https://support.hpe.com/connect/s/softwaredetails?language=en_US&collectionId=MTX-UNITY_C8723&tab=releaseNotes)

## RAID Check

Check for faults on your RAID array, and email it to yourself. Put this in `/etc/cron.daily` to schedule regular checks.

```bash
#!/bin/bash
MAIL=mail@example.com
RESULT=`hpacucli ctrl slot=0 pd all show | grep physicaldrive | grep -v "OK"`
if [ -n "$RESULT" ]; then
    echo "RAID array: ERROR"
    echo "$RESULT"
    echo "$RESULT" | mail -s 'RAID array: ERROR' "$MAIL"
# uncomment the following to test
#    else
#       echo "RAID array: OK"
#       RESULT=`hpacucli ctrl slot=0 pd all show | grep physicaldrive`
#       echo "$RESULT"
#       echo "$RESULT" | mail -s 'RAID array: OK' "$MAIL"
fi
```