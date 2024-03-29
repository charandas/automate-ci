*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]

# Accept all loopback (local) traffic:
-A INPUT -i lo -j ACCEPT

# Accept all traffic on the local network from other members of
# our CoreOS cluster:
-A INPUT -i eth1 -p tcp -s ${coreos_host_private_ip_0} -j ACCEPT
-A INPUT -i eth1 -p tcp -s ${coreos_host_private_ip_1} -j ACCEPT
-A INPUT -i eth1 -p tcp -s ${coreos_host_private_ip_2} -j ACCEPT
-A INPUT -i eth1 -p udp -s ${coreos_host_private_ip_0} -j ACCEPT
-A INPUT -i eth1 -p udp -s ${coreos_host_private_ip_1} -j ACCEPT
-A INPUT -i eth1 -p udp -s ${coreos_host_private_ip_2} -j ACCEPT

# Keep existing connections (like our SSH session) alive:
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Accept all TCP/IP traffic to SSH, HTTP, and HTTPS ports - this should
# be customized  for your application:
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 443 -j ACCEPT

# Accept pings:
-A INPUT -p icmp -m icmp --icmp-type 0 -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 3 -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT
COMMIT
