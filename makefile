
# *****************************************************
# Variables to control Compile / Link.

CC = g++

X11_CFLAGS=`pkg-config --cflags x11`
X11_LFLAGS=`pkg-config --libs x11`

# Minor styling.
COLOR_RED = \033[0;31m
COLOR_GREEN = \033[1;32m
COLOR_YELLOW = \033[1;33m
COLOR_BLUE = \033[1;34m
COLOR_NORMAL = \033[0m

# ****************************************************
# Compile any single FOO.cpp file and link it as FOO.

all: MsgBox.cpp
	@echo
	@echo "$(COLOR_BLUE)Build Starts.$(COLOR_NORMAL)"
	@echo

	$(CC) $(X11_CFLAGS) -c MsgBox.cpp
	$(CC) MsgBox.o $(X11_LFLAGS) -o MsgBox

	@echo
	@echo "$(COLOR_BLUE)Build Done.$(COLOR_NORMAL)"

# ****************************************************
# sudo make install

install: all
ifneq ($(shell id -u), 0)
	@echo
	@echo "$(COLOR_RED)Error!$(COLOR_NORMAL) You must "\
		"be root to perform this action."
	@echo
	@echo  "Please re-run with:"
	@echo "   $(COLOR_GREEN)sudo make install$(COLOR_NORMAL)"
	@echo
	@exit 1;
endif

	@echo
	@echo "$(COLOR_BLUE)Install Starts.$(COLOR_NORMAL)"
	@echo

	cp 'MsgBox' /usr/local/bin
	chmod +x /usr/local/bin/MsgBox
	@echo

	cp 'msgbox.png' /usr/share/icons/hicolor/48x48/apps/

	@echo
	@echo "$(COLOR_BLUE)Install Done.$(COLOR_NORMAL)"

# ****************************************************
# sudo make uninstall

uninstall:
ifneq ($(shell id -u), 0)
	@echo
	@echo "$(COLOR_RED)Error!$(COLOR_NORMAL) You must "\
		"be root to perform this action."
	@echo
	@echo  "Please re-run with:"
	@echo "   $(COLOR_GREEN)sudo make uninstall$(COLOR_NORMAL)"
	@echo
	@exit 1;
endif

	@echo
	@echo "$(COLOR_BLUE)Uninstall Starts.$(COLOR_NORMAL)"
	@echo

	rm -f /usr/local/bin/MsgBox
	@echo

	rm -f /usr/share/icons/hicolor/48x48/apps/msgbox.png

	@echo
	@echo "$(COLOR_BLUE)Uninstall Done.$(COLOR_NORMAL)"

# ****************************************************
# make clean

clean:
	@echo
	@echo "$(COLOR_BLUE)Clean Starts.$(COLOR_NORMAL)"
	@echo

	rm -f MsgBox.o
	rm -f MsgBox

	@echo
	@echo "$(COLOR_BLUE)Clean Done.$(COLOR_NORMAL)"
