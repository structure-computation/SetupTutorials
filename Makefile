LIBRARIES = \
	Metil \
	Soca \
	Soda \
	Soja \
	Celo \
	Sipe \
	PrepArg \
	TutoLab \
	TutoPlugins
	
BRANCHES = \
	Soja,master \
	Soda,master \
	Soca,master \
	Celo,master \
	Sipe,master \
	PrepArg,master \
	TutoLab,master \
	TutoPlugins,master
	
	
SYM_LINKS = \
	Soja,software_library/TutoLab/ext/Soja \
	Soda,software_library/TutoLab/ext/Soda \
	Celo,software_library/Soda/ext/Celo \
	Sipe,software_library/Soda/ext/Sipe \
	PrepArg,software_library/Soda/ext/PrepArg 


LD = \
	libfftw3-dev \
	libjpeg-dev \
	libpng12-dev \
	libtiff4-dev \
	gcc \
	g++ \
	libboost-dev \
	libgsl0-dev \
	libxml2-dev \
	libxml++2 \
	libreadline-dev \
	cmake \
	libqt4-core \
	libqt4-dev \
	qt4-qmake \
	qtcreator \
	coffeescript \
	zlib1g-dev \
	libglew-dev \
	libxi-dev \
	libxmu-dev \
	freeglut3-dev \
	libcurl4-openssl-dev \
	
	
SHELL = /bin/bash
	
all: compilation


compilation: sym_links
	which metil_comp || make -C software_library/Metil install
	
soda_server: compilation
	make -C Javascript mechanic

plugins: compilation
	make -C software_library/ScwalPlugins/GlobalManagerPlugin
	
plugins_with_sleep: compilation
	sleep 5
	make plugins


software_library:
	mkdir software_library
	
prereq: software_library
	# ========================= CLONING IF NECESSARY =========================
	for i in ${LIBRARIES}; do test -e software_library/$$i || git clone git@github.com:structure-computation/$$i software_library/$$i; done

pull:
	for i in ${LIBRARIES}; do \
		pushd software_library/$$i; \
		git pull; \
		popd; \
	done

push:
	for i in ${LIBRARIES}; do \
		pushd software_library/$$i; \
		git commit -a; \
		git push; \
		popd; \
	done

branches: prereq
	# ========================= SETTING BRANCHES =========================
	for i in ${BRANCHES}; do \
		R=`echo $$i | sed 's/\\(.*\\),.*/\\1/'`; \
		B=`echo $$i | sed 's/.*,\\(.*\\)/\\1/'`; \
		pushd software_library/$$R; \
		git checkout -b $$B origin/$$B 2> /dev/null || git checkout $$B; \
		popd; \
	done

ld_libraries: prereq
	# ========================= LD LIBRARIES =========================
	for i in ${LD}; do \
		R=`echo $$i | sed 's/\\(.*\\),.*/\\1/'`; \
		which $$R || sudo apt-get install $$R; \
	done
	
sym_links: ld_libraries
	# ========================= SYMBOLIC LINKS =========================
	for i in ${SYM_LINKS}; do \
		R=`echo $$i | sed 's/\\(.*\\),.*/\\1/'`; \
		B=`echo $$i | sed 's/.*,\\(.*\\)/\\1/'`; \
		mkdir -p `dirname $$B`; \
		test -e $$B || ln -s `pwd`/software_library/$$R $$B; \
	done

#  		test -e $$B && ( test -h $$B || ( echo $$B SHOULD BE A SYMLINK -- GOING TO DELETE IT; read ) ) ; \
# 		rm $$B; \

# 
# Dans scills
# ln -s ../scult/src/GEOMETRY src/GEOMETRY 
# ln -s ../scult/src/COMPUTE src/COMPUTE 
# ln -s ../scult/src/UTILS src/UTILS
# mkdir UTIL
# cd UTIL ; ln -s ../../metis-4 metis ; ln -s /usr/include/openmpi openmpi


.PHONY: prereq branches sym_links server compilation
