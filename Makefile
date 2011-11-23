REBAR:=./rebar

.PHONY: all test clean

all:
	$(REBAR) compile

test: all
	@mkdir -p .eunit
	$(REBAR) eunit skip_deps=true

clean:
	$(REBAR) clean
	@rm -rf ebin .eunit TEST*
