# Wireguard benchmark

This is a stupidly simple benchmarking tool for wireguard.

It creates two new network namespaces and a veth link between them. Then it creates wireguard interfaces inside each and runs iperf between them. First without wireguard, then with wireguard. Here's an example from a Netgear AC750:
```
root@OpenWrt:~/wgbench# ./wgbench.sh 
##############################################
#                                            #
#            Triggering handshake            #
#                                            #
##############################################
PING 192.168.45.2 (192.168.45.2): 56 data bytes
64 bytes from 192.168.45.2: seq=0 ttl=64 time=33.244 ms

--- 192.168.45.2 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 33.244/33.244/33.244 ms
Running Iperf Server as a daemon
##############################################
#                                            #
#    Running iperf on non-wireguard link     #
#                                            #
##############################################
------------------------------------------------------------
Client connecting to 192.168.44.2, TCP port 5001
TCP window size:  438 KByte (default)
------------------------------------------------------------
[  3] local 192.168.44.1 port 33616 connected with 192.168.44.2 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 5.0 sec   253 MBytes   424 Mbits/sec
##############################################
#                                            #
#      Running iperf on wireguard link       #
#                                            #
##############################################
------------------------------------------------------------
Client connecting to 192.168.45.2, TCP port 5001
TCP window size:  324 KByte (default)
------------------------------------------------------------
[  3] local 192.168.45.1 port 59286 connected with 192.168.45.2 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 5.0 sec  26.6 MBytes  44.7 Mbits/sec
cleaning up
```
