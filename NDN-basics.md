# NDN Basics

# Networking Named Content [Van Jacobson](https://named-data.net/wp-content/uploads/Jacob.pdf)
- Current internet methodology still based on host-host connection abstraction (telephone net)
- Uses **interest packets** to allow node to express interest in a named piece of data to network
- **Data packets** satisfy these interest packets and are returned to the consumer


## CCN Node Model
### Forwarding Informatio Base (FIB)
### Content Store
### Pending Interests Table

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

## Papers to Read
- NDN Naming scheme
- [NDN Project Parc 2010](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.366.6736&rep=rep1&type=pdf)