install: install-command-t

install-command-t:
	cd bundle/command-t/ruby/command-t/ && /opt/local/bin/ruby extconf.rb && make
