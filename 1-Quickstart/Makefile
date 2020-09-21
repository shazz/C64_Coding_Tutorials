CA65   = ca65
CL65   = cl65
LD65   = ld65

BINDIR = bin

DEMOS = $(BINDIR)/test.prg $(BINDIR)/border.prg

all: $(DEMOS) $(EXAMPLES)

$(BINDIR)/test.prg: test.s
	$(CL65) -t c64 -C c64-asm.cfg -u __EXEHDR__ $< -o $@

$(BINDIR)/border.prg: border.s
	$(CL65) -t c64 -C c64-asm.cfg -u __EXEHDR__ $< -o $@

clean:
	rm -f *.o
