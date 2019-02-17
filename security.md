# Security

## [Security Support in NDN](https://named-data.net/wp-content/uploads/2018/04/ndn-0057-2-ndn-security.pdf)
- Retrieval of *secured* data packets instead of delivery of packets between hosts
- Data is secured directly at Network Layer
- *"From 10,000 feet, one could view the basic idea of NDN as shifting HTTP’s request (for a named data object)-andresponse (with the object) semantics to the network layer [1]"*
- NDN packets are immutable
- At time of creation, producer uses its key to sign the data and this sig is stored in the NDN packet
	- This binds the **name** of the data to the **content** of the data
	- This whole thing can also be encrypted if needed
- Each name (e.g. /com/stefanolupo/desktop) must generate a key pair.
	- An NDN certificate then binds the public key to that name
		- Certifies user's ownership of that name and the key
		- Certified names are known as **identities**
- **User's must know which keys can legitmately sign what data
### Trust Authorities
- Certificate authority for a given namespace
- Allows users to get certs for a given namespace (e.g. /com/stefnaolupo)
- Typically done using commercial certificate authorities (LetsEncrypt) or global trust anchors (DNSSEC)
- NDN does things differently (Simple Distributed Security Infrastructure)
	- Each networked system (e.g. a smart home or university) establishses its own trust anchos
	- Entities under this network use this trust anchor
### Trust Policies
- Applciations define trust policies to determine whether a packet or identity is trustworthy or not
...
#### NDN Certificates
- These are just typical NDN Data packets carrrying public key info and can be fetched with interest packets
- Use the following convention: `/<prefix>/KEY/<key-id>/<issuer-info>/<cert-version>`
...

#### NDNFit Case Study
- **Security Bootstrapping**: system needs to be initialized by sec bootstraping before it can function
- Allows entities to obtain trust anchors, certs and trust policies
- **Trust Anchor**
	- Alice controls the entire system here so trust anchor is her certificate `/ndnfit/alice/KEY/key001/ndnfit-agent/version`
	- Entities will trust Alice (the certificate signer)
	- This will allow entities to discover other authentic entities
	- Assume we can set up trust anchor securly (out of bound)
	- Other entities in this case are "Sensor" and "Analyzer"
		- Simple naive way is to just manually install Alice's cert to Sensor and Analyzer (they both trust her now)
- **Obtaining Certificates**
	- Sensor must establish ownership of `/ndnfit/alice/sensor` (needs a cert)
	- How this is done is up to application programmer
	- In this case we're using NDNCERT daemon (the _agent_)
		- Alice controls namespace for `/ndnfit/alice` (she is the CA for that namespace)
	- Same for Analyzer
	- Sensor and Analyzer use the NDNCERT protocol to obtain certs from this agent
	- Sensor gets `/ndnfit/alice/sensor/KEY/1/alice-agent/<version>` and Analyzer gets `/ndnfit/alice/analyzer/KEY/1/alice-agent/<version>`
- **Trust Policies**
	- These can be dynamically acquired from the trust anchor (better / easy to change)
	- Or they can just be pre configured
	- These define what packets to trust based on the _packet name_, the _signing key name_, the _relationship betweenthe two names_, and the _trust anchor_  
- **Trust Schemas**
	- Use NDN naming conventions to enable descriptions of trust policies
		- How data packets must be structured
		- How packet signing key Names must be structured
		- How data packet names relate to packet signing key names
		- Which trust anchors are acceptable
	- On receipt of packet, app uses trust schemas to check trustworthiness, even before any crypto checks
	- E.g. schema 1 (stricter) only accepts packets:
		- Name prefix is `/ndnfit/alice`
		- Signing prefix is `/ndnfit/alice/KEY`
		- Certificate chain ends with trust anchor `/ndnfit/alice`
	- E.g. schema 2 (looser) only accepts:
		- Name prefix `/ndnfit`
		- Signing prefix is `/ndnfit`
		- Eventually signed by `/ndnfit`
		- **Looser schema and will accept packets from Bob and Alice**
**_Note: Interest packets can also be signed in the exact same way_**
	- E.g. a controller for a smart home IoT device
	- Wan't to be sure commands (expressed as interest) are from legit source
- **Confidentiality (Encryption)**
	- Point to point comms can use standard encryption methods (e.g. diffie helman key exchanges etc)
	- However this is inefficient for producer / multiple consumer situation
	- Can use Named Access Control (NAC)
		- Name of key used for data encryption is appended to name of data
		- `/ndnfit/alice/sensor/data/ENCRYPTED-BY/ndnfit/alice/E-KEY/sensor
	- Alice generates a key pair: `E-KEY` and `D-KEY`.
		- Data packet containing `E-KEY` is then produced (`/ndnfit/alice/E-KEY/sensor`)
		- Data packet containing `D-KEY` is produced encrypted with Analyzer's public key (`/ndnfit/alice/D-KEY/analyzer/ENCRYPTED-BY/ndnfit/alice/analyzer`)
	- For sensor to produce data:
		- Generates symmetric key for content encryption
		- Fetches `E-KEY` and encrypts the symmetric key with it
		- Packs encrypted sym key into a Data packet with name `/ndnfit/alice/sensor/data/ENCRYPTED_BY/ndnfit/alice/E-KEY/sensor`
			- Only those with `D-KEY` can decrypt this to get the symmetric key (Alice and Analyzer)
			- The sym key can then be used to decrypt the data
### Benefits
- The main benefit to NDN security is that data can be taken from anywhere in the network and we can be sure of its trustworthiness
	- This allows popular content to be cached a lot
	- Cert availability is fundamental to NDN so high availability of certs is vital
		- NDN certs are contained in Data packets and thus have all the benefits of caching as normal data packets
		- _Certificate Bundles_ allow producers to gather all certs in a chain and bundle them in a single packet
			- These can be made available to consumers 
			- E.g. the producer (Sensor) would boundle all of the needed certs into a certificate bundle (`/ndnfit/alice/sensor/KEY/...` and `/ndnfit/alice/KEY`)
			- Consumers can then fetch all of the needed certs in a single interest.
- TCP/IP secures channels. TLS etc work well for securing point to point comms
	- However in a P2P setting with multiple people all communicating, the # channels to secure grows exponentially
	- NDN on the otherhand just secures the data and avoids this problem
- TCP/IP requires governing CAs 
	- NDN allows for finer grained control as trust policies can use the semantics of the names

## Papers to Read
- Schematizing Trust in Named Data Networking
