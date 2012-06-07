update: install-vundle vundles install-command-t

install: cleanup update

cleanup:
	rm -rf bundle

install-vundle:
	mkdir -p bundle && cd bundle && git clone https://github.com/gmarik/vundle.git

vundles:
	vim -u ./vundles.vim +BundleInstall

install-command-t:
	cd bundle/Command-T/ruby/command-t/ && /opt/local/bin/ruby extconf.rb && make
