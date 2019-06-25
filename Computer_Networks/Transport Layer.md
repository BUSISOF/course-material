# Transport Layer
> The transport layer builds on the network layer to provide data transport on the network layer to provide data transport from a process on a source machine to a process on a destination machine with the desired level of reliability that is independent of the physical network in use.  

## 1. The transport service
### 1.1 Services provided by Upper Layers
The transport layer makes use of the services provided by the network layer. the software and or hardware within the transport layer that does the work is called the **transport entity**. It provides **end-to-end delivery** of data encapsulated in segments using **virtual circuits** and strives for efficiency, reliability and cost 
effectiveness. 

= Often located in the kernel, a library package, a separate user process or on the Network Interface Card.

::Two types of service::
1. Connection oriented transport service: 
	— addressing & flow control are similar to the connection oriented network services
	— 3 phase connection
2. Connectionless transport service: 
	— Focused upon providing **fast and simple communication**. 
	— No connection setup is needed 
	— There is limited error control (simple checksums) and no flow control. 

Why bother? Because users cannot solve the problem of a poor network service. Thus to improve **quality of service** the transport layer is put on top. In essence, the existence of the transport layer allows for more reliable connections. Furthermore, hiding the network service behind a set of transport service primitives ensures changing the network only means updating the primitives.

![](Transport%20Layer/page6image1224%204.png) 

There is a qualitative distinction between the bottom four layers forming the **transport service provider** and the upper layer(s) forming the **transport service user**. It is the only layer that will be exposed to the applications.

## 1.2 Transport Service primitives
Each transport layer has its own interface, hiding away the imperfections/complexity of the network service so that users can assume the existence of an error-free bit stream even when they are on different machines. 
Because of the wide-spread usage of the transport service, it must be convenient and easy to use.

![](Transport%20Layer/page10image1264%204.png) 

![](Transport%20Layer/page9image3736%204.png) 

A segment is also called a **TPDU (Transport Protocol Data Unit)**.
In the transport layer, even a simple unidirectional data exchange is more complicated than at the network layer. Every TPDU needs an ACK, similarly the transport entities need to worry about timers and retransmissions. All of this is not visible to the transport users. 

Disconnection has two variants, either symmetric or asymmetric. In the former each direction is closed separately. In the latter both directions are closed on the arrival of a DISCONNECT segment.

## 1.3 Berkeley Sockets
![](Transport%20Layer/page14image1224%204.png) 
![](Transport%20Layer/page18image2536%204.png) 

At the client side, a socket must first be created using the SOCKET primitive. BIND is not required since the local address (port) used does not matter to the server. 

The ::socket API:: used with TCP is often used to provide a **reliable byte stream**.
It can also be used for a connectionless transport service. Or can be used to provide a message stream instead of a byte stream such as **DCCP (Datagram Congestion Controlled Protocol)**.

Most natural fit for application programs is to use one stream per object (suboptimal for congestion).
So new protocols and interfaces such as **SCTP (Stream Control Transmission Protocol)** and **SST (Structured Stream Protocol)** which supports groups of related streams more effectively and simply.

## 2. Elements of transport protocols
The transport service is implemented by a transport protocol which resembles data link protocols.
They share f.e. the concepts of error control, flow control and sequencing. 
::The significant difference:: 

* Data Link Layer provides communication between two hosts on the same physical link while hosts at the Transport Layer may be separated by a whole network.
* It is usually not necessary to specify the destination on point-to-point links, whereas in the transport layer, explicit addressing is needed. 
* Connections over a network can differ heavily in bandwidth  etc. which requires another approach when designing flow control.

### 2.1 Adressing
The method is to define transport addresses to which processes can listen for connection requests. In the Internet these endpoints are called ports. 

* **Transport Service Access Points (TSAPs)** define an end-point for transport layer traffic, the analogous endpoint in the network layer are called NSAPs (such as IP addresses). 
* IP addresses are not enough because multiple processes running on the same host may concurrently exchange data.
* Some ports are well known and permanently assigned 

User processes often want to talk to other user processes that do not have known TSAP addresses. To resolve this, a user process connects to a **portmapper** (which listens to a well defined port) which can send back corresponding TSAP addresses in response of a service-name query.

![](Transport%20Layer/page27image2192%203.png) 

Some servers may only operate sporadically. So why run them all the time? 
—> Initial Connection Protocol (ICP):
			1. **Process Server** listens for connections on well known TSAP addresses. 
			2. When a connection is received, the server process is started and passed the TSAP address. 

![](Transport%20Layer/page30image1304%203.png) 

### 2.2 Connection establishment
Problems occur when the network can lose, delay, corrupt and duplicate packets.
::The crux of the problem is that delayed duplicates are thought to be new packets.::

The problem can be attacked in various ways:
1. Throwaway transport addresses => makes it more difficult to connect with a process
2. Unique ID per connection => requires each transport entity to maintain a certain amount of history information indefinitely + persistency is needed
3. **Bounded Packet Lifetime**: Rather than allowing packets to live forever in the network, we devise a mechanism to avoid accepting these delayed duplicates.

Packet lifetime can be restricted to a known maximum:
1. Restricted network design
2. ::Putting a hop counter in each packet::
3. Time-stamping each packet (requires router synch)

In practice we will also need to guarantee that all acknowledgements of the dead packet are also dead.

Each packet carries a **sequence number** that will not be re-used within **T** seconds (multiple of true packet lifetime: 120s). The range of sequence numbers is determined by the number of packets per second and T. The sequence space must thus be sufficiently large so that by the time it wraps around, old segments are already starved to death.

::Dealing with crashes::
 – In a crash sequence numbers would be lost. 
 – Instead of idling for T seconds, a **persistent, real time clock** is used to provide initial sequence numbers during connection. 
 – Thus after a crash, hosts continue with a higher sequence number than before

To establish a connection, a three-way handshake is needed. TCP makes use of this.
To protect sequence numbers from over-wrapping to fast an extra timestamp is used. **PAWS (Protection Against Wrapped Sequence-numbers)**. TCP originally did use the clock-based scheme as described. However a major security flaw was that the clock made it easy for a hacker to predict the next sequence numbers. So it could in fact trick the handshake into a forged connection.
As a solution, pseudorandom sequence numbers are used nowadays.

### 2.3 Connection release
There are two styles of terminating a connection:

1. Asymmetric release (the way telephone system works), may result in data loss
2. Symmetric release: treats the connection as two separate unidirectional connections. (TCP)

Unfortunately, the latter does not always work. Meet, the two army problem: the sender of the final message can never be sure of its arrival. => it is up to the transport user to decide when done.

In theory protocol can still fail if the initial Disconnect Request & N retransmissions are all lost. The sender will give up leaving a half open connection. => Automatic shutdown after a timed idle period

### 2.4 Error Control & Flow Control
::Error control:: is ensuring that the data is delivered with the desired level of reliability. 
::Flow control:: is keeping a fast transmitter from overrunning a slow receiver. 

In the **Link Layer Protocols** a frame…
1. carries an error-correcting code
2. carries a sequence number
3. is retransmitted until ACK received (**Automatic Repeat ReQuest**)
4. maximum number of outstanding frames which causes the sender to pause when not ACK’ed fast enough
5. is a sliding window protocol

In the transport protocols we use a same approach with difference in function/degree.
Checksum here is an **end-to-end** check. Safeguard against router corruption.

Transport protocols use larger sliding windows with buffers on both sides. 
Best trade-off between source buffering and destination buffering depends on the type of traffic.
For low-bandwidth, bursty traffic: no initial buffers are needed (dynamic acquirement).
For high-bandwidth traffic: receiver dedicate a full window of buffers.

::Buffer pool::

1. If segments are nearly all the same size => pool of identically sized buffer slots with one segment per slot
2. Variable sized buffer slots => better performance the cost of buffer management overhead
3. Single large circular buffer per connection => efficient when heavy loaded
4. Dynamic buffer allocation => sender requests nr. of buffers based on expected needs, receiver allocates as many as possible => adopted by TCP (window-size header field)

Deadlocks can occur at strategy 4, so control segments need to periodically be sent to escape this problem.

What is needed is a mechanism to limit transmissions from the sender based on the **carrying capacity** of the network. => Using a sliding window flow-control scheme in which the sender dynamically adjusts window size (= c (segments/s) * r (roundtrip time)) to match the network’s capacity. 

### 2.5 Multiplexing
In the transport, the need for multiplexing can arise in a number of ways.
F.e. if there is only one NSAP.
If a user needs more bandwidth or more reliability than one of the network paths can provide, a way out is to have connection that distributes the traffic among multiple network paths.
![](Transport%20Layer/page31image1288%203.png) 

## 3. Congestion Control
> If the transport entities send too many packets into the network too quickly, the network will become congested with degraded performance as packets are delayed and lost. Controlling congestion is a combined responsibility of the network and transport layers.  

### 3.1 Desirable Bandwidth Allocation
Congestion occurs at routers, so the Network Layer should signal it, yet Transport Layer controls dispatching of segments.

::What is the optimal state we are aiming for?::
— We should use all available bandwidth. 
– We should avoid congestion.
– We should be fair across Transport entities.
– We should respond quickly to changing usage. 

#### Efficiency and power
Two refinements:
1. We must use a little less than all of the bandwidth due to ‘bursty’ traffic. 
2. We should worry about **goodput** not throughput. 

As we approach our bandwidth limits, bursts of higher traffic cause losses in network buffers 
these losses cause more retransmissions initiating a congestion collapse. As the network approaches congestion, delay rises at an increasing rate. Packets are lost after the maximum buffering delay is exceeded. 
 
Power to identify the most efficient load: load / delay.
![](Transport%20Layer/page7image1264%203.png) 

#### MinMax Fairness
An allocation of bandwidth is min-max fair if the bandwidth given to one flow cannot be increased without decreasing bandwidth for another flow with an allocation that is no larger. This is only easy to compute if you have global knowledge! Fairness is complicated (e.g. heterogeneity), but ::precise fairness is less important than preventing starvation and congestion::.

#### Convergence
Connections are not static. They come and go. Any approach to fair allocation must converge 
quickly to the ideal operating point. 

![](Transport%20Layer/page12image1224%203.png) 
Things to avoid:
	– Algorithms that do converge slowly.
	– Algorithms that oscillate 

### 3.2 Regulating sending r	ate
::Two reasons our connection may be slow::
1. We are dealing with a low capacity receiver, which cannot receive quickly or has a smaller buffer. 
2. We are dealing with a high capacity receiver, but we have a congested router in-between.
![](Transport%20Layer/page13image1304%203.png) 

* In the case of a small capacity receiver, we need to dynamically resize our flow control buffer – a Transport Layer Solution. 
* In the case of network congestion, we need to lower our send rate in the Transport Layer based upon a signal from the Network Layer. 

A protocol does both, feedback is given by:
* XCP (eXplicit Congestion Protocol)
* ECN (Explicit Congestion Notification): routers set bits on packets experiencing congestion
* FAST TCP: measures round-trip delay

The way in which rates are increased/decreased is defined by **control law**.

::AIMD — Additive Increase, Multiple Decrease:: 
![](Transport%20Layer/page17image2536%203.png) 
Converges no matter what the starting point —> Used by TCP
It also fits with a more general rule of thumb: it is easy to drive the network into congestion and difficult to recover. So our increase in rate should be gentle and our decrease should be aggressive.

## 4. UDP — User Diagram Protocol
> UDP is a connectionless transport layer protocol that allows for the sending of segments between hosts with no connection overhead. . It provides no: flow control, ordering, congestion control. Only addressing and checksums.  

### 4.1 UDP
UDP transmits segments consisting of a 8-byte header followed by the payload. The main advantage over raw IP is the addressing which allows deliveries to applications.

![](Transport%20Layer/page21image1320%203.png) 

The maximum length is 2^16 = 65,515 bytes. In practice limited to 1500 bytes (Ethernet).
The UDP checksum is calculated based upon a simple hash of the UDP header and the IP pseudo-header. 

::Benefits::
1. Connectionless, so works well with anycast (e.g. DNS), broadcast (e.g. DHCP, Wake on LAN) and multicast. 
2. Low overhead in comparison to TCP, so it can be implemented on **tiny devices**.
3. Useful in client-server situations. (f.e. DNS)

### 4.3 Realtime Transport Protocols
* Multimedia applications tend to need the same kinds of realtime services. 
* Real-time Transport Protocol (**RTP**) is a common approach to addressing these concerns. 
![](Transport%20Layer/page32image1304%203.png) 

RTP’s position in the stack?
::For Application Layer::
**+** Implemented in user-space (apps not OS). 
**+** RTP packets are encapsulated as UDP. 
::For Transport Layer::
**+** Implements a generic service. 
**+** Is not tied to an 

#### RTP — Realtime Transport Protocol
Basic function of RTP is to multiplex several real-time data streams onto a single stream of UDP packets. UDP stream can be sent to a single address or to multiple destinations. Packets are not treated specially unless IP’s QoS are enabled. RTP has no ACK’s or ARQ’s. Time-stamping allows applications for buffering.

![](Transport%20Layer/page37image1320%203.png) 
* We still need to know if packets went missing, but the action we take could be different: interpolate, ignore, etc. 
* RTP packets carry linearly increasing sequence number 1 higher than its predecessor. 
* RTP also supports **extension headers** (X field marks presence) for more advanced functionality.

#### RTCP — Realtime Transport Control Protocol
* Real Time Control Protocol (**RTCP**) controls RTP streams, it is defined in **RFC 3550**. 
* Providing feedback and control on delay, variation in delay, jitter, bandwidth, congestion. 
* Provides synchronization of streams using clocks of different granularity. 
* Provides human-readable naming of sources. 

#### Playout with Buffering and Jitter Control

* As we have discussed, packets take a variable amount of time to travel between hosts. 
* This results in out of order arrival, but also results in **variable delay** between sender and receiver. 
* This variability in delay is known as **jitter**. It can have a very significant impact on the perceived quality of multimedia streams.

![](Transport%20Layer/page42image1240%203.png) 
We can minimize the observable effect of jitter using a buffer. 

![](Transport%20Layer/page43image1400%203.png)
**Note:** the average delay is not very different, but the buffer required to capture 99% of packets differs significantly 
 

::Key consideration is the playback point::
* The playback point determines how long to wait at the receiver before playing incoming RTP packets. 
* We must select it correctly, or end up with either (a.) unnecessary delay or (b.) high loss 


## 5. TCP — Transmission Control Protocol
### 5.1 Introduction to TCP
TCP is designed to provide a reliable end-to-end byte stream over an unreliable internetwork.
TCP must be ::robust and adaptable::. 

The **transport entity** is the software process that implements the TCP protocol.
Responsible for: 
1. Splitting the streams into segments
2. Reliable transmission
3. Reconstructing byte streams
4. Efficiently using bandwidth and avoiding congestion

### 5.2 TCP Service Model
The TCP endpoints are called sockets. Each socket has an IP address and a 16-bit local address (port) => 48 bits. Ports below 1024 are reserved for well known applications. Commonly a single daemon (in UNIX **inetd**) attaches itself to multiple ports and wait for the first connection.

All TCP connections are **full duplex** and map to exactly two sockets.
Multicasting/Broadcasting is not supported. 
TCP is a byte stream, not a message stream.

### 5.3-4 TCP Protocol & Header
![](Transport%20Layer/page10image800%203.png) 
Every byte has its own 32-bit sequence number. One for each direction (REQ & ACK).
Options field has Type-Length-Value encoding. (MSS, Window Scale, Timestamp, SACK are common)
A TCP segment consists of a fixed 20-byte header, followed by the payload.
Max. payload size = 65515 bytes
Each segment must fit the **MTU (Maximum Transmission Unit** => 1500 bytes in general.
Can be calculated through path MTU discovery. (ICMP error message to find bottleneck)

![](Transport%20Layer/A6592C2B-0C63-4E8F-B98C-78C024DEA6F8%203.png)
 
TCP implements a variable sized sliding window. Window size specifies how many bytes may be sent starting at the byte acknowledged. Window size of 0 indicates that bytes up to ACK number have been received but needs time to process them.

### 5.5-7 TCP Connection

![](Transport%20Layer/page27image936%203.png) 

A vulnerability is that the listening process must remember its sequence number as soon as it responds with its own SYN segment. This can lead to a **SYN Flood** attack on which a malicious sender tie up server resources through the flooding of SYNS. A way to counter this is to use **SYN Cookies**. A host chooses a cryptographically generated sequence number, puts it on the outgoing segment and forgets. On a completed handshake, the incremented sequence number will be returned to the host.

### 5.8 TCP Sliding Window

TCP decouples acknowledgement from buffer allocation, sender must independently ACK packets and advertise available buffer space.
 
When receiver window is 0, no transmission can occur except for:
1. **Urgent traffic:** sent to interrupt remote process
2. **Window probe:** Deadlock is possible if window updates are lost -> Solution

![](Transport%20Layer/page54image784%202.png) 

::Tinygram syndrome:: 
Worst case TCP overhead is using the connection to send 1-byte-payload segments to an echo-server.
Transmission = 20 (TCP) + 20 (IPv4) + 1 byte
ACK = 20 (TCP) + 20 (IPv4) bytes 
Window advertisement = 20 (TCP) + 20 (IPv4) bytes
Response = 20 (TCP) + 20 (IPv4) bytes
=> 160 bytes needed to send 1 byte (in each direction) => 1.25% efficiency

To reduce network load: **Delayed Acknowledgements:** 
* Until timeout (usually 500 ms), wait for data to be transmitted
* If data is transmitted within time -> piggyback ACK

Another improvement: **Nagle’s algorithm**:
While there is a sent segment with no ACK, buffer output until we have a full segment (with respect to MSS) and send at once.

However: both combined can sometimes cause a deadlock!

::Silly Window syndrome:: 
Silly Window Syndrome occurs when the sending entity receives data in large blocks, but the receiving application reads at 1-byte at a time.
![](Transport%20Layer/page62image784%202.png) 

Solution: **Clarke’s Algorithm**: Delay window updates until the window can receive the MSS or until the buffer is half empty. (= complementary with Nagle’s solution, the sender does not send small segments and the receiver does not ask for it)


### 5.9 TCP Timer Management
 **RTO (Retransmission Time Out)** in TCP determines how long to wait for an ACK before retransmitting a segment -> If an ACK is not received, we retransmit and restart the timer
TCP must _dynamically adapt_ the RTO period.

Proposed solution:
1. Estimating Round Trip Time -> **SRTT (Smoothed RTT)** = a*SRTT + (1-a)R (a typically 7/8)
2. Estimating Variance in Delay (needed to counter congestion collapse) -> **RTTVAR** = b*RTTVAR+(1-b)|SRTT-R| (b typically 3/4)
=> RTO = SRTT + 4*RTTVAR

::The Persistence timer::
This timer is used to determine when to send window probes. The persistence timer starts when a window of size 0 is reported. If a non-zero window size update is received -> cancel timer.
If the timer expires, a window probe is sent.

::Keep Alive timer:: (optional)
Timer is restarted whenever a message is received from a remote host. If the timer expires, the remote host is probed to ensure that it has not crashed. If no response is received, the connection use terminated. 

::TIME_WAIT timer::
Runs when TCP entity enters TIME_WAIT state prior to connection closure.
Waits twice the Max. Packet Lifetime -> Ensures all segments associated with the connection have died

### 5.10 Congestion Control
Network layer detects congestion and takes action.

Notifications may be:
1. Explicit or implicit (recall XCP,ECN, FAST_TCP)
2. Precise or imprecise

TCP uses AIMD using packet loss as an implicit, imprecise signal.

#### Congestion Window
Is maintained separately from the control window.
Window defines the bytes a sender may have in transmission at any time.
Since we have two windows, one that measures host capacity and one that measures network capacity, TCP will use whichever window is the smallest.
===> RATE = MIN. WS / RTT

_Is packet loss a good signal?_
-> Wired routers will drop packets when congested
-> Wireless devices may drop packets unpredictably
-> Requires a good retransmission timer (We have! RTO)

#### Timing of Packet Transmissions
Even if we infer congestion from loss, we cannot send packets into the network in large bursts.
We must match the timing of segment transmission to match the speed at which they are transmitted across the slowest link (-> MINMAX Fairness).

Fortunately we can discover the lowest rate on the path. The returning ACK’s match the slowest link rate:
![](Transport%20Layer/page92image792%202.png) 
We inject new traffic into the network only as fast as the rate at we receive ACKS’s.
-> Avoids overwhelming slow links

#### A Short Coming of AIMD
AIMD additive increase can be slow for high cap. connections -> we cannot assume larger windows 
Thus we need a way to tweak the build-up to be faster than pure-AIMD would allow.

::TCP Slow Start::
* Additively increases the congestion window exponentially until congestion is detected
* We start with 1 segment, receive 1 ACK, send 2 segments…
* Only restriction is the ACK clock
* Threshold is needed to keep it in check -> Flow Control Window Size

![](Transport%20Layer/page96image784%202.png) 
When the threshold is breached, it is re-set to half the congestion window. TCP then switches to additive increase until packet loss occurs, when slow start restarts.
![](Transport%20Layer/page101image784%202.png) 

We can still do better, rather than begin from scratch, we wait until the number of packets in the network falls to the new threshold (1/2 RTT) -> detected through counting duplicate ACK’s
Once we have fallen below -> additive increase

![](Transport%20Layer/page105image792%202.png) 

#### Selective ACK
SACK allows for fast recovery after multiple loss. SACK provides information in the options field on which interval of packets are ACK’ed (-> backwards compatibility). When a packet is received out-of-border, the receiver responds with: 
1. A duplicate ACK
2. A SACK giving the byte range received above the cumulative acknowledgement 
=> As the sender knows which packets have been received above the acknowledgment, these can be selectively retransmitted

