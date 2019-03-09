# Games

## [Matryoshka: Design of NDN Multiplayer Online Game](http://conferences2.sigcomm.org/acm-icn/2014/papers/p209.pdf)
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

## [NDNGame: A NDN Based Architecture for Online Games](https://www.thinkmind.org/download.php?articleid=icn_2015_3_30_30135)
- NDN for content dissemination, IP for Point to point communications
- Pretty nice description / diagram of NDN architecture / how it all works
- Reduce load on _"local servers"_ (see Server Pools) by allowing content to be distributed in P2P fashion
- This paper literally said absolutely nothing..

## [Peer to Peer Sandbox Game](https://github.com/blacksponge/bakasable)


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
	 
### Unstructured P2P
- No deterministic alg used
- No global mechanism such as DHT
- Nodes randomly connected to each other (usually probibalistically higher to connect to nearby nodes etc)
- Data duplication used to speed up search for data in the net
- Usual mutual notification systems to allow for node dicsovery
	- A node in your AOI will inform you if a new node is approaching your AOI
	- You can then contact that node directly and neighbourship formed

## PubSub Network Designs for Multiplayer Games](http://msrg.utoronto.ca/publications/pdf_files/2014/psgames-Publish-Subscribe_Network_Designs_for.pdf)
- Three PubSub architectures - one with servers, brokers and clients, two with just clients and brokers
### Interest Mgmt
- Rectangle Based
	- Area of Interest (AOI) is a rectangle centered over a point (avatar)
	- False Positive: If entity is behind a wall (not visible) --> rectangle based still thinks its interesting
- Tile Based
	- World divided into tiles
	- Tile borders never cross impassable borders!
	- Can use constrained Delaunay triangulation to make tiles obstacle aware 
	- Player is only ever on one tile
		- AOI of each tile in gameworld can be precomputed 
		- Then can easily get AOI for any player
- IM is actually usually performed on the server
	- Requires a lot of knowledge 
	- Can be distributed across nodes each owning a section of the gameworld
	- Proposes a way for clients to do their own IM
### Network Comms
- Update Messages
	- Client wants to update master copy of game object
		- Request must be sent to master copy holder
		- Update performed
		- Update must propogate to all interested nodes
		- Send deltas instead of entire object
- Replica Transfers
	- Needed as cannot construct new game object from detlas
	- On discovery of a new interesting game object
	- Client sends replica request object
	- Typically point to point
- Need different pub sub approaches to handle point to point comms
- PubSub typically used to distribute updates to all subscribed consumers
	- Not typically used for replica transfers (but will be in this paper)
- **Mercury/ Decentralized pub sub style systems**
	- _Content_ (not topic) based decentralized pub sub system
	- Use rendevous points (similar to Scribe/Hermes)
	- Publications / Subscriptions are sent to rendevouz points
		- Then matched to their appropriate recipients and sent on
	- Subscriptions contain predicates which are run through content-based engine
	- Allows clients to subscribe to attributes they find interesting using predicates
		- e.g within a certain radius of plauer
	- This works well for several tens of plauers where a client can have replicas of all objects in game (e.g. FPS game)
- **G-COPSS: Content oriented pub sub system**
	- Partitions game world hierarchicaly into layers
	- Players can send / receive updatesto particular layers they are interested in
- **Both of the above can handle update dissemination but not object replication**
	- This means clients must have replicas of all in game objects at startup through some mechanism
	- This is unrealistic for MMOGs due to sheer number of game objects
- Three use cases targetted by paper:
	- Object discovery
		- Replicas need to be requested as player's AOI moves
		- Hopefully dont need a server for IM
	- Replica Transfer
		- On discovery of new game object in AoI
		- Need protocol for transfer of replica from master to client
	- Update Propogation
		- Sending game state updates from master node to all nodes
- Point to Point Comms
	- Each node has a topic
	- In order to communicate with Node N, just publish message to N

**Key Difference: These all use extra broker nodes to provide pub-sub functionality**

### Engine 1: Object Based Network Engine
- Topic based p/s: one topic per game object, one comms channel per game object
	- **Probably able to reuse comms channels (faces in this case) in NDN**
- Interest in object, subscribe to topic
- Requires separate IM service
	- Receives updates of all players and monitors interest of each player
- Relays interested in Game objects back to clients who subscribe to those topics
- Tasks:
	- Object Discovery:
		- Handled entirely by IM service
	- Replica Transfer:
		- IM service sends point to point message to client via client topic 
		- Client then subs to game objects topic and sends Replica Request Messae
		- Reverse for leaving Interest zone
	- Update Propogation
		- Client requests update to master holder
		- Master holder decides whether its valid and updates accordingly
		- Master then publishes object update
- Only message making use of multicast capable pub sub is the update dissemination

### Engine 2: Tile based Network Engine
- Used for games which partition word into tile map 
- Communication between nodes done via topics linked to map tiles
- No dedicated IM present
- Node topics as before
- For each tile: 3 different topic channels for each tile
	- Replica Request
		- Used to request replicas
		- Master holders _subscribe_ to replica request topic of tile if one or more of their master objects is on that tile
		- Clients can use replica request of tile T to get all game objects on that tile with single publication
	- Replica Reply
		- Used to transfer the actual replicas
		- Clients subscribe temporarily to tile T's Replica Reply topic _before_ producing to replica request for T
		- All subs here are _temporary_
	- Notify Update
		- Nodes subscribe to Notify Update topic of tiles of their AOI
		- As clients know their AOI in terms of tiles (precomputed) they know which Notify Update topics to sub to
- Use cases
	- Update Propogation
		- Clients request updates through the master copy holder's own node topic
		- MAsters then propogate updates using multicast of the Notify update of tile it resides one
- Object Discovery
	- Consider P1 moving to T which puts P2 in interest region (and P1 in P2s interest region)
	- Two things: (a) P1 needs to discover all game objects of interst for T, (b) P2 has to discover than P1 has entered its AoI
	- Master holders always subscribe to replica request topic of tile for their game objects
		- P1 subs to rep reply of **all** tiles in its new AoI
		- P1 then publishes replica request to all of the topics for each of its tiles in its new AoI
		- All master holders now receive P1s replica requests
		- That handles (a)
	- When P1 moves onto tile T:
		- It publishes an update to Tile T's Notify Update
		- But P2 will be subscribed to this
		- So P2 gets a notify update for a replica it doesnt have and can request one
- Replica Transfer
	- Pretty simple: P1 publishes to Replica Request, master sees this (as they sub to this) and publishes replica to Replica Reply
	- For (b) above: P2 receives a notify update for a replica it doesnt have:
		- Subscribes to replica reply for tile T
		- Publishes to replica request for that object
		- Receives replica reply from P1
- **This is cool because object discovery and replica transfer dont rely on point to point comms anymore**
- **Upon moving to new tile T, just send _one_ request to Replica Request for each T' that you are interested in and get back all of the replicas**
- **Can potentially coallesce replica requests so that a single reply can potentially serve multile requests (e.g. multiple people become interested in same tile at same time)**

### Engine 3: Area-Based Engine
- _Content_ (not topic) based engine
- Much finer grained control over pub as subs can contain filters allowing fine grained multi cast
- Can be used to specify locations and AoI ranges
- Can publish events wtih xy coords of where event takes place
	- Player moves, publish its new x and y
- Can subscribe to rectangle using x and y predicates
- Player movement 
- Has 3 channels again: Replica Request, Replica Reply and Notify Update
	- **BUT NOW THERE IS ONLY 3 CHANNELS FOR THE ENTIRE WORLD!**
	- Notify Update:
		- Each client subs to this with x and y ranges that define AoI
		- Updates to objects are published on a point
		- All clients subbed with predicate that this point falls within get notified of update
	- Replica Request:
		- Master holder of object subscribes to Replica Request topic with xy that represents AoI of that object
		- Replica requests associated with an XY and if that falls within master copies xy, they receive request
	- Replica Reply:
		- As before, client nodes subscribe to this temporarily before requesting replicas
- Use Case:
	- Update Propogations:
		- When player wants to update an object, uses master node's topic and point to point to issue update request
		- Master then publishes update on Notify Update
	- Object Discovery:
		- Case (a):
			- **Note: AOI updates are regulated by time, distance or both to minimize number of AOI changes and replica requests**
			- Client subs to replica reply with its AoI
			- Publishes replica request using current location as AoI center
			- Master holders can respond with ths
		- Case (b):
			- Same as before
	- Replica Transfer:
		- Case (a): easy, master just sends replica reply on replica reply topic using master's location
		- Case (b): As before.

- Basically same as tile based, except mechanism for describing the AoI is different
	- Area is rectangular and non aware in area base
	- Way less comms channels (no longer one per tile)


## Papers to Read
- DonnyBrook enabling high performance peer to peer games
- G-COPSS / COPPS (J. Chen) content centric comms infrastructure for gaming
- Aspects of networking in multiplayer computer games --> Server Pools?
- J.-S. Boulanger, J. Kienzle, and C. Verbrugge. Comparing interest management algorithms for massively multiplayer games. In NETGAMES, page 6,2006.