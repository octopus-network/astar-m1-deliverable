#!/usr/bin/env bash

#createclient
cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw create-client earth ibc-0            #成功 
# cargo run -p ibc-relayer-cli -- -c hermes.toml query client state earth 10-grandpa-0       #success
cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw create-client ibc-0 earth            #成功
# cargo run -p ibc-relayer-cli -- -c hermes.toml query client state ibc-0  07-tendermint-0   #success

#updateclient
cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw update-client earth 10-grandpa-0     #
# cargo run -p ibc-relayer-cli -- -c hermes.toml query client state earth 10-grandpa-0       #
cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw update-client ibc-0  07-tendermint-0 #
# cargo run -p ibc-relayer-cli -- -c hermes.toml query client state ibc-0  07-tendermint-0   #

#connection
cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw conn-init earth ibc-0 10-grandpa-0 07-tendermint-0                                     #成功
cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw conn-try ibc-0 earth 07-tendermint-0 10-grandpa-0 -s connection-0                      #success
# cargo run -p ibc-relayer-cli -- -c hermes.toml query connection end earth connection-0
# cargo run -p ibc-relayer-cli -- -c hermes.toml query connection end ibc-0 connection-0
sleep 30
cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw conn-ack earth ibc-0 10-grandpa-0 07-tendermint-0 -d connection-0 -s connection-0      #
cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw conn-confirm ibc-0 earth 07-tendermint-0 10-grandpa-0 -d connection-0 -s connection-0  #
sleep 30
# cargo run -p ibc-relayer-cli -- -c hermes.toml query connection end ibc-0 connection-0  #成功
# cargo run -p ibc-relayer-cli -- -c hermes.toml query connection end earth connection-0  

#channle
cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw chan-open-init earth ibc-0 connection-0 transfer transfer -o UNORDERED                   #成功
cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw chan-open-try ibc-0 earth connection-0 transfer transfer -s channel-0                   
sleep 25
# cargo run -p ibc-relayer-cli -- -c hermes.toml query channel end earth transfer channel-0
# cargo run -p ibc-relayer-cli -- -c hermes.toml query channel end ibc-0 transfer channel-0
cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw chan-open-ack earth ibc-0 connection-0 transfer transfer -d channel-0 -s channel-0    
cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw chan-open-confirm ibc-0 earth connection-0 transfer transfer -d channel-0 -s channel-0 
sleep 25
# cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw chan-close-init ibc-0 earth connection-0 transfer transfer -d channel-0 -s channel-0
# cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw chan-close-confirm earth ibc-0 connection-0 transfer transfer -d channel-0 -s channel-0

# cargo run -p ibc-relayer-cli -- -c hermes.toml tx raw ft-transfer earth ibc-0 transfer channel-0 9999 -o 60 -n 1 -t 9999

#Fungible token transfer
#TODO