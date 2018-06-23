# Application layer

### 1.3 Domain Server
In theory: a single server could contain the entire DNS database

In practice: server overload ---> crippled Internet

DNS namespace divided into non-overlapping zones.
Each zones is associated with one or more NS.
Each zone has a
1. primary NS: get info from files on disk
2. (possible) secondary NS's: get info from primary

Process of looking up a name and finding an address is called name resolution.

An authoritative record is one that comes from the authority that manages the record and is thus always correct.

In contrast: cached records are not always correct ---> may be out of date.

Most of the servers are present in multiple geographical locations and reached using any-cast routing. The replication improves reliability and performance.

Local DNS handles the resolution (it delivers a name resolution service), it does not return partial answers = recursive query

Root NS and subsequent NS (because they are too busy) return a partial answer = iterative query.

Performance improvement through caching: cached answers reduce query steps.
Entries should not live too long, depending on the situation the TTL field is set a small value to guarantee being up to date.

DNS uses UDP transport protocol, if no query-response arrives within time, another request is sent. 16-bit ID for matching requests with responses.

=> highly robust, performant


# 2 - Electronic Mail

First email systems: FTP (on port 21) with convention of recipient address head.

### 2.1 Architecture and Services
Architecture consists of two types of subsystems:
1. user agents
2. message transfer agents (**mail servers**)

Act of sending new messages = mail submission.
Mail servers are typically system processes: automatically move email through the system from the originator to the recipient with **SMTP** (Simple Mail Transfer Protocol).

Message transfer agents also implement mailing lists: copy is sent to everyone on the list.

Mailboxes store user's received email.

Key idea: In the message format there is a distinction between the envelope and its contents. The envelope encapsulates the message. Mail servers use envelope for routing.

Message inside consists of the header and the body.


### 2.2 User Agent
After a message has been read, user decides what to do = **message disposition**
Auto responders, vacation agent, signature blocks... are part of the user agent.

X.400: Form of addressing besides SMTP: uses attribute-value pairs with slashes.


### 2.3 Message Formats

#### RFC 5322 -- Internet Message Formats
In normal usage, user agent builds a message and passes it to the mail server, which then uses header fields to construct the envelope.

#### MIME -- Multipurpose Internet Mail Extensions
Basic idea of MIME is to continue to use RFC 822 (RFC 3522 precursor) but to add structure to the message body and add encoding rules for transfer of non-ASCII messages.

ASCII base64 encoding: very popular before binary-capable MS existed. (inefficient)
Now: for pure ASCII messages quoted-printable encoding is used. (efficient)

MIME supports the header "Content-Type" which defines a whole list of subtypes f.e. text_css, audio_mp3, video/mpeg...

### 2.4 Message Transfer
Simplest way to move messages is to establish a transport connection from the source machine to the destination and then transfer the message.

#### SMTP and Extensions
Within the internet, email is delivered by having the sending computers establish a TCP connection to port 25 of the destination. Listening to this port is a server that understands the SMTP, server accepts incoming connections subject to some security checks.

Process:
* Establish TCP connection (telnet) to port 25
* Sending machine listens until receiver tells it is prepared
* Client announces sender and recipient, if such recipient exists at the destination, server gives the client go-ahead to send the message.
* Message is sent and server acknowledges. Done

(Numerical code of replies = most important)

ESMTP Extends SMTP with authentication and privacy measures such as encryption.

#### Mail Submission
Originally: users ran on the same computer as the sending message transfer agent.
Nowadays: Mail servers on company server: TCP supports remote connections

However AUTH will be needed (cause spammers tend to launder their sender-address).

Inter mail server transport will make use of port 25.
Mail Submission to a (company) mail server makes use of port 587.


#### Mail Transfer
DNS query is made ---> results in IPv4 ---> sender's MS makes TCP p.25 connection with IPv4
Mail travels in a (high level) single hop!
Receiving MS can lookup Sending MS in DNS if it has a mail sending policy.
=> spammers need valid sending addresses to send mail => easier to detect and delete


### 2.5 Final Delivery
All that remains is to transfer a copy of the message to receiver's user agent for display.
SMTP = pushed-based protocol so cannot be used for local (sometimes offline) user agents

#### IMAP -- Internet Mail Access Protocol
* IMAP server listens to port 143.
* Client uses a secure transport protocol.

#### POP3 -- Post Office Protocol v3 (deprecated)
* Supports less features
* Less secure
* Mail is downloaded to user agent and is removed from server (no multiple access)

#### Webmail
* Increasingly popular (cloud based) alternative, runs with SMTP, UI through Web pages.
* Authentication with server is needed.
* Mail submission through posting data on URL.


# 3 -  World Wide Web
> The Web is an architectural framework for accessing distributed linked content. W3C is an organisation devoted to developing the Web, standardizing the protocols etc.  

### 3.1 Architectural Overview
From the users' point of view, the Web consists of a gigantic collection of Web pages. Consisting out of hypertext and linked by hyperlinks. Pages are viewed through browsers.

The browser fetches the Web pages' content through request-response protocols running on TCP -> HTTP (HyperText Transfer Protocol).

The content may simply be a document that is read off a disk, or the result of a DB-query or program execution. If the Web page is generated on demand it is dynamic. In contrast to pages that are static. How the Web keeps track of who does what happens through cookies.

#### Client Side
A browser is a program that can display a Web page and catch mouse events to items on the displayed page. Three questions need to be resolved before a page can be displayed:
1. What is the page called?
2. Where is it located?
3. How can it be accessed?

**Solution** -> Each page is assigned a URL (Uniform Resource Locator).
A URL consists of
* the scheme (protocol) : http:
* the DNS name of the machine on which it is located (f.e. www.google.be)
* the local path (f.e. /index.html)

Browser queries the local DNS for the IPv4 of the name of the page.
Afterwards it can request a TCP connection on port 80 with the IPv4 of the Web server.

++ URL is open-ended: browsers use multiple protocols to get different kind of resources.
-- URL points at a single destination

=> URL is generalised into URI (Uniform Resource Identifiers) which now also consists out of URN (Uniform Resource Locators).
For support of the MIME content-types. Browsers can be extended by third-party plugins or backed by helper applications. (Such as Powerpoint or Adobe Reader)


#### Server Side
Main loop:
1. Accept a TCP connection from the client
2. Get the file from disk according to the requested path
3. Send contents of the file to the client
4. Release the connection

For dynamic content, step 2 can be an exec of a program which returns contents.
IO execution time >> program execution time
Same files may be read repeatedly from disk using OS calls.
	-> Only one request is progressed at a time
	-> large file transfers block other requests

::Improvements::
1. Maintaining a cache: Effective caching requires a large amount of main memory and some extra processing time to maintain the cache structure. BUT trade-off is significant!
2. Multithreaded server: Spawning a processing module per request
3. RAID

#### Cookies
Navigating the Web as we have described requires a series of independent page fetches. Server forgets => not suited for inter-page actions such as a shopping card f.e.

At first glance it may look that servers could track users by observing IP-addresses, but NAT and/or DHCP obstructs this.

To solve the problem cookies are used.
When a client requests a Web page, the server can supply additional information in the form of a cookie. The cookie is a named string (max. 4 KB) that the server associates with the browser. Browsers (may) store cookies for an interval in a directory on disk.

A cookie consists of up to five fields:

1. Domain: tells where the cookie originated from
2. Path: server's directory that identifies which parts of the server's file tree may use the cookie (often /)
3. Content: name-value pair (can be anything)
4. Expires: specifies the TTL
5. Secure: browser may only return cookie using SSL/TLS

A cookie without the Expires field is called a non-persistent cookie, otherwise it is called persistent cookie and is kept until timer runs out.

A browser will check its directory before requesting a page. If a cookie corresponds with the Domain (& Path) it will include the cookie in the request message.

A more controversial use is using cookies to track user-behaviour. It lets Web-operators understand how users navigate their website and advertisers use this information to build up custom fitted ad-profiles.

Web Tracking:

Browser inspects HTML and sees a the link to an image file from www.ads.com, so it sends a request for the image blob. The ad is returned along with a cookie containing a unique UID. The advertiser tracks the user with UID and writes the visited page in the bookkeeping. Later when the user visits another page with an ad from the domain www.ads.com, the request for image blob will contain the cookie previously saved. So the advertiser can update its records and note down the new visited page for that UID. * Even though the user never clicked on the ads, the advertiser can still perform user profiling! *
Even better, the ads can just be images of a single pixel, the browser will still send a request. Such behaviour is often called **spyware**.

A solution for the browser is to only work with cookies from the domain of the first request. Third-party cookies (from links that refer to other domains) are discarded.

### 3.4 HTTP -- HyperText Transfer Protocol
The protocol is used to transport information between Web servers and clients. It is a simple request-response protocol which runs on TCP. Besides browsers, other applications can make use of the same protocol.

#### Connections
The value of using TCP is that neither browsers nor servers have to worry about how to handle long messages, reliability or congestion control. All are provided as a service through the underlying transport layer.

HTTP/1.0: single request and response + release
	-> not efficient: many page objects = many TCP requests to the potentially same domain (setup overhead per request)
HTTP/1.1: persistent connections 
	-> connection reuse 
		-> reduce overhead + more efficient use of slow-start mechanism (congestion control)

Note: Connections are kept open until idle timer goes off or server-load is too high
Another optimisation: request pipelining: multiple subsequent requests (without first waiting for response)

Because all of this, HTTP/1.1 is preferred even when HTTP/1.0 can be parallelised. (Parallel connections tend to compete causing congestion problems)

#### Methods
* HEAD
* GET
* POST
* PUT
* DELETE

#### Message Headers
Request line may be followed by request headers. Responses may also have similar response headers:
* Host header: names the server taken from the URL. (mandatory: IPv4 address may have multiple DNS names)
* Cookie header
* Cache-Control: "no-cache" can tell the server not to cache the page
* ...

#### Caching
Caching requires local storage (which is inexpensive).
To keep cached files up to date, two strategies are used:
		1. Expires header: when cache expires, response fetched from disk and sent to client (otherwise response = immediately)
		2. Conditional GET @ Server: Not Modified (File is OK) or Full Update (File is overwritten from disk) + response

External hierarchical caches, proxy caches are used to further speedup the process. F.e. proxy cache run by ISP per zone.

# 5 -  Content Delivery
Task of distributing content requires different approach than communication.
1. Location does not matter except as is affects performance (or legality)
2. Increased bandwidth usage
3. Delay-sensitivity

Large content providers build their own **CDN (Content Distribution Networks)**:
distributed collection of machines at locations distributed over the Internet.
An alternative architecture is **P2P (Peer-to-Peer)** networks: in it, a collection of computers pooling resources to serve content to each other without separately provided (centralised) servers.


## 5.1 Content and Internet Traffic
Two facts are essential:
1. It changes quickly (needs constant adaptation)
2. Internet traffic is highly skewed, **Zipf’s law** states that given a large sample of pages, the frequency of any page is inversely proportional to its rank in the frequency table. So the most popular page is visited twice as much as the second most popular page. And the same applies to the 40th and the 80th etc.


## 5.4 P2P Networks
Most of the seen protocols HTTP, WWW, TELNET etc are client-server.
Which means each system has a specialised role; either providing (servers) or consuming services (clients).

The alternative is that all nodes provide and consume services. 
All peers are equal. 
There is no dedicated infrastructure.

::The reason for Client-Server adoption:: 
* the emergence of low cost, low capability home computers
* limited dial-up connections
	-> infeasible for users to offer services

P2P can be seen from two perspectives:
1. Application-centric: “A class of applications that take advantage of resources available at the edges of the internet”
2. Network-centric: “Fully decentralised networks with non-hierarchical structures and symmetric communication”

P2P networks can use all of the network capacity to productively distribute content, they are self scaling, decentralised and thus hard to take down.

### Semicentralized Networks
#### Napster
	* One of the earliest P2P applications
	* Large, free music download service
	* Each peer could provide a file-list to share
	* Forced to close by the RIAA lawsuit

![](Application%20layer/5D1099D3-4298-438B-8D45-BE52FABBF679.png)

#### SETI@Home
* Seti@Home was another key application which was developed by UC Berkeley
* Seti@Home allowed users to donate spare CPU cycles to analyse radio signals while running a screen-saver 
* The SETI@Home software downloads small chunks of data from the server (0.35MB), processes the data and send results back to the lab
* **Altruistic:** users of Seti@Home felt good contributing to a scientific project
* Cheap, huge supercomputer
* **BOINC** software supports variety of computations

#### P2P Application Pattern
	1. Provide incentive for users to donate resources
	2. Index resources are available on home PC’s using central servers
	3. Use donated resources to implement a distributed service

::P2P App =/= P2P Network::
* P2P application re-uses edge resources to provide a service
* Centralization limits scalability
* What happens to the service when the server fails


### Unstructured Networks: Gnutella 0.4While application-level networks provide a conceptual routing substrate, each application-level hop may map to multiple network hops. Thus it is critical to minimize message passing.

* Gnutella supports peer-to-peer resource discovery
* Gnutella builds an **unstructured decentralised overlay network** on top of TCP/IP
* Each Gnutella host is required to forward resource discovery and network maintenance messages

== ::Network-Centric vision::

* Gnutella does the same job as Napster without central servers
		* No single point of failure, or attack
		* No need to provision indexing servers
* Each peer is responsible for own files
* Limited anonymity is provided as each user only has the details of its neighbours.

* **PING** is a broadcast message used in peer discovery. A peer that receives a PING and is capable of accepting an incoming connection should respond with a PONG message.
* **PONG** is a response to a PING. It contains the responding peer’s connection details and meta-data such as the amount of data the peer is sharing.
* **QUERY** is a broadcast search message. If a peer receiving a QUERY has matching data, it generates a QUERYHIT search response message.
* **QUERYHIT** is a response to a QUERY. It contains information required to acquire the requested data and meta data (number of shared files, speed of connection etc.)
* **PUSH** is a mechanism to support downloads from firewalled peers.

::PHASE 1: Connection::
1. A newly-arriving peer connects to initial peer by initiating TCP connections to that host. This peer will then broadcast a PING message which floods the network (TTL decrement on hops will prevent survival).
2. Available peers respond with a PONG containing IPv4 and port on which the sending peer is listening for Gnutella connections. This PONG message is forwarded back along the path of the incoming PING.
3. Incoming peers will establish four connections.

::PHASE 2: Search::
1. Peers listen for incoming QUERY messages, and contribute to their broadcast across the network by flooding them to each of their neighbours, while decrementing their TTL value. 
2. If a peer is able to satisfy a QUERY, it responds by sending a QUERYHIT message back along the path of the incoming QUERY. 
3. **QUERYHIT messages contain the network address and port** on which the responding peer is listening for **HTTP file-transfer** connections.

::PHASE 3: Transfer::
1. When a requesting peer receives a QUERYHIT message, it can attempt to initiate a direct download, from the target peer via TCP on port 80. 
2. However, if the target peer is behind a firewall, the requesting peer can instead send a PUSH message to the target, containing details of the file requested. 
3. On receiving a PUSH, the target peer establishes the HTTP connection and pushes the file.

> Problems  
* Broadcast search is not scaleable
* Propagation is limited to the TTL (**search horizon**)
* Gnutella only supports applications with **weak availability requirements**

> Solutions  
* Flat network structure results in high load due to broadcast => hierarchical approach is needed
* Nodes are heterogeneous
* Gnutella 0.6 defines two roles according to a super-node scheme:
	1. **Ultra peers**: Carry more load
	2. **Leaf peers**: Do less work

### Super-node Networks: Gnutella 0.6
Gnutella 0.6 new rules:
* Only ultra-peers participate in peer discovery. Leaf-nodes connect to an ultra-peer.
* When a leaf node connects to an ultra-peer it uploads a complete list of its resources.
* File discovery messages are only sent to leaf-nodes, where they host a matching file.

::Requirements for ultra-peers::
* No firewall
* Sufficient bandwidth
* Sufficient Uptime
* Sufficient RAM and CPU

**But**: still does not scale well for huge networks: flooding still needed, how are we sure the search horizon is big enough?

### Structured Networks: 
Key problem is how to find out which peers have specific content.
Distributed index requires work to keep everything up to date.
To build P2P indexes that perform well: 3 requirements:
1. Each node keeps a small amount of information about other nodes
2. Each node can look up entries in the index
3. Each node can use the index at the same time, even as nodes come and go (performance grows with # nodes)

Four different solutions in the form of **DHT (Distributed Hash Tables)** that map files onto nodes.

#### Chord
The overall index is a listing of all swarms that a user may join to download content.
Key = torrent description
Value = list of peers that comprise the swarm

This index is distributed across the nodes, each node stores a part of the index.
The ::key part of Chord:: is that it navigates the index using ID’s in a virtual space (not IPv4 or names of content). 

The identifiers are m-bit numbers that can be arranged in ascending order into a ring. To turn the node IPv4 address into an ID it is mapped to a 160-bit node identifier through a SHA-1 hash function.
A **key** is also produced by hashing the torrent.

::To start a swarm::
> Node needs to insert (torrent, IPv4) into the index =>   
> asks successor(hash(torrent)) (= Node ID) to store the IPv4 address  

::To find a torrent::
1. Requesting node sends a packet to its successor containing its address and the key it is looking for.
2. The packet is transferred around the ring until the successor of the node identifier (= successor(key)) is located.
3. The recipient checks if it has any information matching the key, and if so sends the value (swarm) to the requesting node by a TCP connection.
4. Node can now start Bittorrent process with the given swarm

-> To speed up the n/2 search, a finger table is used so that every lookup halves the remaining distance: log_2(n).

::Key Benefits::
* Every node is reachable, no search horizon
* Lookup of a known file is trivial (file names need to be UNIQUE for the hash to work)

#### BitTorrent protocol
Gnutella is prone to the **Free Riding problem** whereby only 15% of the peers upload and only 1% serves for 50% of all the files.

_In overview:_
* Gnutella is designed for ::resource discovery::
* Chord is designed for efficient ::object routing::
* BitTorrent is designed for efficient ::content distribution::

_The fundamental questions BitTorrent tries to solve:_

::1.How to discover the location of files to download::
BT leverages on **web infrastructure** for finding the torrents that describe how to download a file.
Each torrent provides connection details of **trackers** that hold the swarm info. Newer versions use a DHT based approach (Kademlia) to store the addresses of peers.

::2. How to optimally replicate content to peers::
Each file is broken into many small **chunks**. Each chunk is identified by an SHA-1 **hash key**. On connection, addresses of the swarm are transferred from the tracker. Peers should both download and upload chunks. Peers with all chunks are **seeders**. Peers share lists of chunks and download the **rarest first**, optimizing availability. 

::3. How to encourage users to upload::
**Tit For Tat principle:** Peers measure download performance. Trading continues only with peers offering high download speed. Over time this matches peers with similar speeds. Free-riders (leechers) are cut off, or “**choked**”.

The **torrent** consists out of:
1. a list of trackers (servers that maintain a list of peers and seeders)
2. a list of chunks defined by its name (160 bit SHA-1)

#### TOR — The Onion Router
* Anonymity is another interesting socio-technical aspect of P2P systems
* Provides cover for censorship
* Provides cover for illicit behaviour 

::Onion Routing::
Messages are encrypted as they travel along each point in a circuit of nodes called **onion routers**.
Each router adds one layer of encryption and routes the message along its way.
Intermediate nodes do not know the origin, destination or content, only the next hop.
Like an onion we have **many layers of privacy**. TOR obtains a list of TOR routers from the directory server.
TOR clients pick random paths through the TOR network terminating at an exit node. All links are encrypted except for the outgoing link from the exit node.

::Threats::
Network cannot prevent a **Sybil attack**, but it is designed to make it difficult.
An adversary can: 
	— generate, modify, delay and delete traffic
	— operate onion routers
	— comprise a part of the network

::Architecture::
* All connections between nodes are TLS secured. 
* Each client node runs Onion Proxy (OP):
	– Offers a **SOCKS (Socket Secure)** interface to applications. 
	– Discovers routers by querying servers 
	– Establishes circuits on the overlay 

* Each router maintains a set of keys that are used to sign descriptors of the router for the directory. 
* Onion routers may act as an exit point, or a forwarding point along a circuit. 
* TOR security is based on public key cryptography.

* Traffic is encapsulated in fixed-size cells, with header containing: 
	– Circuit ID header (circID) to determine which circuit the cell refers to. 
	– Descriptor of cell’s _payload type_.
* _Control cells_ are interpreted by the receiving node. 
* _Relay cells_ carry end-to-end data and an 2nd header containing necessary meta-data. 






