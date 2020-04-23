#!/usr/bin/env bash

./memcached.exe -d -I 128m -m 1024 -l memcached.local.com -p 11214 -vv

./mc_conn_tester.pl --help
./mc_conn_tester.pl -s memcached.local.com -p 11211 -c 1000 --timeout 1


# Troubleshooting Timeouts
echo "stats" | nc memcached.local.com 11211 | grep "listen_disabled_num"


echo "stats slabs" | nc memcached.local.com 11211
echo "stats items" | nc memcached.local.com 11211
echo "stats items" | nc memcached.default.svc.cluster.local 11211

echo "get 94D8567CFF5D5629775EB042BFE84FDD-n1" | nc memcached.local.com 11211
echo "get validity:5C63B7158D753D8F978B7426CC98C2E7-n1" | nc memcached.local.com 11211

echo "get SESSION_COUNT-n1" | nc memcached.local.com 11211


echo "stats cachedump SLABS_ID LIMIT" | nc HOSTNAME PORT
echo "stats cachedump 0 0" | nc memcached.local.com 11211
echo "stats cachedump 15 4" | nc memcached.default.svc.cluster.local 11211



# https://lzone.de/cheat-sheet/memcached

telnet memcached.local.com 11211



echo 'stats items'  \
| nc memcached.local.com 11211  \
| grep -oe ':[0-9]*:'  \
| grep -oe '[0-9]*'  \
| sort  \
| uniq  \
| xargs -L1 -I{} bash -c 'echo "stats cachedump {} 0" | nc localhost 11211'



