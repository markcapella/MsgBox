
# *****************************************************
# Variables to control Compile / Link.
#
APP_NAME="MsgBox"
APP_VERSION="2026-03-06"
APP_AUTHOR="Mark James Capella"

# Color styling.
COLOR_NORMAL := $(shell tput sgr0)

COLOR_BLACK := $(shell tput setaf 0)
COLOR_RED := $(shell tput setaf 1)
COLOR_GREEN := $(shell tput setaf 2)
COLOR_YELLOW := $(shell tput setaf 3)
COLOR_BLUE := $(shell tput setaf 4)
COLOR_MAGENTA := $(shell tput setaf 5)
COLOR_CYAN := $(shell tput setaf 6)
COLOR_WHITE := $(shell tput setaf 7)

CPP = g++

X11_CFLAGS = `pkg-config --cflags x11`
X11_LFLAGS = `pkg-config --libs x11 libpng`

FREETYPE_CFLAGS = `pkg-config --cflags xft`
FREETYPE_LFLAGS = `pkg-config --libs xft`


# ****************************************************
# make
#
all: MsgBox.cpp
	@if [ "$(shell id -u)" = 0 ]; then \
		echo; \
		echo "$(COLOR_RED)Error!$(COLOR_NORMAL) You must not"\
			"be root to perform this action."; \
		echo; \
		echo  "Please re-run with:"; \
		echo "   $(COLOR_GREEN)make$(COLOR_NORMAL)"; \
		echo; \
		exit 1; \
	fi

	@echo
	@echo "$(COLOR_BLUE)Build Starts.$(COLOR_NORMAL)"
	@echo

	$(CPP) $(APP_CFLAGS) -c xDisplayHelper.cpp
	$(CPP) $(X11_CFLAGS) -c xPngWrapper.cpp
	$(CPP) $(X11_CFLAGS) $(FREETYPE_CFLAGS) \
		-c MsgBox.cpp

	$(CPP) MsgBox.o \
		xPngWrapper.o xDisplayHelper.o \
		$(X11_LFLAGS) $(FREETYPE_LFLAGS) \
		-o MsgBox

	@echo "true" > "BUILD_COMPLETE"

	@echo
	@echo "$(COLOR_BLUE)Build Done.$(COLOR_NORMAL)"

# ****************************************************
# make run
#
run:
	@if [ ! -f BUILD_COMPLETE ]; then \
		echo; \
		echo "$(COLOR_RED)Error!$(COLOR_NORMAL) Nothing"\
			"currently built to run."; \
		echo; \
		echo "Please make this project first, with:"; \
		echo "   $(COLOR_GREEN)make$(COLOR_NORMAL)"; \
		echo; \
		exit 1; \
	fi

	@if [ "$(shell id -u)" = 0 ]; then \
		echo; \
		echo "$(COLOR_RED)Error!$(COLOR_NORMAL) You must not"\
			"be root to perform this action."; \
		echo; \
		echo  "Please re-run with:"; \
		echo "   $(COLOR_GREEN)make run$(COLOR_NORMAL)"; \
		echo; \
		exit 1; \
	fi

	@echo
	@echo "$(COLOR_BLUE)Run Starts.$(COLOR_NORMAL)"
	@echo

	./MsgBox 600 500 360 66 "Warning" \
		"Something Bad happened  :-("

	@echo
	@echo "$(COLOR_BLUE)Run Done.$(COLOR_NORMAL)"

# ****************************************************
# sudo make install
#
install:
	@if [ ! -f BUILD_COMPLETE ]; then \
		echo; \
		echo "$(COLOR_RED)Error!$(COLOR_NORMAL) Nothing"\
			"currently built to install."; \
		echo; \
		echo "Please make this project first, with:"; \
		echo "   $(COLOR_GREEN)make$(COLOR_NORMAL)"; \
		echo; \
		exit 1; \
	fi

	@if ! [ "$(shell id -u)" = 0 ]; then \
		echo; \
		echo "$(COLOR_RED)Error!$(COLOR_NORMAL) You must"\
			"be root to perform this action."; \
		echo; \
		echo  "Please re-run with:"; \
		echo "   $(COLOR_GREEN)sudo make install$(COLOR_NORMAL)"; \
		echo; \
		exit 1; \
	fi

	@echo
	@echo "$(COLOR_BLUE)Install Starts.$(COLOR_NORMAL)"
	@echo

	cp 'MsgBox' /usr/local/bin
	chmod +x /usr/local/bin/MsgBox
	@echo

	cp 'msgboxerror.png' /usr/share/icons/hicolor/48x48/apps/

	@echo
	@echo "$(COLOR_BLUE)Install Done.$(COLOR_NORMAL)"

# ****************************************************
# sudo make uninstall
#
uninstall:
	@if ! [ "$(shell id -u)" = 0 ]; then \
		echo; \
		echo "$(COLOR_RED)Error!$(COLOR_NORMAL) You must"\
			"be root to perform this action."; \
		echo; \
		echo  "Please re-run with:"; \
		echo "   $(COLOR_GREEN)sudo make uninstall$(COLOR_NORMAL)"; \
		echo; \
		exit 1; \
	fi

	@echo
	@echo "$(COLOR_BLUE)Uninstall Starts.$(COLOR_NORMAL)"
	@echo

	rm -f /usr/local/bin/MsgBox
	@echo

	rm -f /usr/share/icons/hicolor/48x48/apps/msgboxerror.png

	@echo
	@echo "$(COLOR_BLUE)Uninstall Done.$(COLOR_NORMAL)"

# ****************************************************
# make clean
#
clean:
	@if [ "$(shell id -u)" = 0 ]; then \
		echo; \
		echo "$(COLOR_RED)Error!$(COLOR_NORMAL) You must not"\
			"be root to perform this action."; \
		echo; \
		echo  "Please re-run with:"; \
		echo "   $(COLOR_GREEN)make clean$(COLOR_NORMAL)"; \
		echo; \
		exit 1; \
	fi

	@echo
	@echo "$(COLOR_BLUE)Clean Starts.$(COLOR_NORMAL)"
	@echo

	rm -f xDisplayHelper.o
	rm -f xPngWrapper.o
	rm -f MsgBox.o
	rm -f MsgBox

	@rm -f "BUILD_COMPLETE"

	@echo
	@echo "$(COLOR_BLUE)Clean Done.$(COLOR_NORMAL)"
