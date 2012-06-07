update: submodules vundles install-command-t

install: cleanup update

cleanup:
	rm -rf bundle

submodules:
	git submodule update --init

vundles:
	vim -u ./vundles.vim +BundleInstall

install-command-t:
	cd bundle/Command-T/ruby/command-t/ && /opt/local/bin/ruby extconf.rb && make
