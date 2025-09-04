TARGETS := test
C1541 := c1541
X64 := x64.exe

.PRECIOUS: %.d64 %.prg

all: $(TARGETS)

%.prg: %.asm
	acme --cpu 6510 --format cbm --outfile $@ $<

%.d64: %.prg
	$(C1541) -format foo,id d64 $@ -write $<

%: %.d64
	$(X64) $<

clean:
	rm -f $(TARGETS) *.prg *.d64
