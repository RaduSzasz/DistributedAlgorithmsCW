.SUFFIXES: .erl .beam

MODULES = system5 process pl app beb

ERLC = 	erlc -o ebin

ebin/%.beam: %.erl
	$(ERLC) $<

all:	ebin ${MODULES:%=ebin/%.beam}

ebin:
	mkdir ebin

L_ERL = erl -noshell -pa ebin psetcookie pass


SYSTEM = system5
run: 	all
	$(L_ERL) -s $(SYSTEM) start
