# Design Notes for My Protocol

## Data Types
1. Player: Frequeny updates, not really sure if cachable
2. Placable (blocks): Infrequent updates unless people interacting with them
3. NPC: Pathing, Players Interacting with NPC. Who takes ownership?
4. Projectiles: Frequent updates from shooter, or projectile path and inform when something happens?
    - Probably best if owner shoots, and computes hits based on their state of world
    - Can then publish update if nesc
5. Attacks: 

## Sequence Numbering
- Nodes can fall behind on sequence numbering
    - Upon reaching producer (non cached version), producer should respond with newest data and newest sequence number
- The reason I went with sequence number was to use the outstanding interest model
    - The producer needs a sense of what sequence number a consumer is at to determine whether or not to respond to the interest right away
- So two options: piggyback next sequence number in data sent back, or append it to the name of the data returned
    - e.g Sub requests `/data/5`, Pub is at sequence number 10, sends back data for 10 named `/data/5/10`
        - Sub then requests `/data/10` etc
    - Alternatively, Pub just responds with `/data/5` and can build in next sequence number to all data packets
        - I like this less
- Mechanisms for controlling this in [Interest](https://named-data.net/doc/NDN-packet-spec/current/interest.html) Packet:
    - `CanBePrefix`: Specifies whether or not `/data` can be satisfied by `/data/5` for example (default is false)
    - `MustBeFresh`: Specifies whether or not the contetn store can satisfy the interest with stale data
        - This is determined by the `FreshnessPeriod` of the **Data packet** in the content store
    - `InterestLifetime`: Time before interest times out

- Realistically they are all going to have `CanBePrefix == true`, `MustBeFresh == true`
- So we can tweak Data packets `Freshness Period` and Interests `InterestLifetime`
    - `InterestLifetime` can probably be quite long as presumably the corresponding interest is just sitting at the pub who hasn't got new data yet
    - `FreshnessPeriod`

- Ideal case is we're not really using caching, but multicast

### Custom Parameters
- Should data updates be limted on the pub side (i.e. only update the `data` of the pub every 100ms or something) so that consumers can just requeue up another outstanding interest the second they get data?
- Or should the subscribers build in a wait time between receiving data and queueing up the next request..?



## Diffs vs whole?
- If S requests `/data/blocks/5` and producer is at 10: maybe all those 5 missing updates happend on one block?
    - If S maintains a recent history of the entity IDs that sn 5-10 impacted, could just send back the updates for those IDs
    - Imagine if there was 100 blocks and only 2 got updated
    - Map<ID, >

## Decaying Interest rate as function of distance 
- 2D Gaussian for player status interest rates
    - Have hard upper and hard lower
    - E.g. min rate is 2 seconds as we need to update them occasionally to know if we need to update more frequently
- Alternatively, this could be done on the pub side
    - Pub only sends data back when its locals are ~near the client
    - Interests have a lifespan anyway so this will be refreshed every ~2s
    - Sub's POI is refreshed every 2s so pub could use that
        - That could get messy with sequence numbering suffixes though