all: libs

CMS=cryptominisat

libs: $(CMS).cmxa $(CMS).cma 

$(CMS)_stubs.o: src/$(CMS)_stubs.c
	ocamlc -ccopt -x -ccopt c++ src/$(CMS)_stubs.c

src/$(CMS).cmi: src/$(CMS).mli
	ocamlfind c -package ctypes.foreign -c src/$(CMS).mli

src/$(CMS).cmo: src/$(CMS).cmi src/$(CMS).ml
	ocamlfind c -package ctypes.foreign -c -I src src/$(CMS).ml

src/$(CMS).cmx: src/$(CMS).cmi src/$(CMS).ml
	ocamlfind opt -package ctypes.foreign -I src -c src/$(CMS).ml

$(CMS).cma: src/$(CMS).cmo $(CMS)_stubs.o
	ocamlmklib -o $(CMS) $(CMS)_stubs.o -lcryptominisat4 src/$(CMS).cmo

$(CMS).cmxa: src/$(CMS).cmx $(CMS)_stubs.o
	ocamlmklib -o $(CMS) -I src \
	  -cclib -lstdc++ -cclib -rdynamic \
	  -lcryptominisat4 $(CMS).cmx

install:
	ocamlfind install $(CMS) META \
		src/$(CMS).cmi $(CMS).cma $(CMS).cmxa lib$(CMS).a $(CMS).a dll$(CMS).so

uninstall:
	ocamlfind remove $(CMS)

.PHONY: test
test:
	make -C test

doc:
	ocamlfind ocamldoc -package ctypes.foreign -I src src/cryptominisat.mli -html -d docs

clean:
	ocamlbuild -clean
	-rm *.cm[o,i,x,a] \
		*.cmxa *.so *.o *.a *.byte *.native *~ \
		src/*.cm[o,i,x] src/*.o src/*~
	make -C test clean
