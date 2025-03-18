# Assignment 5: Elixir Programming

## Team
Robert Sullivan and Cole Vita

## Design Rationale
Write a README file giving your design rationale. What decisions did you make to get it running? Explain your overall design.

## Project Description
In this assignment we will write an Elixir program to solve the Sleeping Barber problem. Find this problem in an earlier class PPT.

I want to make some aspects of your solution the same for consistency. There are many ways to design a solution, so we will use this basic outline:
- Let's make each new customer a process.
- Let's make a process for the waiting room.  
- Let's add a receptionist process to the basic problem we defined earlier
  - have this receptionist greet each arriving customer
  - If there is room to wait, the receptionist sends the customer 
  - to the waiting room; if no room, the customer is turned away.
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
