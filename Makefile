install: install-command-t

install-command-t:
	cd bundle/command-t/ruby/command-t/ && ruby extconf.rb && make
