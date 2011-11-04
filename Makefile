REBAR:=./rebar

.PHONY: all test clean

all:
	$(REBAR) compile

test: all
	@mkdir -p .eunit
	$(REBAR) eunit

clean:
	$(REBAR) clean
	@rm -rf ebin .eunit TEST*
