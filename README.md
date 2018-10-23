# Notes on NDN / ICN
## Networking Named Content [Van Jacobson]()
- Current internet methodology still based on host-host connection abstraction (telephone net)
- Uses **interest packets** to allow node to express interest in a named piece of data to network
- **Data packets** satisfy these interest packets and are returned to the consumer


### CCN Node Model
#### Forwarding Informatio Base (FIB)
#### Content Store
#### Pending Interests Table

## Intro to NDN [YouTube] (https://www.youtube.com/watch?v=-9dH2ikl8Zk&feature=youtu.be)
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

## Papers to Read
- Schematizing Trust in Named Data Networking
- A Survey of Distributed Dataset Synchronization in Named Data Networking 
- DonnyBrook enabling high performance peer to peer games
- Voice over CCN (Jacobson)
- G-COPSS / COPPS (J. Chen) content centric comms infrastructure for gaming
- Aspects of networking in multiplayer computer games --> Server Pools?