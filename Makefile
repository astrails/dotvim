# find out where ruby is. can override this by providing environment or command
# line variable
RUBY ?= $(shell ./find-ruby.sh)

default: install

.PHONY: delete git-cleanup cleanup compile-command-t compile-vimproc compile install reinstall help
delete:
	@echo going to remove the bundle directory. press ENTER to continue.
	@read something
	rm -rf bundle

NEOBUNDLE := bundle/neobundle.vim
${NEOBUNDLE}:
	@echo 
	@echo
	@echo '**************************************************************'
	@echo '*    UPGRADING vundle => neobundle                           *'
	@echo '*                                                            *'
	@echo '*    Your existing vundle repository will be DELETED!!!!     *'
	@echo '*    press ENTER to continue, Ctrl-C to stop                 *'
	@echo '**************************************************************'
	@read a
	rm -rf bundle/vundle
	mkdir -p bundle && cd bundle && git clone https://github.com/Shougo/neobundle.vim.git
	@echo
	@echo '**************************************************************************'
	@echo '*   DONE! You might need to upgrade your bundles.vim to the new format.  *'
	@echo '*   see https://github.com/Shougo/neobundle.vim                          *'
	@echo '**************************************************************************'
	@echo

git-cleanup:
	ls bundle | while read b;do (cd bundle/$$b && git clean -f);done

cleanup:
	vim -u bundles.vim +NeoBundleClean +NeoBundleCheck +NeoBundleDocs

compile-command-t:
	test ! -d bundle/Command-T || (cd bundle/Command-T/ruby/command-t/ && $(RUBY) extconf.rb && make)

compile-vimproc:
	test ! -d bundle/vimproc || make -C bundle/vimproc

compile: compile-command-t compile-vimproc

install: ${NEOBUNDLE} cleanup compile

reinstall: delete install

help:
	@echo 'make help                         print this message'
	@echo 'make install                     (default) make sure all bundles installed and compiled'
	@echo 'make reinstall                   [DANGEROUS!] - remove bundles and reinstall'
