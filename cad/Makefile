.PHONY: all check clean
OPENSCAD ?= openscad
PARTS = base front_plate column display_carrier rotor_hub ring pedestal

all: $(addprefix stl/,$(addsuffix .stl,$(PARTS))) stl/assembly-preview.stl stl/layout-ghosts.stl

stl/%.stl: %.scad params.scad
	@mkdir -p stl
	$(OPENSCAD) -o $@ $<

stl/assembly-preview.stl: assembly.scad params.scad $(addsuffix .scad,$(PARTS))
	@mkdir -p stl
	$(OPENSCAD) -o $@ $<

stl/layout-ghosts.stl: ghosts.scad params.scad
	@mkdir -p stl
	$(OPENSCAD) -o $@ $<

check:
	../scripts/check.sh

clean:
	rm -f stl/*.stl
