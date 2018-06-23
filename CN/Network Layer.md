# Network Layer
> The network layer is concerned with getting packets from source to destination. It is the lowest layer that deals with end-to-end transmission. It must take care when choosing routes to avoid overloading the communication lines. It must handle the problem of internetworking.  

## 1. Network Layer Design Issues
* The network layer is the **lowest layer**concerned with end-to-end delivery. 
* End-to-end transmission requires many individual hops: 
	– Network offers alternative routes 
	– Select to minimize overloading and idle routers. 
* The Transport Layer should be shielded from complexity

### 1.1 Store and Forward Packet Switching
Major network components = ISP equipment.
A host with a packet to send transmits it to the nearest router. Routers store and forward the packet until it is fully transmitted and 
verified by check-sum. It is then relayed to the next router on the path to the destination. 

### 1.2 Services to Transport Layer
::Common goals::
1. Service should be independent of router technologies. 
2. Transport Layer should be shielded from number, type and topology of routers. 
3. A uniform addressing scheme should be exposed to the Transport Layer. 

::Divergent philosophies:: 
Telecoms providers advocate for connection-oriented protocols. Internet engineers for connectionless 

Connectionless Protocols:
– Argues that the network is inherently unreliable. 
– Transport Layer handles reliability, no ordering, error-detection or correction. 

Connection-oriented Protocols:
– Argues that end-to-end **QoS**is needed at Layer 3. 
– Network Layer provides specific quality of service support for transport-layer flows

### 1.3 Connectionless Service
* Packets are injected into the network individually: 
	– Each packet is routed independently.
	– No connection setup is necessary.
	– Each packet carries the **end address**. 
* We refer to units of transmission at the Network Layer as **Datagrams**. -> Datagram Network
* Each router maintains a table of **addresses** and **links**to route a packet to that destination. 
* The best link to use may **change over time**and thus packets follow different routes. 
* The algorithm that manages the tables and makes routing decisions = the **routing algorithm**

![](Network%20Layer/page10image1264%202.png) 
 
### 1.4 Connection-oriented Service
* Based upon **Virtual Circuits**:
	– Circuits are calculated at connection setup. 
	– Packets follow the same circuit.
	– Circuits terminate along with connections. 
* Each packet carries its **circuit identifier** rather than its end address.
* To avoid conflicts, routers need the ability to replace connection ID’s in outgoing packets

-> **Label Switching**: used in ISP networks (**MPLS — MultiProtocol Label Switching**). IP Packets are wrapped in a MPLS header having a 20-bit label.

![](Network%20Layer/page23image2192%202.png) 

### 1.5 Service Comparison

::Arguments Pro Datagrams::
* Datagrams do not need a **set-up phase** which takes time and resources. 
* More **resilient to router crashes** (which terminate a virtual circuit). 
* Connection setup itself requires **globally routable addresses**.

::Arguments Pro Virtual Circuits::
* Routing process is **simpler**, requiring no complex lookup. 
* Routing tables are small*, as they do not need an entry for every possible end-point. 
* Circuit **identifiers are smaller** than datagram addresses as they are not globally unique. 
* Resources can be reserved during connection setup, giving **better Quality of Service**
* Since the same direction is followed, the **packets are delivered in proper order**.

![](Network%20Layer/page26image1184%202.png) 

## 2. Routing algorithms
* Route packets from the source machine to the destination. 
* Routing Algorithms choose routes through the network, determining **how a packet should be forwarded**. 
* In Virtual Circuit approaches this occurs once (**session routing**)
* In Datagram networks, routing decisions must be made for every datagram.

Router consists of two processes: 
1. One that handles the arriving packets, looking up the outgoing line for it (-> forwarding)
2. The second is responsible for filling in and updating the routing tables. (-> routing)

::Desired properties::
* **Correctness:** algorithm finds routes to all destinations. 
* **Simplicity:** algorithm executes quickly enough for Internet-scale routing. 
* **Robustness:** must be resilient to lower-level hardware and software faults.
* **Stability:** should converge towards a common set of optimal paths. 
* **Fairness:** all parties using the network should receive a ‘fair’ bandwidth allocation. 
* **Efficiency:** the routing algorithm should optimally exploit network resources. 
-> Many of these goals stand in opposition 

Many networks attempt to minimize the distance a packet must travel, or reduce of hops a packet must make. Either choice reduces amount of bandwidth consumed and improves the delay.

Routing algorithms can be grouped into two major classes:
1. **Nonadaptive algorithms:** do not base their routing decisions on any measurements or estimates of the current topology and traffic. Instead, the route is computed in advance, offline, and downloaded to the routers when the network is booted. -> **Static Routing**
2. **Adaptive algorithms:** change their routing decisions to reflect changes in topology. **Dynamic routing** algorithms differ in 
	1) where they get their information, 
	2) when they change routes,
	3) what optimization metric is used.

### 2.1 The Optimality Principle
Bellman et al. (1957):
1. If **J** is on the optimal path from **I** to **K**, then 
2. optimal path from **J**to **K** falls on the same route. 

::Proof by contradiction::
If there were a more optimal path from J to K, we could append this to path from I to J, invalidating statement (1.) above.

![](Network%20Layer/page34image1312%202.png)

The goal of all routing algorithms is to discover **the sink tree** of all routers:
The set of optimal routes from all sources to destination (D) form a **sink tree** routed at (D). 
-> The distance metric is the **number of hops**. 

 
### 2.2 Shortest Path Function
In the general case, the labels on the edges could be computed as a function of the distance, bandwidth, average traffic, communication cost, measured delay and other factors. By changing the weighting function, the algorithm would then calculate the shortest path.

#### Dijkstra’s algorithm
* Maintain a table of all possible routes from **N**, starting with all routes labeled with **infinite cost**. 
* Examine each adjacent node in turn, re-label each with the distance from **N** to that node and the node from which the probe was made. 
* Make the node with the lowest label (**N’**) **permanent** and move to this node. 
* Examine each adjacent node **X**, if cost of **N-N’** plus cost of **N’** to **X** is lower, update cost.

### 2.3 Flooding
Each router must make decisions based on local knowledge. Technique that can provide this is **flooding**: every incoming packet is forwarded on every outgoing line except the one it came from.
-> Generates vast numbers of duplicate packets (very robust)
-> Hop counter can be used:
	a) If distance to destination is known use that. 
	b) If distance unknown, use network diameter. 
	c) If traffic load too high, decrease TTL.

Better approach is by having the source router putting a sequence number in each packet it receives from the host and each router maintaining a list of sequence numbers of packets that already have been seen for each source . When a packet arrives, router will discard it when it has seen it before.

### 2.4 Distance Vector Routing
Proposed by ::Bellman-Ford::, used in ARPANET as **RIP**.
* Distance Vector Routing is a dynamic routing algorithm for finding the shortest paths in changing topologies. 
* Each router measures distance (e.g. delay) to each neighbour which is measured using special ECHO datagrams.
* Each router maintains a table (vector) containing an entry for each destination and the best link to use to get there. 
* Tables are periodically exchanged with neighbours so that every node gradually learns the best route.
![](Network%20Layer/page43image1280%202.png) 
Upon receiving a routing tables, current tables are discarded and new entries are created for each router based upon: 
	– The lowest distance estimate received. 
	– The distance to the router

#### Count to infinity problem
Good news travels fast, bad news travels slowly.
No router ever has a value more than one higher than the minimum of all its neighbours. Gradually all routers will work their way up to infinity (which is wisely set to the longest possible path+1).**Core problem:** no router is aware if it **itself** is included in a path. 

Solutions? **Poisoned reverse rule** -> In practice does not work well

![](Network%20Layer/page58image5944%202.png) 

### 2.5 Link State Routing
Due to the count to infinity problem, link state routing has the upper hand. It is used in the internet as **IS-IS & OSPF**. It requires a 5-step process.
1. **Discover its neighbors** network addresses. 
2. **Set the distance** to all neighbors. 
3. **Construct a packet with all learned**. 
4. **Send this packet** to all other routers. 
5. **Compute shortest path** to all other routers using **Dijkstra’s Algorithm**

#### Neighbour discovery
* On boot, each router sends a HELLO packet on each point-to-point line. 
* All routers receiving a HELLO respond with a datagram containing its address. 
* Broadcast media (e.g. Ethernet) provide connectivity between all connected routers, **increasing graph size** -> Artificial node![](Network%20Layer/page63image1280%202.png) 

#### Setting Link Cost & building Link State packets
* We can use many link costs: distance, financial cost or signal strength (for wireless media). 
* For Internet most common choice is to use a measure inversely proportional to bandwidth or delay 

A packet is built containing: 
(a) address of sender, 
(b) sequence number, 
(c) age,
(d) a vector of all costs to each neighbor. 

![](Network%20Layer/page65image1320%202.png) 

#### Information Distribution
* Datagrams are distributed using flooding. 
* **32bit Seq. numbers** are used by routers to discard packets already seen. 
* To recover from crashes, **Age** of packets is also included. Packets older than some threshold are discarded 

#### Route computation
* Once all link state packets have been received the router can reconstruct the whole graph. 
* Dijsktra’s algorithm is run on the graph to find shortest path to each remote router. 
**Note:** every link is represented twice, once for each direction as costs may be asymmetric. 

::Link State routing requires routers to do much more computation and store more data::
For a network with _n_ routers and _k_ neighbours -> data need to stored is proportional to _kn_!
It becomes critical to **limit the size of the routing tables**.
LS routing is vulnerable to router problems (software & hardware) -> can wreak havoc across the network. The trick is to limit the damage propagation by arranging the routers in smart ways.

### 2.5 Hierarchical Routing

### The Hierarchy Solution:
Each router is assigned a region. It knows the internal structure of its own region, but only the entry point for remote regions. 
![](Network%20Layer/page75image1224%202.png) 
* Significantly reduces routing table size. Essential when paired with link state routing. 
* Hierarchy also increases path length in some cases due to incomplete knowledge. 
* **Kamoun et al (1979)** define **optimal hierarchy depths (ln N)** and demonstrate that increases in path length are manageable.

### 2.7 Broadcast Routing
#### Delivery models
* **Unicast:** from a single address to a single address.
* **Broadcast:** from a single address to all remote addresses. 
* **Multicast:** from a single address to groups.

#### A. Naïve Broadcast
**Unicast all messages** from the sender to every receiver. 
	-> Very wasteful of bandwidth as routers often see the same packet twice. 
	-> Requires the sender to know the addresses 

#### B. Multi-destination Routing Broadcast
**Send a single message** that contains a list of all destinations.
Each router checks the list of destinations and determines the output lines needed, generating a new copy on each line based on its routing tables. 
	-> Lots of work for the routers.
	-> Requires the sender to know the addresses

#### C. Flooding Broadcast
* **Send a single message** that should be re-transmitted by all routers. 
* Message contains a **Time-to-Live (TTL)** which is decremented at each host and a **sequence number** ID. 
* Hosts forward all incoming messages on all links except the one they arrived one, discarding where TTL=0 or sequence number is in the cache. 
	-> Not the most efficient way

#### D. Reverse Path Forwarding Broadcast
* _Requires:_ shortest path routes for regular packets have been computed
* If a router receives a datagram on the link used to route to the sender, it **probably followed the shortest path** and is first to arrive. 
* If the datagram arrives **on any other link, discard it as a duplicate**
* Can be used with both Vector as Link State Routing.

![](Network%20Layer/page87image1368%202.png) 
 
#### E. Spanning Tree Broadcast
* A spanning tree is a subset of the network that **includes all routers and no loops**, as with the sink tree. 
* Each router knows if it is in the spanning tree and will forward the packet on all spanning tree lines except the one it arrived on. 
* Generates the minimum possible number of packets but is **only possible where routers have global knowledge** -> Applicable for Linked State Routing, not: Vector Routing

### 2.8 Multicast Routing
* Prune the broadcast spanning tree by removing links that do not lead to members.
* **MOSPF, DVMRP (Distance Vector Multicast Routing Protocol)** -> Examples
* Alternative: *Core Based trees: All routers agree on a root (the core) and build the tree
	* Optimization: packets don’t need to reach the core to be multicasted
	* = Major savings in storage costs, messages sent and computation
	* e.g. **PIM (Protocol Independent Multicast)**

### 2.9 Anycast Routing
* Used for DNS 
* Regular DV and LS routing can provide an anycast

### 2.10 Mobile Host Routing
* The problem of keeping mobile hosts connected as they change location: 
	– Truly mobile devices, e.g. cell phone.
	– Nomadic devices, e.g. laptop computer. 
* We tackle this problem by providing a fixed home address for mobile devices. 
* This is better than re-computing routes, which at large scale ties up too many core resources
* Whenever you go to a new location, DHCP acquires you an address and DNS allows you to reach remote services. -> This **does not allow remote clients to remain**

::Solution:::
* The **home agent** provides a single consistent address for mobile nodes. 
* When a host acquires a new local address (**care-of-address**), it reports this to the home agent. 
* When the home agent receives a datagram for the mobile host it is **encapsulated** with a new header and **tunneled** to the care-of address
* Upon receiving a message from its home agent, the mobile host **de-encapsulates** it and **responds directly**. 
* Subsequent datagrams may be **tunneled directly** between the remote host and the mobile host. 

![](Network%20Layer/page38image1248%202.png) 
!!! Security is a big problem for this approach !!!
	-> If I can imitate your mobile host, all of your traffic will be directed to me. 
		-> Security information is included in requests so that validity can be checked

This mobility approach is widely deployed:
	– UMTS cellular routing.
	– IPv6 mobility 

### 2.11 Ad-Hoc Network Routing
* Ad-hoc networks are **infrastructure-less**. All nodes are **both routers and hosts**. 
* This frequently occurs in Vehicular Ad-hoc NETworks (**VANETs**) and multi-hop Internet of Things Networks (**IoT**). 
* All elements of the network may move at any time. Thus static reasoning over topology is **meaningless**. 

::IOT Concerns::
1. **Resource constrained:** embedded microcontrollers, tiny memory, tiny storage. 
2. **Energy conservation:** nodes must run on a single charge for long periods. 
3. **Unreliable**: mote failure due to damage, power failure 

#### AODV — Ad-Hoc On Demand Vector Routing
-> Closely related to Distance Vector routing
-> Routes are only discovered when someone wants to send a datagram (**reactive, not proactive**) 
-> Our network medium is broadcast. Each node has a range. 
-> Neighbors determined by range + location. We assume an ideal circular range (= unlikely) 

1. ROUTE_REQUEST’s are flooded (with sequence number and TTL)
2. Discovered node sends **ROUTE_REPLY** back along the path 
3. A hop counter in **ROUTE_REPLY** is incremented at each intermediate hop and intermediate nodes add the route to their tables

![](Network%20Layer/page50image1304%202.png) 
::Incremental Route Horizon::
As route discovery leads to **high broadcast overhead.** To minimize this ROUTE_REQUESTS are initially sent with TTL=1 if this fails after a time-out, it this is **incrementally increased** until the route is found.

::Route Maintenance:: 
If a node detects that one of its active neighbors has failed:
	– It purges all entries from the routing table using this link
	– and notifies neighbors using this route. 
	– This occurs recursively until all routes using this node are purged 
-> Count-to-infinity is avoided

However NO_ROUTE exceptions still have very long timeouts causing overall slow-down.

## 3. Congestion control
Congestion Control = 
(Presentative)
	— Network Provisioning: Turning on redundant functionality, upgrading 
	– Traffic Aware Routing: Avoid congestion by **including load in link costs**
	– Admission Control: When the network is near capacity, **do not allow new connections**
	– Throttling: **Signal**that the network is congested so that hosts can take action. 
	— Load Shedding: **Drop packets**
(Reactive)

It is the hosts that throttle connections. We cannot fix the problem with bigger buffers. **Nagel et al. (1987)** identified that this is **worse** as packet lifetimes <= queue time. 

### 3.1 Traffic Aware Routing
* The shortest path algorithms that we studied in the previous lecture used **static weights**. 
	-> This allows for adaptation to changes in topology, but not load. 
* Traffic aware routing **shifts traffic away** from hotspots as they appear. 
* To make our routing traffic-aware simply extend so that **cost includes load on neighbors**
	-> Invokes **oscillation** -> No adoption: More research needed

### 3.2 Admission Control
Estimating **how many flows** we can support is also non-trivial. 
	– Allowing only 10 * 1mbps burst streams on a 10mbps router is wasteful. 
	– Allowing too many streams is dangerous.
In reality, for each type of traffic flow, **we use historic patterns**

**Recall:**we do find the shortest path one time for a virtual circuit: during connection setup. 
	* Routers that are at capacity may **remove themselves from remote routing tables**. 
	->  E.g. using the same scheme as in AODV.
	* Thus **new circuits will avoid the congested routers**, using only routers below capacity. 

 ![](Network%20Layer/page20image1288%202.png) 

### 3.3 Throttling
(-> Congestion window in TCP <-)

We use three mechanisms:
1. Choke packets
2. ECN — Explicit Congestion Notification flags
3. RED — Random Early Detection 

::Load can be estimated based upon three metrics::
**–Link utilization:** rapid feedback, but hard to account for bursty traffic. 
**–Packet loss:** accounts for all traffic but usually comes too late. 
**–Queuing delay:** rapid feedback including burstiness -> Exp. Weighted Moving Avg.

#### Choke packets
= explicit notifications provided by congested routers.
	– A warning datagram (choke packet) is sent back to the sender of a congested packet.
	– The packet is marked so that no further choke packets will be generated later on. 
	— Provides warning for the sender’s transport entity to throttle rate it sends segments

#### ECN
* Explicit Congestion Notification is used to tag packets as they travel through routers. 
* ECN-tagged packets reach **destination host**, which messages the sender to throttle send rate. 
* In comparison to Choke Packet, ECN has lower overhead, but takes longer to enact change.

 ![](Network%20Layer/page26image1304%202.png) 

#### RED
Packet loss is a slow indicator. What about: ::randomly discard packets as delay is detected?::
	* This idea is counter-intuitive, but has advantages: 
	– It **makes packet loss a more reliable congestion signal**. 
	– It reduces the delay between congestion starting and transport-layer throttling. 
	* Random Early Detection will drop random packets as congestion approaches 

Why random works? 
	-> Fast senders tend to **have many more packets in the queue**.
	-> Reduces book-keeping overhead.


## 4. Quality of Service

1. **Traffic Shaping**: describe the traffic being sent and police that traffic.
2. **Packet Scheduling**: reserve the resources necessary to assure a QoS level along the whole route. 
3. **Admission control**: ensuring that too many flows are not accepted

### A. Traffic Shaping
A traffic flow is the stream of data sent from a source to a destination.
	– In a connection-oriented protocol, all of the packets of a connection 
	– In a connection-less protocol, all of the packets sent between two processes. 

* We would like to provide assurances over bandwidth, delay, jitter and loss.
* Many traffic types are **bursty**, with peak transmission rates far above the average. 
* A **traffic shape** is encoded in an SLA between the customer and the provider. 
 	->  User agrees to send traffic within this shape.
	->  Traffic outside of the shape is policed. 

#### The leaky bucket
* No matter how fast water enters, it leaves at rate R. 
* If the bucket is empty rate drops to zero. 
* When the bucket is full to capacity B, additional water is lost. 

![](Network%20Layer/page42image4480%202.png) 

#### The token bucket
* Implemented with a counter for the level
* Every time traffic is sent out -> counter is decremented
* B + RS = MS, with B: bucket capacity, M: Max. Out. rate, R: token arrival rate, S: burst length
* Can be implemented at both hosts and routers
* Can be stacked to smooth traffic


### B. Packet Scheduling
Methods to decide which packets to send next:

::First in First Out::
* FIFO routers drop new packets when the queue is full (tail drop). 
* This can easily be abused by aggressive senders: 
	– Fast sender fills queue, results in lost packets
	– Packets that do get through are delayed

::Fair Queuing::
* Maintain a separate queue for each flow.
* When the line is clear to send the router takes a packet from each queue in turn.
* Can be cheated by senders with larger packets. 

![](Network%20Layer/page57image1272%202.png) 

::Weighted Fair Queuing::
* In practice, we often do not want to treat all flows equally. 
* In this case, we can assign a weight. 
* The weight determines the number of bytes per round that are drained from a flow 


### C. Admission Control
* Network decides to **accept or reject a flow** based upon current commitments. 
* For every new flow that is accepted, capacity is reserved. All routers on the path must be reserved, a single congested router breaks QoS. 
* If a flow is rejected from one path, a different route may be found. 
* Applications may have hard requirements or may accept QoS reductions.
* e.g. DifServ & Intserv


## 5. Internetworking
### 5.1 How networks differ
* Internetworking is the process of connecting heterogeneous networks at scale. 
* Why do networks differ? 
	– Different physical challenges: Ethernet vs Satellite. 
	– Reuse of existing infrastructure: phone lines, cable TV lines, power lines. 
* Size matters: the value of a network grows with its size. Metcalfe speculates network value approximates N^2

![](Network%20Layer/page67image1288%202.png) 

### 5.2 Approaches to Internetworking

* **Translation:** devices convert packets of one type A to type B. 
* **Indirection:** higher level processes use a common layer that is mapped differently to different networks. -> IP

![](Network%20Layer/page69image2792%202.png) 
> Routers operate at the boundaries between networks must do extra work to ensure end-to-end routing in the face of dissimilar networks.   

::Switches work at Layer 2 – the Data Link Layer::
	– Switches work in terms of frames and do not consider IP-related issues. 
::Routers work at Layer 3 – the Network Layer::
	– Routers work in terms of packets and extract IP information from a packet when routing it.

### 5.3 Tunneling
* Use when source and destination nodes are on the same type of network with a different network in-between. 
* Timely example: two IPv6 networks connected to the IPv4 Internet. (translation from IPv6 -> IPv4 is impossible) 

![](Network%20Layer/page72image1256%202.png) 
* The entire tunnel is treated as one network hop by the upper layers
	-> None of the hosts on the encapsulated network can be reached -> VPN
* The router must ‘speak’ both IPv4 and IPv6 – it is a **multi-protocol router**. 

### 5.4 Internetwork Routing
::Challenges::
1. Different routing algorithms (DV, Link State). 
2. Different shortest path metrics (latency, throughput, cost). 
3. Obfuscated internal paths (hierarchy). 
4. Scale – millions_billions_trillions of nodes.

**Intradomain routing:** Within their own networks, we are free to use whatever routing approach we wish. 
**Interdomain routing:**
 -> Links Autonomous Systems (AS) 
 -> We must use the same protocol – Border Gateway Protocol 

Improves scaling, lets operators choose their routing algorithms freely, does not require weights to be compared across networks, nor does it require sensitive information to be exposed.

### 5.5 Packet fragmentation
Each network imposes a maximum transmission unit due to:
	– Hardware limits (Ethernet MTU: 1500 bytes)
	– OS limits (e.g. buffer size) 
	– Timing considerations
	– Protocol limits 

::Two archetypal approaches to fragmentation::
1. Transparent: routers re-assemble packets after they have traversed hops with small MTUs: 
	**+** Easier on the hosts.
	**-** More work for (heavily loaded routers). 
2. Nontransparent (used by IP): routers do not reassemble packets, it is the responsibility of hosts: 
	**+** Easier for the routers.
	**-** More work for hosts 

![](Network%20Layer/page78image1208%202.png) 

* Fragmentation is expensive in both cases and should be avoided (header overhead). 
* If a fragment is lost, the whole packet is lost
* To avoid fragmentation the sending host needs to discover the path MTU. 

::Path MTU discovery::
![](Network%20Layer/page80image1264%202.png) 
> If a router receives a packet that is too big, it drops it and returns an error message.   

## The Network Layer in the Internet — IP
::Principles of IP Design::
1.  Make sure it works through multiple prototypes
2.  Keep it simple (Occam’s razor)
3.  Make clear choices avoid unnecessary options
4.  Exploit modularity, work within your layer
5.  Expect heterogeneity
6.  Avoid static options, prefer negotiation
7.  Do not attempt to serve every special case
8.  Base strict when sending and tolerant when receiving
9.  Think about scalability
10. Consider performance costs.

::Structures of the Internet::
* A collection of loosely-structured Autonomous Systems (AS)
* **Tier 1:** provide the backbone, **pays no transit fees**
* **Tier 2:** ISP and regional networks are attached to this backbone. These networks **peer** with other T2 networks or pay transit fees.
* **Tier 3:** Edge networks are connected to Tier 2 networks. **Purchase all transit** from other networks.

### The IPv4 Protocol
![](Network%20Layer/page9image800%202.png) 
 
An admin. domain defines as set of traffic classes as domain for charging and prioritization. Traffic within the domain is tagged using the DiffServ field of the IP header. These classes determine:
1. How each router should treat the packet
2. How the traffic is shaped (leaky bucket)

::Differentiated services —  Expedited Forwarding::
Two classes of traffic: regular (most) and expedited 
	-> VOIP is increasingly marked.
	-> Routers maintain a regular and expedited queue, packets are taken from the latter first

![](Network%20Layer/page14image928%202.png) 

::Differentiated services — Assured Forwarding::
Four **priority classes**: gold, silver, bronze, normal
Three **discard classes**: low, medium, high
	=> 12 permutations

The sending host classifies packets by priority. Discard classes may be determined by traffic shape. Small bursts are low discard, long bursts are high discard.

![](Network%20Layer/page16image784%202.png) 

::DF/MF::
DF = Don’t fragment, **used in MTU discovery datagrams**
MF = Indicates more fragments are on their way

::Fragment offset:: Where in the current packet this fragment belongs


::Options:: 
Provide flexibility, allowing for up to 40 bytes of additional TLV encoded fields (padded to a multiple of 4 bytes)
	-> Security option
	-> Strict/Loose source routing
	-> Record Route option
	-> Timestamp option


### The IPv4 Address

**Network Service Access Point (NSAP)** 
-> IPv4 maps to a network interface, not a machine
-> PC has an IP address for each network it belongs to (routers also have multiple interfaces)
-> Sequences of 32 bits (4 octets)

**The prefix**: Each address has a variable sized network portion in the leading bits and a host portion in the trailing bits. A network corresponds to a contiguous block of IP-address space, the prefix. The size is determined by the number of bits in the network portion (power of two). By convention it is written after the prefix IPv4 address as a slash followed by the length.

The length of the prefix corresponds to a binary mask of 1s (the **subnet mask**). Can be ANDed with IPv4 to get the network portion.

Routers only need one route per network prefix , all IP addresses (hosts) can be reached via the same router. -> Hierarchy reduced routing table size from > 2bn to +-300K.

#### Subnets
As organisations grow, they may need to re-allocate IP addresses.
**Subnetting** splits an IP address into sub networks. The change is only locally visible but transparent from the outer net. The network router must store each internal prefix using the standard method.

Originally: Class system was used: 
![](Network%20Layer/page32image2024%202.png) 
-> Three bears problem: Most of the class B networks have in practice < 50 hosts.

#### CIDR — Classless Inter-Domain Routing (CIDR)
Core routers in ISP’s and backbones in the middle of the internet have no luxury. They must know which way to go to get to every network. (**Default-free zone**)
Hierarchical approach would require more than 32 bits.

::The solution:: is to allow for precise prefix lengths to be requested. Where multiple subnets with the same prefix share a route and where multiple prefixes are combined into a larger one. As a further twist, prefixes are allowed to overlap. The rule is that packets are sent to the **most specific route / the longest matching prefix**.

![](Network%20Layer/page39image944%202.png) 
 
#### DCHP (REVISITED) — Dynamic Host Configuration Protocol
-> APPLICATION LAYER PROTOCOL
-> IP addresses are assigned on demand (**leased**) for a specific period
-> IPv4 reserves the following address ranges:
	— 10.0.0.0/8 
	— 172.16.0.0/12
	— 192.168.0.0/16 

#### NAT — Network Adress Translation
A NAT box has one externally routable IP. Internal private addresses appear to be sent from the public IP of the NAT box. Incoming messages are translated to the private address. It is widely used for home networks and small businesses because of the address shortage.

![](Network%20Layer/page46image784%202.png) 
![](Network%20Layer/page47image264%202.png) 

TSAPs Provide Multiplexing -> Transport Layer
 
::Problems with NAT::
1. NAT violates IP addressing principles — one address per IF
2. NAT breaks end-2-end model. Only hosts behind the NAT can initiate a connection. (protection is however useful in some cases — Firewalling)
3. NAT is connection-oriented (NAT maintains connection info, What if the NAT crashes?)
4. NAT confuses layering (It assumes TCP headers stay the same)
5. Only works with TCP and UDP
6. What about IP-addresses in the Body (FTP fails with NAT)


### The IPv6 Protocol

::Features::
* 128 bit address space: 64 bits hierarchical routing + 64 bits for addressing
* Simplified fixed-length headers: 40 bytes in each packet, extra info in extension headers
* **Stateless auto-config**: allows nodes to obtain an IP address and routing information
* **End-2-End Security** at the network layer.
* **Quality of Service**: support by traffic class and data flow
* **Simplified fragmentation** of messages
* Support for **mobility**
* Mandatory support for **multicast**
* Support for **anycast** messages that allow for load balancing

Requires some DNS changes.

::Adressing::
8 groups of four hexadecimal digits -> 8 * 4 * 4 bits, separated by “:”
Shortening address: 
* Removing consecutive groups of zeroes and replace with “::” (can only be done once!)
* Removing leading zeroes for each remaining group

::Address Ranges::
= Notation for representing a group of contiguous IPv6 addresses:
		-> IPv6/prefix-length
		-> Example: 	2001:db8::/32 = from 2001:db8:0:0:0:0 to 2001:db8:ffff:ffff:ffff:ffff
						2001:db8::/48 = from 2001:db8:0:0:0:0 to 2001:db8:0000:ffff:ffff:ffff

There are three type of addresses defined in IPv6:
	-> Unicast: 
			1) Global Unicast Addresses (for servers)
			2) Unique Local Unicast Addresses
			3) Local Addresses (every IPv6 host must have one for each interface)
	-> Multicast: …
	-> Anycast: …

 ::Interface Identifier::
Create an IID from a MAC address
![](Network%20Layer/page68image2752%202.png) 

### Internet Routing Protocols

Seven design rules:
	1. Open and published in public literature 
	2. Support a variety of distance metrics. 
	3. Adapt quickly to changes. 
	4. Supports type of service. 
	5. Support for load balancing. 
	6. Support for hierarchy 
	7. Security support
	
#### OSPF — Open Shortest Path First
= INTERIOR GATEWAY PROTOCOL (Like RIP and IS IS): used for exchanging  routing information between gateways (commonly routers) _within_ an  autonomous system.

::Process used: Link State Routing::

**Step 1: Learn about Neighbours**
On boot, each router sends a HELLO packet on each line…

**Step 2: Setting Link Cost**
Most common is to use a measure inversely proportional to bandwidth or delay.

**Step 3 & 4: Constructing and Distributing Datagrams**

**Step 5: Computing New routes**
Dijkstra’s algorithm on a bidirectional graph as cost may be assymmetric.

![](Network%20Layer/page12image1248%202.png) 

/ Within an area routers share link state routing tables. Border routers have tables for all connected areas. /

::Load Balancing:: can be done with *ECMP (Equal Cost MultiPath) routing.
	-> Remembers all equal length paths and splits packets across them

![](Network%20Layer/page16image1224%202.png) 
> All OSPF messages are sent as standard IP packets  


#### BGP — Open Shortest Path First
= EXTERIOR GATEWAY PROTOCOL:  used to exchange routing information between AS. This exchange is crucial for communications across the Internet. 

BGP focuses on supporting flexible routing policies.
	-> AS care about more than shortest path

AS may pay for transit. Or **peer** for free delivery to neighbours.
Connections are made at **IXPs (Internet eXchange Points)**
Networks connected by one link are **stubs**.

![](Network%20Layer/page26image1264%202.png) 
BGP is a form of distance vector protocol that operates on paths not routers.
Internal BGP requires boundary routes to learn routes of all other boundary routers. (ISP networks)
Prefixes for external AS are stored at each boundary router and discovered internally using OSPF.


![](Network%20Layer/Schermafbeelding%202018-06-17%20om%2020.56.09%202.png)


### Internet Control Protocols

#### ICMP — Internet Control Message Protocol

![](Network%20Layer/page55image2616%202.png) 
1. Error message sent when no route exists at a router or when DF bit is set
2. A symptom that (a) packets are looping or (b) TTL values are too short. 
3. Indicates a bug in the IP stack of the sending host, or the transiting router. 
4. Used in ECN. 
5. Inform a router that there is a more efficient route to the destination. 
6. Commonly known as PING and PONG 
7. Used for time synchronization. 
8. Used to advertise the address of routers to hosts. 

#### ARP — Adress Resolution Protocol
						 
::Purpose::
What is the purpose of Address Resolution Protocol and Reverse Address Resolution Protocol? 
ARP is used to mediate between ethernet (or other broadcast link-level protocols) and the network layer, or IP protocols. Put more simply, ARP converts IP addresses to ethernet addresses.

::Why ARP is necessary::
ARP is necessary because the underlying ethernet hardware communicates using ethernet addresses, not IP addresses. 

Suppose that one machine, with IP address 2 on an ethernet network, wants to speak to another machine on the same network with IP address 8. The two machines use ARP to conduct the following dialogue:
1. ARP Request—Machine 1 (IP=2) broadcasts to all machines on the network: 
2. Question: Who has IP address 8?
3. ARP Reply—Machine 2 (IP=8) replies: I do. 
4. The reply of Machine 2 contains its ethernet address, so now Machine 1 knows it.

Machine 1 stashes that address temporarily in a _kernel memory_ area called the ARP cache. That way, if it needs to speak to Machine 2 again soon, it does not have to repeat the ARP request.

The (ARP) _Address Resolution Protocol_ feature performs a required function in IP routing. ARP finds the hardware address, also known as **MAC (Media Access Control address)**, of a host from its known IP address and maintains a cache (table) in which MAC addresses are mapped to IP addresses. ARP is part of all Cisco systems that run IP. The ARP feature for IP routing and the optional ARP feature you can configure, such as static ARP entries, timeout for dynamic ARP entries, clearing the cache, and proxy ARP are part of its standard feature set.






