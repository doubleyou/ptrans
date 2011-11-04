-module(pl2rec_test).
-compile({parse_transform, pl2rec}).

-include_lib("eunit/include/eunit.hrl").

-record(state, {
    field_a :: atom(),
    bar :: integer()
}).

-record(myrec, {
    foo = [],
    bar = bar
}).

parse_state(Options) ->
    parse_options(Options, #state{}).

parse_myrec(Options) ->
    parse_options(Options, #myrec{}).

basic_test() ->
    ?assertEqual(
        #state{field_a=foo,bar=11},
        parse_state([{field_a, foo},{bar, 11}])
    ),
    ?assertEqual(
        #myrec{foo=[],bar=notbar},
        parse_myrec([{bar, notbar},{test, skip}])
    ).
