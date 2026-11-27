.PHONY: all check clean 3mf/ring-two-colour.3mf
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

# two-colour ring for Bambu Studio: ring body + knurl ribs as two parts of one object
3mf/ring-two-colour.3mf: ring.scad params.scad
	$(OPENSCAD) -D 'part="body"' -o stl/ring-body.stl ring.scad
	$(OPENSCAD) -D 'part="ribs"' -o stl/ring-ribs.stl ring.scad
	node ../scripts/make-3mf.mjs
