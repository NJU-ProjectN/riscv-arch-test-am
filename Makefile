.PHONY: all run gdb clean latest $(ALL)

TEST_ISA = I M # check ./riscv-test-suite/<TARGET_ISA>/ for more extensions
EXCLUDE_TEST = 

RESULT = .result
$(shell > $(RESULT))

COLOR_RED   = \033[1;31m
COLOR_GREEN = \033[1;32m
COLOR_NONE  = \033[0m

SUPPORTED_AM_ISA = riscv32 riscv32e riscv64
AM_ISA = $(word 1, $(subst -, ,$(ARCH)))
ifeq ($(AM_ISA),riscv32e)
	RV32E = 1
endif

ifeq ($(findstring $(MAKECMDGOALS),clean),)  # ignore the commands if the target is clean
ifeq ($(filter $(SUPPORTED_AM_ISA), $(AM_ISA)), )
  $(error Expected $$ISA in {$(SUPPORTED_AM_ISA)}, Got "$(AM_ISA)")
endif
XLEN = $(shell echo $(AM_ISA) | grep -o '32\|64')
TARGET_ISA = $(if $(RV32E),rv32e_m,rv$(XLEN)i_m)
TEST_DIR = $(TEST_ISA:%=./riscv-test-suite/$(TARGET_ISA)/%/src)
endif

ORIGINAL_TEST = $(subst -01.S,,$(notdir $(shell find $(TEST_DIR) -name "*-01.S" | sort)))
ALL = $(filter-out $(EXCLUDE_TEST),$(ORIGINAL_TEST))
ALL_SRCS = $(foreach d,$(TEST_DIR),$(foreach f,$(ALL),$(wildcard $(d)/$(f)-01.S)))

define find_src
  $(filter %/$(1)-01.S,$(ALL_SRCS))
endef

all: $(addprefix Makefile., $(ALL))
	@echo "test list [$(words $(ALL)) item(s)]:" $(ALL)

$(ALL): %: Makefile.%

.SECONDEXPANSION:  # this helps to call function in prerequisite
Makefile.%: $$(call find_src,%)
	@/bin/echo -e "\
NAME = $*\n\
SRCS = ./main.c $<\n\
INC_PATH += ./riscv-test-suite/env\n\
$(if $(RV32E),ASFLAGS += -DRVTEST_E\n)\
ASFLAGS += -DXLEN=$(XLEN)\n\
include $${AM_HOME}/Makefile" > $@
	@if make -s -f $@ ARCH=$(ARCH) $(MAKECMDGOALS); then \
		printf "[%14s] $(COLOR_GREEN)PASS$(COLOR_NONE)\n" $* >> $(RESULT); \
	else \
		printf "[%14s] $(COLOR_RED)***FAIL***$(COLOR_NONE)\n" $* >> $(RESULT); \
	fi
	-@rm -f Makefile.$*

run: all
	@cat $(RESULT)
	@rm $(RESULT)

gdb: all

clean:
	rm -rf Makefile.* build/

latest: