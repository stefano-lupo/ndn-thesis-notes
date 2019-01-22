# Notes on NDN / ICN
## Networking Named Content [Van Jacobson]()
- Current internet methodology still based on host-host connection abstraction (telephone net)
- Uses **interest packets** to allow node to express interest in a named piece of data to network
- **Data packets** satisfy these interest packets and are returned to the consumer


### CCN Node Model
#### Forwarding Informatio Base (FIB)
#### Content Store
#### Pending Interests Table

## Intro to NDN [YouTube](https://www.youtube.com/watch?v=-9dH2ikl8Zk&feature=youtu.be)
- Host based comms don't work well in vehicular networks
- Network layer can't really support Multicase / mobility / multicast forwarding (spanning tree next hop)
- NDN has same abstraction (using same name) at app layer and network layer
- NDN secure the data itself, not the connection
	- Data centric security: how do we know the data we get back is really what we want
	- All data has cryptographic signature
	- Data signed by the producers private key
	- Data can come from anywhere as we can easily determine if the data is legit
- Producers of data advertise their prefixes to their network when they come online
	- Routers know where to pass interest packets on to
	- Routers cache data (LRU as opposed to dropping data once its been sent out of interface)
- NDN can be built upon anything (IP, TCP, UDP, Blutooth, 802.11 etc)
- End-to-End Security in NDN  is application to application not host to host.
- New Things in NDN:
	- Sync: multiple parties in distributed app keep synchronized state
		- TCP / UDP / SMTP etc all only support 1:1 communication
		- No address --> How do we ensure all users (eg in a chat room) have the same data?
			- Set reconciliation between participants that syncs data in a namespace
			- Use a digest of their current data (hash) and exchange these to detect missing data
	- Repo: persistent storage across network (instead of just opurtunistic caching)
		- Producer can go offline
		- Producers produce data which is stored by Repos (Servers)
		- Data can be served by repos

# [Security Support in NDN](https://named-data.net/wp-content/uploads/2018/04/ndn-0057-2-ndn-security.pdf)
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
## Trust Authorities
- Certificate authority for a given namespace
- Allows users to get certs for a given namespace (e.g. /com/stefnaolupo)
- Typically done using commercial certificate authorities (LetsEncrypt) or global trust anchors (DNSSEC)
- NDN does things differently (Simple Distributed Security Infrastructure)
	- Each networked system (e.g. a smart home or university) establishses its own trust anchos
	- Entities under this network use this trust anchor
## Trust Policies
- Applciations define trust policies to determine whether a packet or identity is trustworthy or not
...
### NDN Certificates
- These are just typical NDN Data packets carrrying public key info and can be fetched with interest packets
- Use the following convention: `/<prefix>/KEY/<key-id>/<issuer-info>/<cert-version>`
...

### NDNFit Case Study
- **Security Bootstrapping**: system needs to be initialized by sec bootstraping before it can function
- Allows entities to obtain trust anchors, certs and trust policies
- Alice controls the entire system here so trust anchor is her certificate `/ndnfit/alice/KEY/key001/ndnfit-agent/version`
	- Entities will trust Alice (the certificate signer)
	- This will allow entities to discover other authentic entities
	- Assume we can set up trust anchor securly (out of bound)

# [Matryoshka: Design of NDN Multiplayer Online Game](http://conferences2.sigcomm.org/acm-icn/2014/papers/p209.pdf)
- Two parts to syncing state for MMOG (Massively MOG)
- Recursively partitiion virtual environment into smaller and smaller chunks (form tree like structure)
- Each node in the tree is indexed (represents coordinates of virtual env)
	- **Discovery**
		- Indentifying which other players are in your zone (chunk of interest)
		- Periodically send out _discovery interests_ for a given chunk
			- This contains the chunks indices and a digest of the set of objects in that chunk (that the source node knows about)
			- Peers receiving these digests compare against their own digest and respond if they're different
	- **Updates**
		- Periodically request updates for each peer / NPC in the discovered set of objects
		- Each node on the network (_"process"_) is responsible for hosting some of the **NPCs** in the world, themselves and other elements of the game
		- Version numbers are used to ensure newest version 

## [Peer to Peer Sandbox Game](https://github.com/blacksponge/bakasable)

## [Lets ChronoSync](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.705.8908&rep=rep1&type=pdf)
- BitTorrent Sync service
	- Requires maintenance of P2P network
- Maintain a digest of the current state, exchange it around the network
- Incoming State digest same: no action
- Incoming State digest different
	- We maintain old state digests too so if an incoming state digest is same as an old one, we can figure out the changes that are missing and respond with them
	- Otherwise state reconciliation method can be used to figure out the differences
#### ChronoSync Module
- Maintain a digest tree (eg digest of all the messages in the chatroom)
- Maintain history of dataset state changes (digest log)
- Periodically send out sync interests which contain the digest at rood of digest tree
- Data produced by given producer is numbered sequentially (eg chatroom/alice/56 is Alice's 57th message). The latest of these is known as the **producer status**
- Similar situtation for state digests. These are broadcasted on some prefix so that participants can subscribe (eg .../chatroom/a1234asd9 is the current state digest (digest at end))
- Maintain a digest tree where leaf nodes are **producer statuses**. These are hashed to form digests for each producer (eg one for Alice, one for Bob) which are then hashed to form a single **state digesgt** (Merkle Tree)
- The **digest log** is a list of key value pairs (key == digest, value == diffs from previous state that led to new digest)
	- If participant puts out old state digest, changes can be infered and used as response.
- To maintain state, node continuously have a state interest outstanding (i think)
	- Identical interests are collapsed by NDN routers, meaning during steady state (all nodes agree on state), there will only be one outstanding interest propogated through the network
- On generating a new message, local machines state digest changes and it can then satisfy the current state interest (as its digest is newer / different)
	- Then produces a data packet containing **THE NAME** of the piece of data that caused the state change (**NOT THE ACTUAL DATA**)
		- Other nodes will then receive this (have their interest satisfied) and produce a new state interest with the new digest, returning the system to the steady state
		- If the application **WANTS THE DATA** that caused the state change, it can request it as normal by sending out an interest for it (since it now knows the name from the state-data packet)
- If A and B both simultaneously generate data (respond with state data):
	- One will reach C first (eg B's in this case)
	- Only one piece of data can be returned for given interest in NDN (so C's sync interest satisfied)
	- C repeats sync interest for **previous digest** with exclusion filter set to the hash of B's data that satisfies this interest
		- Network responds with A's sync data allowing C to get all data as required.
- If networks become partitioned (eg A and B cut off from B and C)
	- Sync still works in each of the subnets, but there state sync will diverge
	- On reconnection, digests will not be understood and theres _recovery_ packets to handle this (not exactly sure how)


# [NDNGame: A NDN Based Architecture for Online Games](https://www.thinkmind.org/download.php?articleid=icn_2015_3_30_30135)
- NDN for content dissemination, IP for Point to point communications
- Pretty nice description / diagram of NDN architecture / how it all works
- Reduce load on _"local servers"_ (see Server Pools) by allowing content to be distributed in P2P fashion
- This paper literally said absolutely nothing..

# [Egal Car - Peer-to-Peer Car Raching over NDN](https://named-data.net/publications/techreports/tregalcar/)
- Assets them selves: Need to be unordered, but reliable
	- Okay to discover a _younger_ player before an _older one_
- State updates of assets: Need to be ordered, but can be unreliable
	- If we lose a transformCar(x, y), it doesn't matter as they just move double the distance on next packet
		- Note: these packets are snapshots **NOT** changelogs (i.e. data in reponse to interest is eg x, y, vel of car, not its deltas)
	- If we get a packet out of order (and use it), car's position will jerk around the place
- Uses CCNxSync to synchronize assets (eg players themselves)
	- Complicated description of this
- Uses standard NDN Interest/Data to maintain state syncrhonization
	- Alice periodically asks for Bob's position with interests
	- Maintain a timestamp (version) floor and don't make use of older versions (handles out of order packets)
	- Then use an exclusion filter to specify we are not interested in data responses whos timestamp is below our timestamp floors
		- Otherwise any node in the net could be responding with **their** knowledge of the state and it may be the same / older than our knowledge of the state
### Traffic Optimization
- State sync is by far the most traffic
	- Every peer wants to know about every other peer
	- Frequent updates
- Mean num packets for state optimization: N = xfhn(n-1)
	- x = number of packets per state exchange (>= 2 usually)
	- f = the frequency of the state updates (eg 60 updates per sec)
	- h = the average numbver of hops between peers
		- Large for std IP
		- Lower for NDN
	- n = number of peers / nodes
- NDN should be more efficient because:
	- Interests are aggregated by nodes (just add face to PIT entry if exists)
	- Data is cached at each hop
	- This means interests are likely to only need to go a few hops before being satisfied by cached data or aggregated with other interests
	- This reduces overall traffic on the network
- We can also be smart about state syncs and syncrhonize a summary of the state (maybe a digest a la CCNxSync?) instead of the nested states?

### Future Work
- Assets are **independant of each other** --> **no interactions**
	- This is what enabled us to use unordered / unreliable sync strategies without effecting consistency of the game
	- This would not apply to eg RPGs or games where players need to explicitly interact
		- Even in egal car they shouls be able to crash etc

# [What Every Programmer Needs To Know About Game Networking](https://gafferongames.com/post/what_every_programmer_needs_to_know_about_game_networking/)

# [	Peer-to-Peer Architectures for Massively Multiplayer Online Games: A Survey](http://web.a.ebscohost.com.elib.tcd.ie/ehost/pdfviewer/pdfviewer?vid=2&sid=c429fb71-fa02-4ba7-9e5f-91d5b3a3502f%40sdc-v-sessmgr02)
### Game Object Types
- Immutable
	- eg Landscape - loaded on startup, never changes
- Characters
	- Controlled by players
		- Three types of interactions:
			- Player updates
				- Interactions with the game world that only affect the player themself (e.g. position update)
			- Player object interactions
				- Interaction between players and mutable objects (e.g. player consuming health pack on map)
			- Player player interactions
				- Player attacking another player
- Mutable
	- Objects which change over course of game (e.g. health packs being consumed)
- NPC
	- Controlled by AI in the game engine
### Object Replciation
- All players maintain an instance of the game world
-	_Primary Copy Replication_
	- Primary copy of a game object (e.g. an NPC) exists somewhere (typically on server)
		- Authorative updates done on the primary copu
		- Updates propogate downstream to the secondary copies (held on client machines etc)
	- Analogies to Pub-Sub
### Bucket Synchronization
- Essentially lockstep where a frame rate (tick rate, **not** graphical FPS) is decided upon which limits the rate of updates on the server
### Interest Management
- Limit the vision / sensing range of players in multiplayer world
- Temporal / Spatial locality
- Reduce overall bandwidth on network
- Players have an AOI (area of interest) and can only interact with objects in that area (aura-nimbus)
- More advanced methods also exist eg Delaunay triangulation
	- Can take obstacles into account (i.e. blocked from view from a mountain), potentially reducing the number of game objects of interest
- AOI / Dynamic Zoning (different zone sizes / AOI sizes in different locations)
	- HotSpotting causes issues (e.g. players flocking to one spot)
### Consistency Control
- Concurrent interactions with game objects can cause inconsitencies (e.g. both players shoot NPC at same time)
- Systems typically deterministic
	- If all events are processed in the same order, all game worlds will converge to same state
- Loss of updates can also lead to inconsistencies
	- Games typically use UDP in which packets can be lost
	- Some critical updates sent with TCP or use commit protocols 
- Often employ **eventual consistency**
	- Any game object may be in an incosistent state at a given time
	- If all updates cease, all game objects eventually end up consistent./
	- Standard distributed systems problem (CAP theorem etc)
		- Games often sacrifiy consistency (in favour of availability and network partioning)
		- Provide inconsistency _resolution_ as opposed to _prevention_
- Not all game objects treated the same way
	-	Eg games objects with associated value (real or monetary) need to be consistent
### Replica Staleness
- Using primary copy replication simplifies consistency management (updates are serialized at primary copy)
- However secondary copies now can be stale
	- Clients may try to invoke commands on stale object copies which don't make sense
### Consistency Techniques
- Dead Reckoning - predict future player positions / collisions locally (next position + some velocity info etc)
	- Other more complex predictors suggested (e.g. neural nets etc)
	- Primary copy only pushes updates to clients when they detect they have veered from true position by more than some threshold
### Measuring Consistency
- Some approaches exist for measuring the degree of inconsistency
- Worth looking into if needs arise.

# Distributed Hash Tables
- P2P Nets: nodes only know about small fraction of nodes in network (to make this feasible)
- Distribute data throughout a P2P network
- Each node will store some of the data and some of the routing table
- DHTs are **NOT** O(1) like typical hash tables
- Each node is assigned a partition of the key space
	- Eg key is an int: node 0 gets 0-10, node 1 gets 10-20 etc
	- Keys are run through a hash function before lookups
- On looking up
	- Ask known nodes for key
	- They return their knowledge of routing information
	- Next hop is the node that has the keyspace closest to your key

## MMOG Architectures
### Client-Server
- Server holds all mutable objects and avatars and maintains global state of world
- All updates sent to the server for processing (incl conflict resolution)
- Server computes new state and sends object updates to interested players
- Add more servers for scalability
- **Pros**
	- Highest level of control of game world
	- Easiest way to maintain consistency
	- Easy to push updates
	- By far the simplest architecture to program in
- **Cons**
	- Scalability issues
	- No fault tolerance
### Multi Server
- Can shard game world into multiple **seperate and entire game worlds** (realms in WoW)
	- Client's cant cross shards (e.g. Geographical Servers etc)
- Or, have a single game world but split it into regions
	- Players can only interact with objects in that region (think zones in wow)
	- Different servers for different regions
	- Hand off mechanism required for players moving between regions
		- Often transparent to client (they have to go through portal or FP or something)
- **Pros**
	- More scalable (playerbase split across multiple servers)
	- Fault tolerance (other servers can act as backup servers if one goes down)
	- Server failures (without backups) only affect parts of population
- **Cons**
	- Artificial segmentation of player base (if multiple game worlds used (shards))
	- Hand-off mechanism required in other case
	- Not infinitely scalable as the game world can't be forever divided into smaller and smaller regions
	- Player hotspotting causes region loads to be spikey
### Peer-to-Peer
- All clients are also servers
- Client's responsible for the primary copies of some game objects
- Client's must disseminate updates
- Highly scalable as load is distributed across many nodes / networks
- As more players join, more resources available to host them
- **Pros**
	- Scalability: every peer adds more resources to the network (at no cost to the game provider)
	- Cost: no (or less) need for really expensive servers
	- Fault tolerant
	- Lower latency: updates can be directly sent to interested peers
- **Cons**
	- Security / ease of cheating
	- Hard for company to maintain the state 
	- Consistency problems: conflicting updates at edges of networks need to be resolved.
## Hybrid Architectures
- **Cooperative Message Dissemination**
	- State is maintained on servers and players publish updates to server
	- Updates are disseminated using a P2P Multicast approach
- **State Distribution**
	- State is distributed among peers and they're responsible for game actions
	- Server responsible for authentication, tracking player joins/leaves
- **Basic Server Control**
	- State and dissemination done in P2P
	- Server keeps highly sensitive data etc
	- Server may work to coordinate the P2P network
	- Server may orchestrate updates that require the highest consistency etc
## Peer-To-Peer Architectures
- Build an application-layer overlay network on top of the network layer
- No nodes should ever know all other nodes in the network (infeasible)
	- Instead they are connected to a fraction of the peers
- Need way to route / locate data in the network
### Structured P2P (e.g. SimMud)
- Deterministic alg used to generate the overlay graph network
- Any node can route a message to any other node in O(log N) messages
- Distributed hash tables used (key/value pairs distributed accross nodes in the network)
	- Uses Pastry to distribute game objects to the P2P net
	- Uses Scribe (which uses pastry) which provides multicast functionality
- Divide games into regions
- Each region gets a multicast group ID (Scribe) (hash of region name)
	- Node with closest node Id to the group Id is the region coordinator (root of a multicast tree)
	- All game objects in a particular region are mapped to the root node of that region (it owns the primary copies)
	- Thus all game object updates are sent to the coordinator (who is easily discoverable)
	- Updates are sent to all nodes in the region through the muilticast tree
	 
## Unstructured P2P
- No deterministic alg used
- No global mechanism such as DHT
- Nodes randomly connected to each other (usually probibalistically higher to connect to nearby nodes etc)
- Data duplication used to speed up search for data in the net
- Usual mutual notification systems to allow for node dicsovery
	- A node in your AOI will inform you if a new node is approaching your AOI
	- You can then contact that node directly and neighbourship formed
	

## Papers to Read
- Schematizing Trust in Named Data Networking
- A Survey of Distributed Dataset Synchronization in Named Data Networking 
- DonnyBrook enabling high performance peer to peer games
- Voice over CCN (Jacobson)
- G-COPSS / COPPS (J. Chen) content centric comms infrastructure for gaming
- Aspects of networking in multiplayer computer games --> Server Pools?