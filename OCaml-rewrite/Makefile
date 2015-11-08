COMPILER = ocamlopt
DEPENDENCIES = str.cmxa

all: elottery

elottery: evilLottery.ml
	$(COMPILER) $(DEPENDENCIES) evilLottery.ml -o elottery

clean:
	rm -f elottery *.o *.cmi *.cmx *.cmo

