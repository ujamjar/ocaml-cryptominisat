PKG = -package cryptominisat -linkpkg
BYTE = ocamlfind c
NATIVE = ocamlfind opt

all: test.byte test_low.byte test.native test_low.native

test.byte: test.ml
	$(BYTE) $(PKG) -o $@ $<

test_low.byte: test_low.ml
	$(BYTE) $(PKG) -o $@ $<

test.native: test.ml
	$(NATIVE) $(PKG) -o $@ $<

test_low.native: test_low.ml
	$(NATIVE) $(PKG) -o $@ $<

clean:
	-rm *.o *.cmo *.cmi *.cmx *.byte *.native *~

