PLATFORM=win32

ifeq (win, $(findstring win,$(PLATFORM)))
SUFF=dll
PREF=
else
ifeq (darwin, $(findstring win,$(PLATFORM)))
SUFF=dylib
EXTRA="-install_name @rpath/$@"
else
SUFF=so
endif
PREF=lib
endif

DIR=../Library/$(PLATFORM)
INC=../Include

all : add_shared add_static array_shared array_static

add_shared: $(PREF)addNumbers.$(SUFF) lib_dir
	mv $< $(DIR)

add_static: libaddNumbers.a lib_dir
	mv $< $(DIR)


array_shared: $(PREF)arrayFunctions.$(SUFF) lib_dir
	mv $< $(DIR)

array_static: libarrayFunctions.a lib_dir
	mv $< $(DIR)


lib_dir:
	mkdir -p $(DIR)

%.o: %.c
	$(CC) -c -fPIC -I$(INC) $< -o $@

$(PREF)%.$(SUFF): %.o
	$(CC) -shared -Wl,-soname,$@ $(EXTRA) -o $@ $^

lib%.a: %.o
	$(AR) rcs $@ $<

clean:
	rm -rf $(DIR) *.o

.PHONY: lib_dir all clean add_shared add_static array_shared array_static