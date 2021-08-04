.PHONY: test fast-build-lambda build get-linter lint get-staticcheck staticcheck pack build-lambda pack-lambda

OK_COLOR=\033[32;01m
NO_COLOR=\033[0m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m

NOW = $(shell date -u '+%Y%m%d%I%M%S')

GO := go
GO_LINTER := golint
BUILDOS ?= $(shell go env GOHOSTOS)
BUILDARCH ?= $(shell go env GOHOSTARCH)
GOFLAGS ?=
ECHOFLAGS ?=
ROOT_DIR := $(realpath .)

ifneq ($(REBUILD), false)
	REBUILDFLAG = -a
endif

ENVFLAGS ?= CGO_ENABLED=0
BUILDENV ?= GOOS=$(BUILDOS) GOARCH=$(BUILDARCH)
BUILDFLAGS ?= $(REBUILDFLAG) -installsuffix cgo $(GOFLAGS)
EXTLDFLAGS ?= -extldflags "-lm -lstdc++ -static"
 
RV := rv-handling-dlq

PKGS = $(shell $(GO) list ./...)

all: test lint staticcheck pack

test:
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Running tests...$(NO_COLOR)"
	@GO111MODULE=on $(ENVFLAGS) $(BUILDENV) $(GO) test --mod=vendor  $(PKGS) --cover
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Tests finished!!!$(NO_COLOR)"

 
fast-build-lambda: 
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Building $(RV)-lambda binary (bin/$(BUILDOS)_$(BUILDARCH)/lambda/$(RV))...$(NO_COLOR)"
	@echo $(ECHOFLAGS) $(ENVFLAGS) $(BUILDENV) $(GO) build $(BUILDFLAGS) -o bin/$(BUILDOS)_$(BUILDARCH)/$(RV) ./cmd/lambda
	@GO111MODULE=on $(ENVFLAGS) $(BUILDENV) $(GO) build --mod=vendor $(BUILDFLAGS) -o bin/$(BUILDOS)_$(BUILDARCH)/lambda/$(RV) ./cmd/lambda
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Build lambda-sync Ok!!!$(NO_COLOR)"
 


build: test lint staticcheck fast-build-lambda

get-linter:
ifeq (, $(shell which $(GO_LINTER)))
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Getting linter...$(NO_COLOR)"
	@$(GO) get -u golang.org/x/lint/golint
endif

lint: get-linter
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Running linter...$(NO_COLOR)"
	@$(GO_LINTER) -set_exit_status $(PKGS)
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Linter finished!!!$(NO_COLOR)"

get-staticcheck:
ifeq (, $(shell which staticcheck))
	@echo $(ECHOFLAGS) "$(OK_COLOR) ==> Getting staticcheck... $(NO_COLOR)"
	@$(GO) get -v honnef.co/go/tools/cmd/staticcheck
endif

staticcheck: get-staticcheck
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Running staticcheck...$(NO_COLOR)"
	@$(ENVFLAGS) staticcheck $(PKGS)	
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Staticcheck finished!!!$(NO_COLOR)"

pack: pack-lambda

build-lambda: lint staticcheck test fast-build-lambda
pack-lambda: pack-lambda 

pack-lambda: fast-build-lambda
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Creating pack lambda-sync...$(NO_COLOR)"
	@zip -j $(RV)-sync.zip bin/$(BUILDOS)_$(BUILDARCH)/lambda/$(RV)	
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Pack lambda created!!!$(NO_COLOR)"

 