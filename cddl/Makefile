.DEFAULT_GOAL := check

SHELL := /bin/bash

include tools.mk
include funcs.mk

DC_DIR := ./
#IMPORTS_DIR := $(DC_DIR)imports/
EXPORTS_DIR := $(DC_DIR)exports/

%.cbor: %.diag
	$(diag2cbor) $< > $@

check:: cbor-tags-unique
check:: check-corim check-corim-examples
check:: check-comid check-comid-examples
#check:: check-cotl check-cotl-examples
check:: export-all

# Commented since CI doesn't have openssl
examples/sig-structure.diag: examples/sig-structure.diag.tmpl examples/payload-corim-4.diag examples/protected-header-map.diag
	payload="$$(cat examples/payload-corim-4.diag)" \
	protected="$$(cat examples/protected-header-map.diag)" \
	envsubst < examples/sig-structure.diag.tmpl > examples/sig-structure.diag

examples/testkey.pem:
	openssl ecparam -name secp384r1 -genkey -noout -out examples/testkey.pem

examples/corim-4.sig: examples/sig-structure.cbor examples/testkey.pem
	openssl dgst -sha384 -sign examples/testkey.pem -out examples/corim-4.sig examples/sig-structure.cbor

examples/corim-4.diag: examples/corim-4.sig examples/corim-4.diag.tmpl examples/payload-corim-4.diag examples/protected-header-map.diag
	payload="$$(cat examples/payload-corim-4.diag)" \
	protected="$$(cat examples/protected-header-map.diag)" \
	signature="h'$$(cat examples/corim-4.sig | xxd -p -c 128)'" \
	envsubst < examples/corim-4.diag.tmpl > examples/corim-4.diag

include corim-frags.mk
COMID_START := concise-mid-tag
CORIM_START := tagged-corim-map
$(eval $(call cddl_check_template,comid,$(COMID_FRAGS) $(IMPORT_FRAGS),$(COMID_EXAMPLES),$(COMID_START)))
#$(eval $(call cddl_check_template,cotl,$(COTL_FRAGS),$(COTL_EXAMPLES)))
$(eval $(call cddl_check_template,corim,$(CORIM_FRAGS) $(IMPORT_FRAGS),$(CORIM_EXAMPLES),$(CORIM_START)))

GITHUB := https://raw.githubusercontent.com/
COSWID_REPO := sacmwg/draft-ietf-sacm-coswid/master
COSWID_REPO_URL := $(join $(GITHUB), $(COSWID_REPO))

concise-swid-tag.cddl: ; $(curl) -O $(COSWID_REPO_URL)/$@

CLEANFILES += concise-swid-tag.cddl

# Make exports - used by cddl-releases
$(eval $(call cddl_exp_template,dice-corim,$(CORIM_FRAGS),$(EXPORTS_DIR),$(IMPORT_FRAGS)))
AUTOGEN_FRAGS := $(addprefix $(DC_DIR), corim-autogen.cddl)
AUTOGEN_EXPORTS := $(addprefix $(EXPORTS_DIR), corim-autogen.cddl)

export-all: exp-dice-corim check-corim check-comid
	cp $(AUTOGEN_FRAGS) $(EXPORTS_DIR)

CLEANFILES += $(AUTOGEN_EXPORTS)

clean: ; rm -f $(CLEANFILES)

# Extract the CBOR tags defined by CoRIM/CoMID (i.e., those in the 5xx space)
cbor-tags.txt: $(wildcard *.cddl) ; grep -h '#6\.5' *cddl | sort -u -t'=' -k2 > $@

# Return an error if there are duplicate CBOR Tags defined
cbor-tags-unique: cbor-tags.txt
	@echo -n "duplicated CBOR tag(s): "
	@if grep -E -h -o '#6\.[0-9]{3}' $< | uniq -d | grep . -c ; \
	then \
		echo "check the following:" ; \
		grep -E -h -o '#6\.[0-9]{3}' $< | uniq -d ; \
	fi
