ptrans - a bunch of handy parse transforms
==========================================

<h2>1. pl2rec - proplist to record converter</h2>

A lot of people prefer to pass gen_server options as a proplist and store them in a state being a record. So, they generally write something like that:

```erlang

-record(state, {
    port = 8080,
    ip = {127,0,0,1},
    name
}).

...

init(Options) ->
    State = parse_options(Options, #state{}),
    {ok, State}.

...

parse_options([], State) -> State;
parse_options([{port, Port} | T], State) ->
    parse_options(T, State#state{port = Port});
parse_options([{ip, IP} | T], State) ->
    parse_options(T, State#state{ip = IP});
parse_options([{name, Name} | T], State) ->
    parse_options(T, State#state{name = Name}).

```

Annoying, isn't it?

But instead, you could just write:

```erlang
-compile({parse_transform, pl2rec}).

-record(state, {
    port = 8080,
    ip = {127,0,0,1},
    name
}).

init(Options) ->
    State = parse_options(Options, #state{}),
    {ok, State}.
```

You can even parse multiple records this way. They may have same field names, still the parsing mechanism will work properly.

If you have some unexisting properties in your proplists, they will be just silently ignored during the parsing process.

Basic type-check guards will be added soon (they'll check if a given record has type definitions and insert the proper guards to the generated parse_options function.
