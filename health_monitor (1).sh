#!/bin/bash

TIME=$(date '+%Y-%m-%d %H:%M:%S')

CPU=$(top -bn1 | awk '/Cpu/ {print 100 - $8}')
MEM=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100}')
DISK=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

# log
echo "[$TIME] CPU:$CPU% MEM:$MEM% DISK:$DISK%" >> health.log

# alerts — print to terminal AND log
[ "$CPU"  -gt 80 ] && echo "[$TIME] ALERT: High CPU ($CPU%)" | tee -a health.log
[ "$MEM"  -gt 80 ] && echo "[$TIME] ALERT: High MEM ($MEM%)" | tee -a health.log
[ "$DISK" -gt 85 ] && echo "[$TIME] ALERT: High DISK ($DISK%)" | tee -a health.log
