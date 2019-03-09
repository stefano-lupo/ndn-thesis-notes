# NDN Thesis Literature
- [NDN Basics](./NDN-basics.md)
- [Games](./games.md)
- [Dataset Synchronization](./dataset-sync.md)
- [Realtime Applications](./realtime.md)
- [Routing](./routing.md)
- [Security](./security.md)

# NDN Practical Notes
- [Docker (just begining)](./docker.md)

# How to Analyze Results? (Misc papers)
- Clock ticks per second (NLSR)
- RTT of pings (NLSR)
- [The incredibles (simulations)](https://www.cs.auckland.ac.nz/courses/compsci742s2c/resources/p50-kurkowski.pdf)


# Points to talk about
- Calculating latency is dependent on traffic minimization algorithms
    - E.g. dead reckoning / interest zone filtering makes latency appear higher
    - Can send back the time spent on the producer
        - But other consumers may get this data (multicast / caching)
        - This would skew their latencies
- Profiling the game, asyncing certain parts
- Topologies
    - E.g. triangle gets no benefit from NDN
- Are interests being coallesced?
    - Cache rate?
- Talk about caching
    - Obviously player textures can be cached etc but only hjappens once really
    - Useful on discovery
- Difference between my sync protocol and chronosync etc
    - No second round trip required
    - Don't need synchronized dataset writing capabilities

