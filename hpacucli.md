# HPACUCLI

## RAID Check
```bash
#!/bin/bash
MAIL=augie@schwer.us
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