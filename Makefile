.PHONY: all install clean uninstall
all:
	@mkdir -p output/bin output/conf
	if [ -f src/install.sh -o -f src/uninstall.sh ]; then cp -f src/*install.sh output/bin; fi
	if [ -f conf/install.sh -o -f conf/uninstall.sh ]; then cp -f conf/*install.sh output/conf; fi
	@cp src/condense.sh output/bin
	@chmod +x output/bin/condense.sh
install:
	if [ -f 'output/bin/install.sh' ]; then \
		cd output/bin; sh install.sh; cd -; \
	else \
	    mkdir -p ~/bin; \
	    if [ "`ls output/bin`" ]; then chmod +x output/bin/*;cp -pf output/bin/* ~/bin; fi; \
	fi
	if [ -f 'output/conf/install.sh' ]; then \
		cd output/conf; sh install.sh; cd -; \
	else \
	    mkdir -p ~/bin/conf; \
	    if [ "`ls output/conf`" ]; then cp -f output/conf/* ~/bin/conf; fi; \
	fi
clean:
	rm -rf output/*
uninstall:
	if [ -f 'output/bin/uninstall.sh' ]; then \
		cd output/bin; sh uninstall.sh; cd -; \
	fi
	if [ -f 'output/conf/uninstall.sh' ]; then \
		cd output/conf; sh uninstall.sh; cd -; \
	fi
