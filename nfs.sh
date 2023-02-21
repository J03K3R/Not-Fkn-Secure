#!/bin/bash
echo "
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░███╗░░██╗░█████╗░████████╗░░███████╗██╗░░██╗███╗░░██╗░░░██████╗███████╗░█████╗░██╗░░░██╗██████╗░███████╗░░
░░████╗░██║██╔══██╗╚══██╔══╝░░██╔════╝██║░██╔╝████╗░██║░░██╔════╝██╔════╝██╔══██╗██║░░░██║██╔══██╗██╔════╝░░
░░██╔██╗██║██║░░██║░░░██║░░░░░█████╗░░█████═╝░██╔██╗██║░░╚█████╗░█████╗░░██║░░╚═╝██║░░░██║██████╔╝█████╗░░░░
░░██║╚████║██║░░██║░░░██║░░░░░██╔══╝░░██╔═██╗░██║╚████║░░░╚═══██╗██╔══╝░░██║░░██╗██║░░░██║██╔══██╗██╔══╝░░░░
░░██║░╚███║╚█████╔╝░░░██║░░░░░██║░░░░░██║░╚██╗██║░╚███║░░██████╔╝███████╗╚█████╔╝╚██████╔╝██║░░██║███████╗░░
░░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░░░╚═╝░░░░░╚═╝░░╚═╝╚═╝░░╚══╝░░╚═════╝░╚══════╝░╚════╝░░╚═════╝░╚═╝░░╚═╝╚══════╝░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

DISCLAIMER: This tool was created to demonstrate the dangers of having unprotected NFS. 
It is purely for education purposes and should not be used with malicious intent. 
Using this tool against targets that you don’t have permission to test is illegal. 
"
# Define the range of IP addresses to check
start_ip="192.168.1.1"
end_ip="192.168.1.254"

# Define the output file
output_file="nfs_shares.txt"

# Convert start and end IP addresses to integers
start_int=$(echo $start_ip | tr '.' ' ' | awk '{print ($1 * 256^3) + ($2 * 256^2) + ($3 * 256) + $4}')
end_int=$(echo $end_ip | tr '.' ' ' | awk '{print ($1 * 256^3) + ($2 * 256^2) + ($3 * 256) + $4}')

# Loop through the IP addresses
while [ $start_int -le $end_int ]; do
  # Convert integer IP address to dotted decimal format
  ip=$(printf "%d.%d.%d.%d\n" $(($start_int >> 24)) $(($start_int >> 16 & 255)) $(($start_int >> 8 & 255)) $(($start_int & 255)))
  
  echo "Checking $ip..."
  
  # Check if NFS is enabled
  if timeout 5 showmount -e $ip >/dev/null 2>&1; then
    echo "$ip has NFS enabled"
    
    # Check if authentication is enabled
    if timeout 5 rpcinfo -t $ip nfs 4 >/dev/null 2>&1; then
      echo "Authentication required for NFS on $ip"
    else
      echo "No authentication required for NFS on $ip"
      echo "Listing NFS shares on $ip:"
      showmount -e $ip | awk '{if (NR > 1) print "'"$ip"'" " " $0}' >> $output_file
      showmount -e $ip
    fi
  else
    echo "$ip does not have NFS enabled"
  fi
  
  # Increment the IP address
  start_int=$((start_int + 1))
done

