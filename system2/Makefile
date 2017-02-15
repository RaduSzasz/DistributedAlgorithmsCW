.SUFFIXES: .erl .beam

MODULES = system2 process pl app

ERLC = 	erlc -o ebin

ebin/%.beam: %.erl
	$(ERLC) $<

all:	ebin ${MODULES:%=ebin/%.beam}

ebin:
	mkdir ebin

L_ERL = erl -noshell -pa ebin psetcookie pass


SYSTEM = system2
run: 	all
	$(L_ERL) -s $(SYSTEM) start
