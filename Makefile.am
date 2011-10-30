## Copyright 2008 Savarese Software Research Corporation
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.savarese.com/software/ApacheLicense-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

EXTRA_DIST = LICENSE NOTICE CHANGES ltp.lua ltp.1.txt
bin_SCRIPTS = ltp
dist_man1_MANS = ltp.1

LTP_LIB = ltp/util.lua ltp/template.lua
LTP_SHARE = $(LTP_LIB:%=share/ltp/%)
LTP_HTML_DIR = doc
LTP_HTML = $(LTP_HTML_DIR)/ltp.1.html
nobase_dist_pkgdata_DATA = $(LTP_LIB) $(LTP_HTML)

CLEANFILES = $(bin_SCRIPTS) $(dist_man1_MANS) $(LTP_SHARE) $(LTP_HTML)

BUILD := $(shell date "+%Y-%m-%d %T %Z")

# This is only for development purposes, so we can run ltp from the
# current directory.
$(LTP_SHARE): share/ltp/%: $(top_srcdir)/%
	$(MKDIR_P) $(@D)
	cp $< $@

ltp: ltp.lua $(LTP_SHARE)
	sed -e 's#\@LTP_LIB_DIR\@#$(pkgdatadir)#g' \
	    -e 's#\@LTP_INST_DIR\@#$(prefix)#g' \
	    -e 's/\@VERSION\@/$(VERSION)/g' \
	    -e 's/\@BUILD\@/$(BUILD)/g'  < $< > $@
	chmod +x $@

ltp.1: ltp.1.txt
	a2x -f manpage -D . -a revnumber=$(VERSION) $<

$(LTP_HTML_DIR):
	$(MKDIR_P) $@

$(LTP_HTML): ltp.1.txt $(LTP_HTML_DIR)
	if [ ! -f $(top_srcdir)/$(LTP_HTML) ]; then \
	  a2x -f xhtml -D $(@D) -a revnumber=$(VERSION) --copy $< ;\
	fi
