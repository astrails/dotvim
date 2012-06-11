# find out where ruby is. can override this by providing environment or command
# line variable
RUBY ?= $(shell ./find-ruby.sh)

update: install-vundle vundles install-command-t

install: cleanup update

cleanup:
	rm -rf bundle

install-vundle:
	test -d bundle/vundle || (mkdir -p bundle && cd bundle && git clone https://github.com/gmarik/vundle.git)

vundles:
	vim -u ./vundles.vim +BundleInstall

install-command-t:
	cd bundle/Command-T/ruby/command-t/ && $(RUBY) extconf.rb && make
