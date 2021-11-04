#!/bin/sh

set -e

do_cleanup() {
	echo cleaning up
	eval "${cleancmds}"
}

trap do_cleanup EXIT

cleanup() {
	cleancmds="$@; ${cleancmds}"
}

ip link add wgbenchlink1 type veth peer wgbenchlink2 
cleanup 'ip link del wgbenchlink1 2> /dev/null || true'
cleanup 'ip link del wgbenchlink2 2> /dev/null || true'

for i in 1 2
do
	ip netns add wgbench$i
	cleanup "ip netns del wgbench$i"

	ip link set wgbenchlink$i mtu 9000
	ip link set wgbenchlink$i netns wgbench$i
	cleanup "ip netns exec wgbench$i ip link del wgbenchlink$i 2> /dev/null || true"

	ip netns exec wgbench$i ip link add wgbench$i type wireguard
	cleanup "ip netns exec wgbench$i ip link del wgbench$i 2> /dev/null || true"

	ip netns exec wgbench$i ip link set wgbenchlink$i up 
	ip netns exec wgbench$i ip link set wgbench$i up mtu 8920 

	ip netns exec wgbench$i ip addr add 192.168.44.$i/24 dev wgbenchlink$i 
	ip netns exec wgbench$i ip addr add 192.168.45.$i/24 dev wgbench$i 
	ip netns exec wgbench$i wg setconf wgbench$i wgbench$i.conf 
done

ip netns exec wgbench2 iperf -s -D
cleanup 'ip netns exec wgbench2 sh -c '"'"'pkill -f "^iperf -s -D$" --ns $$ --nslist net'"'"
echo '##############################################'
echo '#                                            #'
echo '#    Running iperf on non-wireguard link     #'
echo '#                                            #'
echo '##############################################'
ip netns exec wgbench1 iperf -c 192.168.44.2 -t 5 -d
echo '##############################################'
echo '#                                            #'
echo '#      Running iperf on wireguard link       #'
echo '#                                            #'
echo '##############################################'
ip netns exec wgbench1 iperf -c 192.168.45.2 -t 5 -d
