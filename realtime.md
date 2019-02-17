# Realtime Applications


## [Real Time Data Retrieval in NDN](https://named-data.net/wp-content/uploads/2018/08/hoticn18realtime-retrieval.pdf)
- Content can come from anywhere (router cache, producer etc)
	- May be getting old data
	- New joiner needs mechanism for figuring out the current frame to request it
		- IF dont know current frame then can use prefix and will get back something
- Uses NDN RTC app as our use case
	- NDN-RTC Producer collects audio / video samples and splits them into data packets and serves them in response to incoming requests
- Related work:
	- Chasing in initial NDN RTC (for finding frame number)
		- Send out interest using only prefix (no s no)
			- Get frame number back
			- Send out a bunch of interests for n+1, n+2 at a higher rate than the generation rate of frames
			- Estimate when we are getting new frames when receival rate becomes ~= generation rate
	- Similar in ACT (NDN audio confrencing tool)
	- VR Video confrencing: uses a centralised signlaing server that helps newcomers discover latest data names
		- Notifies server of first frame generated for every second
		- Server broadcasts this to all consumers
- **All of these are because video  / audio require info about previous frames (I think) - so not only interested in latest frame?**
- Design:
	- Consumers must be able to deterministically construct the name for desired piece of data
	- Frames / Frame segments are named sequentially so that when a consumer gets one, can construct names for future data
	- Consumers need to know most recent frame number and how they should pipeline outstanding interests for optimal performance
		- This uses metadata packets for this
		- Periodicallu / response to interest producer publishes these
		- Uses `FreshnessPeriod` (NDD interest packet) so that will get metadata packets direcxtly from producer if router caches are stale
		- Discovery interests used to fetch the latest metadata value (just prefix without metadata number)
		- Consumers send discovery interest and measure round trip time
			- Received metadata packet with relevant sequence number
			- Can use this data to infer data names for frames / deltas in the near past/future
			- **KEY**: Consumer can estimate data generation rate and pipeline interests accordingly to minimize latency

## [Voice Over CCN](https://named-data.net/wp-content/uploads/JacobsonVoccn.pdf)
- Loads of references for content focused over host 
- "A variety of proposals call for a new Internet architecture
focused on retrieving content by name, but it has not been
clear that any of these approaches are general enough to support Internet applications like real-time streaming or email"
- Implementation is "simpler, more secure and more scalable than its VoIP (Voice-over-IP) equivalent"
- Conforms to VoIP standard payloads
	- Interoperable with VoIP
	- Uses a stateless IP-to-CCN gateway
- Strategies for mapping IP based mechanisms onto NDN / CCN
- **Background on VoIP** could be useful
	- Session Initiation Protocol (SIP) through their respective proxies sets up a bi-directional media path between them
- Need to support two things to map conversational protocols SIP and RTP to CCN
	- Must be able to initiate call to callee's phone
		- This is _service rendezvous_
		- Typically in IP: Listen on certain port for requests and generate responses
		- CCN: _on demand publishing_: Ability to request content not yet published, route request to potential publisher and relay the published data back to requester
	- Must be able to transition from service rendezvous into bidirectional flow of data
		- E.g. IP: TCP packet contains information on exactly where this packet should end up
		- **KEY**: CCN: Need constructable names 
			- Must be possible to construct name of piece of data without ever having seen the data / being told the name
				- CCN: Hierarchical naming allows data to be querieid by prefix (e.g. /usr/bob instead of /usr/bob/192831)
- SIP --> CCN
	- Each entity has an identity (lupos@tcd)
		- Some derivable name from that entity to which they will produce data e.g /tcd/stefanolupo/sip/invite
		- Caller sends interest for that name + the stuff in the initial SIP invite packet
			- Callee responds with data analgous to SIP packet
			- Now both have the data they need
	- Can now derive media path (content) names for the call e.g. /identity/call-id/seq-no
- **KEY**: Interest / Data exchange typically happen in lock step (one data pakcet for one data packet)
	- In high latency environments this can make Real time applications unusable
	- Solution here is to always have a number of interest packets outstanding (pipeline)
		- These are set up on call set up and maintained through out the call
- Benefits
	- Multipoint routing: call request can be forwarded to a bunch of places where callee might be (Property of NDN routing)
		- Endpoints no longer have to register every time they change IP (within a routing domain) e.g. /voip/tcd
	- Provisioning / Management of identities is simple
		- No mapping from entity --> IPs needs to be maintained
		- Just need to give a new entity a credential to provision (a key for signing)
- Implementation uses a Proxy for conversions to and from VoIP <==> CCN Packets

## Papers to read
- NDN RTC
- ACT NDN audio confrencing tool
- VR video conferencing over Named Data Networks