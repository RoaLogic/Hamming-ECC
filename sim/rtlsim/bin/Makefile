####################################################################
##   ,------.                    ,--.                ,--.          ##
##   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.    ##
##   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--'    ##
##   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  |\ `--.    ##
##   `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---'    ##
##                                             `---'               ##
##   Main Simulation Makefile                                      ##
##                                                                 ##
#####################################################################
##                                                                 ##
##             Copyright (C) 2017-2023 ROA Logic BV                ##
##             www.roalogic.com                                    ##
##                                                                 ##
##   This source file may be used and distributed without          ##
##   restriction provided that this copyright statement is not     ##
##   removed from the file and that any derivative work contains   ##
##   the original copyright notice and the associated disclaimer.  ##
##                                                                 ##
##      THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY        ##
##   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED     ##
##   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS     ##
##   FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR OR     ##
##   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,  ##
##   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT  ##
##   NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;  ##
##   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)      ##
##   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN     ##
##   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR  ##
##   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS          ##
##   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  ##
##                                                                 ##
#####################################################################

all: regression

sim        = msim_waves

SIMULATORS = msim ncsim vcs riviera
LINTERS    = $(addsuffix _lint, $(SIMULATORS))
SIMWAVES   = $(addsuffix _waves, $(SIMULATORS))

MS     = -s

ROOT_DIR    = ../../..


##########################################################################
#
# Regression variables
#
##########################################################################
REGRESSION_K  = 1 4 8 9 11 16 26 32 57 64 72 120
#REGRESSION_K = 4
REGRESSION_P0_LSB = 0 1
REGRESSION_DEC_LATENCY = 0
REGRESSION_RUNS = 100


######################################################################
#
# Sources
#
######################################################################
-include Makefile.include

.PHONY: help


###########################################################################
#
# Functions
#
############################################################################
add_regression    = $(foreach p,$(REGRESSION_$(1)), $(addprefix $(1)$(p)@, $(2)))
add_regression_if = $(if $(filter $(2), $(subst -, , $(1))), $(call add_regression,$(3),$(4)),$(4))

logs = $(call add_regression,K,                               \
       $(call add_regression,P0_LSB,                          \
       $(call add_regression,DEC_LATENCY,                     \
       $(call add_regression,RUNS,                            \
         $(TB_TOP).log                                        \
       )                                                      \
       )                                                      \
       )                                                      \
       )

regression: $(logs)

%.log:
	$(MAKE) $(sim) LOG=./log/$(@F)                                        \
          PARAMS="K=$(subst K,,$(word 1,$(subst @, ,$*)))                     \
                  P0_LSB=$(subst P0_LSB,,$(word 2,$(subst @, ,$*)))           \
                  DEC_LATENCY=$(subst DEC_LATENCY,,$(word 3,$(subst @, ,$*))) \
                  RUNS=$(subst RUNS,,$(word 4,$(subst @, ,$*)))"


#####################################################################
#
# Misc Variables
#
#####################################################################
INCDIRS:=$(INCDIRS)
DEFINES:=$(DEFINES)

shell=/bin/sh


#####################################################################
#
# OVL
#
#####################################################################
ifeq ($(OVL_ASSERT),ON)
    INCDIRS +=$(STD_OVL_DIR)
    DEFINES +=OVL_ASSERT_ON
    LIBDIRS +=$(STD_OVL_DIR)
    LIBEXT  +=.vlib

    ifeq ($(OVL_INIT_MSG),ON)
        DEFINES +=OVL_INIT_MSG
    endif
endif


#####################################################################
#
# Make Targets
#
#####################################################################
.PHONY: $(SIMULATORS) $(LINTERS) $(SIMWAVES)
$(SIMULATORS): % : %/Makefile $(TB_PREREQ)
	@$(MAKE) $(MS) -C $@ sim				\
	VLOG="$(abspath $(RTL_VLOG) $(TB_VLOG))"		\
	TECHLIBS="$(TECHLIBS)"					\
	LIBDIRS="$(LIBDIRS)"					\
	LIBEXT="$(LIBEXT)"					\
	VHDL="$(abspath $(RTL_VHDL) $(TB_VHDL))"		\
	INCDIRS="$(abspath $(INCDIRS))"				\
	DEFINES="$(DEFINES)"					\
	TOP=$(TB_TOP)						\
	LOG=$(LOG) PARAMS="$(PARAMS)"

$(SIMWAVES): %_waves : %/Makefile $(TB_PREREQ)
	@$(MAKE) $(MS) -C $(subst _waves,,$@) simw		\
	VLOG="$(abspath $(RTL_VLOG) $(TB_VLOG))"		\
	TECHLIBS="$(TECHLIBS)"					\
	LIBDIRS="$(LIBDIRS)"					\
	LIBEXT="$(LIBEXT)"					\
	VHDL="$(abspath $(RTL_VHDL) $(TB_VHDL))"		\
	INCDIRS="$(abspath $(INCDIRS))"				\
	DEFINES="$(DEFINES)"					\
	TOP=$(TB_TOP)						\
	LOG=$(LOG) PARAMS="$(PARAMS)"

$(LINTERS): %_lint : %/Makefile $(TB_PREREQ)
	@$(MAKE) $(MS) -C $(subst _lint,,$@) lint		\
	VLOG="$(abspath $(RTL_VLOG))"				\
	VHDL="$(abspath $(RTL_VHDL))"				\
	INCDIRS="$(abspath $(INCDIRS))"				\
	DEFINES="$(DEFINES)"					\
	TOP=$(RTL_TOP)


.PHONY: bps bps_gui
bps: % : %/Makefile
	@$(MAKE) $(MS) -C $@ $@                                 \
	VLOG="$(abspath $(RTL_VLOG))"                           \
	VHDL="$(abspath $(RTL_VHDL))"                           \
	TOP=$(RTL_TOP)

bps_gui: %_gui : %/Makefile
	@$(MAKE) $(MS) -C $* gui

.PHONY: clean distclean mrproper
clean:
	@for f in $(wildcard *); do				\
		if test -d $$f; then $(MAKE) -C $$f clean; fi	\
	done

distclean:
	@rm -rf $(SIMULATORS) bps Makefile.include $(TB_PREREQ)

mrproper:
	@rm -rf *


#####################################################################
#
# Make simulation structure
#
#####################################################################
Makefile.include:
	@cp ../bin/Makefile.include .

%/Makefile:
	@mkdir -p $*
	@cp ../bin/sims/Makefile.$* $@

$(TB_PREREQ):
	@cp ../bin/$@ $@
