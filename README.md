# astar-m1-deliverable


## E2E Test
## Launch IBC Enabled Shiden Network Locally
```bash
git clone https://github.com:octopus-network/Astar.git 
cd Astar
ls test/README.md  # <== Follow this "README.md"
```
Follow the `test/README.md` to run the IBC enabled Shiden network locally.

## Launch A Cosmos Chain with Mock Grandpa Module Locally
```bash
git clone https://github.com/octopus-network/mock-grandpa.git 
cd mock-grandpa
ls astar-readme.md  # <== Follow this "astar-readme.md"
```
Follow the `astar-readme.md` to run the Cosmos chain locally.

## Prepare the Relayer
### Requirement
* python3.8+
* `pip install toml`

### Compile Relayer
```bash
git clone -b dv-update-subxt https://github.com/octopus-network/ibc-rs.git
cd ibc-rs
cargo build --release
```

### Run e2e Testing
```bash
cd e2e-astar
python run.py -c ../hermes.toml --cmd ../target/release/hermes
```
