# Datalink Layer
* Provides a well-defined software service interface to the physical media. 
* Handles transmission errors. 
* Regulates the flow of data so that slow receivers are not swamped by fast senders. 
* Contains the Medium Access Control sub-layer which we have studied in depth. 

**Unacknowledged connectionless service.**
	– E.g. Ethernet, appropriate for media with inherently low error rates or when collisions are detectable. 
**Acknowledged connectionless service.**
	– E.g. 802.11, appropriate for unreliable channels and when collisions are undetectable. 
**Acknowledged connection-oriented service.**
	– E.g., Telephone or serial line, provides a reliable bit stream. 

## Framing
-> Receivers require a mechanism for to find the start and end of a frame without wasting bandwidth. 

::Byte count::
 Appends a field to the start of the frame giving its length. 
	– What if this is garbled, we could read past the end of our frame. 
	– Note: checksum does not help as we don’t know where the next frame starts.

::Flag Bytes::
-> Special values used to mark the start and end of each frame.
		– Two flag bytes indicate the frame boundary. 
		– As this can occur in the data, we must insert a special escape byte to show that this is not an end-of frame (byte stuffing). 
		– What if the escape byte occurs in the data? 

::Bit Stuffing::
Imagine a flag byte of 01111110. Whenever the sender detects a sequence of five ones, 
It stuffs a zero in to make 011111010. When the receiver sees five consecutive incoming 1 bits followed by a 0, it de-stuffs the 0 and stores the original sequence in memory. 
![](Datalink%20Layer/page80image1680%202.png) 

### Security issues
* One of the key security issues with wireless media is overhearing. 
* This is the same problem as promiscuous mode in classic Ethernet. 
* In a wireless scenario we cannot use switches to mitigate the problem!

## Sliding Windows

* Sliding window protocols tackle error and flow control. 
* Senders and receivers each maintain a window of messages for which no ACKs have been received. 
* The **window** is a sequence of message IDs, with a lower and upper bound. 
	– ACKs above or below the bounds are discarded.
	– When ACK is received, the low and high bounds advanced by 1, allowing 1 more ACK 
* Sliding window protocols may used a fixed window size, or adapt window size. 


### Stop-and-Wait
The simple approach is window of fixed size 1, or stop and wait.
	– Send one frame and wait until it is acknowledged. 
	– Note, this will be slow for large networks with a long Round Trip Time (RTT). 
	– A one-bit sequence number 
* Sender keeps last frame until it receives ACK. 
* Both data and ACKs are numbered alternatively 0 and 1. 
* Sender stores (S) with number of the last frame sent. 
* Receiver stores (R) with number of next frame expected. 
* Sender starts timer on frame send. If an ACK not received before expiry, sender assumes loss or damage and retransmits. 
* Receiver sends ACK if the frame is intact.

![](Datalink%20Layer/page7image2424%202.png) 
![](Datalink%20Layer/page8image3704%202.png) 
![](Datalink%20Layer/page9image3864%202.png) 

::Piggyback optimization::
![](Datalink%20Layer/page11image2960%202.png) 
 
::Summary::
* The simplest sliding window protocol to implement. 
* Uses very few resources (i.e. buffer space is 1 on sender, 0 on receiver). 
* However, very inefficient, especially if we have high RTT compared to speed
* Suffers from a synchronization flaw: if both sides simultaneously send an init packet?
	-> Wastes lots of bandwidth
	-> Can also occur on premature timeouts 


### Go-Back-N
* Frames have a larger range of sequence numbers, that wrap around. 
* We send W frames before requiring an ACK. 
* Keep a copy of the frames until ACKs arrive. 
* This requires extended data structures and more variables than stop-and-wait. 
* Size of the window is < **2m-1** where **m** is the number of bits for the sequence number. 
* The window **slides** to include new unsent frames as ACKs are received

![](Datalink%20Layer/page14image3792%202.png) 

::Acknowledgment::
* Sender starts a **per-frame timer**. 
* Receiver sends ACK only on next expected frame arriving safely. All damaged or out of order frames are discarded. 
* If timer expires on a frame, all frames in the window are resent 
* The receiver does not have to acknowledge each frame received, it can send a cumulative ACK for several frames.

![](Datalink%20Layer/page19image1248%202.png) 

Case 1: ACK arrives before expiration of timer
		* No frames will be retransmitted. We know the receiver only sends ACKs sequentially. 
		* I.E. ACK1, ACK2, and ACK3 are lost, ACK4 covers them if it arrives before the timer expires. 
Case 2: ACK arrives after the timer expires
		* All N unacknowledged frames are 

::Summary::
* Go back N significantly improves performance by parallelizing the sending of packets. 
* This will improve performance most where RTT is long and bandwidth is high. 
* Frames are discarded for the rest of a timeout interval
	-> Wastes bandwidth when error rate is high 
	-> Can be solved with a NAK: receiver sends a NAK to stimulate retransmission
	-> **Cumulative acknowledgement**


### Selective Repeat
* Go-Back-N is bandwidth inefficient and slows down the transmission due to the repeated transmission of received packets. 

* Selective Repeat **eliminates wasted retransmission** of received packets.
This is bandwidth efficient, but:
	-> Requires **buffers at both sender and receiver**. 
  	-> Requires new variables and book-keeping.
	=> Trade-off between efficient use of bandwidth and buffer space  
* NAK is used + cumulative ACKs

![](Datalink%20Layer/page24image1248%202.png) 

**Note**: the use of a buffer on the receiver means that it can receive packets out of order 
To counter overlap (+ needed to be robust): Max. Window Size = Max. Sequence Nr. / 2
Extra timer: ACK_timeout: allows for unidirectional traffic (when piggybacking is not possible)
If an ACK is lost then the frame timer will time out and retransmits the frame. 
-> This causes the frame to be **individually** retransmitted (not the whole window)

::Summary::
* This is the **most general**of our schemes. 
* It provides the **best performance** by using parallel transmission and eliminating resending of valid frames. 
* However, this **requires buffers and book-keeping**on both senders and receivers. 
	-> If buffer space is scarcer than bandwidth, opt for Go-Back-N.




