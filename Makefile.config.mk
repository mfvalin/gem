SHELL = /bin/bash

## Main targets: make TARGET VERSION=version
##
## all     : build everything and make SSM pkgs
## install : make all then install the SSM pkgs in DESTDIR
## dist    : build an archive for export
## check       : TODO
## installcheck: TODO
## installdirs : TODO
## uninstall   : TODO
##
## clean       : remove all build files
## mostlyclean : remove dist file
## distclean   : remove build and dist files
## 
## force_all: make distclean buildall distall force_allssmpkgs
##
## versiontag: set version from Git tag or VERSION var
## buildall  : build everything up to libs and abs
## distall   : make buildall then make dist dir (excluding SSM pkgs)
##
## objects   : compile everything
## libs      : make objects then ar libs
## allabs    : make libs then make allbin_$(PKGNAME) (pkg defined target)
## distdir   : make distdirall distdirarch
##
## distdirall  : make dist dir for the SSM all pkg
## distdirarch : make dist dir for the SSM arch specific pkg
## distdirmulti: make dist dir for the SSM multi(all and arch specific) pkg
##
## force_allssmpkgs : make allssmpkgs even if they exists (are up to date)
## allssmpkgs  : make ssmpkgall ssmpkgarch
## ssmpkgall   : make distdirall then make $(PKGNAME)_$(VERSION)_all.ssm
## ssmpkgarch  : make distdirarch then make $(PKGNAME)_$(VERSION)_$(SSMARCH).ssm
## ssmpkgmulti : make distdirmulti then make $(PKGNAME)_$(VERSION)_multi.ssm

## Basic pkg info
## RELEASE PREFIX/POSTFIX are string to add to GEM Abs names
export PKGNAME := gem
export ABSPREFIX := 
export ABSPOSTFIX := _REL
#TODO: produce allbin w/ gemntr, gemdm w/ optional _REL_
export gem := $(shell echo $${gem:-$(PWD)})
export ATM_MODEL_ISOFFICIAL=true

## Location of parts to include in the SSM pkg
export SRCDIR   := $(PWD)
export INCDIR0  := $(PWD)/include
export LIBDIR0  := $(PWD)/lib
export BINDIR0  := $(PWD)/bin
export SHAREDIR := $(PWD)/share

## List of subdir names to build as lib in the specified order
## each subdir produce a library named lib$(PKGNAME)_$(SUBDIR).a
## except for SUBDIRS_LIB_MERGE where all subdir are merged into :lib$(PKGNAME).a
## except for SUBDIRS_LIB_SPLIT where all files will produce its onw lib, used mainly for stubs dir: lib$(filename)_$(SUBDIR).a
export SUBDIRS_LIB_PRE   := 
export SUBDIRS_LIB_MERGE := 
export SUBDIRS_LIB_POST  := 
export SUBDIRS_LIB_SPLIT := 
export SUBDIRS_LIB := $(SUBDIRS_LIB_PRE) $(SUBDIRS_LIB_MERGE) $(SUBDIRS_LIB_POST) $(SUBDIRS_LIB_SPLIT)

## SUBDIRS_SRC List of subdir names to add as src/rcs
export SUBDIRS_SRC := $(SUBDIRS_LIB)

## Work diretories, DISTDIR will contain final products
export ROOTWORKDIR  := $(TMPDIR)
export BUILDDIRROOT := $(ROOTWORKDIR)/__build__/$(PKGNAME)
export DISTDIR      := $(ROOTWORKDIR)/__dist__/$(PKGNAME)

## SSM specific vars
## SSMTMPLDIR location of template/generic ssm pkg
## SSMDEPOTDIR dest dir for the ssm pkg
## SSMARCH arch of localhost, ssm flavor
## SSM_PGK list of ssmpkg to produce by default (all, arch, multi)
## SUBDIRS_SSMALL list of subdirs to include/produce in the SSM all pkg
## SUBDIRS_SSMARCH list of subdirs to include/produce in the SSM arch specific pkg
## SUBDIRS_SSMMULTI list of subdirs to include/produce in the SSM multi pkg
export SSMTMPLDIR = $(modelutils)/share/ssm_tmpl
export SSMDEPOTDIR := $(HOME)/SsmDepot
export SSMARCH := $(shell mu.ssmarch)

#export SSM_PKG := multi
export SSM_PKG := all arch

export SUBDIRS_SSMALL   := RCS include bin
export SUBDIRS_SSMARCH  := bin/$(BASE_ARCH)
export SUBDIRS_SSMMULTI := $(SUBDIRS_SSMALL) $(SUBDIRS_SSMARCH)

export SSMTMPLNAMEARCH  := PKG_V998V_ARCH

export SSMPOSTCHMOD     := a-w

##DESRDIR location where to perform the installation
export DESTDIR := $(HOME)/SsmBundles/
export SSM_RELDIR := GEM/
export SSM_X := x/
export SSM_RELDIRDOM     := $(SSM_RELDIR)d/$(SSM_X)
export SSM_RELDIRBNDL    := $(SSM_RELDIR)$(SSM_X)
export SSMINSTALLDIR     := $(DESTDIR)$(SSM_RELDIR)
export SSMINSTALLDIRDOM  := $(DESTDIR)$(SSM_RELDIRDOM)
export SSMINSTALLDIRBNDL := $(DESTDIR)$(SSM_RELDIRBNDL)
export SSMDEPENDENCIES   := $(PWD)/ssmuse_pre.bndl $(PWD)/ssmuse_dependencies.bndl
export SSMDEPENDENCIESPOST := $(PWD)/ssmuse_post.bndl 

##TAR gnu tar function name on localhost
export TAR := $(shell mu.echo_tarcmd)

export ATM_MODEL_BNDL     = $(SSM_RELDIRBNDL)$(VERSION)
export ATM_MODEL_DSTP    := $(shell date '+%Y-%m-%d %H:%M %Z')
#export FORCE_RMN_VERSION := export FORCE_RMN_VERSION_RC=_rc1
export FORCE_RMN_VERSION :=

.PHONY: .env_setup.dot
.env_setup.dot: | VERSION
	rm -f $(BINDIR0)/.env_setup.dot
	$(MAKE) $(BINDIR0)/.env_setup.dot
$(BINDIR0)/.env_setup.dot: $(BINDIR0)/.env_setup.dot0
	cat $< \
	| sed "s|__MY_BNDL__|$(ATM_MODEL_BNDL)|" \
	| sed "s|__MY_DSTP__|$(ATM_MODEL_DSTP)|" \
	| sed "s|__MY_FORCE_RMN__|$(FORCE_RMN_VERSION)|" \
	> $@