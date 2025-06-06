.DEFAULT_GOAL := check

SHELL := /bin/bash

CDDL_DIR := ./cddl/

check:
	$(MAKE) -C $(CDDL_DIR)