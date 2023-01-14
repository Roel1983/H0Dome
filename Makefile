# Targets
PARTS                    = Dom
IMAGES                   = Dom

# Folders
DEPDIR                  ?= ./.deps
PARTSDIR                ?= ./parts
IMAGESDIR               ?= ./images

# Applications
OPENSCAD                ?= openscad

# Derived
stl_files = $(PARTS:%=$(PARTSDIR)/%.stl)
png_files = $(IMAGES:%=$(IMAGESDIR)/%.png)

# Targets
.PHONY: all all_stl all_png
all: all_stl all_png
all_stl: $(stl_files)
all_png: $(png_files)

clean:
	@if [ -d "./$(DEPDIR)" ]; then rm -r ./$(DEPDIR); fi
cleanall: clean
	@if [ -d "./$(PARTSDIR)" ]; then rm -r ./$(PARTSDIR); fi
	@if [ -d "./$(IMAGESDIR)" ]; then rm -r ./$(IMAGESDIR); fi

$(PARTSDIR)/%.stl: %.scad
$(PARTSDIR)/%.stl: %.scad | $(PARTSDIR) $(DEPDIR) $(DEPDIR)/%.d
	$(OPENSCAD) -d $(DEPDIR)/$*.d -o $(PARTSDIR)/$*.stl $*.scad

$(IMAGESDIR)/%.png: %.scad
$(IMAGESDIR)/%.png: %.scad | $(IMAGESDIR) $(DEPDIR) $(DEPDIR)/%.d
	$(OPENSCAD) -d $(DEPDIR)/$*.d -DRENDER_IMAGE=true -o $(IMAGESDIR)/$*.png $*.scad

$(DEPDIR) $(PARTSDIR) $(IMAGESDIR): ; @mkdir -p $@

DEPFILES := $(PARTS:%=$(DEPDIR)/%.d) $(IMAGES:%=$(DEPDIR)/%.d)
$(DEPFILES):
include $(wildcard $(DEPFILES))
