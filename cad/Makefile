.PHONY: all check clean
OPENSCAD ?= openscad
PARTS = base_usbc front_plate column display_carrier rotor_hub ring pedestal sensor_holder clamp_bar

all: $(addprefix stl/,$(addsuffix .stl,$(PARTS))) stl/assembly-preview.stl

stl/%.stl: %.scad params.scad
	@mkdir -p stl
	$(OPENSCAD) -o $@ $<

stl/assembly-preview.stl: assembly.scad params.scad $(addsuffix .scad,$(PARTS))
	@mkdir -p stl
	$(OPENSCAD) -o $@ $<

check:
	../scripts/check.sh

clean:
	rm -f stl/*.stl
