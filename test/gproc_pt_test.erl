-module(gproc_pt_test).

-include_lib("eunit/include/eunit.hrl").

-compile({parse_transform, gproc_pt}).

reg_and_send_test_() ->
    {setup,
        fun() -> meck:new(gproc) end,
        fun(_) -> meck:unload(gproc) end,
        [{"gproc", fun gproc/0}]
    }.

gproc() ->
    meck:expect(gproc, lookup_local_name, fun (_) -> self() end),

    Msg = random:uniform(1000),
    <<"test">> ! Msg,

    Echo = receive
        V -> V
    end,

    ?assertEqual(Echo, Msg).
