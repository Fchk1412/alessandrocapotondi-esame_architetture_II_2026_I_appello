TESTBENCH ?= tb.v
SIMLIST ?= top.vvp

all: $(SIMLIST)

$(SIMLIST): top.v $(TESTBENCH)
	iverilog -o $@ $^

run: $(SIMLIST)
	vvp $(SIMLIST)

clean:
	rm -rf $(SIMLIST) *.vcd
