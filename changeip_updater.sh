#!/bin/bash
#################################################
### Command Line Tool to set/update changeip.com 
### ChangeIP dynamic address update
### 2023 - GOOKO WEB SOLUTIONS
### https://www.gooko.gr
###
##################################################

###################################################
#
#  ChangeIP parameters
#  modify to your preferences
#
C_HOSTNAME=YOUR_DYNAMIC_DNS_NAME;
C_USER=MYUSERNAME;    
C_PASS=MYPASSWORD;


###############################################
# If you need Logging when
# IP changes set parameter to 1 and full path
ENABLE_LOG=1;  #0=FALSE 1=TRUE
LOG_FILE=/tmp/dynamic_ip.log;
###############################################



# In order to parse the json we use jq 
# (jq is a lightweight and flexible command-line JSON processor.)
# https://jqlang.github.io/jq/
# To install sudo apt install jq
#
#
# USE GOOKO's free ip check service
# which returns json format
# 
# Make GET request to URL and parse JSON response
response=$(curl -s "https://gooko.online/ip/dyn?h=$C_HOSTNAME")
ip=$(echo "$response" | jq -r '.ip')
dyn_ip=$(echo "$response" | jq -r '.dyn_ip')

# Check if IP addresses are the same
# if not same make the update and log if enable_log is set
if [ "$ip" != "$dyn_ip" ]; then

	# Make GET request to URL with dyn_ip value
	if [ "$ENABLE_LOG" -eq 1 ]; then
  		curl -s -w "%{http_code} %{time_total}\n" "https://nic.ChangeIP.com/nic/update?u=$C_USER&p=$C_PASS&hostname=$C_HOSTNAME&ip=$ip" -o /dev/null | awk -v old_ip="$dyn_ip" -v new_ip="$ip" '$1 == "200" { print strftime("%Y-%m-%d %H:%M:%S"), "Successful Update ", old_ip, " -> ", new_ip }' >> $LOG_FILE
	else
  		curl -s -w "%{http_code} %{time_total}\n" "https://nic.ChangeIP.com/nic/update?u=$C_USER&p=$C_PASS&hostname=$C_HOSTNAME&ip=$ip" -o /dev/null
	fi

fi
