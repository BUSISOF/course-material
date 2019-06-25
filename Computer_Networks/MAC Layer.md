# MAC Layer
> Key issue is how to determine who gets to use the channel in case of competing systems  

## Channel Allocation Problem
MAC is about sharing a single broadcast channel.
Two basic options: Static or dynamic allocation.

::Static Allocation:: 
-> Frequency/Frame Division Multiplexing
-> 
-> Wasteful: If we have N chunks and only a few are in use, bandwidth is wasted!

::Dynamic Allocation:: assumptions:
1. Independent traffic — multiple nodes generating constant traffic levels.
2. Single channel — Heart of the model.
3. Observable collisions — when two nodes transmit at once, the result is garbage.
4. Continuous or slotted — are transmissions constrained to period or free?
5. Carrier sense or not — can we tell if the channel is in use? (Wired -> YES, Wireless -> NO)

## Multiple Access Protocols
### ALOHA

::PURE ALOHA::
Lets users transmit upstream frames whenever they like.
Collisions occur resulting in garbage frames -> Detected by downstream retransmission of received packets.
If the frame was lost, to prevent synchronous retransmits, a user waits a random interval before retransmitting.
Throughput is maximised by having a uniform frame size.

![](MAC%20Layer/page14image768%203.png) 

The probability that _k_ frames are generated during a given frame time in which G frames are expected is given by a Poisson distribution:

P = G^k*e^-G / k!

The probability for zero frames is just e^-G 
=> The probability no frame is generated during the vulnerable period is e^-2G
=> Throughput (channel utilisation) S = G*e^-2G
=> Maximum at G = 0.5 with S = 18%

::SLOTTED ALOHA::
Time is divided into discrete ‘slots’. Requires synchronization with clocks.
Nodes may only send at the beginning of a time-slot.
=> S = G*e^-G with a maximum at G = 1, S = 37%

![](MAC%20Layer/page16image768%203.png) 

### CSMA — Carrier Sense Multiple Access

* Protocols that listen for a carrier and respond accordingly are CSMA
* By listening for 3rd party transmissions before sending, collisions are reduced
* Listening all of the time is known as **persistent CSMA**

::non-Persistent CSMA::
When a node has data ready, it samples the channel:
	Channel idle? -> Transmit data
	Channel busy? -> Wait a random time and try again (so no continuous listening is necessary)
Leads to better utilisation at the cost of longer delays.

::1-Persistent CSMA::
When a node has data ready, it samples the channel:
	Channel idle? -> Transmit data (possibility of transmit = 1)
	Channel busy? -> Eagerly wait and transmit when possible 

::p-Persistent CSMA::
When a node has data ready, it samples the channel:
	Channel idle? -> Transmit data (possibility of transmit = p)
	Channel busy? -> Eagerly wait and transmit when possible

![](MAC%20Layer/page22image768%203.png) 
 
::CSMA/CD::
Another improvement: CSMA with Collision Detection enables the early abortion of transmission when collision is detected.
-> Collision detection is an analogous process
-> Collision signal must not be tiny compared to the transmitted signal.
-> Modulation must be chosen to support detection.

If a station detects collision it aborts transmission and waits a random period of time before retransmitting.
It will boost performance significantly when frame-time >> propagation time.

### Collision Free Protocols
#### 	Bit-Map Protocol
#### 	Token Passing
#### 	Binary Countdown

### Limited-contention protocol


### LPL & the BMAC protocol
IOT Challenges:
* RF Interference & occlusion -> Only small (congested) chunks of the spectrum are used
* Power constraints -> radio is power-hungry
* Node Loss

::Berkeley MAC::
B-MAC target requirements:
		* Low-power, simple implementation, configurable, scalable, decentralised
		* Suitable for diverse applications
Based on a simple CSMA scheme
	-> No time-synch required, joining the network is quick and low-cost
	-> **LPL (Low Power Listening)**: As transmissions are rare, it is better to spend little more energy when transmitting than while listening.
	-> Nodes only turn on the radio for short sampling periods
	-> If traffic is detected, the radio remains active and listening to receive a packet
	-> As transmissions may occur at random, we add a **long preamble** (> Sampling Period) to ensure that the radio is awake
	-> Offers clear channel assessment 
	-> Offers optional link-layer ACK of packet transmission
	-> Highly configurable
	-> A totally decentralised approach:
				* Should scale to massive numbers of nodes due to its small world properties
				* Is very well suited to unpredictable traffic


### TSMP — Time Synchronized Mesh Protocol
TSMP is a MAC and Network Layer protocol for WSAN developed by _Smart Dust_
Target requirements: Reliable, low power and secure, self organizing, self-healing, minimal management

-> Targeted primarily at many-to-one data gathering and control applications.
-> Requires a centralised manager for coordination (High load on manager + lacks robustness)

-> Uses **TDMA (Time Division Medium Access)**
	— Minimizes collisions that occur when two nodes within range transmit at the same time
	— Less collisions means less retransmissions => low power
	— Synched by a master node:
			1) Upon joining the network, nodes listen for transmissions, using this timing to set their own hardware clock
			2) By listening through a complete time-cycle or ‘frame’ a node can discover when to transmit upstream and listen to incoming packets from downstream
			3) Radio is only on within its message reception/transmission window

-> Supporting precise QoS configuration with the time-slots:
	 as time slots are precisely allocated, exact bandwidth allocation can take place
-> Avoiding interference with frequency hopping:
	— Interference tends to cluster around a subset of channels
	— As all nodes are time synched, they can hop through all channels based on a known sequence
-> Reliability is ensured using link layer ACKs and retransmission
-> Each node has multiple parents providing another layer of safety: Spatial & Temporal redundancy

::Limits:: 
-> Limits of a centralised approach: 
	-> Manager becomes a bottleneck
	-> TSMP packet structure: 1 byte ID allows only for 256 nodes
-> Limits of a time-synched approach 
	— High latency for sporadic traffic
-> High energy cost for (re)joining the network



## Ethernet / IEEE 802
Ethernet comes in 4 variants:
1. Classic Ethernet
2. Switched Ethernet
3. Fast Ethernet
4. 1Gbps Ethernet
5. 10Gbps Ethernet

### Classic Ethernet
First version used a thick coaxial cable and ran at 3mbps, DIX reached 10mbps and was standardised as 802.3

![](MAC%20Layer/page7image1168%202.png) 
![](MAC%20Layer/page9image2336%202.png) 
* Preamble (10101010 * 8) of 8 bytes containing alternating bit pattern allows sender and receiver clocks to synchronize. 
* Start of Frame uses a ’11’ bit pattern to signal frame data is about to start.
* Source and destination addresses are 48 bit IEEE MAC Addresses.
	-> First bit: 0 for unicast, 1 for multicast
	-> All 1’s = broadcast
	-> Globally Unique
	-> first 3 bytes = OUI (Organisational Unique Identifier) + last 3 = Manufacturer
* Type field tells higher layers what the packet contains 
	-> Field would carry the length of the frame (802.3)
	-> **LCC (Logical Link Control)** uses 8 bytes to convey the 2 bytes of information.
* The length field tells the receiver how much data is in the frame. (DIX)
* Padding is required to ensure collision detection for short frames 
* Checksums allow link-level error detection and correction. 

RAM-friendly frame size -> 1500 bytes
DIX and IEEE 802.3 were not compatible on the type-length -> <= 1500 denotes size; > 1500 denotes type.
Minimum frame size of 64 bytes makes it easy to distinguish valid packets from failed chunks.
 -> On collision, Ethernet generates a 48 bit noise burst to warn other stations. 

![](MAC%20Layer/page20image1288%202.png) 

Ethernet uses **1-persistent CSMA/CD** with binary exponential back-off.
		-> Back-off is slotted. After collision, each station waits a random number chosen in the range 0 to 2^i-1, where i is the number of collisions. We try: 0-1, 0-3, 0-7, etc. 
Range is upper bounded to 1023 slots, after 16 collisions higher layers are signaled.
		-> Algorithm ensures lowest delay when collisions are rare and adapts otherwise

::Security issues::
* With persistent channel sampling, an Ethernet interface sees frames for all hosts on its link. 
* The host is free to keep them and analyze them – promiscuous mode. 

::Channel efficiency:: = 1/(1 + 2BLe/cF) with
B: the network bandwidth
L: Cable Length
e: Contention slots per frame (CSMA)
F: Frame Length

### Switched Ethernet

![](MAC%20Layer/page26image1728%202.png) 
> A hub makes it easier to debug networks. If a link is broken, it affects one host.   

* Hubs do not increase capacity and eventually the LAN will saturate. 
* We can increase speed, but the volume of traffic always seems to catch up. 
* Switched Ethernet uses a high-speed backplane to connect hosts on a single line. 


![](MAC%20Layer/page30image1592%202.png) 
* Switches only output frames to ports for which they are destined. (Less visibility -> Better security)
* Each cable is usually full duplex, so the switch and host can talk at the same time. 
* Each port is thus a single collision domain that only needs to run the CSMA/CD protocol if: 
		– it has multiple hosts connected via a hub, 
		– the cable is half-duplex. 
* Switches improve performance as all hosts can send packets at the same time, without CSMA/CD. 
* Capacity is improved as frames are only delivered to hosts that they are intended for. 
* The impact of promiscuous mode is limited. 
* As two input ports may try to deliver frames to the same output port, the switch needs buffers, making it more expensive. 

### Fast Ethernet
* IEEE reconvened the 802.3 group in 1992 to create a faster 100mbps standard. 
* Two competing proposals:
	– Keep the protocol the same, but run it faster. 
	– Add lots of features. 
* The first proposal won out and was standardized by 1995. 
* Required twisted pair wiring – no more BNC connectors or Vampire Taps. 

::Compromise::
Reduce bit transmit time from 100nsec to 10nsec -> CSMA cuts cable length by factor 10.

### Gigabit Ethernet
* Gigabit Ethernet was standardized in 1999: 
	– Goal 1: 10 fold increase in speed.
	– Goal 2: backwards compatibility. 
* Gigabit Ethernet does allows interconnection by hubs and switches. 
* In the case of connection to a switch on a duplex cable CSMA is not used, thus cable lengths are only limited by signal strength. 
* Half duplex operation requires CSMA, limiting cable lengths to 25 meters = problematic. 
* Two hardware features were added: 
		– Carrier extension, which pads all packets to 512 bytes. 
		– Frame bursting, which concatenates small frames into a single > 512 byte transmission. 
* As these are hardware features they re invisible to software. 

### 10-Gigabit Ethernet
* Follows the same approach as 1 gigabit Ethernet: increase speeds using the same approach. 
* To eliminate length restrictions, **only full-duplex operation is allowed and hubs are not used**. 
* Transmission over copper is difficult (4 pairs of UTP). **Transmission over optical fiber** is preferred. 


##  IEEE 802.11

### Two modes of operation:
	– Infrastructure mode: used by wired access points to provide access to wireless hosts. 
	– Ad-hoc mode: used to create a network on-the-fly between wireless hosts. 
![](MAC%20Layer/page42image1168%202.png) 
![](MAC%20Layer/page43image1008%202.png) 
 

### Wireless challenges:
RF Interference:
	– Only small chunks of the spectrum may be used without a license and are therefore highly congested. 
	– Sporadic interference must be anticipated. 
Blocked Paths:
	– 2.4GHz signals are blocked by metal, absorbed by water and scattered by foliage. 
	– Optical signals are blocked by any opaque object. 
Bandwidth Limitations:
	– Low-power networking typically has an order of magnitude lower bandwidth than standard WiFi. 
	– Maximum packet sizes may be incompatible with other communication media. 
Mobility:
	– Nodes may move; necessitating protocols that can cope with a dynamic network topology. 
Power constraints

::Hidden and Exposed Terminals::
![](MAC%20Layer/page46image1408%202.png) 
1. We cannot transmit and listen for noise bursts at the same time. 
2. Transmission ranges are limited – we cannot see the whole network. 

::CSMA/CA::
* 802.11 implements Carrier Sense Medium Access with Collision avoidance. 
* As in Ethernet we do channel sensing with exponential back-off. 
* However if a station has a frame to send, it also starts with a random back-off in a small range (e.g. 0-15). 

_Why a starting Back Off?_
		* Collisions are more expensive in wireless. 
		* Acknowledgements must be used instead to make sure a frame has been delivered. 
		* A starting back-off makes sure that we do not compete with acknowledgements. 

::Virtual Channel Sensing::
* In virtual channel sensing, we us higher level information to infer if we need to check the channel again. 
* This higher level information may describe sequences of frames. 
* The 802.11 implementation of virtual channel sensing is based on **NAV (Network Allocation Vector)**. 
	-> Each frame carries a NAV field that says how long the transmission sequence will take to complete (e.g. frame + ack). 
	-> All stations that overhear this frame will wait until the sequence is complete before trying to transmit. 
	-> Note we are exploiting the fact that nodes overhear each other. 

::Power Saving::
* First approach is based on periodic broadcasts from the AP (beacon frames). 
* Used to advertise to the client that the AP has data ready for them. 
* In-between beacon frames the client sleeps. 
* Second approach uses client transmissions for timing. 
* The AP buffers traffic for a client until the client transmits, then sends it immediately after the ACK. 
* The client can sleep until it needs to transmit. 

::Frame Structure::

![](MAC%20Layer/page55image1192%202.png) 


