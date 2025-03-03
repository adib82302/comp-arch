##########################
# ---- Introduction ---- #
##########################

# Welcome to the CSEE 4824 standard makefile! (plus parameters!)

# NOTE: you should only need to modify the "Executable Compilation" section
# namely the TESTBENCH, SOURCES, and SYNTH_FILES variables
# look for the 'LAB5 TODO' or 'LAB5 NOTE' markers below

# LAB5 TODO: there is a new "Modules with Paramters" section
#            read it to learn about the compilation and synthesis process for the CAM

# reference table of all make targets:

# make           <- runs the default target, set explicitly below as 'make sim'
.DEFAULT_GOAL = sim
# ^ this overrides using the first listed target as the default

# make sim       <- execute the simulation testbench (simv)
# make simv      <- compiles simv from the testbench and SOURCES

# make syn       <- execute the synthesized module testbench (syn_simv)
# make syn_simv  <- compiles syn_simv from the testbench and *.vg SYNTH_FILES
# make *.vg      <- synthesize the top level module in SOURCES for use in syn_simv
# make slack     <- a phony command to print the slack of any synthesized modules

# make verdi     <- runs the Verdi GUI debugger for simulation
# make syn_verdi <- runs the Verdi GUI debugger for synthesis

# make clean     <- remove files created during compilations (but not synthesis)
# make nuke      <- remove all files created during compilation and synthesis
# make clean_run_files <- remove per-run output files
# make clean_exe       <- remove compiled executable files
# make clean_synth     <- remove generated synthesis files

######################################################
# ---- Compilation Commands and Other Variables ---- #
######################################################

# this is a global clock period variable used in the tcl script and referenced in testbenches
export CLOCK_PERIOD = 10000.0

# the Verilog Compiler command and arguments
VCS = SW_VCS=2020.12-SP2-1 vcs -sverilog +vc -Mupdate -line -full64 -kdb -lca -nc \
      -debug_access+all+reverse $(VCS_BAD_WARNINGS) +define+CLOCK_PERIOD=$(CLOCK_PERIOD)ps
# a SYNTH define is added when compiling for synthesis that can be used in testbenches

# remove certain warnings that generate MB of text but can be safely ignored
VCS_BAD_WARNINGS = +warn=noTFIPC +warn=noDEBUG_DEP +warn=noENUMASSIGN

# Verdi executable setup
export VERDI_HOME = /tools/synopsys/verdi/verdi/U-2023.03-SP2-1
VERDI_EXE = $(VERDI_HOME)/bin/verdi

# a reference library of standard structural cells that we link against when synthesizing
LIB = $(wildcard /homes/user/fac/tk3070/tmp/synthesis/OpenROAD-flow-scripts/flow/platforms/asap7/work_around_yosys/asap7sc7p5t*.v)

# the CSEE 4824 synthesis script
TCL_SCRIPT = csee4824_synth.tcl

# Set the shell's pipefail option: causes return values through pipes to match the last non-zero value
# (useful for, i.e. piping to `tee`)
SHELL := $(SHELL) -o pipefail

#####################################
# ---- Modules with Parameters ---- #
#####################################

# for designs with parameters, we need to create custom synthesis rules
# and add new macro definitions to VCS
# these changes are organized in this section, the rest of the file is untouched

# LAB5 NOTE: Our CAM module has a SIZE parameter, which we can set at the command line
#            like this: 'make CAM_SIZE=4 sim' (or use the default value set below)
#            Inside our verilog files we declare CAM like:
#            'module CAM #(parameter SIZE=8) (...);'
#            and our testbench instantiates it as:
#            `INSTANCE(CAM) #(.SIZE(`CAM_SIZE)) cam_test(...);
#            The testbench references two special macros:
#            1: `CAM_SIZE: the size, added below for when VCS is called
#            2: `INSTANCE: is defined in the header file 'sys_defs.svh'
#            `INSTANCE will rename the module to CAM_svsim if `SYNTH is defined (by syn_simv)
#            this uses the _svsim.sv file below to make the CAM_SIZE8 generated module
#            compile with the testbench

# LAB5 TODO: Set CAM_SIZE at the command line with:
#            'make CAM_SIZE=4 sim'
#            If it isn't set, defaults to 8

CAM_SIZE = 8
VCS += +define+CAM_SIZE=$(CAM_SIZE)

# synthesis will generate new filenames given parameters i.e. CAM_SIZE8, CAM_SIZE12
# we match that here:
CAM_params = CAM_SIZE$(CAM_SIZE)
SYNTH_FILES = $(CAM_params).vg $(CAM_params)_svsim.sv

# our SYNTH_FILES are named by the parameter values (i.e. CAM_SIZE8)
# so they won't re-synthesize unless the module source is updated
# it means designs can save multiple .vg files with different params concurrently
# though we use the same names for executable compilation (simv, syn_simv)
# but those are faster to compile and don't need the speed boost

# we need a custom synthesis rule for each .vg file with unique parameters
$(CAM_params).vg: $(SOURCES) | $(TCL_SCRIPT) $(HEADERS)
	@$(call PRINT_COLOR, 5, synthesizing the CAM module with SIZE=$(CAM_SIZE))
	@$(call PRINT_COLOR, 3, NOTE: if this is slow to startup: run '"module load vcs verdi synopsys-synth"')
	# pipefail causes the command to exit on failure even though it's piping to tee
	set -o pipefail; MODULE=CAM SOURCES="$^" PARAMS="SIZE=$(CAM_SIZE)" dc_shell-t -f $(TCL_SCRIPT) | tee $(CAM_params).out
	@$(call PRINT_COLOR, 6, finished synthesizing $@)

# tell Make that making .vg files also generates matching _svsim.sv files
%_svsim.sv: %.vg

####################################
# ---- Executable Compilation ---- #
####################################

# You should only need to modify either these variables or the Parameters section
TESTBENCH   = CAM_test.sv
SOURCES     = CAM.sv
HEADERS     = sys_defs.svh
# SYNTH_FILES = # LAB5 NOTE: moved to Parameters section above

# NOTE: HEADERS are added as dependencies after the pipe "|" to avoid matching in "$^"

# the .vg rule is automatically generated below when the name of the file matches its top level module

# the normal simulation executable will run your testbench on the original modules
simv: $(TESTBENCH) $(SOURCES) | $(HEADERS)
	@$(call PRINT_COLOR, 5, compiling the simulation executable $@)
	@$(call PRINT_COLOR, 3, NOTE: if this is slow to startup: run '"module load vcs verdi synopsys-synth"')
	$(VCS) $^ -o $@
	@$(call PRINT_COLOR, 6, finished compiling $@)
# NOTE: we reference variables with $(VARIABLE), and can make use of the automatic variables: ^, @, <, etc
# see: https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html for explanations

# a make pattern rule to generate the .vg synthesis files
# pattern rules use the % as a wildcard to match multiple possible targets
%.vg: %.sv | $(TCL_SCRIPT) | $(HEADERS)
	@$(call PRINT_COLOR, 5, synthesizing the $* module)
	@$(call PRINT_COLOR, 3, this might take a while...)
	@$(call PRINT_COLOR, 3, NOTE: if this is slow to startup: run '"module load vcs verdi synopsys-synth"')
	# pipefail causes the command to exit on failure even though it's piping to tee
	set -o pipefail; MODULE=$* SOURCES="$^" dc_shell-t -f $(TCL_SCRIPT) | tee $*_synth.out
	@$(call PRINT_COLOR, 6, finished synthesizing $@)
# this also generates many other files, see the tcl script's introduction for info on each of them

# add all sources as extra dependencies for each SYNTH_FILES target
# this is used when SOURCES="$^" uses the automatic variable $^ to reference all dependencies
$(SYNTH_FILES): $(SOURCES)

# LAB5 NOTE: defines the SYNTH variable that changes the module name in the testbench to CAM_svsim
# the synthesis executable runs your testbench on the synthesized versions of your modules
syn_simv: $(TESTBENCH) $(SYNTH_FILES) | $(HEADERS)
	@$(call PRINT_COLOR, 5, compiling the synthesis executable $@)
	$(VCS) +define+SYNTH $^ $(LIB) -o $@
	@$(call PRINT_COLOR, 6, finished compiling $@)
# we need to link the synthesized modules against LIB, so this differs slightly from simv above
# but we still compile with the same non-synthesizable testbench

# a phony target to view the slack in the *.rep synthesis report file
slack:
	grep --color=auto "slack" *.rep
.PHONY: slack

#####################################
# ---- Running the Executables ---- #
#####################################

# these targets run the compiled executable and save the output to a .out file
# their respective files are program.out or program.syn.out

sim: simv
	@$(call PRINT_COLOR, 5, running $<)
	./simv | tee program.out
	@$(call PRINT_COLOR, 2, output saved to program.out)

syn: syn_simv
	@$(call PRINT_COLOR, 5, running $<)
	./syn_simv | tee program.syn.out
	@$(call PRINT_COLOR, 2, output saved to program.syn.out)

# NOTE: phony targets don't create files matching their name, and make will always run their commands
# make doesn't know how files get created, so we tell it about these explicitly:
.PHONY: sim syn

###################
# ---- Verdi ---- #
###################

# verdi is the synopsys debug system, and an essential tool in CSEE 4824

# these targets run the executables using verdi
verdi: simv novas.rc verdi_dir
	./simv -gui=$(VERDI_EXE)

syn_verdi: syn_simv novas.rc verdi_dir
	./syn_simv -gui=$(VERDI_EXE)

.PHONY: verdi syn_verdi

# this creates a directory verdi will use if it doesn't exist yet
verdi_dir:
	mkdir -p /workdir/$${USER}_csee4824
.PHONY: verdi_dir

novas.rc: initialnovas.rc
	sed s/UNIQNAME/$$USER/ initialnovas.rc > novas.rc

#####################
# ---- Cleanup ---- #
#####################

# You should only clean your directory if you think something has built incorrectly
# or you want to prepare a clean directory for e.g. git (first check your .gitignore).
# Please avoid cleaning before every build. The point of a makefile is to
# automatically determine which targets have dependencies that are modified,
# and to re-build only those as needed; avoiding re-building everything everytime.

# 'make clean' removes build/output files, 'make nuke' removes all generated files
# clean_* commands clean certain groups of files

clean: clean_exe clean_run_files
	@$(call PRINT_COLOR, 6, note: clean is split into multiple commands that you can call separately: clean_exe and clean_run_files)

# use cautiously, this can cause hours of recompiling in later projects
nuke: clean clean_synth
	@$(call PRINT_COLOR, 6, note: nuke is split into multiple commands that you can call separately: clean_synth)

clean_exe:
	@$(call PRINT_COLOR, 3, removing compiled executable files)
	rm -rf *simv *.daidir csrc *.key vcdplus.vpd vc_hdrs.h
	rm -rf verdi* novas* *fsdb*

clean_run_files:
	@$(call PRINT_COLOR, 3, removing per-run outputs)
	rm -rf *.out *.dump

clean_synth:
	@$(call PRINT_COLOR, 1, removing synthesis files)
	rm -rf *.vg *_svsim.sv *.res *.rep *.ddc *.chk *.syn *_synth.out *.mr *.pvl command.log

.PHONY: clean nuke clean_%

######################
# ---- Printing ---- #
######################

# this is a GNU Make function with two arguments: PRINT_COLOR(color: number, msg: string)
# it does all the color printing throughout the makefile
PRINT_COLOR = if [ -t 0 ]; then tput setaf $(1) ; fi; echo $(2); if [ -t 0 ]; then tput sgr0; fi
# colors: 0:black, 1:red, 2:green, 3:yellow, 4:blue, 5:magenta, 6:cyan, 7:white
# other numbers are valid, but aren't specified in the tput man page

# Make functions are called like this:
# $(call PRINT_COLOR,3,Hello World!)
# NOTE: adding '@' to the start of a line avoids printing the command itself, only the output
