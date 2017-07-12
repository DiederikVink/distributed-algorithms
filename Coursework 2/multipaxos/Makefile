#Diederik Vink (dav114) Aditya Rajagopal (ar4414)

.SUFFIXES: .erl .beam

MODULES  = commander scout leader replica acceptor client database server system
#MODULES = test
#HOSTS    = 3
#HOSTSm1  = 2

# BUILD =======================================================

ERLC	= erlc -o ebin

ebin/%.beam: %.erl
	$(ERLC) $<

all:	ebin ${MODULES:%=ebin/%.beam} 

ebin:	
	mkdir ebin

debug:
	erl -s crashdump_viewer start 

.PHONY: clean
clean:
	rm -f ebin/* erl_crash.dump

# LOCAL RUN ===================================================

SYSTEM    = system
#SYSTEM	   = test
#L_SYSTEM  = system2

#L_HOST    = localhost.localdomain
L_ERL     = erl -noshell -pa ebin -setcookie pass
#L_ERLNODE = node

run:	all
	$(L_ERL) -s $(SYSTEM) start 

# to run manually, run make node1 and make node2 in separate windows
# then make man2, remove manually
#node1:	all
#	$(L_ERL) -name $(L_ERLNODE)1@$(L_HOST)
#
#node2:	all
#	$(L_ERL) -name $(L_ERLNODE)2@$(L_HOST)
#
#man2:	all
#	$(L_ERL) -name $(L_ERLNODE)3@$(L_HOST) -s $(L_SYSTEM) start 
#
## to run and clean up automatically
#run2:	all
#	for k in $$(seq 1 1 $(HOSTSm1)); do \
#	  ( $(L_ERL) -name $(L_ERLNODE)$$k@$(L_HOST) & ) ; \
#	done
#	sleep 1
#	$(L_ERL) -name $(L_ERLNODE)$(HOSTS)@$(L_HOST) -s $(L_SYSTEM) start 


