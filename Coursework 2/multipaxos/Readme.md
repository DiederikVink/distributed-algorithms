%%% Diederik Vink (dav114) and Aditya Rajagopal (ar4414)

Information for project:

To run the code, please just type, "make run1", "make run2" or "make run3". This will call the makefile and run everything according to the specifications.
"make run1": the standard setup provided in the coursework.
Setup 1: 5 servers, 3 clients, 10 accounts
"make run2": this setup tested to see how the system responded to having more clients and more accounts than servers, as this seemed to represents the real world in a more accurate way.
Setup 2: 5 servers, 10 clients, 10 accounts
"make run3": this setup was similar to run2, except now we drastically increased the scale of the system to ensure the system still worked with a far large amount of processes running.
Setup 3: 50 servers, 100 clients, 100 accounts

System 2 shows some minor inconsistencies. Ther transactions numbers are still high, but there are very small inconsitencies between the replicas as they were missing a few transactions. This shows that given enough runtime every replica would be consistent (as shown by setup1). But due to the size of the message cues and cutting the process time short results in minor inconsistencies.

System 3 shows that with this many clients, accounts and servers, the runtime provided is not adequate to properly process everything across all servers. A drastic drop of the number of transactions completed and the difference between each database is a clear indicator that the runtime is inadequate. 

We made some minor changes to the files you provided. We added a feature that ensure all processes were killed well after the database was done with its printing messages.
