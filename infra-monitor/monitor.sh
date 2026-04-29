#!/bin/bash
SERVICE="ssh"
PORT="22"
REPORT_DIR="reports"
REPORT_FILE="$REPORT_DIR/latest.log"
mkdir -p "$REPORT_DIR"
echo "======================" >> "$REPORT_FILE"
echo "linux  Infra Monitoring " >> "$REPORT_FILE"
echo "Time: $(date)" >> "$REPORT_FILE"
echo "Host: $(hostname)" >> "$REPORT_FILE"
echo "====================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "1. Checking service status: $SERVICE" >> "$REPORT_FILE"
if systemctl is-active --quiet "$SERVICE"; then
echo "STATUS: $SERVICE is running" >> "$REPORT_FILE"
else
echo "STATUS: $SERVICE is DOWN" >> "$REPORT_FILE"
sudo systemctl restart "$SERVICE"
if systemctl is-active --quiet "$SERVICE"; then
echo "RESULT: $SERVICE restarted successfully" >> "$REPORT_FILE"
else
echo "RESULT: Failed to restart $SERVICE" >> "$REPORT_FILE"
journalctl -u "$SERVICE" -n 30 >> "$REPORT_FILE"
    fi
fi
echo "" >> "$REPORT_FILE"
echo "2. Checking port $PORT" >> "$REPORT_FILE"

if ss -tlnp | grep -q ":$PORT"; then
    echo "STATUS: Port $PORT is listening" >> "$REPORT_FILE"
else
    echo "WARNING: Port $PORT is NOT listening" >> "$REPORT_FILE"
    echo "Possible issue: service not bound to port or config problem" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"
echo "3. Checking disk usage" >> "$REPORT_FILE"

df -h >> "$REPORT_FILE"
DISK_USAGE=$(df / | awk '{print $5}' | tail -1 | tr -d '%')

if [ "$DISK_USAGE" -gt 80 ]; then
    echo "WARNING: Disk usage is high: $DISK_USAGE%" >> "$REPORT_FILE"
    echo "Top large directories inside /var:" >> "$REPORT_FILE"
     du -sh /var/* | sort -rh >> "$REPORT_FILE"
else
    echo "STATUS: Disk usage is normal: $DISK_USAGE%" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"
echo "4. Checking memory usage" >> "$REPORT_FILE"

free -h >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "Checking OOM kill logs:" >> "$REPORT_FILE"

dmesg | grep -i 'oom\|killed' | tail -10 >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "5. Top CPU consuming processes" >> "$REPORT_FILE"

ps aux --sort=-%cpu | head -10 >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Monitoring completed." >> "$REPORT_FILE"
echo "Report saved at: $REPORT_FILE"
