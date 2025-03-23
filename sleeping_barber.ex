# team: Robert Sullivan and Cole Vita
defmodule WaitingRoom do
  # initializes the waiting room (empty)
  def start do
    spawn(fn -> loop([]) end)
  end

  def loop(customers) do
    receive do
      # if receive a request to add to wait list, check if wait is full
      {:add, customer, reply_to} -> # adding reply_to to add call here for synchronous behavior
        if length(customers) < 6 do
          IO.puts("#{customer} has entered the waiting room")
          new_customers = customers ++ [customer] # if not, update customers 
          send(reply_to, {:added})
          loop(new_customers) # updates state to include added customer
        else
          IO.puts("#{customer} leaves - no space in waiting room.")
          send(reply_to, {:full})
          loop(customers) # no update to list, continue
        end

      # queue behavior is all found here
      {:remove, reply_to} ->
        case customers do
          [first | rest] -> # extract first customer from list (customer is a string here)
            send(reply_to, {:removed, first}) # both reply_to are for synchronous behavior
            loop(rest) # updates "state" to exclude the removed customer (just rest of waiting list now)
          [] ->
            send(reply_to, {:empty})
            loop(customers)
        end
    end
  end

  # add a customer by interacting with WaitingRoom loop
  # this will be called outside of module so needs to be public
  def add(room_pid, customer) do
    send(room_pid, {:add, customer, self()})
    receive do
      msg -> msg # callback here ensures synchronous behavior
    after 5000 ->
      {:error, :timeout} # error tracing
    end
  end

  # removes customer by interacting with WaitingRoom loop 
  def remove(room_pid) do
    send(room_pid, {:remove, self()})
    receive do
      msg -> msg # callback here ensures synchronous behavior and returns either successully removed (:removed) or not (:empty)
    after 5000 ->
      {:error, :timeout} # error tracing
    end
  end
end

defmodule Receptionist do
  # receptionist represents the main loop for the barbershop (and overall logic for controlling customer flow)
  # here, state is a map which includes the waiting room process, whether or not barber is busy, and the barber's process id
  # as follows in the rest of the loops, we use recursion to update the state!
  def start do
    # initialize waiting room here
    waiting_room = WaitingRoom.start()
    spawn(fn -> loop(%{barber: :idle, barber_pid: nil, waiting_room: waiting_room}) end)
  end

  def loop(state) do
    receive do
      {:customer_arrives, customer} ->
        # call waiting room api to see if we can add customer 
        WaitingRoom.add(state.waiting_room, customer) # synchronous call ensures that waiting room is fully processed before next line is processed
        state = if state.barber == :idle do
          handle_next_customer(state) # if barber is free, begin haircut process
        else
          state
        end
        loop(state)

      # update barber state to idle as haircut is done
      {:barber_done} ->
        state = %{state | barber: :idle}
        state = handle_next_customer(state)
        loop(state)

      # first step of registering the barber pid for all communication
      {:register_barber, barber_pid} ->
        state = %{state | barber_pid: barber_pid}
        loop(state)
    end
  end

  # begins haircut process
  def handle_next_customer(%{waiting_room: room_pid, barber_pid: barber_pid} = state) do
    # use waiting room api to remove customer (queue logic handled there)
    case WaitingRoom.remove(room_pid) do
      {:removed, customer} ->
        IO.puts("#{customer} goes to the barber")
        send(barber_pid, {:cut_hair, customer})
        %{state | barber: :busy}
      {:empty} ->
        state
      _ ->
        state # for any extraneous messages received
    end
  end

  def handle_next_customer(state), do: state
  def handle_barber_done(state), do: state
end

defmodule Barber do
  # starts the barber process and registers its PID with the shop.
  def start(shop) do
    pid = spawn(fn -> loop(shop) end)
    send(shop, {:register_barber, pid})
    pid
  end

  def loop(shop) do
    receive do
      # cut hair for random amount of time (~6 seconds, uniform distribution)
      {:cut_hair, customer} ->
        IO.puts("Cutting hair for #{customer}")
        :timer.sleep(:rand.uniform(6000))
        IO.puts("#{customer} finished up with the haircut")
        send(shop, {:barber_done})
        loop(shop)
    end
  end
end

defmodule Customer do
  # each customer is their own unique process
  # for documenting, maintain string with customer id (not pid) we generate and increment
  def start(shop, id) do
    spawn(fn -> enter_shop(shop, "Customer #{id}") end)
  end
  
  # notify receptionist of customer's arrival 
  def enter_shop(shop, customer) do
    send(shop, {:customer_arrives, customer})
  end
end

defmodule CustomerSpawner do
  def start(shop) do
    spawn(fn -> loop(shop, 1) end)
  end

  def loop(shop, id) do
    # generate new customer randomly (~ 4 seconds, uniform distribution)
    :timer.sleep(:rand.uniform(4000))
    Customer.start(shop, id)
    loop(shop, id + 1)
  end
end

# begin
shop = Receptionist.start()
Barber.start(shop)
CustomerSpawner.start(shop)

# sleeping barber will run infinity
# to abort, press control + c then a
Process.sleep(:infinity)