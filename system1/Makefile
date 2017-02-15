.SUFFIXES: .erl .beam

MODULES = system1

ERLC = 	erlc -o ebin

ebin/%.beam: %.erl
	$(ERLC) $<

all:	ebin ${MODULES:%=ebin/%.beam}

ebin:
	mkdir ebin

L_ERL = erl -noshell -pa ebin psetcookie pass


SYSTEM = system1
run1: 	all
	$(L_ERL) -s $(SYSTEM) start
