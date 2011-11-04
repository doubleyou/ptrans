-module(pl2rec).
-export([parse_transform/2]).

parse_transform(Forms, _Options) ->
    Records = parse_records(Forms),
    case Records of
        [] ->
            Forms;
        _ ->
            {eof, Line} = lists:keyfind(eof, 1, Forms),
            ParseFunc = parsefunc_body(Records, Line),
            lists:takewhile(fun ({eof, _}) -> false; (_) -> true end, Forms) ++
                [ParseFunc] ++ [{eof, Line + parsefunc_lines(Records) + 1}]
    end.

parse_records(Forms) ->
    RawRecords = lists:filter(
        fun ({attribute, _, record, _}) -> true; (_) -> false end,
        Forms
    ),
    [{RecName, parse_record_fields(RecRawFields)}
        || {attribute, _, record, {RecName, RecRawFields}} <- RawRecords].

parse_record_fields(RawFields) ->
    lists:map(
        fun ({record_field, _, {_, _, Field}}) -> Field;
            ({record_field, _, {_, _, Field}, _}) -> Field
        end,
        RawFields
    ).

parsefunc_body(Records, Line) ->
    {Clauses, LastLine} = lists:foldl(
        fun ({Record, Fields}, {Cs, L}) ->
            {
                parsefunc_record_clauses(Record, Fields, L) ++ Cs,
                L+2*length(Fields)
            }
        end,
        {[], Line+1},
        Records
    ),
    {function,Line,parse_options,2,
        [parsefunc_tail(Line) | lists:reverse(Clauses)] ++
            [parsefunc_skip(LastLine + 1)]
    }.

parsefunc_tail(Line) ->
    {clause,Line,[{nil,Line},{var,Line,'R'}],[],[{var,Line,'R'}]}.

parsefunc_record_clauses(Record, Fields, Line) ->
    {Clauses, _} = lists:foldl(
        fun(Field, {Cs, L}) ->
            {[parsefunc_clause(Record, Field, L)| Cs], L+2}
        end,
        {[], Line},
        Fields
    ),
    lists:reverse(Clauses).

parsefunc_clause(Record, Field, Line) ->
    {clause,Line,
             [{cons,Line,
                  {tuple,Line,[{atom,10,Field},{var,10,'V'}]},
                  {var,Line,'T'}},
              {match,Line,{var,Line,'R'},{record,Line,Record,[]}}],
             [],
             [{call,Line+1,
                  {atom,Line+1,parse_options},
                  [{var,Line+1,'T'},
                   {record,Line+1,
                       {var,Line+1,'R'},
                       Record,
                       [{record_field,Line+1,
                            {atom,Line+1,Field},
                            {var,Line+1,'V'}}]}]}]}.

parsefunc_skip(Line) ->
    {clause,Line,
               [{cons,Line,{var,Line,'_'},{var,Line,'T'}},{var,Line,'R'}],
               [],
               [{call,Line+1,
                      {atom,Line+1,parse_options},
                      [{var,Line+1,'T'},{var,Line+1,'R'}]}]}.

parsefunc_lines(Records) ->
    lists:sum([length(Fields) || {_Rec, Fields} <- Records]) + 3.
