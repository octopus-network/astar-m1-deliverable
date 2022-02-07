# GRANDPA light client(mock) on cosmos

# 

## I**nstall Golang**

Install golang go1.16.4+

## Install Starport

Linux:

```bash
sudo curl https://get.starport.network/starport | bash

```

This command invokes `curl` to download the install script and pipes the output to `bash` to perform the installation. The `starport` binary is installed in `/usr/local/bin`.

MacOS:

```bash
brew install tendermint/tap/starport
```

### From Source Code

```bash
git clone https://github.com/tendermint/starport --depth=1
cd starport && make install
```

Ref: [https://docs.starport.network/guide/install.html](https://docs.starport.network/guide/install.html)



```bash
starport version

Starport version:       development
Starport build date:    2021-10-07T16:33:11
Starport source hash:   513972c00128418e5eaacb3b32b2e48776789098
Your OS:                linux
Your arch:              amd64
Your go version:        go version go1.17.2 linux/amd64
Your uname -a:          Linux mars.ultraspace.network 5.4.0-89-generic #100-Ubuntu SMP Fri Sep 24 14:50:10 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
Your cwd:               /home/boern
Is on Gitpod:           false
```

# Dev grandpa light client (mock) on ibc-go

fork and clone ibc-go repo：

```bash
# firt, fork from cosmos/ibc-go to octopus-network github account
# second,clone from octopus-network/ibc-go
git clone https://github.com/octopus-network/ibc-go.git
# 在ibc-go v1.2.0 上创建分支
git branch mock-grandpa v1.2.0
git checkout mock-grandpa
```

define the protocol buffer for  GRANDPA(ICS-10): grandpa.proto

```protobuf
syntax = "proto3";

package ibc.lightclients.grandpa.v1;

option go_package = "github.com/cosmos/ibc-go/modules/light-clients/10-grandpa/types";

import "ibc/core/client/v1/client.proto";
import "ibc/core/commitment/v1/commitment.proto";
import "gogoproto/gogo.proto";

// Client state
// The GRANDPA client state tracks latest height and a possible frozen height.
// interface ClientState {
//   latestHeight: uint64
//   frozenHeight: Maybe<uint64>
// }
message ClientState {
  option (gogoproto.goproto_getters) = false;

  string chain_id = 1;
  // Latest height the client was updated to
  ibc.core.client.v1.Height latest_height = 2
      [(gogoproto.nullable) = false, (gogoproto.moretags) = "yaml:\"latest_height\""];
  // Block height when the client was frozen due to a misbehaviour
  ibc.core.client.v1.Height frozen_height = 3
      [(gogoproto.nullable) = false, (gogoproto.moretags) = "yaml:\"frozen_height\""];
}

// Consensus state
// The GRANDPA client tracks authority set and commitment root for all previously verified consensus states.
// interface ConsensusState {
//   authoritySet: AuthoritySet
//   commitmentRoot: []byte
// }
message ConsensusState {
  option (gogoproto.goproto_getters) = false;

  // commitment root (i.e app hash)
  ibc.core.commitment.v1.MerkleRoot root = 1 [(gogoproto.nullable) = false];
  // authoritySet
  // AuthoritySet authority_set = 2 [(gogoproto.nullable) = false];
}
// Misbehaviour
// The Misbehaviour type is used for detecting misbehaviour and freezing the client - to prevent further packet flow -
// if applicable. GRANDPA client Misbehaviour consists of two headers at the same height both of which the light client
// would have considered valid. interface Misbehaviour {
//   fromHeight: uint64
//   h1: Header
//   h2: Header
// }
// message Misbehaviour {
//   option (gogoproto.goproto_getters) = false;

//   ibc.core.client.v1.Height from_height = 1 [(gogoproto.nullable) = false, (gogoproto.moretags) = "yaml:\"frome_height\""];
//   Header header_1 = 2 [(gogoproto.customname) = "Header1", (gogoproto.moretags) = "yaml:\"header_1\""];
//   Header header_2 = 3 [(gogoproto.customname) = "Header2", (gogoproto.moretags) = "yaml:\"header_2\""];
// }
message Misbehaviour {
  option (gogoproto.goproto_getters) = false;

  string client_id = 1 [(gogoproto.moretags) = "yaml:\"client_id\""];
  Header header_1  = 2 [(gogoproto.customname) = "Header1", (gogoproto.moretags) = "yaml:\"header_1\""];
  Header header_2  = 3 [(gogoproto.customname) = "Header2", (gogoproto.moretags) = "yaml:\"header_2\""];
}

// Headers
// The GRANDPA client headers include the height, the commitment root,a justification of block and authority set.
// (In fact, here is a proof of authority set rather than the authority set itself, but we can using a fixed key
// to verify the proof and extract the real set, the details are ignored here)
// interface Header {
//   height: uint64
//   commitmentRoot: []byte
//   justification: Justification
//   authoritySet: AuthoritySet
// }
message Header {
  option (gogoproto.goproto_getters) = false;
  ibc.core.client.v1.Height height = 1 [(gogoproto.nullable) = false, (gogoproto.moretags) = "yaml:\"height\""];
  
  // ibc.core.commitment.v1.MerkleRoot root  = 2 [(gogoproto.nullable) = false];
  // Justification justification = 3 [(gogoproto.nullable) = false];
  // AuthoritySet authority_set = 4 [(gogoproto.nullable) = false];
}

// Justification
// A GRANDPA justification for block finality, it includes a commit message and an ancestry proof including
// all headers routing all precommit target blocks to the commit target block. For example, the latest blocks
// are A - B - C - D - E - F, where A is the last finalised block, F is the point where a majority for vote
//(they may on B, C, D, E, F) can be collected. Then the proof need to include all headers from F back to A.

// interface Justification {
//   round: uint64
//   commit: Commit
//   votesAncestries: []Header
// }
message Justification {
  option (gogoproto.goproto_getters) = false;

  uint64          round          = 1 [(gogoproto.moretags) = "yaml:\"round\""];
  bytes           commit         = 2 [(gogoproto.moretags) = "yaml:\"commit\""];
  repeated Header votes_ancestry = 3 [(gogoproto.moretags) = "yaml:\"vote_ancestry\""];
}

// Authority set
// A set of authorities for GRANDPA.
// interface AuthoritySet {
//   // this is incremented every time the set changes
//   setId: uint64
//   authorities: List<Pair<AuthorityId, AuthorityWeight>>
// }
message AuthoritySet {
  option (gogoproto.goproto_getters) = false;

  uint64             set_id    = 1 [(gogoproto.moretags) = "yaml:\"set_id\""];
  repeated Authority authority = 2 [(gogoproto.moretags) = "yaml:\"authority\""];
}
// Authority
message Authority {
  option (gogoproto.goproto_getters) = false;

  bytes authority_id     = 1 [(gogoproto.moretags) = "yaml:\"authority_id\""];
  bytes authority_weight = 2 [(gogoproto.moretags) = "yaml:\"authority_weight\""];
}

// Commit
// A commit message which is an aggregate of signed precommits.
// interface Commit {
//   precommits: []SignedPrecommit
// }
// interface SignedPrecommit {
//   targetHash: Hash
//   signature: Signature
//   id: AuthorityId
// }
message Commit {
  option (gogoproto.goproto_getters) = false;

  repeated SignedPrecommit precommit = 1 [(gogoproto.moretags) = "yaml:\"precommit\""];
}
// SignedPrecommit
message SignedPrecommit {
  option (gogoproto.goproto_getters) = false;

  bytes authority_id = 1 [(gogoproto.moretags) = "yaml:\"authority_id\""];
  bytes target_hash  = 2 [(gogoproto.moretags) = "yaml:\"target_hash\""];
  bytes signature    = 3 [(gogoproto.moretags) = "yaml:\"signature\""];
}
```

put the grandpa.proto file into the ibc-go/proto/ibc/lightclients/grandpa/v1

![微信图片_20211031092356.png](GRANDPA%20light%20client(mock)%20on%20cosmos%200714981dc71f40a69ae229c3d12209f8/%E5%BE%AE%E4%BF%A1%E5%9B%BE%E7%89%87_20211031092356.png)

compile the grandpa.proto

```bash
cd ibc-go/

# install protoc-gen-gocosmos
go get github.com/regen-network/cosmos-proto/protoc-gen-gocosmos@latest

# install buf
# Substitute BIN for your bin directory.
# Substitute VERSION for the current released version.
# Substitute BINARY_NAME for "buf", "protoc-gen-buf-breaking", or "protoc-gen-buf-lint".
BIN="/usr/local/bin" && \
VERSION="1.0.0-rc6" && \
BINARY_NAME="buf" && \
  curl -sSL \
    "https://github.com/bufbuild/buf/releases/download/v${VERSION}/${BINARY_NAME}-$(uname -s)-$(uname -m)" \
    -o "${BIN}/${BINARY_NAME}" && \
  chmod +x "${BIN}/${BINARY_NAME}"

# compile the grandpa.proto
buf protoc \
  -I "proto" \
  -I "third_party/proto" \
  --gocosmos_out=plugins=interfacetype+grpc,\
Mgoogle/protobuf/any.proto=github.com/cosmos/cosmos-sdk/codec/types:. \
  --grpc-gateway_out=logtostderr=true:. \
 proto/ibc/lightclients/grandpa/v1/grandpa.proto
```

Ref：[https://docs.buf.build/introduction](https://docs.buf.build/introduction)

File generated：

![微信图片_20211031093857.png](GRANDPA%20light%20client(mock)%20on%20cosmos%200714981dc71f40a69ae229c3d12209f8/%E5%BE%AE%E4%BF%A1%E5%9B%BE%E7%89%87_20211031093857.png)

Copy 10-grandpa/types/grandpa.proto to ibc-go/module/light-clients/：

![微信图片_20211031094540.png](GRANDPA%20light%20client(mock)%20on%20cosmos%200714981dc71f40a69ae229c3d12209f8/%E5%BE%AE%E4%BF%A1%E5%9B%BE%E7%89%87_20211031094540.png)

The mock Grandpa light client is developed basded on the existing Tendermint light client. You may refer to the [commits](https://github.com/octopus-network/mock-grandpa/commits/main) for the development details.

# Test grandpa light client（mock）

```bash
git clone git@github.com:octopus-network/mock-grandpa.git

cd mock-grandpa
# start earth app chain and redirect the output to file
·
# start mars app chain and redirect the output to file
starport chain serve -v -c mars.yml >| mars.log
```

Modify go.mod，replace remote dependency to local dependency：

```bash
# clone ibc-go
git clone https://github.com/octopus-network/ibc-go.git
# checkout to mock-grandpa
git checkout mock-grandpa

# clone mock-grandpa
git clone git@github.com:octopus-network/mock-grandpa.git
cd mock-grandpa
# 修改mock-grandpa项目中的go.mod文件，将ibc-go依赖改为本地依赖,指向ibc-go所在位置，可以是相对路径也可以绝对路径
# for Dev
replace github.com/cosmos/ibc-go v1.2.0 => ../ibc-go 
#for CI/Test/Product
#replace github.com/cosmos/ibc-go v1.2.0 => github.com/octopus-network/ibc-go v1.2.1-0.20211028233327-fba0a50b3261
...
```

## starport chain serve 

Start a blockchain node with automatic reloading

```bash
**starport chain serve [flags]**
```

**Options**

```bash
-c, --config string       Starport config file (default: ./config.yml)
-f, --force-reset         Force reset of the app state on start and every source change
-h, --help                help for serve
    --home string         Home directory used for blockchains
    --proto-all-modules   Enables proto code generation for 3rd party modules used in your chain
-r, --reset-once          Reset of the app state on first start
-v, --verbose             Verbose output
```

Ref：[https://docs.starport.network/cli/](https://docs.starport.network/cli/)

# Refs：

[Cosmos](https://tutorials.cosmos.network)

[ibc-go](https://github.com/cosmos/ibc-go)

[Starport](https://docs.starport.network/)

[Protobuf](https://developers.google.com/protocol-buffers/docs/proto3)

[gogoprotobuf](https://github.com/gogo/protobuf)

[buf](https://docs.buf.build/)

