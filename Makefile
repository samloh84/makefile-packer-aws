SHELL := /bin/bash
.SHELLFLAGS := -ec

.PHONY: build

PACKER_VAR_FILE_PATTERNS := *var*.json
PACKER_ENV_FILE_PATTERNS := *.env
PACKER_CONFIGURATION_FILE := packer.json


define _LOAD_AWSRC :=
	if [[ -f "~/.awsrc" ]]; then \
		source "~/.awsrc"; \
	fi; \
	if [[ -f "$(CURDIR)/.awsrc" ]]; then \
		source "$(CURDIR)/.awsrc";  \
	fi
endef

define _SET_PACKER_VAR_FILE_ARGS :=
	if [[ ! -z "$(PACKER_VAR_FILE_PATTERNS)" ]]; then \
		PACKER_VAR_FILE_PATTERNS=($(PACKER_VAR_FILE_PATTERNS)); \
	else \
		PACKER_VAR_FILE_PATTERNS=(); \
	fi; \
	PACKER_VAR_FILE_ARGS=(); \
	for PACKER_VAR_FILE_PATTERN in "$${PACKER_VAR_FILE_PATTERNS[@]}"; do \
		for PACKER_VAR_FILE in $$(find $(CURDIR) -name "$${PACKER_VAR_FILE_PATTERN}"); do \
			PACKER_VAR_FILE_ARGS+=("-var-file" "$${PACKER_VAR_FILE}"); \
		done; \
	done
endef

define _SET_PACKER_ENV_ARGS :=
	if [[ ! -z "$(PACKER_ENV_FILE_PATTERNS)" ]]; then \
		PACKER_ENV_FILE_PATTERNS=("$(PACKER_ENV_FILE_PATTERNS)"); \
	else \
		PACKER_ENV_FILE_PATTERNS=(); \
	fi; \
	PACKER_ENV_ARGS=(); \
	for PACKER_ENV_FILE_PATTERN in "$${PACKER_ENV_FILE_PATTERNS[@]}"; do \
		for PACKER_ENV_FILE in $$(find $(CURDIR) -name "$${PACKER_ENV_FILE_PATTERN}"); do \
			while read -r PACKER_ENV_FILE_LINE; do \
				PACKER_ENV_ARGS+=("--var" "$${PACKER_ENV_FILE_LINE}"); \
			done <<<$$(cat "$${PACKER_ENV_FILE}" | envsubst); \
		done; \
	done
endef


define _SET_LOCAL_CIDR :=
	export LOCAL_CIDR="$$(curl -sSLj "https://icanhazip.com/")/32"
endef

all: build

build:
	set -euxo pipefail; \
	$(call _LOAD_AWSRC); \
	$(call _SET_PACKER_VAR_FILE_ARGS); \
	$(call _SET_PACKER_ENV_ARGS); \
	$(call _SET_LOCAL_CIDR); \
	PACKER_BUILD_ARGS=("$${PACKER_VAR_FILE_ARGS[@]}" "$${PACKER_ENV_ARGS[@]}" "$(PACKER_CONFIGURATION_FILE)"); \
	packer build "$${PACKER_BUILD_ARGS[@]}"
