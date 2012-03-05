update: submodules vundles install-command-t

install: cleanup install

cleanup:
	rm -rf bundle

submodules:
	git submodule update --init

vundles:
	vim +BundleInstall

install-command-t:
	cd bundle/command-t/ruby/command-t/ && /opt/local/bin/ruby extconf.rb && make
