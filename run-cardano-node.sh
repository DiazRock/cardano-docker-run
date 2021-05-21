docker run \
 -p 12798:12798\
 --add-host=host.docker.internal:host-gateway \
 -v $PWD/testnet:/configuration \
 -v $PWD/testnet/data:/data \
 -v $PWD/testnet/node-ipc:/ipc\
 inputoutput/cardano-node run \
 --topology /configuration/testnet-topology.json \
 --database-path /configuration/db \
 --socket-path /configuration/node.socket \
 --host-addr 0.0.0.0 \
 --port 3001 \
 --config /configuration/testnet-config.json