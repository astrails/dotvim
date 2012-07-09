# find out where ruby is. can override this by providing environment or command
# line variable
RUBY ?= $(shell ./find-ruby.sh)

update: install-vundle bundles compile-command-t

upgrade: upgrade-bundles compile-command-t

install: cleanup update

cleanup:
	rm -rf bundle

install-vundle:
	test -d bundle/vundle || (mkdir -p bundle && cd bundle && git clone https://github.com/gmarik/vundle.git)

bundles:
	vim -u ./bundles.vim +BundleClean! +BundleInstall

cleanup-bundles:
	ls bundle | while read b;do (cd bundle/$$b && git clean -f);done

upgrade-bundles: cleanup-bundles
	vim -u ./bundles.vim +BundleClean! +BundleInstall!

# only run compilation if bundle installed
compile-command-t:
	test ! -d bundle/Command-T || (cd bundle/Command-T/ruby/command-t/ && $(RUBY) extconf.rb && make)
