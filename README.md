[![Hex version badge](https://img.shields.io/hexpm/v/what_the_fuck_is_the_monad.svg)](https://hex.pm/packages/what-the-fuck-is-the-monad)
[![License badge](https://img.shields.io/hexpm/l/what_the_fuck_is_the_monad.svg)](https://github.com/rudebono/what-the-fuck-is-the-monad/blob/main/LICENSE)

# WHAT THE FUCK IS THE MONAD
ELIXIR MACROS FOR FUNCTION DEFINITIONS WITH ERROR HANDLING

## WHY
I'VE BEEN MAKING PRODUCTS USING ELIXIR AT A BLOCKCHAIN COMPANY IN REPUBLIC OF KOREA FOR ABOUT THREE YEARS.

MY POSITION WAS TO MANAGE THE CLIENT'S CRYPTO ASSETS.

I IMPLEMENTED THE BLOCKCHAIN PROTOCOL AND CREATED A CLIENT TO CONNECT THIRD-PARTY APPS (BLOCKCHAIN NODES) AND OUR DATABASE.

I WAS ABLE TO SUCCESSFULLY COMPLETE THE PRODUCT THANKS TO THE MERITS OF ERLANG AND ELIXIR, AS YOU ALL KNOW.

HOWEVER, AN ERROR OCCURRED WHILE OPERATING THE ACTUAL SERVICE, AND I HAD A LOT OF TROUBLE IN HANDLING THIS ERROR.

THESE ERRORS DID NOT OCCUR FROM ELIXIR PURE FUNCTIONS, BUT FROM THIRD-PARTY APPS OR DATABASES. (SIDE-EFFECT ERROR)

ALL THE ELIXIR DEVELOPERS IN OUR COMPANY SHARED AN ACTIVE DISCUSSION ON THIS ISSUE, AND AS A RESULT, WE DECIDED TO USE MONAD ([`:witchcraft`](https://hex.pm/packages/witchcraft)) TO HANDLE THE ERROR.

AS WE USED THE MONAD, MANY PROBLEMS OCCURRED.

THE LEARNING CURVE WAS SO EXPENSIVE THAT THE MANY DEVELOPERS WERE CONFUSED.

HOWEVER, SADLY... AS THE COMPANY'S PROJECT WAS CANCELLED, THERE WAS NO FURTHER COMMENT ON THE ISSUE OF HANDLING ERROR.

BUT I'VE BEEN THINKING ABOUT HANDLING ERROR EVER SINCE, AND WONDERING IF MONAD IS SURELY THE BEST WAY TO HANDLE ERRORS IN ELIXIR.

I STARTED THIS PROJECT FOR FUN AT FIRST, BUT WHEN I COMPLETED THIS PROJECT AND APPLIED IT TO OTHER PROJECTS THEN I WAS ABLE TO HANDLE ALL THE ERRORS.

YOU MAY THINK THAT THIS PROJECT IS BULLSHIT BUT GIVE IT A TRY.

YOU SIMPLY WILL REALIZE THAT ALL THE ERRORS CAN BE HANDLED BY THE SIMPLE MACROS.


## INSTALLATION
THE PACKAGE CAN BE INSTALLED BY ADDING `:what_the_fuck_is_the_monad` TO YOUR LIST OF DEPENDENCIES IN `mix.exs`:
```elixir
def deps do
  [{:what_the_fuck_is_the_monad, "~> 0.2.0"}]
end
```

## USAGE
```elixir
defmodule MyApp do
  # DEFINE MACRO BY `use WhatTheFuckIsTheMonad`
  use WhatTheFuckIsTheMonad

  # DEFINE PUBLIC FUCTION BY `wtfitm`
  wtfitm my_pulbic_function() do
    # HAPPY PATTERN MATCHING SIDE-EFFECT CODE HERE
  else
    # UNHAPPY NO SIDE-EFFECT CODE HERE
  end

  # DEFINE PRIVATE FUNCTION BY `wtfitmp`
  wtfitmp my_private_function() do
    # HAPPY PATTERN MATCHING SIDE-EFFECT CODE HERE
  else
    # UNHAPPY NO SIDE-EFFECT CODE HERE
  end
end
```

## EXAMPLE
SIMPLE WEBSOCKET CLIENT USING [`:phoenix_pubsub`](https://hex.pm/packages/phoenix_pubsub) AND [`:gen_server`](https://hexdocs.pm/elixir/GenServer.html) + [`:gun`](https://hex.pm/packages/gun)
```elixir
defmodule MyApp.PubSub do
  use(WhatTheFuckIsTheMonad)
  alias(Phoenix.PubSub)
  alias(Phoenix.PubSub.PG2)

  wtfitm child_spec() do
    [
      {:name, __MODULE__},
      {:adapter, PG2},
      {:pool_size, System.schedulers_online()}
    ]
    |> PubSub.child_spec()
  else
    {:error, nil}
  end

  wtfitm node_name() do
    {:ok, PubSub.node_name(__MODULE__)}
  else
    {:error, nil}
  end

  wtfitm subscribe(channel) do
    :ok = PubSub.subscribe(__MODULE__, channel)
    {:ok, channel}
  else
    {:error, channel}
  end

  wtfitm unsubscribe(channel) do
    :ok = PubSub.unsubscribe(__MODULE__, channel)
    {:ok, channel}
  else
    {:error, channel}
  end

  wtfitm broadcast(channel, message) do
    :ok = PubSub.broadcast(__MODULE__, channel, {:broadcast, channel, message})
    {:ok, {channel, message}}
  else
    {:error, {channel, message}}
  end

  wtfitm broadcast_from(channel, message) do
    :ok = PubSub.broadcast_from(__MODULE__, self(), channel, {:broadcast, channel, message})
    {:ok, {channel, message}}
  else
    {:error, {channel, message}}
  end
end
```

```elixir
defmodule MyApp.WebSocket do
  use(WhatTheFuckIsTheMonad)
  use(GenServer)

  alias(MyApp.PubSub)

  @channel Atom.to_string(__MODULE__)
  @host Application.compile_env(:my_app, :third_party_host)
  @port Application.compile_env(:my_app, :third_party_port)
  @path Application.compile_env(:my_app, :third_party_path)
  @cert Application.compile_env(:my_app, :third_party_cert)
  @key Application.compile_env(:my_app, :third_party_key)
  @timeout 5_000

  wtfitm start_link(_arguments) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, nil, [{:name, __MODULE__}])
  else
    {:error, nil}
  end

  @impl true
  wtfitm init(_arguments) do
    {:ok, nil, {:continue, :connect}}
  else
    {:stop, nil}
  end

  @impl true
  wtfitm terminate(reason, gun_pid) do
    _pid = spawn(fn -> {:ok, {@channel, :terminate}} = PubSub.broadcast(@channel, :terminate) end)
    _pid = spawn(fn -> :ok = :gun.close(gun_pid) end)
    {:ok, reason}
  else
    {:error, reason}
  end

  # handle_continue/2
  @impl true
  wtfitm handle_continue(:connect, gun_pid) do
    option = %{protocols: [:http], transport: :tls, tls_opts: [{:cert, @cert}, {:key, @key}]}
    {:ok, gun_pid} = :gun.open(@host, @port, option)
    {:ok, :http} = :gun.await_up(gun_pid, @timeout)
    stream_ref = :gun.ws_upgrade(gun_pid, @path)
    {:ok, {["websocket"], _header}} = await_upgrade(gun_pid, stream_ref)
    {:ok, {_channel, _message}} = PubSub.broadcast_from(@channel, :connect)
    {:noreply, gun_pid}
  else
    {:stop, :connect, gun_pid}
  end

  # handle_info/2
  @impl true
  wtfitm handle_info(:ping, gun_pid) do
    {:ok, {@channel, :pong}} = PubSub.broadcast_from(@channel, :pong)
    {:noreply, gun_pid}
  else
    {:stop, :ping, gun_pid}
  end

  @impl true
  wtfitm handle_info({:gun_ws, gun_pid, _stream_ref, {:text, frame}}, gun_pid) do
    {:ok, message} = Jason.decode(frame)
    {:ok, {@channel, ^message}} = PubSub.broadcast_from(@channel, message)
    {:noreply, gun_pid}
  else
    {:stop, frame, gun_pid}
  end

  @impl true
  wtfitm handle_info(frame, gun_pid) do
    {:stop, frame, gun_pid}
  else
    {:stop, frame, gun_pid}
  end

  # handle_call/3
  @impl true
  wtfitm handle_call(:ping, _from, gun_pid) do
    {:reply, :pong, gun_pid}
  else
    {:stop, :ping, gun_pid}
  end

  @impl true
  wtfitm handle_call({:ws_send, frame}, _from, gun_pid) do
    {:reply, :gun.ws_send(gun_pid, frame), gun_pid}
  else
    {:stop, {:ws_send, frame}, gun_pid}
  end

  @impl true
  wtfitm handle_call(frame, _from, gun_pid) do
    {:stop, frame, gun_pid}
  else
    {:stop, frame, gun_pid}
  end

  # handle_cast/2
  @impl true
  wtfitm handle_cast(frame, gun_pid) do
    {:stop, frame, gun_pid}
  else
    {:stop, frame, gun_pid}
  end

  # Public
  wtfitm channel() do
    {:ok, @channel}
  else
    {:error, nil}
  end

  wtfitm ping(timeout \\ @timeout) do
    :pong = GenServer.call(__MODULE__, :ping, timeout)
    {:ok, :pong}
  else
    {:error, timeout}
  end

  wtfitm ws_send(frame, timeout \\ @timeout) do
    :ok = GenServer.call(__MODULE__, {:ws_send, frame}, timeout)
    {:ok, frame}
  else
    {:error, {frame, timeout}}
  end

  # Private
  wtfitmp await_upgrade(gun_pid, stream_ref) do
    receive do
      {:gun_upgrade, ^gun_pid, ^stream_ref, protocols, headers} ->
        {:ok, {protocols, headers}}
    after
      @timeout ->
        {:error, :timeout}
    end
  else
    {:error, nil}
  end
end
```