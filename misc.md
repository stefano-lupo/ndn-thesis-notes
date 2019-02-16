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

# Bloom Filters
- Lets you know **for certain** if a you have **not** seen a piece of data before
- Have a bit array `B` of length `k` and a list of `n` hash functions `[h1, ..., hn]` which map data onto range `[0, n-1]`
- When a piece of data arrives, run it through the hash functions 
    - Use the hash values as indices into the array and set all of the bits at the corresponding indices: `set B[h1(d)], ..., B[h2(d)]`
- If you want to check if a piece of data has not been found
    - Hash it with each of the hash functions and check if _any_ of the bits at the corresponding indicies are unset
- If they are all set you may or may not have seen the data before
- Obviously the false positive rate can be arbitrarilt reduce with larger bit arrays at the cost of space complexity
- Problem: we cannot delete entries from a bloom filter as it may unset collided bits from other pieces of data

# Invertible Bloom Filter
- Works with key-value pairs
- Enables partial _retrieval_ from bloom filters
- Uses a list of a three component data structure instead of a bit array
    - Stores key `x`, value `y` and a `count`
    - `B[i].count` is the number of times `B[i]` has been used
    - `B[i]`.key is `x` and `B[i].value` is `y`
- (Insertion mechanism explained below) To retrieve from bloom filter
    - Can only retrieve data if `B[i].count == 1`
    - Otherwise the data may have been overwrriten
    - However as we store the data in a bunch of places (one for each hash function)
        - There is a high chance that at least one of them didn't collide and that we can extract the data from there 
- Insertion: Recall XOR is inverse of itself
    - `1101` XOR `1010` = `0111`
    - `0111` XOR `1010` = `1101`
    - `(A XOR B) XOR A = A`
    - Imagine a key `k` sitting in a position of the bloom filters array is `1101`
        - A new key `k' = 1010` needs to be inserted here now
        - Instead of inserting `k'` as the new key (losing all reference to `k`)
            - The new key becomes `k` XOR `k'` = `1101` XOR `1010` = `0111`
            - We do the same for the value
            - We also increment the count
- Deletion: enabled by this whole XOR business (assuming this key value pair was inserted at some point!!)
    - For each hash function applied to key `hi(x)`
        - `key :=  B[hi(x)].key XOR x`
            - From example: key had become `0111`  after XORing the two
                - If we remove the first entry `1101`: `key := 0111 XOR 1101 = 1010` <-- the second entry
                - If we remove the second entry `1010`: `key := 0111 XOR 1010 = 1101` <-- the first entry
                - Do the same for value
                - Decrement the counter