# Assignment 5: Elixir Programming

## Team
Robert Sullivan and Cole Vita

## Design Rationale
Our implementation of the Sleeping Barber problem uses concurrent processes to model the Customer, Barber, Waiting Room, Receptionist.

The Receptionist contains most of the logic of the store and recursively updates its state. The state is a containing the waiting room process, barber pid for communication, and whether or not the barber is ready for new customers.

Notably, our waiting room process ensures that a maximum of 6 customers are waiting at any time. Otherwise, the customer leaves. This is done through WaitingRoom's function WaitingRoom.add.

When "popping" a customer from the waiting room, we extract the first customer and update the customers still waiting to be the rest of the list.

The haircut logic can be found in handle_next_customer. handle_next_customer calls WaitingRoom.remove which returns either {:empty} or {:removed, first} where first represents the popped customer. Then handle_next_customer logs that the customer has been seated by the barber and instructs the barber to cut the hair, a randomly timed process with a uniform distribution ~6 seconds.

Anytime either the (1) barber finishes a haircut or (2) a new customer enters and the barber is idle, the receptionist calls handle_next_customer which begins the haircut process.

An important aspect of the waiting room design is ensuring that each of the add and remove requests are processed synchronously (or wait for the return message). These are crucial because it ensures that each call is completed before the program moves on (forces the call to be synchronous). Also, as documented above, remove needs to return whether or not there was a customer to pop.

Our design was set up so that when each customer is spawned, it uses the current version of the Customer module code as with the Barber loop code. Thus, if the program is running processes already, their loop continues to use the previous version whereas new processes spawned can use the more recent version (successfully demonstrating hot swapping)

The program will run forever and requires control c then a to abort.

## Project Description
In this assignment we will write an Elixir program to solve the Sleeping Barber problem. Find this problem in an earlier class PPT.

I want to make some aspects of your solution the same for consistency. There are many ways to design a solution, so we will use this basic outline:
- Let's make each new customer a process.
- Let's make a process for the waiting room.  
- Let's add a receptionist process to the basic problem we defined earlier
  - have this receptionist greet each arriving customer
  - If there is room to wait, the receptionist sends the customer to the waiting room; if no room, the customer is turned away.
- Let's make the barber a process.  
  
This basic structure gives a lot of places that behavior can be parameterized or varied. The barber can cut hair in fixed time, long or short, or in random amounts of time. The barber can work a while and take a break for a while. The barber might get 2 chairs at some point, and handle 2 customer at once (like one has washed hair drying while another gets a cut). Customers can wait "forever" until served, or made to wait some amount of time and leave if not served. The wait room process can control how customers are handled... FIFO queue, priority some way, random, etc. All these different things can easily be written into the behavior of processes if we have the system architected that way.

I also want you to make parts of the program hot swappable. Do this for the main barber loop. In this way we can alter some of the barber characteristics without ending the execution of the program. Also make the spawning of a customer be a hot-swap... so that every time a customer is made we make the most recent version of the customer process code. The loop in a customer process can stay non-hot-swapped... when a customer is made, its behavior stays the same for its lifetime. But when a new customer is made we check for the latest version.

Feel free to make any other aspects of the program hot swappable as you see fit.

Some initial parameters/behaviors:

- The waiting room has 6 waiting chairs.  
- The barber has one cutting chair.
- Customers arrive at the shop at random times.
- The barber takes a random time to complete each haircut.
- The wait room is a FIFO queue
- customers who wait stay until they are served
- the simulation operates "forever" generating new customers

## Sources
https://hexdocs.pm/elixir/1.12/GenServer.html
https://samuelmullen.com/articles/elixir-processes-send-and-receive
https://stackoverflow.com/questions/35735762/whats-the-difference-between-def-and-defp
https://hexdocs.pm/elixir/processes.html 
https://hexdocs.pm/elixir/case-cond-and-if.html
https://elixirforum.com/t/purpose-of-process-sleep-infinity/4014
https://stackoverflow.com/questions/38778054/how-to-generate-a-random-number-in-elixir
https://hexdocs.pm/elixir/modules-and-functions.html